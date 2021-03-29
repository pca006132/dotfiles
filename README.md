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
### CUDA
Set the `LD_LIBRARY_PATH` to include opengl-driver:
```nix
export LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib/:/run/opengl-driver/lib:$LD_LIBRARY_PATH
```
