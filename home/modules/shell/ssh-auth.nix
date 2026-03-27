{ ... }:

{
  # Seahorse ("Passwords and Keys") is part of GNOME and needs no separate package.
  # Use it once to import your SSH key and save its passphrase in the keyring:
  #   Applications → Passwords and Keys → + → Import an SSH key
  # After that, PAM unlocks the keyring at GDM login and gcr-ssh-agent
  # auto-loads the key — no passphrase prompt ever again.

  # Point SSH at the GCR SSH agent socket.
  # gcr-ssh-agent (GCR 4) supersedes the old gnome-keyring SSH component.
  # Its socket lives at $XDG_RUNTIME_DIR/gcr/ssh (expanded by the shell at startup).
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };

  # SSH client configuration.
  # AddKeysToAgent yes: after the user enters the passphrase for the first SSH
  # connection in a session, the decrypted key is handed to gcr-ssh-agent so
  # all subsequent git/ssh commands in the same session work without a prompt.
  # (For persistence across reboots, register the key in Seahorse as described above.)
  #
  # enableDefaultConfig is false to suppress the home-manager deprecation warning;
  # the home-manager defaults are preserved explicitly in matchBlocks."*".
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
      serverAliveInterval = 120;
      serverAliveCountMax = 3;
    };
  };
}
