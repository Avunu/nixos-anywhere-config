{
  modulesPath,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
  ];

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

  networking.useDHCP = true;

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

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOv4SpIhHJqtRaYBRQOin4PTDUxRwo7ozoQHTUFjMGLW avunu@AvunuCentral"
  ];

  system.stateVersion = "24.05";
}
