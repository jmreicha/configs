#!/usr/bin/env bash

# Simple install script for various tools and configuration

COMMON_TOOLS="git jq yq shellcheck fzf ripgrep hstr yamllint highlight terraform-ls pandoc zip"
OSX_TOOLS="hadolint fd findutils golang"
DEBIAN_TOOLS="fd-find"
ARCH_TOOLS="python-pip fd exa go unzip"
ALPINE_TOOLS=""
LINUX_TOOLS="pass tmux zsh"
PY_TOOLS="ansible ansible-lint pylint flake8 bashate pre-commit pygments isort virtualenvwrapper"
NODE_TOOLS="bash-language-server fixjson"
# EXTRA_TOOLS="tflint tfsec ondir magic-wormhole delta k9s"

install_packages() {
    if grep ID=arch /etc/os-release; then
        install_cmd="sudo pacman -S --needed --noconfirm"
    elif grep ID=debian /etc/os-release; then
        install_cmd="sudo apt install -y"
    elif grep ID=alpine /etc/os-release; then
        install_cmd="sudo apk add"
    fi

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
            $install_cmd "$tool"
        done

        echo "Installing Linux tools"
        for tool in $LINUX_TOOLS; do
            $install_cmd "$tool"
        done

        echo "Installing Arch tools"
        for tool in $ARCH_TOOLS; do
            $install_cmd "$tool"
        done

        echo "Installing Python tools"
        for tool in $PY_TOOLS; do
            pip install "$tool"
        done

        # TODO i3/wayland configurations

        # TODO kitty configuration

    else
        echo "Unkown OS"
        exit 0
    fi

    echo "Finished installing packages"
}

install_awscli() {
    # Grab the newest version by default
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws*
}

install_nvm() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    . ~/.nvm/nvm.sh
    nvm install --lts
    nvm alias default stable
    npm install -g $NODE_TOOLS
}

configure() {
    echo "Configuring environment"

    # powerlevel fonts
    curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf > "MesloLGS NF Regular.ttf"

    # oh-my-zsh
    if [[ ! -d $HOME/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
        git clone --depth=1 https://github.com/agkozak/zsh-z "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-z
    fi

    # Link configs
    rm -rf ~/.oh-my-zsh/themes/josh-custom.zsh-theme && ln -s ~/github.com/configs/josh.zsh-theme ~/.oh-my-zsh/themes/josh-custom.zsh-theme
    rm -rf ~/.zshrc && ln -s ~/github.com/configs/.zshrc ~/.zshrc
    rm -rf ~/.vimrc && ln -s ~/github.com/configs/.vimrc ~/.vimrc
    rm -rf ~/.p10k.zsh && ln -s ~/github.com/configs/.p10k.zsh ~/.p10k.zsh
    rm -rf ~/.tmux.conf && ln -s ~/github.com/configs/.tmux.conf ~/.tmux.conf

    echo "Configuring Vim"

    rm -rf ~/.vim/plugged/*
    # Vim 8.2+ tools/plugins + coc plugins
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugInstall +qall
    vim +'CocInstall coc-json coc-sh coc-yaml coc-go coc-pyright coc-go coc-docker coc-markdownlint' +qall
}

switch_shell() {
    if [[ $SHELL != "/usr/bin/zsh" ]]; then
        echo "Switching to zsh"
        chsh -s "$(which zsh)"
    fi
}

cleanup() {
    echo "Cleaning up"
    rm -rf "MesloLGS NF Regular.ttf"
}

install_packages
install_nvm
install_awscli
configure
cleanup
# Change the shell as the last step because it is interactive
switch_shell

echo "Finished bootstrapping environment, reload/restart shell"
