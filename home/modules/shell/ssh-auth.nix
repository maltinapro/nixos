{ pkgs, ... }:

let
  # Filename of the SSH key to be managed. Update this if your key file has a
  # different name (e.g. id_rsa, id_ecdsa).
  sshKeyName = "id_ed25519";
  # Systemd specifier path (used for ConditionPathExists)
  sshKeyPath = "%h/.ssh/${sshKeyName}";
in
{
  # GUI tools for managing keys
  home.packages = with pkgs; [
    seahorse          # GNOME Keyring GUI (Passwords and Keys)
  ];

  # Point SSH at the GCR SSH agent socket.
  # In NixOS with GNOME, the SSH agent is provided by gcr-ssh-agent (GCR 4),
  # which supersedes the old gnome-keyring SSH component.  Its socket lives at
  # $XDG_RUNTIME_DIR/gcr/ssh (not the old /keyring/ssh path).
  # $XDG_RUNTIME_DIR is expanded by the shell at startup (typically /run/user/1000).
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };

  # Tell SSH to cache keys in the agent after the first passphrase entry.
  # Without this, SSH prompts for the passphrase on every connection even though
  # an agent is running — because it uses the key file directly and never stores
  # the result. With AddKeysToAgent yes, the decrypted key is handed to the
  # gcr-ssh-agent after the first use and all subsequent git/ssh commands
  # in the same session work silently.
  #
  # enableDefaultConfig is set to false to silence the deprecation warning; the
  # defaults that home-manager previously applied globally are preserved in the
  # catch-all matchBlocks."*" block below.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
      # Preserve the home-manager defaults that would otherwise be dropped.
      serverAliveInterval = 120;
      serverAliveCountMax = 3;
    };
  };

  # Systemd user service: add SSH key to the gcr-ssh-agent once per session.
  # The service first checks whether the key is already loaded (gcr-ssh-agent
  # auto-loads keys stored in the GNOME Keyring after a successful GDM login).
  # If the key is already present, nothing happens.  If not (first login after
  # the key was never stored in the keyring), ssh-add prompts via the seahorse
  # dialog; gcr-ssh-agent then persists the passphrase in the now-unlocked
  # GNOME Keyring so subsequent logins need no prompt at all.
  systemd.user.services.ssh-key-add = {
    Unit = {
      Description = "Add SSH key to gcr-ssh-agent (GNOME Keyring)";
      # Wait for the gcr-ssh-agent socket to be active before running ssh-add.
      After = [ "gcr-ssh-agent.socket" "graphical-session.target" ];
      Requires = [ "gcr-ssh-agent.socket" ];
      ConditionPathExists = sshKeyPath;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # Use the gcr-ssh-agent socket (%t = $XDG_RUNTIME_DIR)
      Environment = [
        "SSH_AUTH_SOCK=%t/gcr/ssh"
        "SSH_ASKPASS=${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
        "SSH_ASKPASS_REQUIRE=prefer"
      ];
      # Inherit display variables so the askpass dialog can open
      PassEnvironment = "DISPLAY WAYLAND_DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS";
      # Only call ssh-add if the key is not already in the agent.
      # After the GDM PAM keyring fix, gcr-ssh-agent will auto-load the key
      # from the GNOME Keyring on login, making this a no-op in normal use.
      ExecStart = toString (pkgs.writeShellScript "ssh-key-add" ''
        ${pkgs.openssh}/bin/ssh-add -l 2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep -qF "${sshKeyName}" \
          || exec ${pkgs.openssh}/bin/ssh-add "$HOME/.ssh/${sshKeyName}"
      '');
      RemainAfterExit = true;
    };
  };
}
