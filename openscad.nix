{ pkgs ? import <nixpkgs> { }, }:

let name = "openscad";
in
pkgs.appimageTools.wrapType2 {
  name = name;
  src = builtins.fetchurl {
    url = "https://output.circle-artifacts.com/output/job/48f63e84-44ad-4aa5-9d8d-aae50d0e23d9/artifacts/0/64-bit/OpenSCAD-2023.03.18.ai13977_PR4533-x86_64.AppImage";
    sha256 = "0f6jrlh1r3s9gff755gbg24gdjghhnq7fb2qp15lbfykv7qvi0sp";
  };
}


