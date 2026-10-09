{
  description = "Personal nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
          # Basic pkgs
          vim
          tmux
          git
          karabiner-elements

          # Security tools
          nmap
          lldb
          #gdb
          qemu

          # Rust CLI tools
          bat         # cat replacement
          bottom      # graphical proc/sys monitor
          dust        # du replacement
          eza         # ls replacement
          fd          # find replacement
          delta       # syntax-highlighter
          hexyl       # hex viewer
          hyperfine   # benchmarking tool
          #lxtrace     # linux system call tracer, similar to strace
          procs       # ps replacement
          ripgrep     # grep replacement
          sd          # sed replacement
          starship    # cross-shell prompt
          tealdeer    # help page fetcher
          tokei       # displays code stats
          zoxide      # cd replacement
          
          # Languages
          rustc
          cargo
          rustfmt
          clippy
          python3

      ];

      programs.zsh = {
          enable = true;

          # Setup shell with:
          #   - case-insensitive completion
          #   - fuzzy completion
          #   - prefix-based history search
          interactiveShellInit = ''
              eval "$(starship init zsh)"
              eval "$(zoxide init zsh)"

              zmodload -i zsh/complist
              WORDCHARS=\'\'

              unsetopt menu_complete
              unsetopt flowcontrol
              setopt auto_menu
              setopt complete_in_word
              setopt always_to_end

              zstyle ':completion:*:*:*:*:*' menu select
              zstyle ':completion:*' matcher-list \
                'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
                'r:|=*' \
                'l:|=* r:|=*'
              zstyle ':completion:*' special-dirs true

              # Enable prefix-based search
              autoload -Uz up-line-or-beginning-search
              autoload -Uz down-line-or-beginning-search

              zle -N up-line-or-beginning-search
              zle -N down-line-or-beginning-search

              bindkey '^[[A' up-line-or-beginning-search
              bindkey '^[[B' down-line-or-beginning-search
          '';
      }; 

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Test config options to enabled TouchID for sudo
      security.pam.services.sudo_local = {
          touchIdAuth = true;
          reattach = true;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#dotfiles
    darwinConfigurations."dotfiles" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
