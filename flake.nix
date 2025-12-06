{
  description = "NixOS Configurations for ThinkPad T490 with multiple profiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }:
  let
    system = "x86_64-linux";
    
    # Helper function to create a complete T490 profile
    createT490Config = name: modules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          baseModule
        ] ++ modules;
      };

    # baseModule accepts pkgs, lib, and config
    baseModule = { lib, config, pkgs, ... }: { 
    
      imports = [
        ./hardware-configuration.nix 
        (nixos-hardware.nixosModules.lenovo-thinkpad-t490)
      ];

      config = {

        # --- Global System Settings ---
        time.timeZone = "Europe/Berlin";

        # Locale and i18n settings 
        i18n.defaultLocale = "en_US.UTF-8";
        i18n.extraLocaleSettings = {
          LC_ADDRESS = "de_DE.UTF-8"; LC_IDENTIFICATION = "de_DE.UTF-8";
          LC_MEASUREMENT = "de_DE.UTF-8"; LC_MONETARY = "de_DE.UTF-8";
          LC_NAME = "de_DE.UTF-8"; LC_NUMERIC = "de_DE.UTF-8";
          LC_PAPER = "de_DE.UTF-8"; LC_TELEPHONE = "de_DE.UTF-8";
          LC_TIME = "de_DE.UTF-8";
        };

        # Keyboard Layout (Working QWERTZ)
        services.xserver.xkb.layout = "de";
        services.xserver.xkb.variant = "nodeadkeys";
        console.keyMap = "de";

        networking.networkmanager.enable = true;


        # --- BOOTLOADER CONFIGURATION ---
        boot.loader.systemd-boot.enable = true;
        boot.loader.grub.enable = false; 


        # --- XFCE Desktop Configuration ---
        services.xserver = {
          enable = true;
          desktopManager = {
            xfce = {
              enable = true;
            };
          };
        };
        
        # Power management via UPower
        services.upower.enable = true;

        # Sound & Pipewire
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true;
        };

        # --- BLUETOOTH CONFIGURATION ---
        hardware.bluetooth.enable = true;
        services.blueman.enable = true;
        # -----------------------------------------------------------------

        # --- PACKAGES ---
        environment.systemPackages = with pkgs; [
          acpi 
          upower 
          vim 
          blueman 
        ];

        programs.firefox.enable = true; 
        nixpkgs.config.allowUnfree = true;

        users.users.maltina = {
          isNormalUser = true;
          description = "Maltina Basse";
          extraGroups = [ "wheel" "networkmanager" "lp" ]; 
        };

        system.stateVersion = "24.11";

        nix.extraOptions = ''
          experimental-features = nix-command flakes
        ''; 
      }; # END OF 'config' ATTRIBUTE
    }; # END OF baseModule


  in {

    nixosConfigurations = {

      # 1. Development Profile
      "thinkpad-development" = createT490Config "Development" [ ./hosts/thinkpad-t490/development.nix ];

      # 2. Test Profile
      "thinkpad-test" = createT490Config "Test" [ ./hosts/thinkpad-t490/test.nix ];

      # 3. Media Profile
      "thinkpad-media" = createT490Config "Media" [ ./hosts/thinkpad-t490/media.nix ];

    };

  };
}

