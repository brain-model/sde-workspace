"""Utilitários compartilhados para gerenciamento do cliente Gemini."""

from __future__ import annotations

import os
import sys
from typing import Optional

from dotenv import load_dotenv
from google import genai  # type: ignore
from google.genai import client as genai_client  # type: ignore

load_dotenv()

MODEL_ID = "gemini-2.5-flash"
CLIENT_NOT_READY_MSG = "Cliente Gemini não inicializado"
TEXT_HTTP_TIMEOUT = 90
IMAGE_HTTP_TIMEOUT = 60

_client: Optional[genai_client.Client] = None


def _log(message: str) -> None:
    print(message, file=sys.stderr)


def initialize_client() -> genai_client.Client:
    """Cria e valida um cliente compartilhado para a API Gemini."""
    global _client
    if _client is not None:
        return _client

    _log("[INFO] Validando a chave de API do Gemini...")
    api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")

    if not api_key:
        _log("\n[ERRO] Configure GEMINI_API_KEY ou GOOGLE_API_KEY no ambiente.")
        sys.exit(1)

    try:
        _client = genai.Client()
        _log("[INFO] Cliente criado. Realizando requisição de teste...")
        _client.models.generate_content(model=MODEL_ID, contents="test")
        _log("[INFO] Conexão validada com sucesso.")
    except Exception as exc:  # pylint: disable=broad-except
        _log("\n[ERRO] Falha ao validar chave do Gemini. Detalhes exibidos abaixo.")
        _log(str(exc))
        sys.exit(1)

    return _client


def get_client() -> genai_client.Client:
    """Retorna o cliente já inicializado ou lança erro se indisponível."""
    if _client is None:
        raise RuntimeError(CLIENT_NOT_READY_MSG)
    return _client


def close_client(show_message: bool = True) -> None:
    """Fecha o cliente compartilhado liberando recursos."""
    global _client
    if _client is None:
        return

    _client.close()
    _client = None
    if show_message:
        _log("[INFO] Cliente da API fechado.")
