{ pkgs }:
let
  inherit (pkgs) lib buildEnv;
  pkgs-unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
in
{
  allowUnfree = true;
  packageOverrides = pkgs: {
    devEnv = lib.lowPrio (buildEnv {
      name = "dev-env";
      ignoreCollisions = true;
      paths = with pkgs; [
        # Rust
        rustc cargo rls pkgs-unstable.rust-analyzer rustracer
        # C/C++
        gcc clang ccls cmake gnumake
        # Java
        adoptopenjdk-bin maven
        # Misc
        gdb emacs (python3.withPackages(ps: with ps; [ numpy scipy matplotlib regex])) 
        python37Packages.jsbeautifier nixfmt
        material-design-icons 
      ];
    });
    # WIP
    embeddedEnv = lib.lowPrio (buildEnv {
      name = "embedded-env";
      ignoreCollisions = true;
      paths = with pkgs; [
        openocd
      ];
    });
  };
}
