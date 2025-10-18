"""Coleção de scripts utilitários do SDE."""

from sde_scripts import (
    gemini_client,
    transcribe_mp4,
    transcribe_pdf,
    shell_orchestrator,
)

__all__ = [
    "transcribe_mp4",
    "transcribe_pdf",
    "gemini_client",
    "shell_orchestrator",
]
__version__ = "0.1.0"
