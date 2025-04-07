#!/usr/bin/env bash

# A cross platform installation script for basic setup including tools and other
# configurations.

# TODO
# Make a runner user for Arch to test AUR package installs - https://blog.ganssle.io/articles/2019/12/gitlab-ci-arch-pkg.html
# Make the install() function more DRY - reusable approach to passing different options for OSes
# Caching for packages

set -eou pipefail

ALPINE_TOOLS="yq docker python3-dev py3-pip fd colordiff ca-certificates openssl ncurses coreutils python2 make gcc g++ libgcc linux-headers grep util-linux binutils findutils libressl-dev openssl-dev musl-dev libffi-dev rust cargo sudo zsh libstdc++ direnv bat pass shfmt"
ARCH_TOOLS="python-pip fd go unzip base-devel fakeroot sudo bat shfmt"
COMMON_TOOLS="git jq shellcheck fzf ripgrep yamllint highlight pandoc zip exa vim curl wget zoxide"
DEBIAN_TOOLS="fd-find colordiff python3-pip ondir build-essential locales"
LINUX_TOOLS="pass tmux zsh"
NODE_TOOLS="bash-language-server fixjson"
PY_TOOLS="ansible ansible-lint pylint flake8 bashate pre-commit isort virtualenvwrapper commitizen"

ARCH_EXTRAS="docker ondir-git hadolint-bin colordiff yq direnv-bin bat bat-extras \
    kubectl kubectx kube-linter k9s helm krew-bin \
    tfenv tgenv terraform-ls tfsec-bin tflint-bin"

# DEBIAN_EXTRAS="terraform-ls kubectx yq docker hadolint bat direnv"

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
        if ! yay -V &>/dev/null; then install_yay; fi
        # Update package list
        $yay_cmd $ARCH_EXTRAS
    fi
    echo "Installing Python tools: $PY_TOOLS"
    pip install $PY_TOOLS
}

_bsd() {
    echo
}

_fonts() {
    if [[ ! -d $HOME/.local/share/fonts ]]; then
        $sudo apt install fontconfig
        cd ~
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
        mkdir -p .local/share/fonts
        unzip Meslo.zip -d .local/share/fonts
        cd .local/share/fonts
        rm *Windows*
        cd ~
        rm Meslo.zip
        fc-cache -fv
    fi
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

    # Install fonts for extra glyphs
    _fonts

    # Set the default locale otherwise the installer stops to configure it
    $sudo sh -c "echo \"en_US.UTF-8 UTF-8\" >> /etc/locale.gen"
    $sudo locale-gen
}

_gentoo() {
    echo
}

_macos() {
    brew analytics off
    brew update
    if [[ $UPDATE ]]; then
        brew upgrade
        return
    fi
    echo "Installing tools from Brewfile"
    brew bundle install
    brew update
    brew bundle install

    # AWS CLI
    if ! command -v aws &>/dev/null; then
        echo "Installing AWS CLI"
        curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
        sudo installer -pkg AWSCLIV2.pkg -target /
    fi

    # Spotify
    if ! [[ -d /Applications/Spotify.app ]]; then
        echo "Installing and configuring Spotify"
        brew install --cask spotify
        bash <(curl -sSL https://spotx-official.github.io/run.sh) --blockupdates
    fi

    # vim key repeating settings https://vimforvscode.com/enable-key-repeat-vim
    defaults write -g ApplePressAndHoldEnabled -bool false
}

_nix() {
    # Link configs
    rm -rf ~/.zshrc && ln -s ~/configs/.zshrc ~/.zshrc
    rm -rf ~/.config/starship.toml && ln -s ~/configs/config/starship/starship.toml ~/.config/starship.toml

    # Vim
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    rm -rf ~/.vimrc && ln -s ~/configs/.vimrc ~/.vimrc

    # OSX
    if [[ "$(uname -s)" = "Darwin" ]]; then
        # This step needs sudo
        if ! command -v nix-build; then
            # TODO: run the original script to update the config file needed to map /run dir
            #curl -L https://nixos.org/nix/install | sh -s -- --daemon --darwin-use-unencrypted-nix-store-volume
            curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sudo sh -s -- install
        fi

        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            set +u
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            set -u
        fi

        mkdir -p ~/.nixpkgs && rm -rf ~/.nixpkgs/darwin-configuration.nix && ln -s ~/configs/nix/darwin-configuration.nix ~/.nixpkgs/darwin-configuration.nix
        nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer

        if ! command -v darwin-rebuild; then
            ./result/bin/darwin-installer
            exec zsh
        fi

        # Either move or chown config files created by nix installer
        sudo mv /etc/bashrc /etc/bashrc.old
        sudo mv /etc/zshrc /etc/zshrc.old
        sudo chown $(id -un) /etc/nix/nix.conf
        darwin-rebuild switch
        exec zsh
    else
        # NIXOS
        ln -s ~/configs/nix/configuration.nix ~/.nixpkgs/configuration.nix
        nixos-rebuild switch
    fi

    # Extra channels
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable
    nix-channel --update
    sudo nix-channel --update

    # Home manager
    nix-shell '<home-manager>' -A install
    # mkdir -p ~/.config/nixpkgs && ln -s ~/configs/nix/home.nix ~/.config/nixpkgs/home.nix
    mkdir -p ~/.config/home-manager && rm -rf ~/.config/home-manager/home.nix && ln -s ~/configs/nix/home.nix ~/.config/home-manager/home.nix
    home-manager switch
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

    # Install fonts for extra glyphs
    _fonts
}

install() {
    set_env
    mkdir -p "$HOME/.config"
    if grep ID=arch /etc/os-release >/dev/null 2>&1; then
        _arch
    elif grep ID=debian /etc/os-release >/dev/null 2>&1; then
        _debian
    elif grep ID=ubuntu /etc/os-release >/dev/null 2>&1; then
        _ubuntu
    elif grep ID=pop /etc/os-release >/dev/null 2>&1; then
        _ubuntu
    elif grep ID=alpine /etc/os-release >/dev/null 2>&1; then
        _alpine
    elif [[ "$(uname -s)" = "Darwin" ]]; then
        echo "Sudo password is required for installing rosetta and homebrew"
        sudo softwareupdate --install-rosetta --agree-to-license
        PATH=$PATH:/opt/homebrew/bin
        if ! command -v brew &>/dev/null; then
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi
        _macos
        #_nix

        # No need to run custom installs for below Linux systems
        return
    else
        echo "Unkown OS"
        exit 0
    fi

    # TODO: Golang
    # goenv install
    # goenv global 1.24
    # go install -v golang.org/x/tools/gopls@latest

    # Install starship across all systems
    curl -sS https://starship.rs/install.sh | sh -s -- -y

    if [[ -z ${REMOTE_CONTAINERS-} ]] || [[ -z ${CODESPACES-} ]]; then
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
    if ! aws --version &>/dev/null; then
        echo "Installing AWS CLI"
        # Grab the newest version by default
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -qq awscliv2.zip
        $sudo ./aws/install
        rm -rf aws*
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

    # Create extra directories if they don't exist
    mkdir -p "$HOME/.config/ghostty"
    mkdir -p "$HOME/.terragrunt/plugins"
    mkdir -p "$HOME/.aws"
    mkdir -p "$HOME/.ssh"
    mkdir -p "$HOME/git"
    mkdir -p "$HOME/hack"
    mkdir -p "$HOME/tmp"

    set_env_paths

    # oh-my-zsh
    if [[ ! -d $"$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Custom zsh plugins

    ZSH_PATH=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

    rm -rf "${ZSH_PATH}/plugins/zsh-you-should-use" || true
    git clone --depth=1 https://github.com/MichaelAquilina/zsh-you-should-use "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-you-should-use || true
    rm -rf "${ZSH_PATH}/plugins/zsh-syntax-highlighting" || true
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting || true
    rm -rf "${ZSH_PATH}/plugins/zsh-autosuggestions" || true
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions || true
    rm -rf "${ZSH_PATH}/plugins/zsh-vi-mode" || true
    git clone --depth=1 https://github.com/jeffreytse/zsh-vi-mode "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-vi-mode || true
    rm -rf "${ZSH_PATH}/plugins/evalcache" || true
    git clone --depth=1 https://github.com/mroth/evalcache "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/evalcache || true

    # Link configs
    rm -rf "$HOME/.zshrc" || true && ln -s "$INSTALLER_PATH/configs/.zshrc" "$HOME/.zshrc"
    rm -rf "$HOME/.vimrc" || true && ln -s "$INSTALLER_PATH/configs/.vimrc" "$HOME/.vimrc"
    rm -rf "$HOME/.tmux.conf" || true && ln -s "$INSTALLER_PATH/configs/.tmux.conf" "$HOME/.tmux.conf"
    rm -rf "$HOME/.gitconfig" || true && ln -s "$INSTALLER_PATH/configs/.gitconfig" "$HOME/.gitconfig"
    rm -rf "$HOME/.ssh/config" || true && ln -s "$INSTALLER_PATH/configs/config/ssh" "$HOME/.ssh/config"
    rm -rf "$HOME/.config/ghostty/config" || true && ln -s "$INSTALLER_PATH/configs/config/ghostty/config" "$HOME/.config/ghostty/config"
    rm -rf "$HOME/.config/starship.toml" || true && ln -s "$INSTALLER_PATH/configs/config/starship/starship.toml" "$HOME/.config/starship.toml"

    # Setup fnm/node so we can stub in node for vim
    fnm install --lts

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

    echo "Open a new zsh shell to finish configuration"
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
        ;;
    esac
}

main "$@"
echo
echo "Finished bootstrapping environment"
