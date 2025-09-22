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

    if [ -z "${1-}" ]; then
        error "Uso: $0 <URL_DO_REPOSITORIO_GIT>"
    fi

    local repo_url="$1"
    local project_dir
    project_dir=$(basename "$repo_url" .git)

    if [ -d "$project_dir" ]; then
        error "O diretório '$project_dir' já existe. Por favor, remova-o ou escolha outro local."
    fi

    info "Clonando o repositório de '$repo_url'..."
    git clone "$repo_url"
    cd "$project_dir"

    if [ ! -f "Makefile" ]; then
        error "Makefile não encontrado no repositório. A instalação não pode continuar."
    fi

    info "Executando 'make install' para criar a estrutura do .sde_workspace..."
    make install

    info "Setup concluído com sucesso!"
    info "Agora você pode entrar no diretório do projeto com: cd $project_dir"
}

# Executa a função principal com todos os argumentos passados para o script.
main "$@"