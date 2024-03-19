{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-alien.url = "github:thiagokokada/nix-alien";
    my-nvim = {
      url = "path:./nvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emanote.url = "github:srid/emanote";
    rime-ice = {
      url = "github:iDvel/rime-ice";
      flake = false;
    };
    librime-lua = {
      url = "github:hchunhui/librime-lua";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , my-nvim
    , nix-alien
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      build = modules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit self inputs; };
        modules = [
          ./modules/nvidia.nix
          ./modules/laptop-powermanagement.nix
          ./modules/defaults.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              users.pca006132 = import ./home.nix;
              extraSpecialArgs = { inherit inputs; };
            };
          }
          ({ ... }: {
            config = {
              environment.etc."nix/channels/nixpkgs".source = inputs.nixpkgs.outPath;
              environment.etc."nix/channels/nixpkgs-unstable".source = inputs.nixpkgs-unstable.outPath;
              nix.nixPath = [
                "nixpkgs=/etc/nix/channels/nixpkgs"
                "nixpkgs-unstable=/etc/nix/channels/nixpkgs-unstable"
              ];
            };
          })
        ] ++ modules;
      };
    in
    {
      nixosConfigurations = {
        pca-xps15 = build [ ./machines/xps-15.nix ];
        pca-pc = build [ ./machines/pc.nix ];
      };
    };
}
