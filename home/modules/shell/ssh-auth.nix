{ ... }:

{
  # Point SSH at the GNOME Keyring agent
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };

  # Automatically cache the key in the agent after the first passphrase
  # entry.  GNOME Keyring (the agent behind SSH_AUTH_SOCK) also stores
  # the passphrase in the login keyring, so future sessions that unlock
  # the keyring via PAM need no passphrase at all.
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
}
