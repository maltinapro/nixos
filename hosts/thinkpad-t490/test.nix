{ pkgs, ... }:

{
  system.nixos.label = "test";
  networking.hostName = "maltinas-thinkpad-t490-test";

  # Test and Analysis Tools
  environment.systemPackages = with pkgs; [
    google-chrome
    curl
    wget
    strace 
    perf   
    wireshark 
    brave
  ];
  
  # Networking and Security
  networking.firewall.enable = true;
  
  # Automatic Garbage Collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
}
