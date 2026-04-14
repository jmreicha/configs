#!/usr/bin/env bash

# A cross platform installation script for basic setup including tools and other
# configurations.

set -eou pipefail

green() {
    echo -e "\033[0;32m$*\033[0m"
}

set_env() {
    CI=${CI:-false}
    RUNNER_PATH=""
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

_brew_install() {
    brew analytics off
    brew update
    if [[ $UPDATE ]]; then
        brew upgrade
        return
    fi
    green "Installing tools from Brewfile"
    brew bundle install || true
    brew update
    brew bundle install
}

_install_system_deps() {
    # Install system-level dependencies that should not be managed by Homebrew.
    # These are tools that require daemon/systemd integration or deep OS-level
    # setup that brew cannot handle on Linux.
    local pacman_pkgs=()
    local apt_pkgs=()
    local apk_pkgs=()

    if ! command -v zsh &>/dev/null; then
        pacman_pkgs+=(zsh)
        apt_pkgs+=(zsh)
        apk_pkgs+=(zsh)
    fi

    if ! command -v docker &>/dev/null; then
        pacman_pkgs+=(docker docker-compose)
        apt_pkgs+=(docker.io docker-compose)
        apk_pkgs+=(docker docker-compose)
    fi

    if command -v pacman &>/dev/null; then
        if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
            green "Installing system deps: ${pacman_pkgs[*]}"
            $sudo pacman -S --needed --noconfirm "${pacman_pkgs[@]}"
            if [[ " ${pacman_pkgs[*]} " == *" docker "* ]]; then
                $sudo systemctl enable --now docker
                $sudo usermod -aG docker "$USER"
            fi
        fi
        # AUR packages
        if command -v yay &>/dev/null; then
            if ! yay -Qi zen-browser-bin &>/dev/null; then
                green "Installing zen-browser-bin"
                yay -S --needed --noconfirm zen-browser-bin
            fi
        fi
    elif command -v apt &>/dev/null; then
        $sudo apt update -y
        if [[ ${#apt_pkgs[@]} -gt 0 ]]; then
            green "Installing system deps: ${apt_pkgs[*]}"
            $sudo apt install -y "${apt_pkgs[@]}"
            if [[ " ${apt_pkgs[*]} " == *" docker.io "* ]]; then
                $sudo systemctl enable --now docker
                $sudo usermod -aG docker "$USER"
            fi
        fi
        # Install Meslo Nerd Fonts for extra glyphs
        if [[ ! -d $HOME/.local/share/fonts ]]; then
            green "Installing Meslo Nerd Fonts"
            $sudo apt install -y fontconfig
            wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip -P /tmp
            mkdir -p "$HOME/.local/share/fonts"
            unzip /tmp/Meslo.zip -d "$HOME/.local/share/fonts"
            rm "$HOME/.local/share/fonts"/*Windows* /tmp/Meslo.zip
            fc-cache -fv
        fi
        # Set default locale to avoid installer prompts
        $sudo sh -c "echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen"
        $sudo locale-gen
    elif command -v apk &>/dev/null; then
        if [[ ${#apk_pkgs[@]} -gt 0 ]]; then
            green "Installing system deps: ${apk_pkgs[*]}"
            $sudo apk add "${apk_pkgs[@]}"
            if [[ " ${apk_pkgs[*]} " == *" docker "* ]]; then
                $sudo rc-update add docker default
                $sudo addgroup "$USER" docker
            fi
        fi
    else
        echo "Warning: could not detect system package manager, skipping system deps"
    fi
}

_linux_brew() {
    _install_system_deps

    # Add Homebrew to PATH for the current session if already installed
    if [[ -d /home/linuxbrew/.linuxbrew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -d "$HOME/.linuxbrew" ]]; then
        eval "$("$HOME/.linuxbrew/bin/brew shellenv")"
    fi

    # Install Homebrew if still not available
    if ! command -v brew &>/dev/null; then
        green "Installing Homebrew"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Re-initialize shellenv after fresh install
        if [[ -d /home/linuxbrew/.linuxbrew ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [[ -d "$HOME/.linuxbrew" ]]; then
            eval "$("$HOME/.linuxbrew/bin/brew shellenv")"
        fi
    fi

    _brew_install

    # SpotX - patch Spotify if installed
    if command -v spotify &>/dev/null; then
        green "Patching Spotify with SpotX"
        bash <(curl -sSL https://spotx-official.github.io/run.sh)
    fi
}

_macos() {
    _brew_install

    # AWS CLI
    if ! command -v aws &>/dev/null; then
        green "Installing AWS CLI"
        curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
        sudo installer -pkg AWSCLIV2.pkg -target /
    fi

    # Spotify
    if ! [[ -d /Applications/Spotify.app ]]; then
        green "Installing and configuring Spotify"
        brew install --cask spotify
        bash <(curl -sSL https://spotx-official.github.io/run.sh) --blockupdates
    fi

    # vim key repeating settings https://vimforvscode.com/enable-key-repeat-vim
    defaults write -g ApplePressAndHoldEnabled -bool false
}

install() {
    set_env
    mkdir -p "$HOME/.config"
    if [[ "$(uname -s)" = "Darwin" ]]; then
        green "Sudo password is required for installing rosetta and homebrew"
        sudo softwareupdate --install-rosetta --agree-to-license
        PATH=$PATH:/opt/homebrew/bin
        if ! command -v brew &>/dev/null; then
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        _macos
        #_nix

        # No need to run custom installs for Linux systems
        return
    elif [[ "$(uname -s)" = "Linux" ]]; then
        _linux_brew
    else
        echo "Unknown OS"
        exit 1
    fi

    # TODO: Golang
    # goenv install
    # goenv global 1.24
    # go install -v golang.org/x/tools/gopls@latest

    if [[ -z ${REMOTE_CONTAINERS-} ]] || [[ -z ${CODESPACES-} ]]; then
        install_awscli
    fi
    green "Finished installing packages and tools"
}

### Non-packaged tools

install_awscli() {
    if ! aws --version &>/dev/null; then
        green "Installing AWS CLI"
        # Grab the newest version by default
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -qq -o awscliv2.zip
        $sudo ./aws/install
        rm -rf aws*
    fi
}

configure() {
    # git pull
    green "Configuring environment"

    # Ensure Homebrew tools are available
    if [[ -d /home/linuxbrew/.linuxbrew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -d "$HOME/.linuxbrew" ]]; then
        eval "$("$HOME/.linuxbrew/bin/brew shellenv")"
    fi

    # Create extra directories if they don't exist
    mkdir -p "$HOME/.aws"
    mkdir -p "$HOME/.config/ghostty"
    mkdir -p "$HOME/.config/k9s"
    mkdir -p "$HOME/.config/mise"
    mkdir -p "$HOME/.config/uwsm"
    mkdir -p "$HOME/.ssh"
    mkdir -p "$HOME/.terragrunt/plugins"
    mkdir -p "$HOME/git"
    mkdir -p "$HOME/hack"
    mkdir -p "$HOME/tmp"

    set_env_paths

    # oh-my-zsh
    if [[ ! -d $"$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Link configs
    rm -rf "$HOME/.zshrc" || true && ln -s "$INSTALLER_PATH/configs/.zshrc" "$HOME/.zshrc"
    rm -rf "$HOME/.vimrc" || true && ln -s "$INSTALLER_PATH/configs/.vimrc" "$HOME/.vimrc"
    rm -rf "$HOME/.tmux.conf" || true && ln -s "$INSTALLER_PATH/configs/.tmux.conf" "$HOME/.tmux.conf"
    rm -rf "$HOME/.gitconfig" || true && ln -s "$INSTALLER_PATH/configs/.gitconfig" "$HOME/.gitconfig"
    rm -rf "$HOME/.ssh/config" || true && ln -s "$INSTALLER_PATH/configs/config/ssh" "$HOME/.ssh/config"
    rm -rf "$HOME/.config/ghostty/config" || true && ln -s "$INSTALLER_PATH/configs/config/ghostty/config" "$HOME/.config/ghostty/config"
    rm -rf "$HOME/.config/k9s/config.yaml" || true && ln -s "$INSTALLER_PATH/configs/config/k9s/config.yaml" "$HOME/.config/k9s/config.yaml"
    rm -rf "$HOME/.config/starship.toml" || true && ln -s "$INSTALLER_PATH/configs/config/starship/starship.toml" "$HOME/.config/starship.toml"
    rm -rf "$HOME/.config/opencode" || true && ln -s "$INSTALLER_PATH/configs/config/opencode" "$HOME/.config/opencode"
    rm -rf "$HOME/.config/mise/config.toml" || true && ln -s "$INSTALLER_PATH/configs/config/mise/config.toml" "$HOME/.config/mise/config.toml"
    rm -rf "$HOME/.config/uwsm/default" || true && ln -s "$INSTALLER_PATH/configs/config/uwsm/default" "$HOME/.config/uwsm/default"
    # On macOS, 1Password agent socket lives in a different path — create a
    # normalized symlink so SSH config can use ~/.1password/agent.sock on both platforms
    if [[ "$(uname -s)" = "Darwin" ]]; then
        mkdir -p "$HOME/.1password"
        ln -sf "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" "$HOME/.1password/agent.sock"
    fi

    green "Configuring global pre-commit hooks"
    pre-commit init-templatedir ~/.git-template --hook-type commit-msg -t post-commit -t pre-commit
    git config --global init.templateDir ~/.git-template

    green "Configuring Mise"
    mise install

    green "Configuring Vim"

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

    green "Close this shell and open a new one to finish configuration"
}

switch_shell() {
    if [[ ! $CI ]]; then
        # Skip chsh on omarchy systems -- omarchy's boot chain requires bash as
        # the login shell. Configure the terminal emulator to launch zsh instead.
        if [[ -d "$HOME/.local/share/omarchy" ]]; then
            green "Omarchy detected: skipping login shell change (configure terminal emulator to use zsh)"
            exec zsh
            return
        fi
        local zsh_path
        zsh_path="$(which zsh)"
        if [[ $SHELL != "$zsh_path" ]]; then
            green "Switching to zsh"
            # On Linux, brew's zsh won't be in /etc/shells by default
            if [[ "$(uname -s)" = "Linux" ]] && ! grep -qF "$zsh_path" /etc/shells; then
                echo "$zsh_path" | $sudo tee -a /etc/shells
            fi
            chsh -s "$zsh_path"
        fi
        green "Non CI environment detected, reloading shell"
        exec zsh
    fi
}

extras() {
    # Python
    uv tool upgrade --all
    # uv tool install c7n
    # uvx --from c7n custodian
    # uv tool install octodns
    # uvx --with octodns-route53 --with octodns-cloudflare --from octodns octodns-dump

    # Node
    npm upgrade -g
    # npm install -g eslint
    # npx eslint
    # npm install -g wrangler
    # npx wrangler

    # Golang
    # go install golang.org/x/tools/gopls@latest

    # Steampipe
    steampipe plugin update --all
    steampipe plugin install aws
    steampipe plugin install kubernetes
    steampipe plugin install github
    steampipe plugin install net
    steampipe plugin install crowdstrike

    # Tailpipe
    tailpipe plugin update --all
    tailpipe plugin install aws
    tailpipe plugin install github
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
    --extras)
        extras
        ;;
    *)
        echo "'$option' not a recognized option"
        exit 1
        ;;
    esac
}

main "$@"
echo
green "Finished bootstrapping environment"
