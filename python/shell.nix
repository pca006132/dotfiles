{ pkgs ? import <nixpkgs> {}, pkgs-unstable ? import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {} }:
pkgs.mkShell {
  buildInputs = [
    pkgs-unstable.python38
  ];
  shellHook = ''
    python -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
  '';
}
