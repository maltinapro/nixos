{ pkgs, ... }:

let
  # Path to the SSH key to be managed. Update this if your key file has a
  # different name (e.g. id_rsa, id_ecdsa).
  sshKeyPath = "%h/.ssh/id_ed25519";
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
  # gcr-ssh-agent stores the passphrase in the GNOME Keyring so that on
  # subsequent logins the key is unlocked automatically when the keyring is
  # unlocked (e.g. at GDM login).
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
      ExecStart = "${pkgs.openssh}/bin/ssh-add ${sshKeyPath}";
      RemainAfterExit = true;
    };
  };
}
