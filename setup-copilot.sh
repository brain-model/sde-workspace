#!/usr/bin/env bash

# Saia imediatamente se um comando falhar.
set -e
set -u
set -o pipefail

# --- CORES E FUNÇÕES AUXILIARES ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color

info() {
    printf "${COLOR_GREEN}[INFO]${COLOR_NC} %s\n" "$1"
}

warn() {
    printf "${COLOR_YELLOW}[WARN]${COLOR_NC} %s\n" "$1"
}

error() {
    printf "${COLOR_RED}[ERROR]${COLOR_NC} %s\n" "$1" >&2
    exit 1
}

# --- LÓGICA PRINCIPAL ---

# Função para verificar dependências, especialmente a CLI do GitHub.
check_dependencies() {
    info "Verificando dependência: GitHub CLI (gh)..."
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI ('gh') não encontrada. É necessária para o Copilot CLI. Por favor, instale-a a partir de https://cli.github.com/ e tente novamente."
    fi
    info "GitHub CLI encontrada."
}

# Função principal do script.
main() {
    info "Iniciando a configuração do ambiente para o GitHub Copilot..."
    
    check_dependencies

    if [ ! -f "Makefile" ]; then
        error "Makefile não encontrado. Execute este script a partir da raiz do projeto (.sde_workspace)."
    fi

    if [ ! -d ".sde_workspace" ]; then
        warn "Diretório .sde_workspace não encontrado ao lado do Makefile. Continuando mesmo assim."
    fi
    
    info "Executando 'make setup-copilot' para criar os arquivos de configuração..."
    make setup-copilot

    info "${COLOR_GREEN}--- Configuração do Copilot Concluída com Sucesso! ---${COLOR_NC}"
    info "Para usar os novos recursos:"
    info "1. Recarregue a janela do VSCode (Ctrl+Shift+P > 'Developer: Reload Window')."
    info "2. No Copilot Chat, use '@' para ver os novos agentes (ex: '@Agente Arquiteto')."
    info "3. Certifique-se de que as extensões 'GitHub Copilot' e 'GitHub Copilot Chat' estão instaladas."
}

# Executa a função principal.
main
