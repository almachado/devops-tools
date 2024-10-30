#!/usr/bin/env bash

# DevOps Tools
# Descrição: Este script detecta o sistema operacional e instala várias ferramentas úteis no dia a dia de um Engenheiro DevOps.
# Uso: Execute este script como usuário com privilégios sudo.
# Autor: Andre Machado <luizm.andre@gmail.com>
# Data: 29/10/2024
# Versão: 1.0

# Cores
YELLOW="\033[1;33m"
RED="\033[1;31m"
GREEN="\033[1;32m"
BOLD="\033[1m"
RESET="\033[0m"

clear

echo -e "${BOLD}${GREEN}..::${RESET} ${BOLD}DevOps Tools ${GREEN}::..${RESET}"

echo -e "\n[${YELLOW}!${RESET}] A execução do script pode levar vários minutos."
echo -e -e "[${YELLOW}!${RESET}] A senha do usuário ou alguma confirmação pode ser solicitada durante a execução.\n"

# Detecta o sistema operacional
if [ -f /etc/debian_version ]; then
    OS="Debian"
elif [ -f /etc/redhat-release ]; then
    OS="RedHat"
else
    echo "Sistema operacional não suportado."
    exit 1
fi

echo -e "Sistema detectado: ${BOLD}$OS${RESET} based\n"

# Atualiza pacotes
echo "Atualizando pacotes..."
if [ "$OS" = "Debian" ]; then
    sudo apt-get update > /dev/null && sudo apt-get upgrade -y > /dev/null
else
    sudo dnf check-update > /dev/null && sudo dnf upgrade -y > /dev/null
fi

if [ $? -eq 0 ]; then
    echo -e "Pacotes atualizados com sucesso!\n"
else
    echo -e "Houve um problema na atualização dos pacotes. Verifique.\n"
fi

echo -e -e "[${YELLOW}-${RESET}] Instalando utilitários..."
if [ "$OS" = "Debian" ]; then
    sudo apt-get install -y jq htop wget gpg curl git terminator > /dev/null 2>&1
else
    sudo dnf install -y jq htop wget gpg curl git terminator > /dev/null 2>&1
fi
echo -e -e "[${GREEN}+${RESET}] Utilitários instalados com sucesso!"

echo -e -e "[${YELLOW}-${RESET}] Instalando Visual Studio Code..."
if [ "$OS" = "Debian" ]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    sudo apt-get install -y apt-transport-https > /dev/null 2>&1
    sudo apt-get update > /dev/null
    sudo apt-get install -y code > /dev/null 2>&1
else
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf check-update > /dev/null
    sudo dnf install -y code > /dev/null 2>&1
fi
echo -e "[${GREEN}+${RESET}] Visual Studio Code instalado com sucesso!"

echo -e "[${YELLOW}-${RESET}] Instalando Sublime Text..."
if [ "$OS" = "Debian" ]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null
    sudo apt-get update > /dev/null
    sudo apt-get install -y sublime-text > /dev/null 2>&1
else
    sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
    sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo > /dev/null
    sudo dnf install -y sublime-text > /dev/null 2>&1
fi
echo -e "[${GREEN}+${RESET}] Sublime Text instalado com sucesso!"

echo -e "[${YELLOW}-${RESET}] Instalando AWS CLI..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install > /dev/null 2>&1
rm -rf awscliv2.zip aws
echo -e "[${GREEN}+${RESET}] AWS CLI instalada com sucesso!"

echo -e "[${YELLOW}-${RESET}] Instalando Docker e Docker Compose..."
if [ "$OS" = "Debian" ]; then
    sudo apt-get install -y docker.io docker-compose > /dev/null 2>&1 || sudo apt install -y docker docker-compose-plugin > /dev/null 2>&1
else
    sudo dnf install -y docker docker-compose-plugin > /dev/null 2>&1
fi
echo -e "[${GREEN}+${RESET}] Docker e Docker Compose instalados com sucesso!"

echo -e "[${YELLOW}-${RESET}] Instalando kubectl..."
curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
echo -e "[${GREEN}+${RESET}] kubectl instalado com sucesso!"

echo -e "[${YELLOW}-${RESET}] Instalando Terraform..."
if [ "$OS" = "Debian" ]; then
    curl -s https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    sudo apt-get update > /dev/null
    sudo apt-get install -y terraform > /dev/null 2>&1
else
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo > /dev/null
    sudo dnf install -y terraform > /dev/null 2>&1
fi
echo -e "[${GREEN}+${RESET}] Terraform instalado com sucesso!"

echo -e "[${YELLOW}-${RESET}] Instalando Ansible..."
if [ "$OS" = "Debian" ]; then
    sudo apt-get install -y ansible > /dev/null 2>&1
else
    sudo dnf install -y ansible > /dev/null 2>&1
fi
echo -e "[${GREEN}+${RESET}] Ansible instalado com sucesso!"

echo -e "[${YELLOW}-${RESET}] Instalando Google Chrome..."
if [ "$OS" = "Debian" ]; then
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb > /dev/null 2>&1
    rm google-chrome-stable_current_amd64.deb
else
    sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm > /dev/null 2>&1
fi
echo -e "[${GREEN}+${RESET}] Google Chrome instalado com sucesso!"

echo -e "\nInstalação completa!"
