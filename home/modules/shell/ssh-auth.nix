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

  # Systemd user service: offer the SSH key to gcr-ssh-agent once per session.
  #
  # HOW gcr-ssh-agent STORES THE PASSPHRASE IN THE KEYRING:
  #   gcr-ssh-agent (GCR 4) has its own built-in passphrase dialog (gcr-prompter,
  #   a D-Bus service).  When ssh-add is run WITHOUT an external SSH_ASKPASS, the
  #   agent intercepts the add request, shows its own dialog, and — crucially —
  #   stores the encrypted key in the GNOME Keyring itself.  On subsequent logins
  #   the PAM keyring-unlock (gdm-password) decrypts the keyring, and gcr-ssh-agent
  #   auto-loads all stored keys with NO passphrase prompt.
  #
  #   If SSH_ASKPASS is set, an external binary supplies the passphrase to ssh-add,
  #   which then hands gcr-ssh-agent a pre-decrypted key.  The agent never sees the
  #   passphrase, so it CANNOT store anything in the keyring → passphrase prompt on
  #   every reboot.  That is the bug this service previously caused.
  #
  # NORMAL OPERATION (key already stored in keyring):
  #   After the first successful passphrase entry the check below ("ssh-add -l")
  #   finds the key already loaded (gcr-ssh-agent auto-loaded it from the keyring
  #   after PAM unlocked it at GDM login) and does nothing.
  systemd.user.services.ssh-key-add = {
    Unit = {
      Description = "Add SSH key to gcr-ssh-agent (GNOME Keyring)";
      After = [ "gcr-ssh-agent.socket" "graphical-session.target" ];
      Requires = [ "gcr-ssh-agent.socket" ];
      ConditionPathExists = sshKeyPath;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # Only SSH_AUTH_SOCK is needed; NO SSH_ASKPASS so that gcr-ssh-agent
      # uses its own gcr-prompter dialog and stores the key in the keyring.
      Environment = [ "SSH_AUTH_SOCK=%t/gcr/ssh" ];
      # gcr-prompter is a D-Bus service — pass the session bus address so
      # the agent's dialog can appear on the Wayland/X display.
      PassEnvironment = "DBUS_SESSION_BUS_ADDRESS DISPLAY WAYLAND_DISPLAY";
      # Skip ssh-add when the key is already loaded (normal case after first
      # successful passphrase entry — gcr-ssh-agent auto-loaded it from the
      # GNOME Keyring when PAM unlocked it at login).
      ExecStart = toString (pkgs.writeShellScript "ssh-key-add" ''
        ${pkgs.openssh}/bin/ssh-add -l 2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep -qF "${sshKeyName}" \
          || exec ${pkgs.openssh}/bin/ssh-add "$HOME/.ssh/${sshKeyName}"
      '');
      RemainAfterExit = true;
    };
  };
}
