{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = (
    with pkgs;
    [
      adoptopenjdk-bin
      maven
      scala
      sbt
      kotlin
      android-studio
      jetbrains.idea-community
    ]
  );
}
