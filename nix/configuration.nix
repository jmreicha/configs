{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  ### Boot

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

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

  ### Nix

  # Collect nix store garbage and optimise daily.
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;

  # Automatic upgrades
  #system.autoUpgrade.enable = true;
  #system.autoUpgrade.allowReboot = false;

  ### Networking

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens18.useDHCP = true;


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  ### System

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jmreicha = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      # Windows Desktop
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAk473LDx0EplCWC2ZVAf7/oZhb7J8J+05SFunRy8rHzEn3TweIi5VJ8If437oJhXLmcTMPnx7+v7+zRGCW/WuLeR1o/kZ+mODufUOUuJ3qsUISgse5duCzgA1tlv34t5L+bRscuOWbIvi8BXkarvOpa6kG/LD/GisRSqrTDuSeSMejVwB3bRwD8IDSXN3H29+nGyld0L/phW5YpAc0CFSrxO/A7yLKzRNXXpPyAiRbff+5G1g+JfqP1eyhqoFTK0E5UG+IJmgdlhHuoAw5bpnC/GAUKMshreKgTqQoUOK3dy2aJtaA/Lxm+9yYmoSrTh8LEzfBjycF6wXI0f4ff4kPQ== rsa-key-20180315"
    ];
    shell = pkgs.zsh;
  };

  # No password for sudo
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    fd
    #python39
    #(python39.withPackages(ps: with ps; [
    #  pylint
    #  flake8
    #  bashate
    #  pre-commit
    #  isort
    #  virtualenvwrapper
    #  commitizen
    #]))
    jq
    fzf
    ripgrep
    bat
    colordiff
    exa
    pandoc
    tmux
    pass
    direnv
    shellcheck
    shfmt
    zsh
    tree
    zoxide
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the Docker daemon.
  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  services.timesyncd.enable = true;

  # Shell config
  programs.zsh.enable = true;

  # copy the configuration.nix into /run/current-system/configuration.nix
  #system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
