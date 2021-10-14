#!/usr/bin/env bash

# Simple cross platform installation script for basic setup including tools and
# other configurations.

set -eu

# TODO Better oraganization of tools

ALPINE_TOOLS=""
ARCH_EXTRAS="docker kubectl tfenv tgenv ondir-git hadolint-bin colordiff"
ARCH_TOOLS="python-pip fd exa go unzip base-devel"
COMMON_TOOLS="jq yq shellcheck fzf ripgrep hstr yamllint highlight terraform-ls pandoc zip kubectx"
DEBIAN_TOOLS="fd-find colordiff"
LINUX_TOOLS="pass tmux zsh"
NODE_TOOLS="bash-language-server fixjson"
OSX_TOOLS="hadolint fd findutils golang kubectl"
PY_TOOLS="ansible ansible-lint pylint flake8 bashate pre-commit pygments isort virtualenvwrapper"

install() {
    if grep ID=arch /etc/os-release; then
        install_cmd="yay -S --needed --noconfirm"
        if ! yay -V &> /dev/null; then install_yay; fi
        # Update package list
        yay
        echo "Installing tools: $COMMON_TOOLS $LINUX_TOOLS $ARCH_TOOLS $ARCH_EXTRAS"
        $install_cmd $COMMON_TOOLS $LINUX_TOOLS $ARCH_TOOLS $ARCH_EXTRAS
        echo "Installing Python tools: $PY_TOOLS"
        pip install $PY_TOOLS
    elif grep ID=debian /etc/os-release; then
        install_cmd="sudo apt install -y"
        # Update package list
        sudo apt update -y
        echo "Installing tools: $COMMON_TOOLS $LINUX_TOOLS $DEBIAN_TOOLS"
        $install_cmd $COMMON_TOOLS $LINUX_TOOLS $DEBIAN_TOOLS
        echo "Installing Python tools: $PY_TOOLS"
        pip install $PY_TOOLS
    elif grep ID=alpine /etc/os-release; then
        install_cmd="apk add"
        # Update package list
        apk update
    # OSX
    elif  [[ "$(uname -s)" = "Darwin" ]]; then
        echo "Installing tools: $COMMON_TOOLS $OSX_TOOLS"
        $install_cmd $COMMON_TOOLS $OSX_TOOLS
        echo "Installing Python tools: $PY_TOOLS"
        pip install --user $PY_TOOLS
    else
        echo "Unkown OS"
        exit 0
    fi

    echo "Installing NVM"
    if [[ ! -f $HOME/.nvm/nvm.sh ]]; then install_nvm; fi
    echo "Installing AWS CLI"
    if ! aws --version &> /dev/null; then install_awscli; fi

    echo "Finished installing packages and tools"
}

### Non-packaged tools

install_yay() {
    git clone https://aur.archlinux.org/yay-bin.git
    pushd yay-bin
    makepkg -si
    popd
    rm -rf yay-bin
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

install_docker_compose() {
    # https://docs.docker.com/compose/cli-command/#installing-compose-v2
    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
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
    # i3/wayland configurations
    # kitty configuration

    echo "Configuring Vim"

    if [[ ! -d $HOME/.vim/plugged ]]; then
        # Vim 8.2+ tools/plugins + coc plugins
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        vim +PlugInstall +qall
        vim +'CocInstall coc-json coc-sh coc-yaml coc-go coc-pyright coc-go coc-docker coc-markdownlint' +qall
    else
        vim +PlugUpdate +qall
    fi
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

main() {
    set +u
    option=$1
    set -u

    case $option in
        --install)
            install
            ;;
        --configure)
            configure
            ;;
        *)
            install
            configure
            cleanup
            # Change the shell as the last step because it is interactive
            # switch_shell
            ;;
    esac
}

main "$@"
echo "Finished bootstrapping environment, reload/restart shell"
