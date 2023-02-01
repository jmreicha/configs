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

  # Link existing config files
  home.file.".config/starship.toml".source = ./starship.toml;
  #home.file.".tmux.conf".source = ./.tmux.conf;
  home.file.".vimrc".source = ./.vimrc;
  home.file.".zshrc".source = ./.zshrc;

  # Environment

  # home.sessionVariables = {
  #   EDITOR = "vim";
  # };

  # bootstrap-home = pkgs.writeScriptBin "bootstrap-home" ''
  #   git clone --depth 1 https://github.com/jmreicha/configs.git || true
  #   # Remove existing configuration.nix and symlink to ours
  #   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  #   # Install extra zsh plugins
  #   # Install home-manager
  #   # symlink to home.nix
  #   # Link .vimrc to nix path
  #   # Link .zshr to nix path
  #   # Link starship.toml to nix path
  #   home-manager switch
  # '';

  # scripts = [ bootstrap-home ];

  # Packages

  home.packages = with pkgs; [
    #bashate
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
    nodejs
    pre-commit

    unstable.starship
  ];

  ### Configurations

  programs.git = {
    enable = true;
    userName = "jmreicha";
    userEmail = "josh.reichardt@gmail.com";
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
    # enableSyntaxHighlighting = true;

    initExtra = "source $HOME/.zshrc";

    oh-my-zsh.enable = true;

    # envExtra = ''
    #   "source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    #   "source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    #   "source $HOME/.zshrc";
    # '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
