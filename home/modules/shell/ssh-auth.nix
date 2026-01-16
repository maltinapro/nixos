{ pkgs, ... }:

{
  # Install the necessary GUI tools for the user
  home.packages = with pkgs; [
    seahorse       # For managing keys visually
    pinentry-gnome3
  ];

  # Set the variables that tell Git and SSH to use the GNOME Keyring
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
      ExecStart = "${pkgs.openssh}/bin/ssh-add %h/.ssh/id_ed25519";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/test -f %h/.ssh/id_ed25519";
    };
  };
}
