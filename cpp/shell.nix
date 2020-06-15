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
