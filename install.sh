#!/usr/bin/env bash

# A cross platform installation script for basic setup including tools and other
# configurations.

# TODO
 # Make a runner user for Arch to test AUR package installs - https://blog.ganssle.io/articles/2019/12/gitlab-ci-arch-pkg.html
 # Make the install() function more DRY - reusable approach to passing different options for OSes
 # Caching for packages

set -eou pipefail

ALPINE_TOOLS="yq docker python3-dev py3-pip fd colordiff ca-certificates openssl ncurses coreutils python2 make gcc g++ libgcc linux-headers grep util-linux binutils findutils libressl-dev openssl-dev musl-dev libffi-dev rust cargo sudo zsh libstdc++ direnv bat pass"
ARCH_TOOLS="python-pip fd go unzip base-devel fakeroot sudo bat"
COMMON_TOOLS="git jq shellcheck fzf ripgrep yamllint highlight pandoc zip exa vim curl wget zoxide"
DEBIAN_TOOLS="fd-find colordiff python3-pip ondir build-essential locales"
LINUX_TOOLS="pass tmux zsh"
NODE_TOOLS="bash-language-server fixjson"
OSX_TOOLS="hadolint fd findutils kubectl yq direnv bat"
PY_TOOLS="ansible ansible-lint pylint flake8 bashate pre-commit isort virtualenvwrapper commitizen"

ARCH_EXTRAS="docker ondir-git hadolint-bin colordiff yq direnv-bin bat bat-extras \
    kubectl kubectx kube-linter k9s helm krew-bin \
    tfenv tgenv terraform-ls tfsec-bin tflint-bin"

# DEBIAN_EXTRAS="terraform-ls kubectx yq docker hadolint bat direnv"

NVM_VERSION="v0.39.0"
COMPOSE_VERSION="v2.0.1"

set_env() {
    CI=${CI:-false}
    # Set options for running in CI
    if [[ $CI = true ]]; then
        if grep ID=ubuntu /etc/os-release; then
            # Ubuntu runs on VM as non root user
            sudo="sudo"
        else
            # No sudo in containers
            sudo=""
        fi
        # github runner path
        RUNNER_PATH="$HOME/work/configs/configs"
    else
        sudo="sudo"
    fi
}

set_env_paths() {
    if [[ ${REMOTE_CONTAINERS-} ]] || [[ ${CODESPACES-} ]]; then
        # Set the home dir to our remote containers path
        INSTALLER_PATH="$HOME/github.com/configs"
    elif [[ ${CODESPACES-} ]]; then
        # Set the home dir to our codespaces path
        INSTALLER_PATH="/workspaces/.codespaces/.persistedshare/dotfiles"
    elif [[ ${CI-} ]]; then
        # Set the home dir to custom path if we're running in CI
        INSTALLER_PATH="${RUNNER_PATH}"
    else
        # Set the default dir to home
        INSTALLER_PATH="${HOME}"
    fi

    mkdir -p "$HOME/.config"
}

_alpine() {
    $sudo apk update --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
    if [[ $UPDATE ]]; then
        $sudo apk upgrade --available --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
        return
    fi
    touch "$HOME/.bashrc"
    install_cmd="apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing"
    echo "Installing tools: $COMMON_TOOLS $ALPINE_TOOLS"
    $sudo $install_cmd $COMMON_TOOLS $ALPINE_TOOLS
    if [[ -z ${REMOTE_CONTAINERS-} ]] || [[ -z ${CODESPACES-} ]]; then
        echo "Installing Python tools: $PY_TOOLS"
        pip install wheel
        pip install $PY_TOOLS
    fi
}

_arch() {
    # Assume we have yay install if we're trying to update
    if [[ $UPDATE ]]; then
        yay -Syu --noconfirm
        return
    fi
    $sudo pacman -Syu --noconfirm
    echo "Installing tools: $COMMON_TOOLS $LINUX_TOOLS $ARCH_TOOLS"
    $sudo pacman -S --needed --noconfirm $COMMON_TOOLS $LINUX_TOOLS $ARCH_TOOLS
    # Skip yay install for now if we are running as the root user (CI)
    if [[ $EUID != 0 ]]; then
        echo "Installing extras: $ARCH_EXTRAS"
        yay_cmd="yay -S --needed --noconfirm"
        if ! yay -V &> /dev/null; then install_yay; fi
        # Update package list
        $yay_cmd $ARCH_EXTRAS
    fi
    echo "Installing Python tools: $PY_TOOLS"
    pip install $PY_TOOLS
}

_bsd() {
    echo
}

_debian() {
    $sudo apt update -y
    if [[ $UPDATE ]]; then
        $sudo apt upgrade
        return
    fi
    install_cmd="$sudo apt install -y"
    echo "Installing tools: $COMMON_TOOLS $LINUX_TOOLS $DEBIAN_TOOLS"
    $install_cmd $COMMON_TOOLS $LINUX_TOOLS $DEBIAN_TOOLS
    echo "Installing Python tools: $PY_TOOLS"
    pip install $PY_TOOLS
    # Set the default locale otherwise the installer stops to configure it
    $sudo sh -c "echo \"en_US.UTF-8 UTF-8\" >> /etc/locale.gen"
    $sudo locale-gen
}

_gentoo() {
    echo
}

_macos() {
    brew update
    if [[ $UPDATE ]]; then
        brew upgrade
        return
    fi
    echo "Installing tools: $COMMON_TOOLS $OSX_TOOLS"
    brew install $COMMON_TOOLS $OSX_TOOLS
    echo "Installing Python tools: $PY_TOOLS"
    pip3 install --user --no-warn-script-location $PY_TOOLS
}

_nixos() {
    echo
}

_ubuntu() {
    $sudo apt update -y
    if [[ $UPDATE ]]; then
        $sudo apt upgrade
        return
    fi
    install_cmd="$sudo apt install -y --ignore-missing"
    echo "Installing tools: ${COMMON_TOOLS//exa/} $LINUX_TOOLS $DEBIAN_TOOLS"
    $install_cmd ${COMMON_TOOLS//exa/} $LINUX_TOOLS $DEBIAN_TOOLS
    echo "Installing Python tools: $PY_TOOLS"
    pip install $PY_TOOLS
}

install() {
    set_env
    if grep ID=arch /etc/os-release; then
        _arch
    elif grep ID=debian /etc/os-release; then
        _debian
    elif grep ID=ubuntu /etc/os-release; then
        _ubuntu
    elif grep ID=alpine /etc/os-release; then
        _alpine
    elif  [[ "$(uname -s)" = "Darwin" ]]; then
        _macos
    else
        echo "Unkown OS"
        exit 0
    fi

    # Install starship across all systems
    curl -sS https://starship.rs/install.sh | sh -s -- -y

    if [[ -z ${REMOTE_CONTAINERS-} ]] || [[ -z ${CODESPACES-} ]]; then
        install_nvm
        install_awscli
        echo "Finished installing packages and tools"
    fi
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
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
        . "$HOME/.nvm/nvm.sh"
        # We need to do some shenanigans to override the function to retrieve
        # the correct architecture and point to a musl version of the nodejs
        # binary when we are using Alpine
        if grep ID=alpine /etc/os-release; then
            nvm_get_arch() { nvm_echo "x64-musl"; }
            export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release
        fi
        nvm install --lts
        nvm alias default stable
        # shellcheck disable=SC2086
        npm install -g $NODE_TOOLS
    fi
}

install_docker_compose() {
    # https://docs.docker.com/compose/cli-command/#installing-compose-v2
    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
}

configure() {
    # git pull
    echo "Configuring environment"

    set_env_paths

    # oh-my-zsh
    if [[ ! -d $"$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting || true
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions || true
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k || true

    # Link configs
    rm -rf "$HOME/.zshrc" || true && ln -s "$INSTALLER_PATH/.zshrc" "$HOME/.zshrc"
    rm -rf "$HOME/.vimrc" || true && ln -s "$INSTALLER_PATH/.vimrc" "$HOME/.vimrc"
    rm -rf "$HOME/.tmux.conf" || true && ln -s "$INSTALLER_PATH/.tmux.conf" "$HOME/.tmux.conf"
    rm -rf "$HOME/.config/starship.toml" || true && ln -s "$INSTALLER_PATH/config/starship/starship.toml" "$HOME/.config/starship.toml"
    rm -rf "$HOME/.p10k.zsh" || true && ln -s "$INSTALLER_PATH/.p10k.zsh" "$HOME/.p10k.zsh"

    # i3/wayland configurations
    # kitty configuration
    # pylint configuration

    echo "Configuring Vim"

    if [[ ! -d $HOME/.vim/plugged ]]; then
        # Vim 8.2+ tools/plugins + coc plugins
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        mkdir -p "$HOME/.config/coc"
        vim --not-a-term +PlugInstall +qall
        vim --not-a-term +'CocInstall coc-json coc-sh coc-yaml coc-go coc-pyright coc-go coc-docker coc-markdownlint' +qall
    else
        vim --not-a-term +'PlugInstall --sync' +qall
    fi

    # Quick check if configs are linked
    ls -lah "$HOME"
    echo "Done configuring environment"
}

switch_shell() {
    if [[ ! $CI ]]; then
        if [[ $SHELL != "/usr/bin/zsh" ]]; then
            echo "Switching to zsh"
            chsh -s "$(which zsh)"
        fi
        echo "Non CI environment detected, reloading shell"
        exec zsh
    fi
}

main() {
    set +u
    option=$1
    set -u

    UPDATE=""

    # Handle automated installs with no args
    if [[ $# -eq 0 ]]; then
        install
        configure
        switch_shell
        exit 0
    fi

    case $option in
        --install)
            install
            ;;
        --configure)
            configure
            ;;
        --update)
            UPDATE=true
            install
            ;;
        --all)
            install
            configure
            # Change the shell as the last step because it is interactive
            switch_shell
            ;;
        --extras)
            # TODO: install extras separately to speed up base installs
            ;;
        *)
            echo "'$option' not a recognized option"
            exit 1
    esac
}

main "$@"
echo "Finished bootstrapping environment"
