{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, vscode-server }: {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        vscode-server.nixosModules.default
        ({ config, pkgs, ... }: {
          boot = {
            loader = {
              efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = "/boot";
              };
              grub = {
                enable = true;
                devices = [
                  "/dev/nvme0n1"
                  "/dev/nvme1n1"
                ];
                efiSupport = true;
                mirroredBoots = [
                  {
                    devices = [
                      "/dev/nvme0n1"
                    ];
                    path = "/mnt/boot";
                  }
                  {
                    devices = [
                      "/dev/nvme1n1"
                    ];
                    path = "/mnt/boot2";
                  }
                ];
              };
            };
            initrd.availableKernelModules = [ "nvme" ];
          };

          fileSystems = {
            "/" = {
              device = "/dev/disk/by-label/root";
              fsType = "btrfs";
              options = [ "compress=zstd" "noatime" ];
            };
            "/boot" = {
              device = "/dev/disk/by-label/ESP";
              fsType = "vfat";
            };
            "/boot2" = {
              device = "/dev/disk/by-label/ESP2";
              fsType = "vfat";
            };
          };

          networking = {
            hostName = "server";
            useDHCP = true;
          };

          nix = {
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
            settings.experimental-features = [ "nix-command" "flakes" ];
          };

          nixpkgs.config = {
            allowUnfree = true;
          };

          services = {
            openssh = {
              enable = true;
              settings.PermitRootLogin = "prohibit-password";
            };
            vscode-server.enable = true;
          };

          environment.systemPackages = with pkgs; [
            curl
            git
            vim
          ];

          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOv4SpIhHJqtRaYBRQOin4PTDUxRwo7ozoQHTUFjMGLW avunu@AvunuCentral"
          ];

          system.stateVersion = "24.05";
        })
      ];
    };
  };
}
