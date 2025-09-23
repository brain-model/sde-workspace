#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# Make pipelines fail if any command fails.
set -o pipefail

# --- COLORS ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color

# --- HELPERS ---
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

# --- MAIN LOGIC ---

# Check required dependencies.
check_dependencies() {
    info "Checking dependencies..."
    local missing_deps=0
    for dep in git make; do
        if ! command -v "$dep" &> /dev/null; then
            warn "Missing dependency: $dep"
            missing_deps=1
        fi
    done

    if [ "$missing_deps" -eq 1 ]; then
        error "Please install the missing dependencies and try again."
    fi
    info "All dependencies found."
}

# Entry point.
main() {
    check_dependencies

    if [ -z "${1-}" ]; then
        error "Usage: $0 <GIT_REPOSITORY_URL>"
    fi

    local repo_url="$1"
    local project_dir
    project_dir=$(basename "$repo_url" .git)

    if [ -d "$project_dir" ]; then
        error "Directory '$project_dir' already exists. Please remove it or choose another location."
    fi

    printf "%b" "\nSelect version to install [default/github-copilot] (default): "
    local version_choice
    read -r version_choice || version_choice="default"
    version_choice=${version_choice:-default}

    printf "%b" "Select language [en/pt-br] (en): "
    local lang_choice
    read -r lang_choice || lang_choice="en"
    lang_choice=${lang_choice:-en}

    info "Cloning repository from '$repo_url'..."
    git clone "$repo_url"
    cd "$project_dir"

    if [ ! -f "Makefile" ]; then
        error "Makefile not found in the repository. Installation cannot continue."
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
        if   try_checkout "copilot-pt-br" && [ "$lang_choice" = "pt-br" ]; then
            target_branch="copilot-pt-br"
        elif try_checkout "github-copilot-pt-br" && [ "$lang_choice" = "pt-br" ]; then
            target_branch="github-copilot-pt-br"
        elif try_checkout "feature/setup-copilot-pt-br" && [ "$lang_choice" = "pt-br" ]; then
            target_branch="feature/setup-copilot-pt-br"
        elif try_checkout "copilot"; then
            target_branch="copilot"
        elif try_checkout "github-copilot"; then
            target_branch="github-copilot"
        elif try_checkout "feature/setup-copilot"; then
            target_branch="feature/setup-copilot"
        else
            warn "No Copilot-specific branch found. Falling back to base branch."
        fi
    fi

    if [ -z "$target_branch" ]; then
        if   try_checkout "main"; then
            target_branch="main"
        elif try_checkout "master"; then
            target_branch="master"
        else
            error "Could not determine base branch (main/master)."
        fi
    fi

    if [ "$lang_choice" = "pt-br" ]; then
        if try_checkout "pt-br"; then
            info "Language pt-br selected: 'pt-br' branch active."
        else
            warn "Branch 'pt-br' not found. Keeping branch '$target_branch'."
        fi
    fi

    info "Running 'make install' to create .sde_workspace structure..."
    make install

    if [ "$version_choice" = "github-copilot" ]; then
        if grep -Eq '^[[:space:]]*setup-copilot:' Makefile; then
            info "Running 'make setup-copilot' to configure Copilot..."
            make setup-copilot
        else
            warn "Target 'setup-copilot' not found in Makefile. Skipping Copilot setup."
        fi
    fi

    info "Setup completed successfully!"
    info "Now you can enter the project directory with: cd $project_dir"
}

# Executa a função principal com todos os argumentos passados para o script.
main "$@"