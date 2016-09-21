configs
=======

A repository for my configs and dotfiles.

The best way to use this repo is to clone it to some location on your desktop
and then create a symlink to where the config file would live locally.

For example, `ln -s ~/configs/.zshrc ~/.zshrc` will link the config to the
correct system path.  Be sure to use the FULL path to the config file when
linking, otherwise you might run into issues.  Here `client` is just cloned to
the home directory and referenced there.

After setting up the link, you can just edit `~/.zshrc` if you want to make
adjustments and can more easily keep configs in sync with commits, etc.

### .vimrc

Uses the Vundle package manager to download and install some additional
packages (this list may change).

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
 
To install the these plugins on a fresh machine, first you need to clone the
Vundle project in to the approriate location.

```
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

From there, you will also need to add a few lines in your `vimrc` file to get
it to work.  I already have them added so won't illustrate that step here.

Then you can run `:PluginInstall` from within a Vim buffer to go get additional
packages.

You can look at my `.vimrc` file for more specific details, I try to comment
most of my configurations.

### Profile.ps1

Customizes the following:

* Creates a custom color scheme for the PowerShell prompt Adds in additional
* Vim functionality

To use, copy the Profile.ps1 file to the following location (Win 7):

```
<code>C:\Users\Username\My Documents\WindowsPowerShell</code>
```

### .tmux.conf

The primary purpose of this config is to bind the keys in a similar fashion to
the way they are bound in screen.

This file should be placed into the <code>~/.tmux.conf</code> file if it is not
already present.  A tmux reload may be required.

### .hyperterm.js

The hyperterm configuration file allows you to customize hyperterm.

Reference Table:

* `logout` close current split or window `^a d` detach from session
* `^a -` create horizontal split
* `^a |` create vertical split
* `^a up` move up between splits
* `^a down` move down between splits
* `^a ,` rename current window
* `^a n` move forward one window <code<^a p</code> move backward one window
* `^a c` create new window `^a [0-9]` jump to numbered window
