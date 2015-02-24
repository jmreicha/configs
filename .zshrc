# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set vim to default editor
export EDITOR=/usr/bin/vim

# go path
export PATH=$PATH:/usr/local/go/bin

# CoreOS administration - only works on VPN
export ETCDCTL_PEERS=http://172.16.1.10:4001
export FLEETCTL_ENDPOINT=http://172.16.1.10:4001

# Kubernetes
export KUBERNETES_MASTER=http://172.16.1.100:8080

# AWS cli tab completion
source /usr/local/bin/aws_zsh_completer.sh

# Set name of the theme to load.
ZSH_THEME="clean"

# use case-sensitive completion.
# CASE_SENSITIVE="true"

# disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# disable colors in ls.
# DISABLE_LS_COLORS="true"

# disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# enable command auto-correction.
# ENABLE_CORRECTION="true"

# display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"


# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git knife vagrant)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
