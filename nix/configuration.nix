{ config, pkgs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  ### Boot

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  # boot.loader.systemd-boot.enable = true; # (for UEFI systems only)

  ### Networking

  networking.hostName = "nixos";
  networking.firewall.enable = false;
  # networking.networkmanager.enable = true;

  # Set a static IP
  # networking.interfaces.eth0.ipv4.addresses = [{
  #   address = "192.0.2.1";
  #   prefixLength = 24;
  # }];

# networking.defaultGateway = "192.0.2.254";
# networking.nameservers = [ "8.8.8.8" ];

  ### Filesystem

  # Note: setting fileSystems is generally not
  # necessary, since nixos-generate-config figures them out
  # automatically in hardware-configuration.nix.
  #fileSystems."/".device = "/dev/disk/by-label/nixos";

  # "/" = {
  #   device = "/dev/sda1";
  #   fsType = "ext4";
  #   autoFormat = true;
  #   autoResize = true;
  # };

  # "/".label = "nixos";

  # fileSystems."/".mountPoint = "/mnt"

  ### System

  # Collect nix store garbage and optimise daily.
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;

  # Automatic upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

  ### Services

  # Only keep the last 500MiB of systemd journal.
  services.journald.extraConfig = "SystemMaxUse=500M";
  services.sshd.enable = true;
  services.timesyncd.enable = true;

  # services.openssh = {
  #     enable = true;
  #     passwordAuthentication = false;
  #     challengeResponseAuthentication = false;
  #   };

  # No passwords for sudo
  security.sudo.wheelNeedsPassword = false

  ### Packages

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # language support
    go
    nodejs
    python39
    # Kube
    krew
    kubectl
    kubectx
    # Terraform
    tfk8s
    tflint
    tfsec
    # Misc
    bat
    colordiff
    curl
    direnv
    docker
    exa
    fd
    fzf
    git
    hadolint
    helm
    jq
    pandoc
    pass
    ripgrep
    shellcheck
    tmux
    tree
    vim
    wget
    yamllint
    yq-go
    zsh
  ];

  virtualisation.docker.enable = true;

  # TODO qemu guest agent

  ### Environment

  time.timeZone = "America/Chicago";
  # environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };
  programs.zsh.enable = true;

  # Disable password prompt for sudo users
  security.sudo.wheelNeedsPassword = false;

  users.extraUsers.jmreicha = {
    isNormalUser = true;
    home = "/home/jmreicha";
    description = "Josh Reichardt";
    extraGroups = ["wheel" "docker"];
    createHome = true;
    # shell = "/run/current-system/sw/bin/zsh";
    # shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Windows Desktop
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAk473LDx0EplCWC2ZVAf7/oZhb7J8J+05SFunRy8rHzEn3TweIi5VJ8If437oJhXLmcTMPnx7+v7+zRGCW/WuLeR1o/kZ+mODufUOUuJ3qsUISgse5duCzgA1tlv34t5L+bRscuOWbIvi8BXkarvOpa6kG/LD/GisRSqrTDuSeSMejVwB3bRwD8IDSXN3H29+nGyld0L/phW5YpAc0CFSrxO/A7yLKzRNXXpPyAiRbff+5G1g+JfqP1eyhqoFTK0E5UG+IJmgdlhHuoAw5bpnC/GAUKMshreKgTqQoUOK3dy2aJtaA/Lxm+9yYmoSrTh8LEzfBjycF6wXI0f4ff4kPQ== rsa-key-20180315"
    ];
  };

  system.stateVersion = "21.05";
}
