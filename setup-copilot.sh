#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e
set -u
set -o pipefail

# --- COLORS AND HELPERS ---
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

# --- GIT HELPERS ---

branch_exists_local() {
    git show-ref --verify --quiet "refs/heads/$1"
}

branch_exists_remote() {
    git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1
}

checkout_branch() {
    local target_branch="$1"
    info "Switching to branch: ${target_branch}"
    if branch_exists_local "$target_branch"; then
        git checkout "$target_branch"
    elif branch_exists_remote "$target_branch"; then
        git fetch origin "$target_branch":"$target_branch"
        git checkout "$target_branch"
    else
        error "Branch '${target_branch}' not found locally or on remote."
    fi
}

# --- PROMPTS ---

prompt_version() {
    local choice
    echo ""; echo "Select the version to install:";
    echo "  1) default (basic structure only, no Copilot)";
    echo "  2) github-copilot (generates chat modes and instructions)";
    read -rp "Enter 1 or 2 [2]: " choice || true
    case "${choice:-2}" in
        1) echo "default" ;;
        2|*) echo "github-copilot" ;;
    esac
}

prompt_language() {
    local choice
    echo ""; echo "Select the language:";
    echo "  1) pt-br";
    echo "  2) en";
    read -rp "Enter 1 or 2 [1]: " choice || true
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

# Check dependencies required only for the github-copilot variant
check_dependencies_copilot() {
    info "Checking dependencies for GitHub Copilot..."
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI ('gh') not found. It is required for the Copilot CLI. Install from https://cli.github.com/ and try again."
    fi
    info "Dependencies OK."
}

# --- MAIN LOGIC ---

main() {
    if [ ! -f "Makefile" ]; then
        error "Makefile not found. Run this script from the project root (.sde_workspace)."
    fi

    # Collect preferences
    local version lang target_branch
    version=$(prompt_version)
    lang=$(prompt_language)
    info "Selected version: ${version} | Language: ${lang}"

    # Determine and switch to the appropriate branch
    git fetch --all --prune >/dev/null 2>&1 || true
    target_branch=$(resolve_branch_for_selection "$version" "$lang")
    checkout_branch "$target_branch"

    # Run the appropriate target
    if [ "$version" = "github-copilot" ]; then
        check_dependencies_copilot
        info "Running 'make setup-copilot'..."
        make setup-copilot
        info "${COLOR_GREEN}--- Copilot setup completed successfully! ---${COLOR_NC}"
        info "Tips: Reload VS Code and use '@' in Copilot Chat to see the agents."
    else
        info "Running 'make install' (basic structure)..."
        make install
        info "${COLOR_GREEN}--- Basic structure created/updated successfully. ---${COLOR_NC}"
    fi
}

# Run main function.
main
