# Nixos config for my Devices

All thanks for **_MatthiasBenaets_** for providing [dotfiles](https://github.com/MatthiasBenaets/nixos-config) and [video](https://www.youtube.com/watch?v=AGVXJ-TIv3Y) for getting started with nixos.

---

## NixOS package manager

---

### Installation (assuming host config already exists)

```sh
# Install nix (single-user installation)
sh <(curl -L https://nixos.org/nix/install) --no-daemon

```

```sh
# Activate nix profile (and add it to the .profile)
. ~/.nix-profile/etc/profile.d/nix.sh
echo ". $HOME/.nix-profile/etc/profile.d/nix.sh" >> ~/.profile
echo ". $HOME/.nix-profile/etc/profile.d/nix.sh" >> ~/.zprofile

# Open tempoary shell with nix and home-manager
nix-shell

# Remove nix (this is necessary, so home-manager can install nix)
nix-env -e nix

# Install the configuration
home-manager switch --flake .#mmieszczak

# Exit temporary shell
exit

# Set zsh (installed by nix) as default shell
echo ~/.nix-profile/bin/zsh | sudo tee -a /etc/shells
usermod -s ~/.nix-profile/bin/zsh $USER

```

## NixOS System

---

```sh
# Open tempoary shell with nix and home-manager
nix-shell

# Remove nix (this is necessary, so home-manager can install nix)
nix-env -e nix
```

```sh
# All as root
HOST=...  # set host variable to use proper configuration


nix-shell
git clone https://this.repo.url/ /etc/nixos # or $HOME/.setup
cd /etc/nixos # or cd $HOME/.setup 
nixos-install -v --root /mnt --impure --flake .#$HOST
nixos-install -v --root /mnt --impure --flake .#$HOST

# Reboot

```
