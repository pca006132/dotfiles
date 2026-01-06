{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-alien.url = "github:thiagokokada/nix-alien";
    my-nvim = {
      url = "path:./nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rime-ice = {
      url = "github:iDvel/rime-ice";
      flake = false;
    };
    rime-3gram = {
      url = "https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , my-nvim
    , nix-alien
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "dotnet-runtime-6.0.428"
          ];
        };
      };
      build = modules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit self inputs pkgs-unstable;
        };
        modules = [
          ./modules/nvidia.nix
          ./modules/laptop-powermanagement.nix
          ./modules/defaults.nix
          inputs.musnix.nixosModules.musnix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              users.pca006132 = import ./home.nix;
              extraSpecialArgs = { inherit inputs pkgs-unstable; };
            };
          }
          ({ ... }: {
            config = {
              environment.etc."nix/channels/nixpkgs".source = nixpkgs.outPath;
              environment.etc."nix/channels/nixpkgs-unstable".source = nixpkgs-unstable.outPath;
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
        pca-workstation = build [ ./machines/workstation.nix ];
      };
    };
}
