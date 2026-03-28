{ pkgs, ... }:

{
  # Point SSH at the gcr-ssh-agent socket (the replacement for the old
  # gnome-keyring-daemon SSH component).  PAM unlocks the keyring at GDM
  # login (security.pam.services.gdm.enableGnomeKeyring in flake.nix),
  # making stored SSH passphrases available automatically.
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
    };
  };

  # Load the SSH key into the gcr-ssh-agent at login — the NixOS
  # equivalent of macOS "UseKeychain yes".
  #
  # First time:  seahorse's askpass shows a one-time GUI prompt; the
  #              passphrase is stored in GNOME Keyring.
  # After that:  PAM unlocks the keyring at GDM login → askpass retrieves
  #              the stored passphrase silently → key loaded with no prompt.
  systemd.user.services.ssh-key-add = {
    Unit = {
      Description = "Add SSH key to gcr-ssh-agent";
      After = [ "gcr-ssh-agent.socket" "graphical-session.target" ];
      Requires = [ "gcr-ssh-agent.socket" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = [
        "SSH_AUTH_SOCK=%t/gcr/ssh"
        "SSH_ASKPASS=${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
        "SSH_ASKPASS_REQUIRE=force"
        "DISPLAY=:0"
      ];
      ExecStart = "${pkgs.openssh}/bin/ssh-add %h/.ssh/id_ed25519";
      RemainAfterExit = true;
    };
  };
}
