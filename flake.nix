{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

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
    neovide-src = {
      url = "github:neovide/neovide";
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
      transitiveInputs = with builtins; s:
        let
          ls = attrValues (if hasAttr "inputs" s then s.inputs else { });
        in
        if length ls == 0 then [ ] else ls ++ concatLists (map transitiveInputs ls);
    in
    rec {
      nixosConfigurations = {
        pca-xps15 = build [ ./machines/xps-15.nix ];
        pca-pc = build [ ./machines/pc.nix ];
        template = build [({pkgs, ...}: {
          networking.hostName = "template";
          # some random fs setting to make it build
          fileSystems."/" = {
            device = "/dev/disk/by-label/root";
            fsType = "btrfs";
          };
          system.stateVersion = "22.11";
        })];
        barebone = build [
          (_: {
            networking.hostName = "pca-vm";
            imports = [ ./hardware-configuration.nix ];
            system.stateVersion = "22.11";
            # disable microcode update, or we will need internet
            hardware.cpu = {
              intel.updateMicrocode = false;
              amd.updateMicrocode = false;
            };
          })
        ];
      };

      # qemu test
      # seems this is not enough
      packages."x86_64-linux".default = with builtins; let
        ins = (filter (s: isAttrs s)) (transitiveInputs self);
      in
      (nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self;
          buildDerivation = nixosConfigurations.template.config.system.build.toplevel;
          flakeInputs = ins;
        };
        modules = [ ./installer-configuration.nix ];
      }).config.system.build.isoImage;
    };
}
