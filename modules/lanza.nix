{pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # For debugging and troubleshooting Secure Boot.
    sbctl
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    # Each generation stores its own kernel and initrd on the small /boot partition
    configurationLimit = 5;
    autoGenerateKeys.enable = true;
    autoEnrollKeys.enable = true;
    autoEnrollKeys.autoReboot = true;
  };
}
