{ pkgs ? import <nixpkgs> {}, pkgs-unstable ? import <nixpkgs-unstable> {} }:
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
