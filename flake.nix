{
  description = "Home Manager configuration of pca006132";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    cmp-copilot-src = {
      url = "github:hrsh7th/cmp-copilot";
      flake = false;
    };
    alpha-nvim-src = {
      url = "github:goolord/alpha-nvim";
      flake = false;
    };
    monokai-nvim-src = {
      url = "github:tanvirtin/monokai.nvim";
      flake = false;
    };
    rust-tools-nvim-src = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };
  };

  outputs =
    { home-manager
    , nixpkgs
    , nixpkgs-unstable
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "pca006132";
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    in
    {
      homeConfigurations.${username} =
        home-manager.lib.homeManagerConfiguration {
          # Specify the path to your home configuration here
          configuration = import ./config.nix {
            inherit pkgs pkgs-unstable inputs;
          };

          inherit system username;
          homeDirectory = "/home/${username}";
          # Update the state version as needed.
          # See the changelog here:
          # https://nix-community.github.io/home-manager/release-notes.html#sec-release-21.05
          stateVersion = "21.11";
        };
    };
}
