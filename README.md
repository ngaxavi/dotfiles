# Settings for my work environment

## Link
```sh
cd dotfiles
stow .
```

# Run Nix Darwin

```sh
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake "$(readlink -f ~/.config/nix)#mini"

darwin-rebuild switch --flake "$(readlink -f ~/.config/nix)#mini"
```

