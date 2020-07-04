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
The `setup.sh` would setup the nix scripts for home-manager,
handle user name etc. Note that this scripts has to be run in its own directory,
without symlink, as it uses `pwd` to print the path to `config.nix`. While other
more sophisticated solutions exist, I just want to keep it simple.

Setup the channels and config as follow:
```bash
nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
# It is recommended to use 20.03, as some modules in home-manager only support
# 20.03.
nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
# Unstable channel is needed for some packages, especially vim plugins.
nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
# Setup the `home.nix` config, you should edit it if needed.
./setup.sh
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

The following compose function is made to allow the retreiving of environment
variables defined in other scripts.
```nix
{ pkgs, ...}:
let
  # clean the unwanted attributes
  # this would not be stable as I just got it from `nix repl`.
  clean = (
    p: removeAttrs p
      [ "__ignoreNulls" "all" "args" "buildInputs" "builder" "configureFlags"
      "depsBuildBuild" "depsBuildBuildPropagated" "depsBuildTarget"
      "depsBuildTargetPropagated" "depsHostHost" "depsHostHostPropagated"
      "depsTargetTarget" "depsTargetTargetPropagated" "doCheck" "doInstallCheck"
      "drvAttrs" "drvPath" "meta" "name" "nativeBuildInputs" "nobuildPhase"
      "out" "outPath" "outputName" "outputUnspecified" "outputs" "overrideAttrs"
      "passthru" "patches" "phases" "propagatedBuildInputs"
      "propagatedNativeBuildInputs" "shellHook" "stdenv" "strictDeps" "system"
      "type" "userHook" ]);
  compose = (
    attr: (
      pkgs.mkShell
        (
          builtins.foldl'
            (a: b: a // clean b)
            attr
            attr.inputsFrom
        )
    )
  );
in
pkgs.mkShell {
    inputsFrom = [
        ( import ./rust/shell.nix {} )
        ( import ./embedded/shell.nix {} )
    ];
}
```
