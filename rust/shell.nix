{ pkgs-unstable ? import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {}
, mozillaOverlay ? import (fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz)
, pkgs ? import <nixpkgs> { overlays = [ mozillaOverlay ]; }
}:
pkgs.mkShell {
  buildInputs = (
    with pkgs.rustPlatform.rust;
    [
      rustc
      cargo
    ]
  )
  ++ (with pkgs; [ rls rustracer rustfmt gdb ])
  ++ (with pkgs-unstable; [ rust-analyzer ]);
  # Set Environment Variables
  RUST_BACKTRACE = 1;
  RUST_ANALYZER_PATH = "${pkgs-unstable.rust-analyzer}/bin/rust-analyzer";
}
