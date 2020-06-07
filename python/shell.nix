{ pkgs ? import <nixpkgs> {}, pkgs-unstable ? import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {} }:
pkgs.mkShell {
  buildInputs = [
    (pkgs-unstable.python38.withPackages
    (
      ps: with ps; [
        numpy
        scipy
        matplotlib
        regex
        jupyter
        ipython
        opencv3
        compiledb
        jedi
        jsbeautifier
      ]
    ))
  ];
}
