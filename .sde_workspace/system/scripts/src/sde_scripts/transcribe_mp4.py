#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Transcrição de arquivos MP4 utilizando a SDK oficial google-genai."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from moviepy import VideoFileClip

from sde_scripts.gemini_client import (  # type: ignore
    MODEL_ID,
    close_client,
    get_client,
    initialize_client,
)


def transcribe_mp4(video_path: Path) -> None:
    """Extrai o áudio do vídeo, envia ao Gemini e persiste a transcrição."""
    client = get_client()

    audio_path = video_path.with_suffix(".mp3")
    transcription_path = video_path.with_suffix(".md")
    uploaded_file = None

    try:
        print(f"[INFO] Extraindo áudio de '{video_path.name}'...", file=sys.stderr)
        with VideoFileClip(str(video_path)) as video_clip:
            video_clip.audio.write_audiofile(str(audio_path), codec="mp3", logger=None)
        print("[INFO] Extração de áudio concluída.", file=sys.stderr)

        print(f"[INFO] Fazendo upload do arquivo '{audio_path.name}'...", file=sys.stderr)
        uploaded_file = client.files.upload(file=audio_path)
        print("[INFO] Upload concluído.", file=sys.stderr)

        print("[INFO] Iniciando a transcrição com o modelo Gemini...", file=sys.stderr)
        response = client.models.generate_content(
            model=MODEL_ID,
            contents=[
                (
                    "Transcreva o áudio por completo mantendo a fidelidade ao idioma e à fala. "
                    "Estruture o texto em parágrafos curtos, inserindo uma quebra de linha dupla "
                    "sempre que houver mudança de falante, pausa longa ou novo tópico. "
                    "Utilize listas ou marcadores quando identificar enumerações explícitas."
                    "Use formatação Markdown (negrito, itálico, listas, cabeçalhos, links, etc.)."
                ),
                uploaded_file,
            ],
        )

        transcription = response.text.strip()
        print(f"[INFO] Salvando transcrição em '{transcription_path.name}'...", file=sys.stderr)
        transcription_path.write_text(transcription, encoding="utf-8")

        print("\n[SUCESSO] Transcrição concluída!", file=sys.stderr)

    finally:
        if "audio_path" in locals() and audio_path.exists():
            print(
                f"[INFO] Removendo arquivo de áudio temporário '{audio_path.name}'...",
                file=sys.stderr,
            )
            audio_path.unlink()

        if uploaded_file:
            print(
                f"[INFO] Removendo arquivo '{uploaded_file.name}' do servidor da API...",
                file=sys.stderr,
            )
            client.files.delete(name=uploaded_file.name)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Transcreve um vídeo (.mp4) para texto usando a SDK google-genai."
    )
    parser.add_argument("input", type=Path, help="Caminho para o arquivo de vídeo .mp4")
    args = parser.parse_args()

    initialize_client()

    try:
        transcribe_mp4(args.input)
    finally:
        close_client()


if __name__ == "__main__":
    main()
