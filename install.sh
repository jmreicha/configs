#!/usr/bin/env bash

# Simple cross platform installation script for basic setup including tools and
# other configurations.

# TODO
 # Make a runner user for Arch - https://blog.ganssle.io/articles/2019/12/gitlab-ci-arch-pkg.html
 # Make the install() function more DRY

set -eu

ALPINE_TOOLS="yq docker python3-dev py3-pip fd colordiff ca-certificates openssl ncurses coreutils python2 make gcc g++ libgcc linux-headers grep util-linux binutils findutils libressl-dev openssl-dev musl-dev libffi-dev rust cargo"
ARCH_TOOLS="python-pip fd go unzip base-devel sudo fakeroot"
COMMON_TOOLS="git jq shellcheck fzf ripgrep yamllint highlight pandoc zip exa vim curl wget"
DEBIAN_TOOLS="fd-find colordiff python3-pip ondir build-essential locales"
LINUX_TOOLS="pass tmux zsh"
NODE_TOOLS="bash-language-server fixjson"
OSX_TOOLS="hadolint fd findutils kubectl yq"
PY_TOOLS="ansible ansible-lint pylint flake8 bashate pre-commit pygments isort virtualenvwrapper commitizen"

ARCH_EXTRAS="docker kubectl tfenv tgenv ondir-git hadolint-bin colordiff yq terraform-ls kubectx"
# DEBIAN_EXTRAS="terraform-ls kubectx yq docker hadolint"

set_env() {
    if [[ $1 == "--ci" ]]; then
        # No sudo in containers
        sudo=""
        # github runner path
        RUNNER_PATH="$HOME/work/configs/configs"
    else
        sudo="sudo"
    fi
}

install() {
    # Arch
    if grep ID=arch /etc/os-release; then
        $sudo pacman -Syu
        # Install git first to avoid package conflicts later
        $sudo pacman -S --needed --noconfirm git
        echo "Installing tools: ${COMMON_TOOLS//git/} $LINUX_TOOLS $ARCH_TOOLS"
        $sudo pacman -S --needed --noconfirm ${COMMON_TOOLS//git/} $LINUX_TOOLS $ARCH_TOOLS
        # Skip yay install for now if we are running as the root user (CI)
        if [[ $EUID != 0 ]]; then
            echo "Installing extras: $ARCH_EXTRAS"
            yay_cmd="yay -S --needed --noconfirm"
            if ! yay -V &> /dev/null; then install_yay; fi
            # Update package list
            yay
            $yay_cmd $ARCH_EXTRAS
        fi
        echo "Installing Python tools: $PY_TOOLS"
        pip install $PY_TOOLS
    # Debian
    elif grep ID=debian /etc/os-release; then
        install_cmd="$sudo apt install -y"
        # Update package list
        $sudo apt update -y
        echo "Installing tools: $COMMON_TOOLS $LINUX_TOOLS $DEBIAN_TOOLS"
        $install_cmd $COMMON_TOOLS $LINUX_TOOLS $DEBIAN_TOOLS
        echo "Installing Python tools: $PY_TOOLS"
        pip install $PY_TOOLS
        # Set the default locale
        $sudo sh -c "echo \"en_US.UTF-8 UTF-8\" >> /etc/locale.gen"
        $sudo locale-gen
    # Ubuntu
    elif grep ID=ubuntu /etc/os-release; then
        install_cmd="sudo apt install -y --ignore-missing"
        # Update package list
        sudo apt update -y
        echo "Installing tools: ${COMMON_TOOLS//exa/} $LINUX_TOOLS $DEBIAN_TOOLS"
        $install_cmd ${COMMON_TOOLS//exa/} $LINUX_TOOLS $DEBIAN_TOOLS
        echo "Installing Python tools: $PY_TOOLS"
        pip install $PY_TOOLS
    # Alpine
    elif grep ID=alpine /etc/os-release; then
        install_cmd="apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing"
        echo "Installing tools: $COMMON_TOOLS $ALPINE_TOOLS"
        $install_cmd $COMMON_TOOLS $ALPINE_TOOLS
        echo "Installing Python tools: $PY_TOOLS"
        pip install $PY_TOOLS
    # OSX
    elif  [[ "$(uname -s)" = "Darwin" ]]; then
        install_cmd="brew install"
        echo "Installing tools: $COMMON_TOOLS $OSX_TOOLS"
        $install_cmd $COMMON_TOOLS $OSX_TOOLS
        echo "Installing Python tools: $PY_TOOLS"
        pip3 install --user --no-warn-script-location $PY_TOOLS
    else
        echo "Unkown OS"
        exit 0
    fi

    install_nvm
    install_awscli
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
    if ! aws --version &> /dev/null; then
        echo "Installing AWS CLI"
        # Grab the newest version by default
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -qq awscliv2.zip
        $sudo ./aws/install
        rm -rf aws*
    fi
}

install_nvm() {
    if [[ ! -f $HOME/.nvm/nvm.sh ]]; then
        echo "Installing NVM"
        NODE_VERSION="v0.39.0"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NODE_VERSION}/install.sh | bash
        . "$HOME/.nvm/nvm.sh"
        nvm install --lts
        nvm alias default stable
        # shellcheck disable=SC2086
        npm install -g $NODE_TOOLS
    fi
}

install_docker_compose() {
    # https://docs.docker.com/compose/cli-command/#installing-compose-v2
    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
}

configure() {
    echo "Configuring environment"

    # Set the home dir to custom path if we're running in CI
    INTSTALLER_PATH="${RUNNER_PATH:-$HOME}"

    # oh-my-zsh
    if [[ ! -d $"$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
        git clone --depth=1 https://github.com/agkozak/zsh-z "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-z
    fi

    # Link configs
    # rm -rf $HOME/.oh-my-zsh/themes/josh-custom.zsh-theme || true && ln -s $HOME/github.com/configs/josh.zsh-theme $HOME/.oh-my-zsh/themes/josh-custom.zsh-theme
    rm -rf $HOME/.zshrc || true && ln -s $INTSTALLER_PATH/github.com/configs/.zshrc $HOME/.zshrc
    rm -rf $HOME/.vimrc || true && ln -s $INTSTALLER_PATH/github.com/configs/.vimrc $HOME/.vimrc
    rm -rf $HOME/.p10k.zsh || true && ln -s $INTSTALLER_PATH/github.com/configs/.p10k.zsh $HOME/.p10k.zsh
    rm -rf $HOME/.tmux.conf || true && ln -s $INTSTALLER_PATH/github.com/configs/.tmux.conf $HOME/.tmux.conf
    # i3/wayland configurations
    # kitty configuration

    echo "Configuring Vim"

    if [[ ! -d $HOME/.vim/plugged ]]; then
        # Vim 8.2+ tools/plugins + coc plugins
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        # mkdir -p "$HOME/.config/coc"
        exit 0
        vim --not-a-term -e +PlugInstall +qall
        vim --not-a-term -e +'CocInstall coc-json coc-sh coc-yaml coc-go coc-pyright coc-go coc-docker coc-markdownlint' +qall
    else
        vim --not-a-term -e +'PlugInstall --sync' +qall
    fi

    ls -lah "$HOME"
    ls -lah "$HOME/.vim/plugged"
}

switch_shell() {
    if [[ $SHELL != "/usr/bin/zsh" ]]; then
        echo "Switching to zsh"
        chsh -s "$(which zsh)"
    fi
    echo "Non CI environment detected, reloading shell"
    exec zsh
}

main() {
    set +u
    option=$1
    set -u

    set_env "$option"

    case $option in
        --install)
            install
            ;;
        --configure)
            configure
            ;;
        --ci)
            install
            configure
            ;;
        *)
            install
            configure
            # Change the shell as the last step because it is interactive
            switch_shell
            ;;
    esac
}

main "$@"
echo
echo "Finished bootstrapping environment"
