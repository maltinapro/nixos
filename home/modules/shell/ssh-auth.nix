{ pkgs, ... }:

{
  # GUI tools for managing keys
  home.packages = with pkgs; [
    seahorse          # GNOME Keyring GUI (Passwords and Keys)
  ];

  # Point SSH at the GNOME Keyring SSH agent socket.
  # $XDG_RUNTIME_DIR is expanded by the shell at startup (typically /run/user/1000).
  # This avoids the need to run `eval $(ssh-agent -s)` manually in every terminal.
  # SSH_ASKPASS / SSH_ASKPASS_REQUIRE are intentionally NOT set here for
  # terminal sessions — SSH will use the keyring agent silently or fall back to
  # TTY prompting, avoiding hangs when the GUI helper can't open a dialog.
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };

  # Tell SSH to cache keys in the agent after the first passphrase entry.
  # Without this, SSH prompts for the passphrase on every connection even though
  # an agent is running — because it uses the key file directly and never stores
  # the result. With AddKeysToAgent yes, the decrypted key is handed to the
  # GNOME Keyring agent after the first use and all subsequent git/ssh commands
  # in the same session work silently.
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

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
