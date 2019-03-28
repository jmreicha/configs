configs
=======

A repository for all my configs and dotfiles.  I also keep track of my preferred command line produdictivity tools here.

The best way to use this repo is to clone it and create a symlink (shown below).

### Tools

* [jq](https://stedolan.github.io/jq/) - json parser
* [yq](https://github.com/mikefarah/yq) - yaml parser
* [shellcheck](https://github.com/koalaman/shellcheck) - analysis tool for shell scripts
* [fzf](https://github.com/junegunn/fzf) - better fuzzy finder 
* [ripgrep](https://github.com/BurntSushi/ripgrep) - better `grep`
* [hstr](https://github.com/dvorka/hstr) - better `history`
* [fd](https://github.com/sharkdp/fd) - better `find`
* [bat](https://github.com/sharkdp/bat) - better `cat`

### Install zsh

```
sudo apt-get install zsh
chsh -s $(which zsh)
logout
```

### Install oh-my-zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

### Configure .zshrc

```
rm ~/.zshrc
ln -s ~/configs/.zshrc ~/.zshrc
```

This will link the `.zshrc` defined in this repo to the correct system path in the home directory.  Be sure to use the FULL path to the config repo when linking, otherwise you might run into linking issues.  Here `client` is just cloned to the home directory and referenced there.

After setting up the link, you can just edit `~/.zshrc` if you want to make adjustments and can more easily keep configs in sync with commits, etc.

### Configure .vimrc

```
ln -s ~/configs/.vimrc ~/.vimrc
```

Same as above, this will link the Vim configuration into the correct location.
 
To install the Vim plugins on a fresh machine, first clone the Vundle project in to the approriate location.

```
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

From there, you will also need to add a few lines in your `vimrc` file to get
it to work.  I already have them added so won't illustrate that step here.

Then you can open up Vim and run `:PluginInstall` to go get additional packages.  There
might be errors when running Vim the first time, these can be ignored.

This `.vimrc` uses the Vundle package manager to download and install some additional
packages (thse can be found ithe the .vimrc).

```
"" GO tools
Bundle 'fatih/vim-go'
"" Color schemes
Bundle 'flazz/vim-colorschemes'
"" Terraform
Bundle 'markcornick/vim-terraform'
"" Git integration
Bundle 'tpope/vim-fugitive'
"" Show Git file changes
Bundle 'airblade/vim-gitgutter'
"" JSON highlighting
Bundle 'elzr/vim-json'
"" Nerdtree
Bundle 'scrooloose/nerdtree'
Bundle 'Xuyuanp/nerdtree-git-plugin'
Bundle 'jistr/vim-nerdtree-tabs'
"" Fuzzy file searching
Bundle 'kien/ctrlp.vim'
"" Keep track of parenths
Bundle 'luochen1990/rainbow'
"" Better status line
Bundle 'bling/vim-airline'
"" Whitespace highlighting
Bundle 'ntpeters/vim-better-whitespace'
"" Syntax highlighting
Bundle 'scrooloose/syntastic'
"" Dockerfile syntax highlighting
Bundle 'ekalinin/Dockerfile.vim'
```

You can look at my `.vimrc` file for more specific details, I try to comment
most of my configurations.

### Configure Profile.ps1

Customizes the following:

* Creates a custom color scheme for the PowerShell prompt Adds in additional
* Vim functionality

To use, copy the Profile.ps1 file to the following location (Win 7):

```
<code>C:\Users\Username\My Documents\WindowsPowerShell</code>
```

### Configure .tmux.conf

The primary purpose of this config is to bind the keys in a similar fashion to
the way they are bound in screen.

This file should be placed into the <code>~/.tmux.conf</code> file if it is not
already present.  A tmux reload may be required.
