# Commands reminder

## Packager Manager 

create nix.conf folder at $HOME/.config/nix
```nix
experimental-features = nix-command flakes
```

Create flake file
```nix
nix flake init
```

Check info
```nix
nix flake metadata
```

Update nix flake lock file
```nix
nix flake update --recreate-lock-file
```