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

# --- AUXILIARES DE GIT ---

branch_exists_local() {
    git show-ref --verify --quiet "refs/heads/$1"
}

branch_exists_remote() {
    git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1
}

checkout_branch() {
    local target_branch="$1"
    info "Trocando para a branch: ${target_branch}"
    if branch_exists_local "$target_branch"; then
        git checkout "$target_branch"
    elif branch_exists_remote "$target_branch"; then
        git fetch origin "$target_branch":"$target_branch"
        git checkout "$target_branch"
    else
        error "Branch '${target_branch}' não encontrada localmente nem no remoto."
    fi
}

# --- PROMPTS ---

prompt_version() {
    local choice
    echo ""; echo "Selecione a versão para instalar:";
    echo "  1) default (apenas estrutura básica, sem Copilot)";
    echo "  2) github-copilot (gera chatmodes e instruções)";
    read -rp "Digite 1 ou 2 [2]: " choice || true
    case "${choice:-2}" in
        1) echo "default" ;;
        2|*) echo "github-copilot" ;;
    esac
}

prompt_language() {
    local choice
    echo ""; echo "Selecione o idioma:";
    echo "  1) pt-br";
    echo "  2) en";
    read -rp "Digite 1 ou 2 [1]: " choice || true
    case "${choice:-1}" in
        2) echo "en" ;;
        1|*) echo "pt-br" ;;
    esac
}

resolve_branch_for_selection() {
    local version="$1" lang="$2"
    # Ordem de preferência por versão/idioma
    if [ "$version" = "default" ]; then
        if [ "$lang" = "pt-br" ]; then
            echo "pt-br"
        else
            # Preferir main; fallback para master
            if branch_exists_remote main || branch_exists_local main; then
                echo "main"
            elif branch_exists_remote master || branch_exists_local master; then
                echo "master"
            else
                echo "main" # fallback final
            fi
        fi
    else
        # github-copilot
        if [ "$lang" = "pt-br" ]; then
            if branch_exists_remote feature/setup-copilot-pt-br || branch_exists_local feature/setup-copilot-pt-br; then
                echo "feature/setup-copilot-pt-br"
            elif branch_exists_remote pt-br || branch_exists_local pt-br; then
                echo "pt-br"
            else
                echo "feature/setup-copilot" # fallback
            fi
        else
            if branch_exists_remote feature/setup-copilot || branch_exists_local feature/setup-copilot; then
                echo "feature/setup-copilot"
            elif branch_exists_remote main || branch_exists_local main; then
                echo "main"
            else
                echo "master"
            fi
        fi
    fi
}

# Verifica dependências necessárias apenas para a variante github-copilot
check_dependencies_copilot() {
    info "Verificando dependências para GitHub Copilot..."
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI ('gh') não encontrada. É necessária para o Copilot CLI. Instale em https://cli.github.com/ e tente novamente."
    fi
    info "Dependências ok."
}

# --- LÓGICA PRINCIPAL ---

main() {
    if [ ! -f "Makefile" ]; then
        error "Makefile não encontrado. Execute este script a partir da raiz do projeto (.sde_workspace)."
    fi

    # Coleta de preferências
    local version lang target_branch
    version=$(prompt_version)
    lang=$(prompt_language)
    info "Versão selecionada: ${version} | Idioma: ${lang}"

    # Determina e troca para a branch adequada
    git fetch --all --prune >/dev/null 2>&1 || true
    target_branch=$(resolve_branch_for_selection "$version" "$lang")
    checkout_branch "$target_branch"

    # Executa o alvo adequado
    if [ "$version" = "github-copilot" ]; then
        check_dependencies_copilot
        info "Executando 'make setup-copilot'..."
        make setup-copilot
        info "${COLOR_GREEN}--- Configuração do Copilot concluída com sucesso! ---${COLOR_NC}"
        info "Dicas: Recarregue o VSCode e use '@' no Copilot Chat para ver os agentes."
    else
        info "Executando 'make install' (estrutura básica)..."
        make install
        info "${COLOR_GREEN}--- Estrutura básica criada/atualizada com sucesso. ---${COLOR_NC}"
    fi
}

# Executa a função principal.
main
