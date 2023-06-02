{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    neovide-src = {
      url = "github:neovide/neovide/new-keyboard-v3";
      flake = false;
    };
    my-nvim = {
      url = "./nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , my-nvim
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}";
      build = modules: nixpkgs.lib.nixosSystem {
        inherit system;
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
              nix.nixPath = [
                "nixpkgs=/etc/nix/channels/nixpkgs"
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
