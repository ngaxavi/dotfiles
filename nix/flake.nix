{
  description = "Mac Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
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
          pkgs.jdk21_headless
          pkgs.jdk17_headless
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
        ];

      services.nix-daemon.enable = true; 

      homebrew = {
        enable = true;
        brews = [
          "fisher"
        ];
        casks = [
          "firefox"
          "appcleaner"
          "brave-browser"
          "font-jetbrains-mono-nerd-font"
          "stats"
          "visual-studio-code"
          "jetbrains-toolbox"
          "docker"
          "microsoft-teams"
        ];
        masApps = {
          "Windows App" = 1295203466;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };
	
     # fonts.packages = [
      #	pkgs.nerdfonts.jetbrains-mono
      #];	
      nixpkgs.config.allowUnfree = true;

      system.defaults = {
        dock.autohide = true;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
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
