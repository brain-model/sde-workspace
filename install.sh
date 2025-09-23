#!/usr/bin/env bash

# Saia imediatamente se um comando falhar.
set -e
# Trate variáveis não definidas como um erro.
set -u
# Garante que pipelines falhem se algum comando falhar.
set -o pipefail

# --- CORES PARA SAÍDA ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color

# --- FUNÇÕES AUXILIARES ---
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

# Função para verificar se os comandos necessários estão instalados.
check_dependencies() {
    info "Verificando dependências..."
    local missing_deps=0
    for dep in git make; do
        if ! command -v "$dep" &> /dev/null; then
            warn "Dependência não encontrada: $dep"
            missing_deps=1
        fi
    done

    if [ "$missing_deps" -eq 1 ]; then
        error "Por favor, instale as dependências faltantes e tente novamente."
    fi
    info "Todas as dependências foram encontradas."
}

# Função principal do script.
main() {
    check_dependencies

    local repo_url="${1-}"
    if [ -z "$repo_url" ]; then
        warn "URL do repositório não fornecida. Usando padrão: https://github.com/brain-model/sde-workspace.git"
        repo_url="https://github.com/brain-model/sde-workspace.git"
    fi
    local project_dir
    project_dir=$(basename "$repo_url" .git)

    if [ -d "$project_dir" ]; then
        error "O diretório '$project_dir' já existe. Por favor, remova-o ou escolha outro local."
    fi

    printf "%b" "\nSelecione a versão a instalar [default/github-copilot] (default): "
    local version_choice
    read -r version_choice || version_choice="default"
    version_choice=${version_choice:-default}

    printf "%b" "Selecione o idioma [en/pt-br] (en): "
    local lang_choice
    read -r lang_choice || lang_choice="en"
    lang_choice=${lang_choice:-en}

    info "Clonando o repositório de '$repo_url'..."
    git clone "$repo_url"
    cd "$project_dir"

    if [ ! -f "Makefile" ]; then
        error "Makefile não encontrado no repositório. A instalação não pode continuar."
    fi

    local has_remote_branch
    has_remote_branch() {
        git show-ref --verify --quiet "refs/remotes/origin/$1"
    }

    local try_checkout
    try_checkout() {
        if git rev-parse --verify --quiet "$1" >/dev/null; then
            git checkout "$1"
            return 0
        elif has_remote_branch "$1"; then
            git checkout -b "$1" "origin/$1"
            return 0
        else
            return 1
        fi
    }

    local target_branch=""
    if [ "$version_choice" = "github-copilot" ]; then
        if [ "$lang_choice" = "pt-br" ]; then
            # Preferências para Copilot PT-BR
            for b in \
                copilot-ptbr \
                copilot-pt-br \
                github-copilot-ptbr \
                github-copilot-pt-br \
                feature/setup-copilot-ptbr \
                feature/setup-copilot-pt-br \
                copilot \
                github-copilot \
                feature/setup-copilot; do
                if try_checkout "$b"; then
                    target_branch="$b"
                    break
                fi
            done
        else
            # Preferências para Copilot EN-US
            for b in \
                copilot-enus \
                copilot-en-us \
                github-copilot-enus \
                github-copilot-en-us \
                copilot \
                github-copilot \
                feature/setup-copilot; do
                if try_checkout "$b"; then
                    target_branch="$b"
                    break
                fi
            done
        fi
        if [ -z "$target_branch" ]; then
            warn "Nenhuma branch específica de Copilot encontrada. Usando branch base."
        else
            info "Branch selecionada: $target_branch"
        fi
    else
        # Versão default (sem Copilot)
        if [ "$lang_choice" = "pt-br" ]; then
            for b in \
                default-ptbr \
                ptbr \
                pt-br; do
                if try_checkout "$b"; then
                    target_branch="$b"
                    break
                fi
            done
        else
            for b in \
                default-enus \
                default-en-us \
                default; do
                if try_checkout "$b"; then
                    target_branch="$b"
                    break
                fi
            done
        fi
        if [ -n "$target_branch" ]; then
            info "Branch selecionada: $target_branch"
        fi
    fi

    if [ -z "$target_branch" ]; then
        if   try_checkout "main"; then
            target_branch="main"
        elif try_checkout "master"; then
            target_branch="master"
        else
            error "Não foi possível determinar a branch base (main/master)."
        fi
    fi

    info "Executando 'make install' para criar a estrutura do .sde_workspace..."
    make install

    if [ "$version_choice" = "github-copilot" ]; then
        if grep -Eq '^[[:space:]]*setup-copilot:' Makefile; then
            info "Executando 'make setup-copilot' para configurar Copilot..."
            make setup-copilot
        else
            warn "Target 'setup-copilot' não encontrado no Makefile. Pulando configuração do Copilot."
        fi
    fi

    info "Setup concluído com sucesso!"
    info "Agora você pode entrar no diretório do projeto com: cd $project_dir"
}

# Executa a função principal com todos os argumentos passados para o script.
main "$@"