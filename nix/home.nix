{ config, pkgs, ... }:

# TODO: Dynamically pick username to assign directory to in below config

{
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

  home.username = "josh.reichardt";
  home.homeDirectory = "/Users/josh.reichardt";

  home.file.".config/git/config.personal".text = ''
  [user]
          email = "josh.reichardt@gmail.com"
          signingKey = "382541722B298C07"
  '';

  home.file.".config/git/config.work".text = ''
  [user]
          email = "josh.reichardt@lytx.com"
          signingKey = "DD1DED98B96B8EDE"
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
    #commitizen
    #flake8
    #pylint
    #yamllint

    # Local
    act
    ansible
    ansible-lint
    aws-vault
    awscli2
    bashate
    black
    colordiff
    gh
    hadolint
    isort
    nerdfonts
    nodejs
    pre-commit
    trivy
    vault
    vaultenv
    watch

    # Kubernetes
    k9s
    krew
    kube-bench
    kube-linter
    kubectx
    kubernetes-helm
    kubescape
    kubeval
    #argo
    #argocd
    #aws-iam-authenticator
    #fluxctl
    #kind
    #kubeaudit
    #kubecolor
    #kubectl
    #kubegrunt
    #kustomize
    #tfk8s

    # Terraform
    iam-policy-json-to-terraform
    terraform-docs
    terraformer
    tflint
    tfsec
    #checkov
    #terrascan
    #conftest
    #tgswitch
    #tfswitch

    unstable.starship
  ];

  ### Program configs

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

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

    # signing = {
    #   signByDefault = false;
    #   key = "382541722B298C07"; # personal key
    # };

    # userName = "jmreicha";
    # userEmail = "josh.reichardt@gmail.com";
  };

  services.gpg-agent = {
    enable = false;
    pinentryFlavor = "curses";
    defaultCacheTtl = 31536000; #86400
    maxCacheTtl = 31536000; #86400
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

    shellAliases = {
      home-rebuild = "home-manager switch && exec zsh";
      rebuild-all = "home-manager switch && darwin-rebuild switch && exec zsh";
    };
  };

  ### Services

  # services.git-sync = {
  #   repositories = [];
  # }

  home.stateVersion = "22.11";
}
