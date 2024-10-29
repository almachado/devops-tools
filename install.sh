#!/usr/bin/env bash

# Detecta o sistema operacional
if [ -f /etc/debian_version ]; then
    OS="Debian"
    PKG_MANAGER="sudo apt update && sudo apt install -y"
elif [ -f /etc/redhat-release ]; then
    OS="RedHat"
    PKG_MANAGER="sudo dnf install -y"
else
    echo "Sistema operacional não suportado."
    exit 1
fi

echo "Sistema detectado: $OS based"

# Atualiza pacotes
echo "Atualizando pacotes..."
if [ "$OS" = "Debian" ]; then
    sudo apt update && sudo apt upgrade -y
else
    sudo dnf check-update && sudo dnf upgrade -y
fi

# Instala as ferramentas
install_tools() {
    echo "Instalando Terminator..."
    $PKG_MANAGER terminator

    echo "Instalando Visual Studio Code..."
    if [ "$OS" = "Debian" ]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt update
        $PKG_MANAGER code
    else
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        $PKG_MANAGER code
    fi

    echo "Instalando Sublime Text..."
    if [ "$OS" = "Debian" ]; then
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
        sudo apt update
        $PKG_MANAGER sublime-text
    else
        sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        $PKG_MANAGER sublime-text
    fi

    echo "Instalando AWS CLI..."
    $PKG_MANAGER awscli

    echo "Instalando Google Chrome..."
    if [ "$OS" = "Debian" ]; then
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt install ./google-chrome-stable_current_amd64.deb -y
        rm google-chrome-stable_current_amd64.deb
    else
        sudo dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -y
    fi

    echo "Instalando Docker e Docker Compose..."
    $PKG_MANAGER docker.io docker-compose || $PKG_MANAGER docker docker-compose-plugin

    echo "Instalando kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl

    echo "Instalando Helm..."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

    echo "Instalando Git..."
    $PKG_MANAGER git

    echo "Instalando jq..."
    $PKG_MANAGER jq

    echo "Instalando htop..."
    $PKG_MANAGER htop

    echo "Instalando Terraform..."
    if [ "$OS" = "Debian" ]; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update
        $PKG_MANAGER terraform
    else
        sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
        $PKG_MANAGER terraform
    fi

    echo "Instalando Ansible..."
    $PKG_MANAGER ansible
}

# Executa a instalação das ferramentas
install_tools
echo "Instalação completa!"
