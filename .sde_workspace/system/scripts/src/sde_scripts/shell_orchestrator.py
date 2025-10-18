#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Utilitário para listar e executar scripts shell padronizados do SDE."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path
from typing import Iterable, List

BASE_SCRIPTS_DIR = (Path(__file__).resolve().parent / "bash").resolve()
SHELL_EXTENSION = ".sh"
DEFAULT_SHELL = os.environ.get("SDE_SHELL", "/bin/bash")


def _log(message: str) -> None:
    print(message, file=sys.stderr)


def discover_shell_scripts(directory: Path | None = None) -> List[Path]:
    """Retorna a lista ordenada de scripts shell disponíveis."""
    target_dir = directory or BASE_SCRIPTS_DIR
    if not target_dir.exists():
        return []
    return sorted(target_dir.glob(f"*{SHELL_EXTENSION}"))


def run_shell_script(script_path: Path, args: Iterable[str]) -> int:
    """Executa um script shell retornando o código de saída."""
    if not script_path.exists():
        _log(f"[ERRO] Script '{script_path}' não encontrado.")
        return 1

    try:
        script_path.relative_to(BASE_SCRIPTS_DIR)
    except ValueError:
        _log("[ERRO] Caminho solicitado está fora do diretório permitido.")
        return 1

    command = [DEFAULT_SHELL, str(script_path), *args]
    _log(f"[INFO] Executando: {' '.join(command)}")
    try:
        completed = subprocess.run(command, check=False)  # noqa: S603
    except Exception as exc:  # pylint: disable=broad-except
        _log(f"[ERRO] Falha ao executar '{script_path.name}': {exc}")
        return 1
    return completed.returncode


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Lista e executa scripts .sh mantidos em sde_scripts/bash.",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("list", help="Lista todos os scripts shell disponíveis.")

    run_parser = subparsers.add_parser(
        "run",
        help="Executa um script shell específico armazenado em sde_scripts/bash.",
    )
    run_parser.add_argument("script", help="Nome do script (ex.: validate_handoff.sh)")
    run_parser.add_argument(
        "script_args",
        nargs=argparse.REMAINDER,
        help="Argumentos adicionais repassados ao script shell.",
    )

    args = parser.parse_args()

    if args.command == "list":
        scripts = discover_shell_scripts()
        if not scripts:
            _log("[AVISO] Nenhum script .sh encontrado no diretório configurado.")
            sys.exit(1)
        _log("[INFO] Scripts disponíveis:")
        for script in scripts:
            print(f"- {script.name}")
        return

    if args.command == "run":
        script_path = (BASE_SCRIPTS_DIR / args.script).resolve()
        exit_code = run_shell_script(script_path, args.script_args)
        if exit_code != 0:
            _log(f"[ERRO] Execução de '{args.script}' finalizada com código {exit_code}.")
        sys.exit(exit_code)


if __name__ == "__main__":
    main()
