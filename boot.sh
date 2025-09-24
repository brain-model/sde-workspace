#!/bin/bash

set -e

ascii_art='
 ███████╗██████╗ ███████╗
 ██╔════╝██╔══██╗██╔════╝
 ███████╗██║  ██║█████╗  
 ╚════██║██║  ██║██╔══╝  
 ███████║██████╔╝███████╗
 ╚══════╝╚═════╝ ╚══════╝
'

# Define o gradiente verde fosforescente (do mais escuro para o mais claro)
colors=(
	'\033[38;5;22m'  # Verde escuro
	'\033[38;5;28m'  # Verde médio escuro
	'\033[38;5;34m'  # Verde médio
	'\033[38;5;40m'  # Verde brilhante
	'\033[38;5;46m'  # Verde claro
	'\033[38;5;82m'  # Verde fosforescente
)

# Separar ASCII art em linhas
IFS=$'\n' read -rd '' -a lines <<<"$ascii_art"

# Imprimir cada linha com a cor correspondente
for i in "${!lines[@]}"; do
	color_index=$((i % ${#colors[@]}))
	echo -e "${colors[color_index]}${lines[i]}\033[0m"
done
echo "=> SDE Workspace é para ambientes de desenvolvimento!"
echo -e "\nInício da instalação (ou cancele com ctrl+c)..."

# Verificar dependências básicas
if ! command -v git &> /dev/null; then
    echo "Instalando dependências..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update >/dev/null
        sudo apt-get install -y git >/dev/null
    elif command -v yum &> /dev/null; then
        sudo yum install -y git >/dev/null
    elif command -v brew &> /dev/null; then
        brew install git >/dev/null
    else
        echo "Por favor, instale o git manualmente e tente novamente."
        exit 1
    fi
fi

echo "Baixando SDE Workspace..."
rm -rf ~/.local/share/sde-workspace
mkdir -p ~/.local/share
git clone https://github.com/brain-model/sde-workspace.git ~/.local/share/sde-workspace >/dev/null 2>&1

# Usar a branch master como padrão, mas permitir override
BRANCH=${SDE_BRANCH:-master}
if [[ $BRANCH != "master" ]]; then
    cd ~/.local/share/sde-workspace
    git fetch origin "$BRANCH" && git checkout "$BRANCH"
    cd -
fi

echo "Iniciando instalação..."
source ~/.local/share/sde-workspace/install.sh