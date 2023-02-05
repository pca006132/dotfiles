{ pkgs ? import <nixpkgs> { }, }:

let name = "super-slicer";
in
pkgs.appimageTools.wrapType2 {
  name = name;
  src = builtins.fetchurl {
    url = "https://github.com/supermerill/SuperSlicer/releases/download/2.5.59.0/SuperSlicer-ubuntu_18.04-2.5.59.0.AppImage";
    sha256 = "0zaijqhcq72i3r46xjdc11bx5c72silc7bbrnbr11jbmb6i49imf";
  };
}

