{ config, pkgs, ... }:

{
  imports = [];

  ### Networking

  networking = {
    computerName = "prometheus";
    # dns = [];
    hostName = "prometheus";
    localHostName = "prometheus";
  };

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
    gnupg
    jq
    pandoc
    pinentry_mac
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
      "pinentry-touchid"
      "terramate"
      "tfenv"
      "tfsort"
      "act"
    ];

    # GUI
    casks = [
      "authy"
      "discord"
      "docker"
      "drawio"
      "firefox"
      "grammarly"
      "iterm2"
      "microsoft-remote-desktop"
      "obsidian"
      "visual-studio-code"
    ];

    # Custom
    taps = [
      "alexnabokikh/tfsort" #tfsort
      "jorgelbg/tap" #pinentry-touchid
    ];
  };

  ### Programs

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # programs.ssh = {
  #   knownHosts = {};
  # };

  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = false;
    enableFzfHistory = true;
  };

  ### Services

  services.nix-daemon.enable = true;
}
