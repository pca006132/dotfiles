{ pkgs ? import <nixpkgs> {} }:
with pkgs;
mkShell {
  buildInputs = [
    (python38.withPackages(ps: with ps; [
      virtualenv
    ]))
    stdenv.cc.cc.lib
  ];

  # libstdc++.so.6 and CUDA
  shellHook = ''
    export LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib/:/run/opengl-driver/lib:$LD_LIBRARY_PATH
  '';
}
