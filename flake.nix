{
  description = "Home Manager configuration of pca006132";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { home-manager, nixpkgs, nixpkgs-unstable, neovim-nightly-overlay, ... }:
    let
      system = "x86_64-linux";
      username = "pca006132";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        # Specify the path to your home configuration here

        configuration = import ./config.nix { inherit pkgs pkgs-unstable neovim-nightly-overlay; };

        inherit system username;
        homeDirectory = "/home/${username}";
        # Update the state version as needed.
        # See the changelog here:
        # https://nix-community.github.io/home-manager/release-notes.html#sec-release-21.05
        stateVersion = "21.11";
      };
    };
}
