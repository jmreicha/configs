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

  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
  # system.keyboard.remapCapsLockToControl = true;

  system.stateVersion = 4;

  time.timeZone = "America/Chicago";

  # system.keyboard.remapCapsLockToControl = true;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

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
      "checkov"
      "packer"
      "cdk8s"
      "maccy"
      "pinentry-touchid"
      "terramate"
      "tfenv"
      "tfsort"
    ];

    # GUI
    casks = [
      "authy"
      "brave-browser"
      "discord"
      "drawio"
      "firefox"
      "grammarly"
      "iterm2"
      "maccy"
      "microsoft-remote-desktop"
      "obsidian"
      "rancher"
      "visual-studio-code"
      "stats"
      "wireshark"
    ];

    # Pull in updates automatically
    # global.autoUpdate = true;
    # onActivation.autoUpdate = true;

    # Custom
    taps = [
      "alexnabokikh/tfsort"
      "common-fate/granted"
      "jorgelbg/tap" #pinentry-touchid
      "iann0036/iamlive/iamlive"
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
