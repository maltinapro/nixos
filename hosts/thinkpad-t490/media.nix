{ pkgs, ... }:

{
  networking.hostName = "t490-media";

  # Desktop Environment: GNOME
  services.xserver.enable = true;
  # GNOME requires GDM (Gnome Display Manager)
  services.xserver.displayManager.gdm.enable = true; 
  services.desktopManager.gnome.enable = true;

  # Media and Graphics Software
  environment.systemPackages = with pkgs; [
    google-chrome
    vlc
    mpv
    gimp
    inkscape
    blender
    kdenlive 
    spotify
  ];

  # Sound System (PipeWire)
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire.enable = true;
  
  # Hardware Acceleration for Intel GPU
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver 
    vaapiVdpau
  ];
}
