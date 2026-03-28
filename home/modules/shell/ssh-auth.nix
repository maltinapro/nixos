{ pkgs, ... }:

{
  # Point SSH at the GNOME Keyring agent
  # SSH_ASKPASS is intentionally NOT set here — in a terminal, SSH can
  # prompt on the TTY.  The systemd service below supplies its own
  # SSH_ASKPASS for the headless (no-TTY) context.
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
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
