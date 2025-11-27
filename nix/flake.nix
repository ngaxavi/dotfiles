{
  description = "Mac Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # nix-homebrew.url = "git+https://github.com/zhaofengli/nix-homebrew?ref=refs/pull/71/merge";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
	        pkgs.neovim
	        pkgs.alacritty
          pkgs.fish
          pkgs.starship
          pkgs.maven
          pkgs.gradle
          pkgs.httpie
          pkgs.jq
          pkgs.k3sup
          pkgs.kubectx
          pkgs.kubectl
          pkgs.magic-wormhole
          pkgs.jdk17_headless
          pkgs.jdk21_headless
          pkgs.jdk23_headless
          pkgs.jdk
          pkgs.sops
          pkgs.protobuf
          pkgs.python312Packages.python
          pkgs.rustup
          pkgs.velero
          pkgs.wget
          pkgs.yq
          pkgs.go
          pkgs.go-task
          pkgs.age
          pkgs.awscli2
          pkgs.kubernetes-helm
          pkgs.git
          pkgs.sshs
          pkgs.bat
          pkgs.fzf
          pkgs.eza
          # pkgs.thefuck
          # pkgs.terraform
        ];

      nix.enable = false; 

      homebrew = {
        enable = true;
        taps = [
          "dashlane/tap"
          "goreleaser/tap"
        ];
        brews = [
          "stow"
          "ykman"
          "libfido2"
          "gnupg"
          "openssl@3"
          "nvm"
          "curlie"
          "xh"
          "pinentry-mac"
          "cloudflared"
          "dashlane-cli"
          "goreleaser"
          "thefuck"
          "terraform"
          "temporal"
          "k9s"
          "lazygit"
        ];
        casks = [
          "ghostty"
          "yubico-yubikey-manager"
          "appcleaner"
          "google-chrome"
          "brave-browser"
          "font-jetbrains-mono-nerd-font"
          "stats"
          "visual-studio-code"
          "jetbrains-toolbox"
          "docker-desktop"
          "microsoft-teams"
          "logi-options+"
          "obsidian"
          "notion"
          "warp"
          "signal"
          "spotify"
          "discord"
          "slack"
          "rectangle"
          "balenaetcher"
          "tableplus"
          "microsoft-azure-storage-explorer"
        ];
        masApps = {
          "Windows App" = 1295203466;
          "CopyClip" = 595191960;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Set fish as the default shell
      users.knownUsers = [ "ngaxavi" ];
      users.users.ngaxavi.uid = 501;
      users.users.ngaxavi.shell = pkgs.fish;
	
     # fonts.packages = [
      #	pkgs.nerdfonts.jetbrains-mono
      #];	
      nixpkgs.config.allowUnfree = true;

      system.defaults = {
        dock.autohide = true;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
      };

      system.primaryUser = "ngaxavi";

      # https://samasaur1.github.io/blog/jdks-on-nix-darwin
      system.activationScripts.extraActivation.text = ''
        ln -sf "${pkgs.jdk17_headless}/zulu-17.jdk" "/Library/Java/JavaVirtualMachines/"
        ln -sf "${pkgs.jdk21_headless}/zulu-21.jdk" "/Library/Java/JavaVirtualMachines/"
        ln -sf "${pkgs.jdk23_headless}/zulu-23.jdk" "/Library/Java/JavaVirtualMachines/"
      '';

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mini" = nix-darwin.lib.darwinSystem {
      modules = [	 
      	configuration
	      mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
             # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

               # User owning the Homebrew prefix
            user = "ngaxavi";

            autoMigrate = true;
          };
        }

      ];
    };
  };
}
