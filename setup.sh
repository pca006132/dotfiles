#!/usr/bin/env bash

echo "{ allowUnfree = true; }" > "/home/$USER/.config/nixpkgs/config.nix"

cat <<EOM >/home/$USER/.config/nixpkgs/home.nix
{ pkgs, ... }:
let
  username = "$USER";
in
  {
    home = {
      username = username;
      homeDirectory = "/home/\${username}";
    };

    imports = [
      (import "$(pwd)/config.nix" { pkgs } )
    ];
  }
EOM
