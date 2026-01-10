{
  description = "NixOS Configurations for ThinkPad T490 with multiple profiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };

  outputs = { self, nixpkgs, lanzaboote, nixos-hardware, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    
    # Helper function to create a complete T490 profile
    # It now correctly takes 3 arguments: name, nixosModules, and hmModules
    createT490Config = name: nixosModules: hmModules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          baseModule
          lanzaboote.nixosModules.lanzaboote
          ./modules/lanza.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.maltina = { 
              imports = [ ./home ] ++ hmModules; 
            };
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ] ++ nixosModules;
      };

    baseModule = { lib, pkgs, ... }: { 
    
      imports = [
        ./hardware-configuration.nix 
        nixos-hardware.nixosModules.lenovo-thinkpad-t490
        ./modules/fonts.nix
      ];

      # Bootloader settings
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Use latest kernel
      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.initrd.luks.devices."luks-48307e0b-b2fb-471a-8f6e-5e0f090bf1b1".device = "/dev/disk/by-uuid/48307e0b-b2fb-471a-8f6e-5e0f090bf1b1";

      networking.networkmanager.enable = true;
      time.timeZone = "Europe/Berlin";
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };

      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      services.xserver.xkb = {
        layout = "de";
        variant = "nodeadkeys";
      };

      console.keyMap = "de-latin1-nodeadkeys";
      services.printing.enable = true;

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      users.users.maltina = {
        isNormalUser = true;
        description = "Maltina Bassse";
        extraGroups = [ "networkmanager" "wheel" ];
      };

      programs.firefox.enable = true;
      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        signal-desktop
        fluffychat
      ];

      system.stateVersion = "25.05";

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
    };

  in {
    nixosConfigurations = {

      # 1. Development Profile
      # Note: vscode and nvchad are now both inside the third argument (the HM module list)
      "thinkpad-development" = createT490Config "Development" 
        [ ./hosts/thinkpad-t490/development.nix ]
        [ 
          ./home/modules/vscode.nix 
          ./home/modules/nvchad.nix 
        ];

      # 2. Test Profile
      "thinkpad-test" = createT490Config "Test" 
        [ ./hosts/thinkpad-t490/test.nix ]
        [ ];

      # 3. Media Profile
      "thinkpad-media" = createT490Config "Media" 
        [ ./hosts/thinkpad-t490/media.nix ]
        [ ];
    };
  };
}
