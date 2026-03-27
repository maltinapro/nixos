{ pkgs, ... }:

{
  # Install pinentry for GPG passphrase prompts in GNOME
  home.packages = with pkgs; [
    pinentry-gnome3
  ];

  # Set the variables that tell SSH to use the GNOME Keyring agent
  home.sessionVariables = {
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    SSH_ASKPASS = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  # Create a user-level service to add the key once when you log in
  systemd.user.services.ssh-key-add = {
    Unit = {
      Description = "Automatically add SSH key to agent";
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = [
        "SSH_AUTH_SOCK=%t/keyring/ssh"
        "SSH_ASKPASS=${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
        "SSH_ASKPASS_REQUIRE=force"
        "DISPLAY=:0"
      ];
      ExecStartPre = "${pkgs.coreutils}/bin/test -f %h/.ssh/id_ed25519";
      ExecStart = "${pkgs.openssh}/bin/ssh-add %h/.ssh/id_ed25519";
      RemainAfterExit = true;
    };
  };
}
