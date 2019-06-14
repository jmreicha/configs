#!/usr/bin/env bash

# Simple install script for various tools and configuration

TOOLS="jq shellcheck fzf ripgrep hstr fd bat"

# Check is we are using osx, otherwise the Linux install is a little trickier
if [[ "$(uname -s)" = "Darwin" ]]; then
    for tool in $TOOLS; do
        brew install "$tool"
    done
    # OSX specific configuration
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
    echo "Installing"
fi

# Set up our configs
rm -rf ~/.zshrc || true
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -s ~/github.com/configs/josh.zsh-theme ~/.oh-my-zsh/themes/josh-custom.zsh-theme
ln -s ~/github.com/configs/.zshrc ~/.zshrc
ln -s ~/github.com/configs/.vimrc ~/.vimrc

