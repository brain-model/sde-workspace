#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Conversor avançado de PDF para Markdown com suporte à API Gemini."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Callable, Dict, List, Optional
import base64
import io

import fitz
from PIL import Image

from sde_scripts.gemini_client import (
    MODEL_ID,
    close_client,
    get_client,
    initialize_client,
)

BULLET_CHARS = ("•", "▪", "●", "-", "–", "—", "·")
ORDERED_PATTERN = re.compile(r"^((\d+|[a-zA-Z])[\.)])(\s+|$)")
INDENT_STEP = 24  # Aproximadamente 0.33" considerando 72 dpi


class ReferenceRegistry:
    """Gerencia referências externas encontradas durante a transcrição."""

    def __init__(self) -> None:
        self._order: List[str] = []
        self._index: Dict[str, int] = {}

    def register(self, url: str) -> int:
        url = url.strip()
        ref = self._index.get(url)
        if ref is None:
            ref = len(self._order) + 1
            self._index[url] = ref
            self._order.append(url)
        return ref

    def to_markdown(self) -> str:
        if not self._order:
            return ""
        lines = ["\n## Referências", ""]
        for idx, url in enumerate(self._order, start=1):
            lines.append(f"{idx}. {url}")
        return "\n".join(lines)


def analyze_font_styles(doc: fitz.Document) -> Dict[str, float]:
    """Detecta tamanhos de fonte para inferir hierarquias de título."""
    sizes = Counter()
    for page in doc:
        blocks = page.get_text("dict")["blocks"]
        for block in filter(lambda b: b["type"] == 0, blocks):
            for line in block["lines"]:
                for span in line["spans"]:
                    sizes[round(span["size"])] += 1

    if not sizes:
        return {"body": 10.0, "h1": 18.0, "h2": 14.0, "h3": 12.0}

    body_size = sizes.most_common(1)[0][0]
    sorted_sizes = sorted(sizes.keys(), reverse=True)
    h1_size = sorted_sizes[0] if sorted_sizes else body_size * 1.8
    h2_size = next(
        (s for s in sorted_sizes if s < h1_size and s > body_size * 1.1),
        body_size * 1.4,
    )
    h3_size = next(
        (s for s in sorted_sizes if s < h2_size and s > body_size),
        body_size * 1.2,
    )
    return {"body": body_size, "h1": h1_size, "h2": h2_size, "h3": h3_size}


def process_image_bytes(image_bytes: bytes, image_label: str) -> Optional[str]:
    """Classifica e descreve imagem utilizando o Gemini."""
    client = get_client()

    print(f"[INFO] Analisando imagem {image_label} com IA...", file=sys.stderr)
    try:
        with Image.open(io.BytesIO(image_bytes)) as pil_image:
            pil_image.load()

            prompt = (
                "Você receberá uma única imagem.\n"
                "Determine o tipo e responda conforme as regras abaixo.\n"
                "1. Se houver fluxogramas, organogramas ou diagramas com conexões,\n"
                "responda APENAS com um bloco ```mermaid``` equivalente.\n"
                "2. Se o conteúdo for majoritariamente texto impresso ou manuscrito,\n"
                "transcreva o texto em Markdown preservando a estrutura (títulos, listas e\n"
                "tabelas). Não acrescente comentários.\n"
                "3. Para quaisquer outras imagens, descreva os elementos principais em até três\n"
                "frases curtas, objetivas e sem adjetivos supérfluos.\n"
                "Nunca misture formatos. Não adicione explicações fora do conteúdo solicitado."
            )

            response = client.models.generate_content(
                model=MODEL_ID,
                contents=[prompt, pil_image]
            )

        text_response = response.text.strip()
        if text_response.startswith("```mermaid") and text_response.endswith("```"):
            print(
                f"[INFO] {image_label} convertida para Mermaid.",
                file=sys.stderr,
            )
        else:
            print(f"[INFO] {image_label} processada com sucesso.", file=sys.stderr)
        return text_response

    except Exception as exc:  # pylint: disable=broad-except
        print(
            f"[AVISO] Falha na análise da imagem {image_label}. Erro: {exc}",
            file=sys.stderr,
        )
        return None


def _build_span_text(
    spans: List[Dict],
    page_links: Dict[str, Dict],
    register_reference: Callable[[str], int],
) -> str:
    parts: List[str] = []
    for span in spans:
        text = span["text"]
        link = page_links.get(str(fitz.Rect(span["bbox"])))
        if link:
            url = link.get("uri") or f"#page={link.get('page', 0) + 1}"
            ref_id = register_reference(url)
            stripped = text.strip()
            text = f"{stripped}[{ref_id}]" if stripped else f"[{ref_id}]"
        font_lower = span["font"].lower()
        if "bold" in font_lower:
            text = f"**{text}**"
        if "italic" in font_lower:
            text = f"*{text}*"
        parts.append(text)
    return "".join(parts).strip()


def _compute_indent_level(raw_indent: float) -> int:
    level = int(raw_indent // INDENT_STEP)
    return max(level, 0)


def _detect_line_type(
    first_span_text: str,
    avg_font_size: float,
    styles: Dict[str, float],
) -> str:
    if first_span_text.startswith(BULLET_CHARS):
        return "unordered"
    if ORDERED_PATTERN.match(first_span_text):
        return "ordered"
    if avg_font_size >= styles["h1"] * 0.9:
        return "heading1"
    if avg_font_size >= styles["h2"] * 0.9:
        return "heading2"
    if avg_font_size >= styles["h3"] * 0.9:
        return "heading3"
    return "paragraph"


def _format_line(
    line: Dict,
    styles: Dict[str, float],
    page_links: Dict[str, Dict],
    register_reference: Callable[[str], int],
) -> Optional[Dict[str, object]]:
    spans = line.get("spans", [])
    if not spans:
        return None
    indentation = line["bbox"][0]
    first_span_text = spans[0]["text"].strip()
    indent_level = _compute_indent_level(indentation)

    full_line_text = _build_span_text(spans, page_links, register_reference)
    if not full_line_text:
        return None

    avg_font_size = round(sum(span["size"] for span in spans) / len(spans))
    line_type = _detect_line_type(first_span_text, avg_font_size, styles)
    if line_type == "unordered":
        full_line_text = full_line_text.lstrip("".join(BULLET_CHARS)).strip()
    elif line_type == "ordered":
        full_line_text = ORDERED_PATTERN.sub("", full_line_text, count=1).strip()

    return {
        "type": line_type,
        "indent": indent_level,
        "text": full_line_text,
    }


def _render_page_text(
    page: fitz.Page,
    styles: Dict[str, float],
    register_reference: Callable[[str], int],
) -> List[Dict[str, object]]:
    page_links = {str(link["from"]): link for link in page.get_links()}
    blocks = page.get_text("dict", flags=fitz.TEXTFLAGS_SEARCH)["blocks"]
    structured_lines: List[Dict[str, object]] = []

    for block in filter(lambda b: b["type"] == 0, blocks):
        for line in block.get("lines", []):
            formatted_line = _format_line(
                line,
                styles,
                page_links,
                register_reference,
            )
            if formatted_line:
                structured_lines.append(formatted_line)

    return structured_lines


def _fallback_markdown(lines: List[Dict[str, object]]) -> str:
    output: List[str] = []
    ordered_counters: List[int] = []

    for line in lines:
        line_type = line["type"]
        indent = int(line["indent"])
        text = str(line["text"]).strip()
        indent_spaces = "  " * indent

        if line_type == "heading1":
            output.append(f"# {text}")
            ordered_counters = []
        elif line_type == "heading2":
            output.append(f"## {text}")
            ordered_counters = []
        elif line_type == "heading3":
            output.append(f"### {text}")
            ordered_counters = []
        elif line_type == "unordered":
            output.append(f"{indent_spaces}- {text}")
        elif line_type == "ordered":
            while len(ordered_counters) <= indent:
                ordered_counters.append(0)
            ordered_counters[indent] += 1
            marker = ordered_counters[indent]
            output.append(f"{indent_spaces}{marker}. {text}")
            ordered_counters = ordered_counters[: indent + 1]
        else:
            output.append(text)
            ordered_counters = []

    return "\n".join(output)


def _ai_markdown_from_lines(lines: List[Dict[str, object]]) -> Optional[str]:
    if not lines:
        return ""
    client = get_client()

    payload = json.dumps(lines, ensure_ascii=False)
    prompt = (
        "Converta o JSON fornecido em Markdown.\n"
        "Regras: use somente os textos presentes; preserve títulos e listas conforme os campos.\n"
        "Não inclua comentários, explicações, exemplos ou código.\n"
        "Não utilize blocos ```python``` nem descreva o processo.\n"
        "Se não conseguir gerar o Markdown fiel, responda apenas com a palavra FALLBACK."
    )

    try:
        response = client.models.generate_content(
            model=MODEL_ID,
            contents=[prompt, payload],
        )
        markdown = response.text.strip()
        if not markdown:
            return None

        if markdown.upper() == "FALLBACK":
            return None

        forbidden_snippets = (
            "import json",
            "generate_markdown(",
            "convert_pdf_json_to_markdown",
            "markdown_output",
            "```python",
            "Para gerar o Markdown",
            "A abordagem utilizada",
            "Você receberá um JSON",
        )
        if any(snippet in markdown for snippet in forbidden_snippets):
            print(
                "[AVISO] Resposta da IA contém trechos inválidos; usando fallback.",
                file=sys.stderr,
            )
            return None

        return markdown
    except Exception as exc:  # pylint: disable=broad-except
        print(
            f"[AVISO] Falha ao gerar Markdown via IA: {exc}. Usando fallback.",
            file=sys.stderr,
        )
    return None


def _render_page_images(
    doc: fitz.Document,
    page: fitz.Page,
    image_counter: int,
) -> tuple[List[str], int]:
    markdown_blocks: List[str] = []

    for image_info in page.get_images(full=True):
        image_counter += 1
        base_image = doc.extract_image(image_info[0])
        image_bytes = base_image["image"]
        image_ext = base_image["ext"].lower()
        label = f"Imagem {image_counter}"

        ai_result = process_image_bytes(image_bytes, label)
        if ai_result:
            markdown_blocks.append(f"\n{ai_result}\n")
            continue

        mime_type = base_image.get("mime") or f"image/{image_ext}"
        if "/" not in mime_type:
            mime_type = f"image/{image_ext}"
        encoded_image = base64.b64encode(image_bytes).decode("ascii")
        data_uri = f"data:{mime_type};base64,{encoded_image}"
        markdown_blocks.append(f"\n![{label}]({data_uri})\n")

    return markdown_blocks, image_counter


def transcribe_pdf_full(pdf_path: Path) -> None:  # noqa: C901
    """Processa o PDF com análise de estrutura completa."""
    get_client()

    doc = fitz.open(pdf_path)
    styles = analyze_font_styles(doc)
    references = ReferenceRegistry()

    markdown_sections: List[str] = []
    image_counter = 0

    print(f"[INFO] Iniciando processamento do arquivo: {pdf_path.name}", file=sys.stderr)
    for page_num, page in enumerate(doc, 1):
        print(f"[INFO] Página {page_num} em processamento...", file=sys.stderr)

        structured_lines = _render_page_text(
            page,
            styles,
            references.register,
        )
        ai_markdown = _ai_markdown_from_lines(structured_lines)
        if ai_markdown is None:
            ai_markdown = _fallback_markdown(structured_lines)
        markdown_sections.append(ai_markdown)

        image_blocks, image_counter = _render_page_images(doc, page, image_counter)
        markdown_sections.extend(image_blocks)

    references_md = references.to_markdown()
    if references_md:
        markdown_sections.append(references_md)

    final_markdown = "\n---\n".join(section.strip() for section in markdown_sections if section)
    final_markdown = final_markdown.replace("\n\n\n", "\n---\n")

    output_md_path = pdf_path.with_suffix(".md")
    output_md_path.write_text(final_markdown, encoding="utf-8")

    print("\n[SUCESSO] Processamento concluído!", file=sys.stderr)
    print(f"Arquivo Markdown gerado: {output_md_path.resolve()}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Conversor avançado de PDF para Markdown.")
    parser.add_argument("input", type=Path, help="Arquivo PDF de entrada")
    args = parser.parse_args()
    initialize_client()
    try:
        transcribe_pdf_full(args.input)
    finally:
        close_client()


if __name__ == "__main__":
    main()
