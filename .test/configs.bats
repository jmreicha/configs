#!/usr/bin/env bats

load "/usr/local/bin/bats-support/load"
load "/usr/local/bin/bats-file/load"

@test "vimrc exists" {
    assert_exists ~/.vimrc
}

@test "vimrc symlinked correctly" {
    assert_symlink_to ~/github.com/configs/.vimrc ~/.vimrc
}

@test "vimrc owner is set correctly" {
    assert_file_owner "jreichardt"  ~/.vimrc
}

@test "vim plugins exist" {
    assert_exists ~/.vim/plugged
}

@test "oh-my-zsh is installed" {
    assert_exists ~/.oh-my-zsh
}

@test "zshrc exists" {
    assert_exists ~/.zshrc
}

@test "tmux.conf exists" {
    if  [[ "$(uname -s)" = "Darwin" ]]; then
        skip "unused on OSX"
    fi
    assert_exists ~/.tmux.conf
}

@test "starship.toml exists" {
    assert_exists ~/.config/starship.toml
}
