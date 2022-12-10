{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

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
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}";
      build = modules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            inherit (pkgs.stdenv.targetPlatform) system;
            config.allowUnfree = true;
          };
        };
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
        ] ++ modules;
      };
    in
    rec {
      nixosConfigurations = {
        pca-xps15 = build [ ./machines/xps-15.nix ];
        pca-pc = build [ ./machines/pc.nix ];
        barebone = build [
          (_: {
            networking.hostName = "pca-vm";
            imports = [ ./hardware-configuration.nix ];
            system.stateVersion = "22.11";
          })
        ];
      };

      # qemu test
      packages."x86_64-linux".default = (nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self;
          baseSystem = nixosConfigurations.pca-xps15;
        };
        modules = [ ./installer-configuration.nix ];
      }).config.system.build.isoImage;
    };
}
