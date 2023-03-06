{ pkgs ? import <nixpkgs> { }, }:

let name = "prusa-slicer";
in
pkgs.appimageTools.wrapType2 {
  name = name;
  src = builtins.fetchurl {
    url = "https://github.com/prusa3d/PrusaSlicer/releases/download/version_2.6.0-alpha3/PrusaSlicer-2.6.0-alpha3+linux-x64-GTK3-202302031527.AppImage";
    sha256 = "1b9dmxsv0yl7xgmllrlqn9540n69pqabj5qvkmn0nih9snxg0v8j";
  };
}

