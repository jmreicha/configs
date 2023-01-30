{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  ### Home settings

  home.username = "jmreicha";
  home.homeDirectory = "/home/jmreicha";

  ### Packages

  home.packages = [
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
    pkgs.ansible
    pkgs.ansible-lint
    pkgs.aws-vault
    pkgs.awscli2
    pkgs.nodejs
    pkgs.pre-commit
    pkgs.starship
  ];

  ### Configurations

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
    enable = false;
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [ "git" "thefuck" ];
    # };
  };

  ### Link existing config files

  home.file.".vimrc".source = ./.vimrc;
  home.file.".zshrc".source = ./.zshrc;
  #home.file.".tmux.conf".source = ./.tmux.conf;
  #home.file.".config/starship/starship.toml".source = ./starship.toml;

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
