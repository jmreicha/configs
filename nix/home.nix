{ config, pkgs, ... }:

# Dynamic variables
let
  user = "josh.reichardt";
  gpgKeyPersonal = "A9752A813F1EF110";
  gpgKeyWork = "DD1DED98B96B8EDE";
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unstable packages to be referenced.
  nixpkgs.config = {
    allowUnfree = true;
    # allowUnsupportedSystem = true;
    packageOverrides = pkgs: {
      unstable = import <unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  ### Home settings

  home.username = "${user}";
  home.homeDirectory = "/Users/${user}";

  home.file.".config/git/config.personal".text = ''
  [user]
          email = "${user}@gmail.com"
          signingKey = "${gpgKeyPersonal}"
  '';

  home.file.".config/git/config.work".text = ''
  [user]
          email = "${user}@lytx.com"
          signingKey = "${gpgKeyWork}"
  '';

  home.file.".npmrc".text = ''
    prefix=''${HOME}/.npm-packages
  '';

  # Link existing config files from our repo
  # home.file.".config/starship.toml".source = ../config/starship/starship.toml;
  # home.file.".tmux.conf".source = ./.tmux.conf;
  # home.file.".vimrc".source = ../.vimrc;
  # home.file.".zshrc".source = ../.zshrc;

  # Environment

  home.sessionVariables = {
    NIX = "true";
  };

  # Packages

  home.packages = with pkgs; [
    # Local tools
    act
    age
    ansible
    ansible-lint
    asdf-vm
    aws-vault
    awscli2
    bashate
    black
    # checkov
    colordiff
    commitizen
    conftest
    doctl
    gh
    glow
    go-task
    hadolint
    just
    lazygit
    nerdfonts
    packer
    pre-commit
    ruff
    s3cmd
    sops
    thefuck
    trivy
    vault
    vaultenv
    watch
    yamllint
    yq-go

    # Kubernetes
    datree
    eksctl
    k9s
    krew
    kube-bench
    kube-linter
    kubeconform
    kubectx
    kubernetes-helm
    # kubescape
    kubeval
    pluto
    popeye
    argocd
    #aws-iam-authenticator
    #fluxctl
    #kind
    #kubeaudit
    #kubecolor
    #kubectl
    #kubegrunt
    #kustomize

    # Terraform
    iam-policy-json-to-terraform
    terraform-docs
    terraformer
    tflint
    tfsec
    #terrascan
    tfk8s

    unstable.starship
    unstable.nodejs_20
  ];

  ### Program configs

  # programs.direnv = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   nix-direnv.enable = true;
  # };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;

    # TODO: Ordering matters and the includeif before user breaks the override.
    extraConfig = {
      commit = {
        gpgSign = true;
      };
      gpg = {
        program = "gpg2";
      };
      include = {
        path = "~/.config/git/config.personal";
      };
      "includeIf \"gitdir:~/git/lytx/\"" = {
        path = "~/.config/git/config.work";
      };
      init = {
        defaultBranch = "main";
      };
      tag = {
        gpgSign = true;
      };
      user = {
        name = "jmreicha";
      };
    };

    ignores = [
      ".DS_Store*"
      ".vscode"
      "*.log"
    ];
  };

  programs.go.enable = true;

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

    shellAliases = {
      home-rebuild = "home-manager switch && exec zsh";
      rebuild-all = "home-manager switch && darwin-rebuild switch && exec zsh";
    };
  };

  ### Services

  # TODO: Waiting for upstream support for osx to get merged
  # services.gpg-agent = {
  #   defaultCacheTtl = 1800;
  #   defaultCacheTtlSsh = 1800;
  #   enable = false;
  #   enableSshSupport = true;
  #   enableZshIntegration = true;
  #   extraConfig = ''
  #     allow-mac-pinentry
  #   '';
  # };

  services.gpg-agent = {
    enable = false;
    pinentryFlavor = "curses";
    defaultCacheTtl = 31536000; #86400
    maxCacheTtl = 31536000; #86400
  };

  # services.git-sync = {
  #   repositories = [];
  # }

  home.stateVersion = "22.11";
}
