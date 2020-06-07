{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = (
    with pkgs;
    [
      pulseview
      gcc-arm-embedded
    ]
  );
}
