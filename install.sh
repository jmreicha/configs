#!/usr/bin/env bash

# Simple install script for various tools and configuration

COMMON_TOOLS="jq shellcheck fzf ripgrep hstr bat yamllint highlight autojump terraform-ls"
OSX_TOOLS="hadolint fd findutils"
LINUX_TOOLS="fd-find"
PY_TOOLS="ansible ansible-lint pylint flake8 pycodstyle bashate pre-commit pygments thefuck isort"
# EXTRA_TOOLS="tflint tfsec ondir magic-wormhole exa delta k9s"
# NODE_TOOLS="bash-language-server fixjson"

# Common across OS
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# powerlevel fonts
curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf > "MesloLGS NF Regular.ttf"

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install -lts
nvm alias default stable

# TODO Install GO

# TODO Vim 8.2+ tools/plugins + coc plugins

# TODO Make the installation below DRY

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
