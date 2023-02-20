{ config, pkgs, ... }:

{
  imports = [
  ];

  ### Networking

  # networking.computerName = "prometheus";
  # networking.dns = [];
  # networking.hostName = "prometheus";
  # networking.localHostName = "prometheus"

  ### Nix

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 28d";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ### Security

  security.pam.enableSudoTouchIdAuth = true;

  ### System

  fonts = {
    fontDir.enable = true;
    fonts = [ pkgs.nerdfonts ];
  };

  system.stateVersion = 4;

  time.timeZone = "America/Chicago";

  # system.keyboard.remapCapsLockToControl = true;

  # Finder
  # system.defaults.finder.ShowPathbar = true;
  # system.defaults.finder.ShowStatusBar = true;
  # system.defaults.finder.QuitMenuItem = true;

  ### Environment

  environment.systemPackages = with pkgs; [
    bat
    curl
    direnv
    exa
    fd
    fzf
    git
    jq
    pandoc
    ripgrep
    shellcheck
    shfmt
    tmux
    tree
    vim
    zoxide
  ];

  # Some packages need to be installed with brew
  homebrew = {
    enable = true;

    # TUI
    brews = [
      "terramate"
      "tfenv"
    ];

    # GUI
    casks = [
      "authy"
      "docker"
      "drawio"
      "grammarly"
      "iterm2"
      "microsoft-remote-desktop"
      "obsidian"
      "visual-studio-code"
    ];
  };

  ### Programs

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # programs.ssh = {
  #   knownHosts = {};
  # };

  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfHistory = true;
  };

  ### Services

  services.nix-daemon.enable = true;
}
