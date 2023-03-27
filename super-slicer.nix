{ pkgs ? import <nixpkgs> { }, }:

let name = "super-slicer";
in
pkgs.appimageTools.wrapType2 {
  name = name;
  src = builtins.fetchurl {
    url = "https://github.com/supermerill/SuperSlicer/releases/download/2.5.59.2/SuperSlicer-ubuntu_18.04-2.5.59.2.AppImage";
    sha256 = "0ipd19d2k0yplrk8d9v6j7w38wy1w190fk4vc7y1cm22d56qcl4b";
  };
}

