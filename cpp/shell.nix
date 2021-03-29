{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = (
    with pkgs;
    [
      clang_9
      gcc
      ccls
      cmake
      gnumake
      lld
      cargo-flamegraph
      clang-tools
      llvmPackages.bintools
      linuxPackages.perf
      (
        python38.withPackages
          (
            ps: with ps; [ compiledb ]
          )
      )
    ]
  );
  CCLS_PATH = "${pkgs.ccls}/bin/ccls";
}
