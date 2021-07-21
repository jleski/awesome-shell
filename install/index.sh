#!/usr/bin/env bash

echo "Installing Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Fetching dotfiles..."

echo " - zshrc"
curl -L -o $HOME/.zshrc https://raw.githubusercontent.com/jleski/awesome-shell/dotfiles/zshrc

echo " - alacritty"
curl -L -o $HOME/.alacritty.yml https://raw.githubusercontent.com/jleski/awesome-shell/dotfiles/alacritty.yml

echo "Downloading cli binaries to $HOME/bin..."
mkdir -p $HOME/bin

echo " - kubectl"
curl -L -o $HOME/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

echo " - kubectx and kubens"
curl -L -o /tmp/go-kubectx.tar.gz https://github.com/aca/go-kubectx/releases/download/v0.1.0/go-kubectx_0.1.0_Darwin_x86_64.tar.gz
tar xfz /tmp/go-kubectx.tar.gz -C $HOME/bin
rm /tmp/go-kubectx.tar.gz

echo "Done."
