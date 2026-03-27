{ pkgs, ... }:

{
  # GUI tools for managing keys
  home.packages = with pkgs; [
    seahorse          # GNOME Keyring GUI (Passwords and Keys)
  ];

  # SSH_AUTH_SOCK is set automatically by the GNOME PAM module on login.
  # SSH_ASKPASS / SSH_ASKPASS_REQUIRE are intentionally NOT set here for
  # terminal sessions — SSH will use the keyring agent silently or fall back to
  # TTY prompting, avoiding hangs when the GUI helper can't open a dialog.
  # They are set inside the systemd service below where no TTY is present.

  # Systemd user service: add SSH key to GNOME Keyring once per session
  systemd.user.services.ssh-key-add = {
    Unit = {
      Description = "Add SSH key to GNOME Keyring agent";
      After = [ "graphical-session.target" ];
      ConditionPathExists = "%h/.ssh/id_ed25519";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # Use the keyring's SSH agent socket (%t = $XDG_RUNTIME_DIR)
      Environment = [
        "SSH_AUTH_SOCK=%t/keyring/ssh"
        "SSH_ASKPASS=${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
        "SSH_ASKPASS_REQUIRE=prefer"
      ];
      # Inherit display variables so the askpass dialog can open
      PassEnvironment = "DISPLAY WAYLAND_DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS";
      ExecStart = "${pkgs.openssh}/bin/ssh-add %h/.ssh/id_ed25519";
      RemainAfterExit = true;
    };
  };
}
