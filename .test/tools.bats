#!/usr/bin/env bats

load "/usr/local/bin/bats-support/load"
load "/usr/local/bin/bats-assert/load"

@test "vim is intalled" {
    run command -v vim
    assert_success
}

@test "npm is installed" {
    run command -v npm
    assert_success
}

@test "git is installed" {
    run command -v git
    assert_success
}

@test "jq is installed" {
    run command -v jq
    assert_success
}

@test "shellcheck is installed" {
    run command -v shellcheck
    assert_success
}

@test "fzf is installed" {
    run command -v fzf
    assert_success
}

@test "ripgrep is installed" {
    run command -v rg
    assert_success
}

@test "yamllint is installed" {
    run command -v yamllint
    assert_success
}

@test "exa is installed" {
    run command -v exa
    assert_success
}

@test "curl is installed" {
    run command -v curl
    assert_success
}

@test "wget is installed" {
    run command -v wget
    assert_success
}

@test "zoxide is installed" {
    run command -v zoxide
    assert_success
}

@test "fd is installed" {
    run command -v fd
    assert_success
}
