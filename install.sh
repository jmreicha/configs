#!/usr/bin/env bash

# Simple install script for various tools and configuration

COMMON_TOOLS="jq shellcheck fzf ripgrep hstr bat yamllint highlight autojump"
OSX_TOOLS="hadolint terraform_landscape kube-ps1 fd findutils"
LINUX_TOOLS="fd-find"
PY_TOOLS="pylint flake8 pycodstyle bashate pre-commit"
EXTRA_TOOLS="tflint tfsec ondir magic-wormhole exa delta"

# Common across OS
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# TODO Make this DRY

# OSX specific
if [[ "$(uname -s)" = "Darwin" ]]; then
    for tool in $COMMON_TOOLS; do
        brew install "$tool"
    done

    for tool in $OSX_TOOLS; do
        brew install "$tool"
    done

    for tool in $PY_TOOLS; do
        pip install --user "$tool"
    done

# Linux specific
elif [[ "$(uname -s)" = "Linux" ]]; then
    for tool in $COMMON_TOOLS; do
        sudo apt install "$tool"
    done

    for tool in $LINUX_TOOLS; do
        sudo apt install "$tool"
    done

    for tool in $PY_TOOLS; do
        pip install "$tool"
    done

    # TODO i3/wayland configurations

    # TODO kitty configuration

else
    echo "Unkown OS"
    exit 0
fi

# Set up our base configs
rm -rf ~/.zshrc || true
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -s ~/github.com/configs/josh.zsh-theme ~/.oh-my-zsh/themes/josh-custom.zsh-theme
ln -s ~/github.com/configs/.zshrc ~/.zshrc
ln -s ~/github.com/configs/.vimrc ~/.vimrc

