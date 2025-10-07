#!/usr/bin/env bash

set -euo pipefail

INFO()  { printf "\033[0;32m[INFO]\033[0m %s\n" "$1"; }
WARN()  { printf "\033[0;33m[WARN]\033[0m %s\n" "$1"; }
ERROR() { printf "\033[0;31m[ERROR]\033[0m %s\n" "$1" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || ERROR "Missing dependency: $1"
}

declare -A DEP_DOCS=(
    [git]="https://git-scm.com/downloads"
    [curl]="https://curl.se/download.html"
    [jq]="https://jqlang.github.io/jq/download/"
    [yq]="https://github.com/mikefarah/yq/#install"
    [sha256sum]="https://www.gnu.org/software/coreutils/coreutils.html#sha256sum-invocation"
    [yajsv]="https://github.com/neilpa/yajsv"
)

SCRIPT_PREREQS=(jq yq sha256sum)
OPTIONAL_PREREQS=(yajsv)

print_prereq_hint() {
    local binary="$1"
    local url="${DEP_DOCS[$binary]:-}"
    if [ -n "$url" ]; then
        printf '  • %s: %s\n' "$binary" "$url"
    else
        printf '  • %s\n' "$binary"
    fi
}

check_script_prereqs() {
    local missing=()
    for dep in "${SCRIPT_PREREQS[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        WARN "Foram detectadas dependências obrigatórias ausentes para os scripts do SDE Workspace."
        printf '\nInstale os pré-requisitos antes de continuar. Documentação oficial:\n'
        for dep in "${missing[@]}"; do
            print_prereq_hint "$dep"
        done
        if printf '%s\n' "${missing[@]}" | grep -q '^sha256sum$'; then
            printf '\nDica: no macOS, instale coreutils para disponibilizar '\''sha256sum'\'' (brew install coreutils).\n'
        fi
        exit 2
    fi

    local optional_missing=()
    for dep in "${OPTIONAL_PREREQS[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            optional_missing+=("$dep")
        fi
    done

    if [ ${#optional_missing[@]} -gt 0 ]; then
        WARN "Dependências opcionais não encontradas: ${optional_missing[*]}"
        printf 'Elas habilitam validações extras. Consulte:\n'
        for dep in "${optional_missing[@]}"; do
            print_prereq_hint "$dep"
        done
    fi
}

choose_option() {
    local title="$1"
    shift
    local -a options=("${!1}")
    shift
    local varname="$1"
    shift
    local default_value="$1"
    local choice

    while true; do
        echo "${title} (default: ${default_value})"
        echo "  [0] Encerrar execução"
        for i in "${!options[@]}"; do
            printf "  [%d] %s\n" "$((i+1))" "${options[$i]}"
        done
        printf "> "
        read -r choice < /dev/tty < /dev/tty
        if [[ -z "$choice" ]]; then
            printf -v "$varname" "%s" "$default_value"
            echo "Opção escolhida (default): $default_value"
            return 0
        elif [[ "$choice" == "0" ]]; then
            ERROR "Execução encerrada pelo usuário."
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            local selected="${options[$((choice-1))]}"
            printf -v "$varname" "%s" "$selected"
            echo "Opção escolhida: $selected"
            return 0
        fi
        echo "Opção inválida. Tente novamente."
    done
}

copy_if_missing() {
    local src_dir="$1"; local dest_dir="$2"
    if [ ! -d "$src_dir" ]; then
        WARN "Source directory not found: $src_dir (skipping)"
        return 0
    fi
    if [ -d "$dest_dir" ]; then
        WARN "Destination exists, skipping: $dest_dir"
        return 0
    fi
    mkdir -p "$(dirname "$dest_dir")"
    cp -a "$src_dir" "$dest_dir"
    INFO "Created: $dest_dir"
}

# Merge files from src into dest without overwriting existing files
merge_dir_no_overwrite() {
    local src_dir="$1"; local dest_dir="$2"
    if [ ! -d "$src_dir" ]; then
        WARN "Source directory not found: $src_dir (skipping)"
        return 0
    fi
    mkdir -p "$dest_dir"
    local copied=0
    while IFS= read -r -d '' file; do
        local rel="${file#"${src_dir}/"}"
        local target="$dest_dir/$rel"
        mkdir -p "$(dirname "$target")"
        if [ -e "$target" ]; then
            INFO "Keeping existing: $target"
        else
            cp -a "$file" "$target"
            INFO "Added: $target"
            copied=$((copied+1))
        fi
    done < <(find "$src_dir" -type f -print0)
    if [ "$copied" -eq 0 ]; then
        INFO "No new files to add from $src_dir"
    fi
}

main() {
    require_cmd git
    require_cmd curl
    check_script_prereqs

    INFO "sde-workspace installer"

    local branch
    local branch_options=("default-ptbr" "default-enus" "copilot-ptbr" "copilot-enus")
    choose_option "Selecione a configuração desejada:" branch_options[@] branch "default-ptbr"
    INFO "Selected branch: $branch"

    local repo_url="${REPO_URL:-https://github.com/brain-model/sde-workspace.git}"
    INFO "Using repository: $repo_url"

    tmpdir="/tmp/sde-workspace-install"
    # Remove o diretório se já existir
    rm -rf "$tmpdir"
    mkdir -p "$tmpdir"
    trap 'rm -rf "$tmpdir"' EXIT

    INFO "Fetching branch '$branch' (sparse shallow clone of .sde_workspace)..."
    git clone --depth 1 --filter=blob:none --no-checkout --branch "$branch" "$repo_url" "$tmpdir/repo" >/dev/null 2>&1 || ERROR "Failed to clone branch '$branch'"
    (
        cd "$tmpdir/repo"
        git sparse-checkout init --cone >/dev/null 2>&1 || true
        git sparse-checkout set .sde_workspace >/dev/null 2>&1 || true
        git checkout >/dev/null 2>&1 || ERROR "Failed to checkout sparse contents"
    )

    local src_ws="$tmpdir/repo/.sde_workspace"
    local dst_ws=".sde_workspace"
    local dst_chatmodes=".github/chatmodes"

    if [ -d "$dst_ws" ]; then
        WARN "Directory exists: $dst_ws"
        printf "Overwrite it? [y/N]: "
        read -r ans < /dev/tty
        if [[ "${ans:-N}" =~ ^[Yy]$ ]]; then
            rm -rf "$dst_ws"
            INFO "Removed: $dst_ws"
            copy_if_missing "$src_ws" "$dst_ws"
        else
            INFO "Keeping existing: $dst_ws"
        fi
    else
        copy_if_missing "$src_ws" "$dst_ws"
    fi

    # Populate chatmodes and copilot-instructions only for GitHub Copilot version
    if [[ "$branch" =~ ^copilot- ]]; then
        local src_chatmodes="$src_ws/.github/chatmodes"
        local src_copilot_instructions="$src_ws/.github/copilot-instructions.md"
        local dst_copilot_instructions=".github/copilot-instructions.md"
        
        INFO "Populating chatmodes for Copilot version..."
        merge_dir_no_overwrite "$src_chatmodes" "$dst_chatmodes"
        
        # Copy copilot-instructions.md for Copilot versions
        if [ -f "$src_copilot_instructions" ]; then
            if [ -f "$dst_copilot_instructions" ]; then
                INFO "Keeping existing: $dst_copilot_instructions"
            else
                mkdir -p "$(dirname "$dst_copilot_instructions")"
                cp -a "$src_copilot_instructions" "$dst_copilot_instructions"
                INFO "Created: $dst_copilot_instructions"
            fi
        else
            WARN "Source file not found: $src_copilot_instructions (skipping)"
        fi
    else
        INFO "Skipping chatmodes and copilot-instructions population (branch: $branch)"
    fi

    INFO "Installation finished."
    echo "- Branch: $branch"
    echo "- Created:  $dst_ws"
    if [[ "$branch" =~ ^copilot- ]]; then
        echo "- Chatmodes: merged from .sde_workspace templates into $dst_chatmodes"
        echo "- GitHub Copilot instructions: .github/copilot-instructions.md"
    fi
}

main "$@"
