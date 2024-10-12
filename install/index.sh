#!/usr/bin/env bash

set -euo pipefail

# Check for minimal installation flag
MINIMAL_INSTALL=${MINIMAL_INSTALL:-false}

# Global versions
GO_VERSION="1.21.5"
NODE_VERSION="20.10.0"
GOOGLE_CLOUD_SDK_VERSION="457.0.0"
NERD_FONT_VERSION="3.1.1"
LSD_VERSION="0.23.1"
FZF_VERSION="0.42.0"

# Determine OS
OS=$(uname -s)
case "${OS}" in
    Darwin*) OS="mac" ;;
    Linux*)  OS="linux" ;;
    *)       echo "Unsupported OS: ${OS}"; exit 1 ;;
esac

# Check and install prerequisites
install_prerequisites() {
    echo "Checking and installing prerequisites..."
    if [ "${OS}" == "mac" ]; then
        # macOS uses Homebrew
        if ! command -v brew &> /dev/null; then
            install_homebrew
        fi
        brew install curl zsh unzip git
    elif [ "${OS}" == "linux" ]; then
        if [ -f /etc/alpine-release ]; then
            # Alpine Linux
            sudo apk add --no-cache curl zsh unzip git
        else
            # Assume Debian-based   
            sudo apt-get update
            sudo apt-get install -y curl zsh unzip git
        fi
    fi
}

# Common functions
install_homebrew() {
    echo "Setting up homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "${OS}" == "mac" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    brew analytics off
}

install_rust() {
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

install_starship() {
    echo "Installing Starship..."
    $HOME/.cargo/bin/cargo install starship --locked
}

install_common_brew_packages() {
    brew analytics off
    brew install git kubectl kubectx terraform lsd helm kubecm fzf gpg2 gsed az zsh ansible just go-task direnv
    brew install cloudflare/cloudflare/cloudflared
    brew tap azure/bicep
    brew install bicep
}

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Oh-My-Zsh is already installed. Skipping installation."
    fi
}

fetch_dotfiles() {
    echo "Fetching dotfiles..."
    curl -L -o $HOME/.zshrc "https://sh.jles.work/dotfiles/zshrc_${OS}"
    if [ "${OS}" == "mac" ]; then
        curl -L -o $HOME/.alacritty.toml https://sh.jles.work/dotfiles/alacritty.toml
    fi
}

configure_starship() {
    echo "Configuring Starship preset..."
    $HOME/.cargo/bin/starship preset pastel-powerline -o ~/.config/starship.toml
}

install_go() {
    echo "Installing Go ${GO_VERSION}..."
    if [ "${OS}" == "mac" ]; then
        curl -L -o "/tmp/go${GO_VERSION}.darwin-amd64.pkg" "https://go.dev/dl/go${GO_VERSION}.darwin-amd64.pkg" && sudo installer -pkg "/tmp/go${GO_VERSION}.darwin-amd64.pkg" -target /
    elif [ "${OS}" == "linux" ]; then
        curl -L "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | sudo tar -C /usr/local -xzf -
    fi
}

install_node() {
    echo "Installing Node ${NODE_VERSION}..."
    if [ "${OS}" == "mac" ]; then
        curl -L -o "/tmp/node-v${NODE_VERSION}.pkg" "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" && sudo installer -pkg "/tmp/node-v${NODE_VERSION}.pkg" -target /
    elif [ "${OS}" == "linux" ]; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs
    fi
}

install_google_cloud_sdk() {
    echo "Installing Google Cloud SDK ${GOOGLE_CLOUD_SDK_VERSION}..."
    if [ "${OS}" == "mac" ]; then
        curl -L "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GOOGLE_CLOUD_SDK_VERSION}-darwin-x86_64.tar.gz" | tar -xz -C $HOME
    elif [ "${OS}" == "linux" ]; then
        curl -L "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" | tar -xz -C $HOME
    fi
}

# OS-specific installations
install_mac_specific() {
    echo "Installing Nerd Fonts..."
    curl -L -o "/tmp/FantasqueSansMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/FantasqueSansMono.zip" && unzip -o /tmp/FantasqueSansMono.zip -d $HOME/Library/Fonts

    brew install alacritty
    brew install --cask visual-studio-code vscodium powershell
    pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force"

    echo "Configuring 1Password SSH Agent..."
    export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
}

install_linux_specific() {
    brew install cmake
    # Import the public repository GPG keys
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    # Register the Microsoft Ubuntu repository
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/microsoft.list'
    # Update the list of products
    sudo apt-get update
    # Install PowerShell
    sudo apt-get install -y powershell
    pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force"
}

install_minimal() {
    echo "Performing minimal installation..."

    # Install Oh My Zsh
    install_oh_my_zsh

    # Install Starship
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi

    # Install lsd
    if ! command -v lsd &> /dev/null; then
        LSD_FILENAME="lsd-${LSD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
        curl -L "https://github.com/Peltoche/lsd/releases/download/${LSD_VERSION}/${LSD_FILENAME}" | tar xzf - -C /tmp
        sudo mv /tmp/lsd-*/lsd /usr/local/bin/
    fi

    # Install fzf
    if ! command -v fzf &> /dev/null; then
        FZF_FILENAME="fzf-${FZF_VERSION}-linux_amd64.tar.gz"
        curl -L "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/${FZF_FILENAME}" | tar xzf - -C /tmp
        sudo mv /tmp/fzf /usr/local/bin/
    fi

    # Install Azure CLI
    if [ "${OS}" == "mac" ]; then
        # Ensure Homebrew is installed on macOS
        if ! command -v brew &> /dev/null; then
            install_homebrew
        fi
        brew install azure-cli
    elif [ "${OS}" == "linux" ]; then
            # Ensure Python3 is installed
            if ! command -v python3 &> /dev/null; then
                if [ -f /etc/alpine-release ]; then
                    sudo apk add --no-cache python3
                else
                    sudo apt-get update && sudo apt-get install -y python3
                fi
            fi

            # Install Azure CLI
            if [ -f /etc/alpine-release ]; then
                # Alpine-specific installation
                sudo apk add --no-cache python3 py3-virtualenv
                if [ ! -d /usr/local/azure-cli ]; then
                    sudo python3 -m venv /usr/local/azure-cli
                fi
                sudo /usr/local/azure-cli/bin/python -m pip install --upgrade pip
                sudo /usr/local/azure-cli/bin/python -m pip install azure-cli
            else
                # For Ubuntu and other distributions
                curl -sL https://aka.ms/InstallAzureCli | sudo bash
            fi
    fi

    # Fetch dotfiles
    fetch_dotfiles

    # Configure Starship
    starship preset pastel-powerline -o ~/.config/starship.toml
}

# Main installation process
main() {
    echo "Installing applications..."
    mkdir -p $HOME/bin

    install_prerequisites

    if [ "$MINIMAL_INSTALL" = true ]; then
        install_minimal
    else
        install_homebrew
        install_rust
        install_starship
        install_common_brew_packages
        install_go
        install_node
        install_google_cloud_sdk

        if [ "${OS}" == "mac" ]; then
            install_mac_specific
        elif [ "${OS}" == "linux" ]; then
            install_linux_specific
        fi

        install_oh_my_zsh
        fetch_dotfiles
        configure_starship
    fi

    echo "Done."
}

main
