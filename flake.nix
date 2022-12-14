{
  description = "Bootstrap digitalocean JSNA NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:

    let
      hostname = "nixos";
    in

    {

      nixosConfigurations.DO = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ];
      };

      homeConfigurations = {
        david = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/david";
          username = "david";
          stateVersion = "22.05";
          configuration = { config, pkgs, ... }:
            let
              overlay-unstable = final: prev: {
                unstable = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
              };
            in
            {
              nixpkgs.overlays = [ overlay-unstable ];
              nixpkgs.config = {
                allowUnfree = true;
                allowBroken = true;
              };

              imports = [
                ./home.nix
              ];
            };
        };


      };
          david = self.homeConfigurations.david.activationPackage;
          defaultPackage.x86_64-linux = self.david;
    };
}
