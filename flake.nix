{
  # description = "Home Manager configuration of pca006132";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lspkind-src = {
      url = "github:onsails/lspkind.nvim";
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
    tabout-nvim-src = {
      url = "github:abecodes/tabout.nvim";
      flake = false;
    };
    knap-nvim-src = {
      url = "github:frabjous/knap";
      flake = false;
    };
    session-manager-src = {
      url = "github:Shatur/neovim-session-manager";
      flake = false;
    };
  };

  outputs =
    { home-manager
    , nixpkgs
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "pca006132";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      homeConfigurations.${username} =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            {
              home = {
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "22.05";
              };
            }
            (import ./config.nix { inherit inputs; })
            (import ./nvim/config.nix { inherit inputs; })
          ];
        };
    };
}
