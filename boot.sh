#!/bin/bash

set -e

ascii_art='
   _____ _____  ______    _    _  ____  _____  _  __ _____ _____        _____ ______
  / ____|  __ \|  ____|  | |  | |/ __ \|  __ \| |/ // ____|  __ \ /\   / ____|  ____|
 | (___ | |  | | |__     | |  | | |  | | |__) | '"'"' /| (___ | |__) /  \ | |    | |__
  \___ \| |  | |  __|    | |  | | |  | |  _  /|  <  \___ \|  ___/ /\ \| |    |  __|
  ____) | |__| | |____   | |__| | |__| | | \ \| . \ ____) | |  / ____ \ |____| |____
 |_____/|_____/|______|   \____/ \____/|_|  \_\_|\_\_____/|_| /_/    \_\_____|______|
'

echo -e "$ascii_art"
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