#!/usr/bin/env bash

# Requires: curl, zsh, unzip
# Recommended: homebrew on mac or linux

OS=""
if [ "$(uname)" == "Darwin" ]; then
    OS="mac"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    OS="linux"
fi

echo "Installing applications..."
mkdir -p $HOME/bin

if [ "${OS}" != "" ]; then
    if [ "${OS}" == "mac" ]; then
        BREW=$(which brew)
        if [ "${BREW}" == "" ]; then
            echo "Setting up homebrew..."
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [ $? -eq 0 ]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            fi
            BREW=$(which brew)
        fi

        echo "Installing Rust ..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

        echo "Installing Nerd Fonts..."
        NERD_FONT_VERSION="3.1.1"
        curl -L -o "/tmp/FantasqueSansMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/FantasqueSansMono.zip" && unzip -o /tmp/FantasqueSansMono.zip -d $HOME/Library/Fonts

        if [ "${BREW}" != "" ]; then
            echo "Using homebrew to install cmake..."
            ${BREW} install cmake
        fi

        echo "Installing Starship ..."
        $HOME/.cargo/bin/cargo install starship --locked

        GO_VERSION="1.21.5"
        echo "Installing Go ${GO_VERSION} ..."
        curl -L -o "/tmp/go${GO_VERSION}.darwin-amd64.pkg" "https://go.dev/dl/go${GO_VERSION}.darwin-amd64.pkg" && sudo installer -pkg "/tmp/go${GO_VERSION}.darwin-amd64.pkg" -target /

        NODE_VERSION="20.10.0"
        echo "Installing Node ${NODE_VERSION} ..."
        curl -L -o "/tmp/node-v${NODE_VERSION}.pkg" "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" && sudo installer -pkg "/tmp/node-v${NODE_VERSION}.pkg" -target /

        GOOGLE_CLOUD_SDK_VERSION="457.0.0"
        echo "Installing Google Cloud SDK ${GOOGLE_CLOUD_SDK_VERSION} ..."
        curl -L "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GOOGLE_CLOUD_SDK_VERSION}-darwin-x86_64.tar.gz" | tar -xz -C $HOME

        if [ "${BREW}" != "" ]; then
            echo "Using homebrew to install apps..."
            ${BREW} analytics off
            ${BREW} install git kubectl kubectx terraform lsd helm kubecm fzf alacritty gpg2 gsed az openlens zsh ansible just go-task direnv
            ${BREW} install cloudflare/cloudflare/cloudflared
            ${BREW} install --cask visual-studio-code
            ${BREW} install --cask vscodium
            ${BREW} tap azure/bicep
            ${BREW} install bicep
            ${BREW} install --cask powershell
            pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force"
        else
            echo "Warning: Homebrew not found on path. Apps may not be installed."
        fi

        echo "Configuring 1Password SSH Agent..."
        export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

    elif [ "${OS}" == "linux" ]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $? -eq 0 ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        BREW=$(which brew)
        echo "Installing Rust ..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

        if [ "${BREW}" != "" ]; then
            echo "Using homebrew to install cmake..."
            ${BREW} install cmake
        fi

        echo "Installing Starship ..."
        $HOME/.cargo/bin/cargo install starship --locked

        if [ "${BREW}" != "" ]; then
            echo "Using homebrew..."
            ${BREW} install kubectl kubectx terraform lsd helm kubecm fzf golang gpg2 gsed az zsh ansible just go-task direnv
            ${BREW} install cloudflare/cloudflare/cloudflared
            ${BREW} tap azure/bicep
            ${BREW} install bicep
            ${BREW} install --cask powershell
            pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force"
        else
            echo "Warning: Homebrew not found on path. Apps may not be installed."
        fi
    fi
fi

echo "Installing Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "Fetching dotfiles..."

if [ "${OS}" != "" ]; then
    if [ "${OS}" == "mac" ]; then
        echo " - zshrc (mac)"
        curl -L -o $HOME/.zshrc https://sh.jles.work/dotfiles/zshrc_mac
    elif [ "${OS}" == "linux" ]; then
        echo " - zshrc (linux)"
        curl -L -o $HOME/.zshrc https://sh.jles.work/dotfiles/zshrc_linux
    fi
fi
echo " - alacritty"
curl -L -o $HOME/.alacritty.yml https://sh.jles.work/dotfiles/alacritty.yml

echo "Configuring Starship preset..."
$HOME/.cargo/bin/starship preset pastel-powerline -o ~/.config/starship.toml

echo "Done."
