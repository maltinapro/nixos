{ pkgs, ... }:

{
  system.nixos.label = "development";
  networking.hostName = "maltinas-thinkpad-t490-dev";
  
  # Development Tools and Environments
  environment.systemPackages = with pkgs; [
    google-chrome
    git
    nodejs
    python3
    go
    tmux
    htop
    dbeaver-bin
    #rust
    rustc
    cargo
    rustlings
    rust-analyzer
    gcc
    pkg-config
    openssl
  ];

  # Set up environment variables for OpenSSL to work with Rust builds
  environment.variables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    OPENSSL_DIR = "${pkgs.openssl.dev}";
    LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [ pkgs.openssl ]}";
  };
  
  # Docker and Virtualization
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "user" ];
}
