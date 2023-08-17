#!/usr/bin/env bash

# Requires: curl, zsh, unzip
# Recommended: homebrew on mac or linux

OS=""
if [ "$(uname)" == "Darwin" ]; then
    OS="mac"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    OS="linux"
fi

echo "Installing Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "Fetching dotfiles..."

echo " - zshrc"
curl -L -o $HOME/.zshrc https://raw.githubusercontent.com/jleski/awesome-shell/main/dotfiles/zshrc

echo " - alacritty"
curl -L -o $HOME/.alacritty.yml https://raw.githubusercontent.com/jleski/awesome-shell/main/dotfiles/alacritty.yml

echo "Installing applications..."
mkdir -p $HOME/bin

if [ "${OS}" != "" ]; then
    if [ "${OS}" == "mac" ]; then
        BREW=$(which brew)
        if [ "${BREW}" != "" ]; then
            echo "Using homebrew..."
            ${BREW} install kubectl kubectx terraform lsd helm kubecm fzf alacritty rust golang gpg2 gsed az bicep openlens
            ${BREW} install --cask visual-studio-code
            ${BREW} tap azure/bicep
            ${BREW} install bicep
        else
            echo "Downloading cli binaries to $HOME/bin..."
            curl -L -o $HOME/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
            curl -L "https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx_v0.9.4_darwin_x86_64.tar.gz" | tar -xz -C $HOME/bin kubectx
            curl -L "https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens_v0.9.4_darwin_x86_64.tar.gz" | tar -xz -C $HOME/bin kubens
            curl -L -o "/tmp/terraform.zip" "https://releases.hashicorp.com/terraform/1.3.4/terraform_1.3.4_darwin_amd64.zip" && unzip /tmp/terraform.zip -d $HOME/bin
            curl -L "https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd-0.23.1-x86_64-apple-darwin.tar.gz" | tar -xz --wildcards --strip-components 1 -C $HOME/bin "*/lsd"
            curl -L "https://get.helm.sh/helm-v3.10.2-darwin-amd64.tar.gz" | tar -xz -C $HOME/bin helm
            curl -L "https://github.com/sunny0826/kubecm/releases/download/v0.21.0/kubecm_v0.21.0_Darwin_x86_64.tar.gz" | tar -xz -C $HOME/bin kubecm
        fi
    elif [ "${OS}" == "linux" ]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $? -eq 0 ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        BREW=$(which brew)
        if [ "${BREW}" != "" ]; then
            echo "Using homebrew..."
            ${BREW} install kubectl kubectx terraform lsd helm kubecm fzf rust golang gpg2 gsed az
            ${BREW} tap azure/bicep
            ${BREW} install bicep
        else
            curl -L -o $HOME/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            curl -L "https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx_v0.9.4_linux_x86_64.tar.gz" | tar -xz -C $HOME/bin kubectx
            curl -L "https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens_v0.9.4_linux_x86_64.tar.gz" | tar -xz -C $HOME/bin kubens
            curl -L -o "/tmp/terraform.zip" "https://releases.hashicorp.com/terraform/1.3.4/terraform_1.3.4_linux_amd64.zip" && unzip /tmp/terraform.zip -d $HOME/bin
            curl -L "https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd-0.23.1-x86_64-unknown-linux-gnu.tar.gz" | tar -xz --wildcards --strip-components 1 -C $HOME/bin "*/lsd"
            curl -L "https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz" | tar -xz --wildcards --strip-components 1 -C $HOME/bin "*/helm"
            curl -L "https://github.com/sunny0826/kubecm/releases/download/v0.21.0/kubecm_v0.21.0_Linux_x86_64.tar.gz" | tar -xz -C $HOME/bin kubecm
        fi
    fi
    test -f $HOME/bin/kubectl && chmod +x $HOME/bin/kubectl
    test -f $HOME/bin/kubectx && chmod +x $HOME/bin/kubectx
    test -f $HOME/bin/kubens && chmod +x $HOME/bin/kubens
    test -f $HOME/bin/lsd && chmod +x $HOME/bin/lsd
    test -f $HOME/bin/kubecm && chmod +x $HOME/bin/kubecm
fi

echo "Done."
