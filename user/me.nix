{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        description = "minimal-env-admin";
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7";
        uid = 1000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = ["wheel" "networkmanager" "video" "docker" "libvirt"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    users = {
      me = {
        home = {
          stateVersion = "24.05";
          username = "me";
          homeDirectory = "/home/me";
          keyboard = {
            layout = "us,de";
          };
          shellAliases = {
            e = "vim";
            cat = "bat --paging=never";
            bandwhich = "sudo bandwhich";
            powertop = "sudo powertop";
            man = "batman";
            ll = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
            la = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
            lt = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
            lo = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
            li = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
          };
          sessionVariables = {
            EDITOR = "vim";
            VISUAL = "vim";
            PAGER = "bat";
            SHELLCHECK_OPTS = "-e SC2086";
          };
          file = {".config/starship.toml".source = ./res/starship/gruvbox-rainbow.toml;};
          packages = with pkgs; [bandwhich dust hyperfine tldr shellsheck shfmt vulnix];
        };
        fonts.fontconfig.enable = true;
        programs = {
          direnv.enable = true;
          fzf.enable = true;
          thefuck.enable = true;
          starship.enable = true;
          go.enable = true;
          gh.enable = true;
          gitui.enable = true;
          home-manager.enable = true;
          ripgrep.enable = true;
          zoxide.enable = true;
          bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch prettybat];
          };
          eza = {
            enable = true;
            git = true;
            icons = true;
            extraOptions = ["--group-directories-first" "--header"];
          };
          fd = {
            enable = true;
            extraOptions = ["--absolute-path" "--no-ignore"];
          };
          git = {
            enable = true;
            userName = "PAEPCKE, Michael";
            userEmail = "git@github.com";
          };
          vim = {
            enable = true;
            defaultEditor = true;
            plugins = with pkgs.vimPlugins; [vim-shellcheck vim-go vim-git];
            settings = {
              expandtab = true;
              history = 1000;
            };
            extraConfig = ''
              set nocompatible
              set nobackup '';
          };
          zsh = {
            enable = true;
            autocd = true;
            autosuggestion.enable = true;
            defaultKeymap = "viins";
            syntaxHighlighting.enable = true;
            historySubstringSearch.enable = true;
            history = {
              extended = true;
              ignoreSpace = true;
              share = true;
            };
          };
        };
      };
    };
  };
}
