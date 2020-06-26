# Rust environment setup
This setups the default rust development environment for me, and it can be
extended through supplying parameters, for example:

```nix
# First, symlink the `shell.nix` to a file like `rust.nix`,
# and write this in the `shell.nix` for that project:
{ pkgs ? import <nixpkgs> {} }:
let
  pkgInput = [
    pkgs.ccls
    pkgs.llvmPackages.bintools
    pkgs.gdb
  ];
  attributes = {
    CCLS_PATH = "${pkgs.ccls}/bin/ccls";
  };
in
(import ./rust.nix { inherit pkgInput; inherit attributes; })
```
