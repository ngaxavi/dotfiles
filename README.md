# Settings for my work environment

## Link
```sh
cd dotfiles
stow .
```

# Run Nix Darwin

```sh
nix run nix-darwin -- switch --flake ~/.config/nix#mini
darwin-rebuild switch --flake ~/.config/nix#mini
```

