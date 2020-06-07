{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = (
    with pkgs;
    [
      texlive.combined.scheme-full
    ]
  );
}
