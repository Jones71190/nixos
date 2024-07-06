{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./hardware-configuration.nix
  ];

  #############
  #-=# NIX #=-#
  #############
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes ";
    settings = {
      auto-optimise-store = true;
      trusted-users = lib.mkForce ["root" "@wheel"];
      allowed-users = lib.mkForce ["@users" "@wheel"];
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "daily";
      options = "--delete-older-than 12d";
    };
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "uas" "sd_mod" "nvme"];
      luks.mitigateDMAAttacks = lib.mkDefault true;
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;
    kernelParams = ["slab_nomerge" "page_poison=1" "page_alloc.shuffle=1" "debugfs=off"];
    kernel.sysctl = {
      "kernel.kptr_restrict" = lib.mkOverride 500 2;
      "net.core.bpf_jit_enable" = lib.mkDefault false;
      "kernel.ftrace_enabled" = lib.mkDefault false;
      "net.ipv4.conf.all.log_martians" = lib.mkDefault true;
      "net.ipv4.conf.all.rp_filter" = lib.mkDefault "1";
      "net.ipv4.conf.default.log_martians" = lib.mkDefault true;
      "net.ipv4.conf.default.rp_filter" = lib.mkDefault "1";
      "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkDefault true;
      "net.ipv4.conf.all.accept_redirects" = lib.mkDefault false;
      "net.ipv4.conf.all.secure_redirects" = lib.mkDefault false;
      "net.ipv4.conf.default.accept_redirects" = lib.mkDefault false;
      "net.ipv4.conf.default.secure_redirects" = lib.mkDefault false;
      "net.ipv6.conf.all.accept_redirects" = lib.mkDefault false;
    };
    blacklistedKernelModules = [
      "ax25"
      "netrom"
      "rose"
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2fs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
    ];
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 4;
      };
    };
  };

  ###############
  #-= SYSTEM #=-#
  ###############
  system = {
    stateVersion = "24.05"; # dummy target, do not modify
    switch.enable = true; # allow updates
    autoUpgrade = {
      enable = false;
      allowReboot = true;
      dates = "hourly";
      flake = "github.com/paepckehh/nixos";
      operation = "switch"; # switch or boot
      persistent = true;
      randomizedDelaySec = "15min";
      rebootWindow = {
        lower = "02:00";
        upper = "04:00";
      };
    };
  };
  hardware = {
    enableRedistributableFirmware = true;
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  console = {
    earlySetup = true;
  };
  time = {
    timeZone = "Europe/Berlin";
    hardwareClockInLocalTime = false;
  };
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    enableIPv6 = lib.mkDefault false;
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    proxy = {
      noProxy = "1270.0.1,local,localhost,localdomain,nixos";
      default = "";
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    auditd.enable = true;
    allowSimultaneousMultithreading = true; # perf
    lockKernelModules = lib.mkForce true;
    protectKernelImage = lib.mkForce true;
    forcePageTableIsolation = lib.mkForce true;
    apparmor = {
      enable = lib.mkDefault true;
      killUnconfinedConfinables = lib.mkDefault true;
    };
    dhparams = {
      enable = true;
      stateful = false;
      defaultBitSize = "3072";
    };
    doas = {
      enable = false;
      wheelNeedsPassword = lib.mkForce true;
    };
    sudo = {
      enable = false;
      execWheelOnly = lib.mkForce true;
      wheelNeedsPassword = lib.mkForce true;
    };
    sudo-rs = {
      enable = true;
      execWheelOnly = lib.mkForce true;
      wheelNeedsPassword = lib.mkForce true;
    };
    audit = {
      enable = lib.mkForce true;
      failureMode = "panic";
      rules = ["-a exit,always -F arch=b64 -S execve"];
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users = {
      root = {
        shell = pkgs.bashInteractive;
        hashedPassword = null; # disable root account
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
      me = {
        description = "minimal-env-admin";
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7";
        uid = 1000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        useDefaultShell = true;
        extraGroups = ["wheel" "networkmanager" "video" "docker" "libvirt"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
      user = {
        description = "normal-user";
        initialHashedPassword = "$y$j9T$LHspGdWTX1m6WpLsN6xvH.$Ewnrv.azy5vko2dySQxtYZc2G3W5VpeIbhMBRxoO5TC";
        uid = 10000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        useDefaultShell = true;
        extraGroups = ["video"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    useUserPackages = true;
    users = {
      me = {
        home = {
          stateVersion = "24.05";
          username = "me";
          homeDirectory = "/home/me";
        };
        programs = {
          home-manager.enable = true;
        };
      };
      user = {
        home = {
          stateVersion = "24.05";
          username = "user";
          homeDirectory = "/home/user";
        };
        programs = {
          home-manager.enable = true;
        };
      };
    };
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    direnv.enable = true;
    gnupg.agent.enable = true;
    htop.enable = true;
    iftop.enable = true;
    iotop.enable = true;
    nano.enable = false;
    nix-index.enable = false;
    usbtop.enable = true;
    fzf.fuzzyCompletion = true;
    ssh = {
      pubkeyAcceptedKeyTypes = ["ssh-ed25519" "ssh-rsa"];
      ciphers = ["chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com"];
      hostKeyAlgorithms = ["ssh-ed25519" "ssh-rsa"];
      kexAlgorithms = [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
      knownHosts = {
        github = {
          extraHostNames = ["github.com" "api.github.com" "git.github.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
        gitlab = {
          extraHostNames = ["gitlab.com" "api.gitlab.com" "git.gitlab.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
        };
        codeberg = {
          extraHostNames = ["codeberg.org" "api.codeberg.org" "git.codeberg.org"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
        };
        sourcehut = {
          extraHostNames = ["sr.ht" "api.sr.ht" "git.sr.ht"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
        };
      };
    };
    git = {
      enable = true;
      prompt.enable = true;
      config = {
        branch.sort = "-committerdate";
        commit.gpgsign = "true";
        init.defaultBranch = "main";
        safe.directory = "/etc/nixos";
        gpg.format = "ssh";
        http = {
          sslVerify = "true";
          sslVersion = "tlsv1.3";
          version = "HTTP/1.1";
        };
        protocol = {
          allow = "never";
          file.allow = "always";
          git.allow = "never";
          ssh.allow = "always";
          http.allow = "never";
          https.allow = "never";
        };
        url = {
          "git@github.com/" = {insteadOf = ["gh:" "github:" "github.com" "https://github.com" "https://git.github.com"];};
          "git@gitlab.com/" = {insteadOf = ["gl:" "gitlab:" "gitlab.com" "https://gitlab.com" "https://git.gitlab.com"];};
          "git@codeberg.org/" = {insteadOf = ["cb:" "codeberg:" "codeberg.org" "https://codeberg.org" "https://git.codeberg.org"];};
        };
      };
    };
    vim = {
      package = pkgs.vim-full;
      defaultEditor = true;
    };
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
  nixpkgs.config.allowUnfree = true;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    # TODO: hardening mem allocator [scudo]
    memoryAllocator.provider = lib.mkForce "libc";
    interactiveShellInit = ''
      ( cd && touch .zshrc .bashrc && uname -a )'';
    variables = {
      VISUAL = "vim";
      EDITOR = "vim";
      PAGER = "bat";
      SHELLCHECK_OPTS = "-e SC2086";
      # SCUDO_OPTIONS = mkDefault "ZeroContents=1";
    };
    systemPackages = with pkgs; [
      alejandra
      bandwhich
      bat
      bat-extras.batman
      bat-extras.prettybat
      eza
      fd
      go
      gopass
      gh
      git-crypt
      git-agecrypt
      dust
      hyperfine
      jq
      tldr
      tree
      paper-age
      passage
      procs
      rage
      ripgrep
      shfmt
      shellcheck
      moreutils
      vimPlugins.vim-shellcheck
      vimPlugins.vim-go
      vimPlugins.vim-git
      vulnix
      yq
    ];
    shells = [pkgs.bashInteractive pkgs.zsh];
    shellAliases = {
      l = "ls -la";
      ll = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
      la = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
      lt = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
      lo = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
      li = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
      e = "vim";
      h = "htop --tree --highlight-changes";
      p = "sudo powertop";
      d = "dmesg -Hw";
      cat = "bat --paging=never";
      less = "bat";
      man = "batman";
      slog = "journalctl --follow --priority=7 --lines=100";
      "nix.push" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . &&\
        sudo chown -R me:users .git &&\
        git reset &&\
        git add . &&\
        git commit -S -m update ;\
        git gc --aggressive ;\
        git push --force '';
      "nix.clean" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 12d ;\
        sudo nix-collect-garbage --delete-older-than 12d ;\
        sudo nix-store --gc ;\
        sudo nix-store --optimise '';
      "nix.hardclean" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo rm /boot/loader/entries/* ;\
        sudo rm -rf /nix/var/nix/profiles/system* ;\
        sudo mkdir -p /nix/var/nix/profiles/system-profiles ;\
        nix.all ;\
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 1d ;\
        sudo nix-collect-garbage --delete-older-than 1d ;\
        sudo nix-store --gc ;\
        sudo nix-store --optimise '';
      "nix.test" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . ;\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        sudo nixos-rebuild dry-activate --flake /etc/nixos/.#$(hostname)'';
      "nix.build" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . ;\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        export DTS="$(date '+%Y-%m-%d-%H-%M')" ;\
        export HNAME="$(hostname)" ;\
        sudo nixos-rebuild switch --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" '';
      "nix.iso" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . &&\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        export HNAME="$(hostname)" ;\
        sudo nix build --impure ".#nixosConfigurations.$HNAME-iso.config.system.build.isoImage" ;\
        eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename /result/iso '';
      "nix.update" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . &&\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        sudo nix --verbose flake update &&\
        sudo alejandra --quiet . &&\
        sudo nixos-generate-config &&\
        sudo alejandra --quiet . &&\
        nix.push ;\
        export DTS="$(date '+%Y-%m-%d-%H-%M')" ;\
        export HNAME="$(hostname)" ;\
        sudo nixos-rebuild boot   --install-bootloader ;\
        sudo nixos-rebuild boot   --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" ;\
        sudo nixos-rebuild switch --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" '';
      "nix.all" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . &&\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        sudo nix --verbose flake update &&\
        sudo alejandra --quiet . &&\
        sudo nixos-generate-config &&\
        sudo alejandra --quiet . &&\
        nix.push ;\
        export DTS="$(date '+%Y-%m-%d-%H-%M')" ;\
        export HNAME="$(hostname)" ;\
        sudo nixos-rebuild boot --install-bootloader ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#$HNAME               -p "$HNAME-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#generic             -p "generic-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#generic-console      -p "generic-console-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixmac182            -p "nixmac182-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixbook141           -p "nixbook141-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixbook141-office    -p "nixbook141-office-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixbook141-console   -p "nixbook141-console-$DTS" -v '';
    };
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    power-profiles-daemon.enable = true;
    thermald.enable = true;
    logind.hibernateKey = "ignore";
    opensnitch = {
      enable = false;
      settings = {
        firewall = "nftables"; # iptables or nftables
        defaultAction = "deny"; # allow or deny
      };
    };
    fstrim = {
      enable = true;
      interval = "daily";
    };
    journald.upload = {
      enable = false;
      settings = {
        Upload.URL = "https://192.168.0.250:19532";
        ServerKeyFile = "/etc/ca/client.key";
        ServerCertificateFile = "/etc/ca/client.pem";
        TrustedCertificateFile = "/etc/ca/journal-server.pem";
      };
    };
    openssh = {
      enable = false;
      allowSFTP = false;
      settings = {
        PasswordAuthentication = false;
        StrictModes = true;
        challengeResponseAuthentication = false;
      };
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey '';
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = "8022";
        }
      ];
    };
  };
}
