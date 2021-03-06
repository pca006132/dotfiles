{ mozillaOverlay ? import (fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz)
, targets ? []
, pkgs-unstable ? import <nixpkgs-unstable> {}
, pkgs ? import <nixpkgs> { overlays = [ mozillaOverlay ]; }
}:
pkgs.mkShell ({
  buildInputs = (
    [
      (
        (pkgs.rustChannelOf { channels = "nightly"; }).rust.override {
          inherit targets;
        }
      )
    ]
  )
  ++ (with pkgs; [ rls rustracer rustfmt])
  ++ (with pkgs-unstable; [ rust-analyzer ]);
  # Set Environment Variables
  RUST_BACKTRACE = 1;
  RUST_ANALYZER_PATH = "${pkgs-unstable.rust-analyzer}/bin/rust-analyzer";
})
