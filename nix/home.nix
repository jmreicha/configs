{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unstable packages to be referenced.
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  ### Home settings

  home.username = "jmreicha";
  home.homeDirectory = "/home/jmreicha";

  # Link existing config files from our repo
  home.file.".config/starship.toml".source = ../config/starship/starship.toml;
  #home.file.".tmux.conf".source = ./.tmux.conf;
  home.file.".vimrc".source = ../.vimrc;
  home.file.".zshrc".source = ../.zshrc;

  # Environment

  # home.sessionVariables = {
  #   FOO = "bar";
  # };

  # bootstrap-home = pkgs.writeScriptBin "bootstrap-home" ''
  #   git clone --depth 1 https://github.com/jmreicha/configs.git || true
  #   # bootstrap vim-plugin
  #   # Add extra config to allow flakes
  #   # Update nix channels/flakes for hm and devenv
  #   # Install home-manager - nix-shell '<home-manager>' -A install
  #   # Install deven - nix profile install github:cachix/devenv/v0.5
  #   # Remove existing configuration.nix and symlink to ours
  #   # symlink to home.nix
  #   # Link .vimrc to nix path
  #   # Link .zshr to nix path
  #   # Link starship.toml to nix path
  #   home-manager switch
  # '';

  # scripts = [ bootstrap-home ];

  # Packages

  home.packages = with pkgs; [
    #commitizen
    #flake8
    #hadolint
    #helm
    #isort
    #k9s
    #krew
    #kube-linter
    #kubectl
    #kubectx
    #pkgs.pylint
    #terraform
    #tfenv
    #tflint
    #tfsec
    #tgenv
    #virtualenvwrapper
    #yamllint
    ansible
    ansible-lint
    aws-vault
    awscli2
    bashate
    nodejs
    pre-commit

    unstable.starship
  ];

  ### Configurations

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "jmreicha";
    userEmail = "josh.reichardt@gmail.com";
    # signing.signByDefault = true;
  };

  programs.starship = {
    enable = false;
  };

  programs.tmux = {
    enable = false;
  };

  programs.vim = {
    enable = false;
  };

  programs.zsh = {
    dotDir = ".config/zsh";
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    initExtra = "source $HOME/.zshrc";
    oh-my-zsh.enable = true;
  };

  ### Services

  # services.git-sync = {
  #   repositories = [];
  # }

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";
}
