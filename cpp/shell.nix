{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = (
    with pkgs;
    [
      clang_9
      ccls
      cmake
      gnumake
      lld
      clang-tools
      llvmPackages.bintools
    ]
  );
}
