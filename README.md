# PCA's Configuration Files
This repo contains configuration for [NixOS](https://nixos.org/) and [Home Manager](https://github.com/rycee/home-manager).

If you don't know what are they, you really should check them out.

I am new to both systems, so there may be problems in the configuration.

* `configuration.nix`: System configuration for NixOS.
* `config.nix`: Home-manager configuration. It also contains my vim
  configuration.
* `.envrc`: file for triggering the `direnv` which setup the `nix-shell`
  environment.
* `/.*/shell.nix`: Template script for setting up the respective development
  environment.

## Usage
### Install NixOS
Install NixOS according to the [manual](https://nixos.org/nixos/manual/index.html#sec-installation), with the following additional notes:

* If you want to setup the home directory in another drive, mount it on
  `/mnt/home` before running the `nixos-generate-config` command.
  Anyway, you may also modify the `hardware-configuration.nix` if you like...
* If you want better performance, you may want to modify the
  `powerManagement.cpuFreqGovernor` option from the default `powersave` to
  `ondemand` or `performance`.
* I recommend using GRUB for boot.
  For UEFI system, you may want to set the following:
  ```nix
  {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {
      devices = [ "nodev" ];
      version = 2;
      # For Windows dual boot.
      useOSProber = true;
      enable = true;
      efiSupport = true;
    };
  }
  ```
  If errors occurred when installing the boot loader, try to set the
  `canTouchEfiVariables` to `false`, and set
  `boot.loader.grub.efiInstallAsRemovable` to `true`.

### Setup Home-Manager
First, run the `setup.sh`, which would setup the nix scripts for home-manager,
handle user name etc. Note that this scripts has to be run in its own directory,
without symlink, as it uses `pwd` to print the path to `config.nix`. While other
more sophisticated solutions exist, I just want to keep it simple.

Install Home-Manager according to the [README](https://github.com/rycee/home-manager/blob/master/README.md), basically the following commands:

```bash
nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
nix-shell '<home-manager>' -A install
```

Example `~/.config/nixpkgs/home.nix` setup:
```nix
{ pkgs, ... }:
let
  username = "pca";
in
  {
    home = {
      username = username;
      homeDirectory = "/home/${username}";
    };

    imports = [
      ( import "/home/pca/code/dotfiles/config.nix" {
        inherit pkgs;
        install-iosevka = true;
      } )
    ];
  }
```

### Setup direnv
I use `direnv` for setting up the development environments when I `cd` or `z`
into the project directory. It is managed using Home-Manager so no additional
configuration is needed.

When adding the `shell.nix`, do not forget to add the `.envrc` also. When you
`cd` into the directory later, there would be a prompt asking you to run `direnv
allow` to allow running the script. Note that in the current configuration, the
script would source all `.envrc` in parent directories.

If you modified some files such as `requirements.txt` for Python virtualenv,
`touch shell.nix` would cause the `direnv` to reload the environment and cache.

If the environment somehow breaks, such as some commands do not exist but they
do exist when you run `nix-shell` manually, try to remove the cache by `rm -rf
.direnv` and setup it again.

