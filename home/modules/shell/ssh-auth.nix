{ pkgs, ... }:

let
  # Wrapper askpass that stores/retrieves SSH passphrases in GNOME Keyring.
  #
  # First call (passphrase not yet in keyring):
  #   → seahorse GUI prompt → user enters passphrase → stored in keyring
  # Subsequent calls (keyring unlocked by PAM at GDM login):
  #   → passphrase retrieved silently → no dialog at all
  ssh-askpass-keyring = pkgs.writeShellScript "ssh-askpass-keyring" ''
    KEY_ID="ssh-key-id_ed25519"

    # Try to retrieve from GNOME Keyring (unlocked by PAM at GDM login)
    passphrase=$(${pkgs.libsecret}/bin/secret-tool lookup unique "$KEY_ID" 2>/dev/null) || true
    if [ -n "$passphrase" ]; then
      echo "$passphrase"
      exit 0
    fi

    # Not found — show seahorse GUI prompt (first time only)
    passphrase=$(${pkgs.seahorse}/libexec/seahorse/ssh-askpass "$@")
    rc=$?
    if [ $rc -eq 0 ] && [ -n "$passphrase" ]; then
      # Store in GNOME Keyring for future reboots
      echo -n "$passphrase" | ${pkgs.libsecret}/bin/secret-tool store \
        --label "SSH: id_ed25519" unique "$KEY_ID"
      echo "$passphrase"
      exit 0
    fi

    exit $rc
  '';

in
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

    # This is the correct, modern structure that Home Manager expects
    settings = {
      "*" = {
        addKeysToAgent = "yes";
      };
    };
  };

  # Load the SSH key into the gcr-ssh-agent at login — the NixOS
  # equivalent of macOS "UseKeychain yes".
  #
  # First time:  seahorse's askpass shows a one-time GUI prompt; the
  #              passphrase is stored in GNOME Keyring via secret-tool.
  # After that:  PAM unlocks the keyring at GDM login → secret-tool
  #              retrieves the stored passphrase silently → no prompt.
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
        "SSH_ASKPASS=${ssh-askpass-keyring}"
        "SSH_ASKPASS_REQUIRE=force"
        "DISPLAY=:0"
      ];
      ExecStart = "${pkgs.openssh}/bin/ssh-add %h/.ssh/id_ed25519";
      RemainAfterExit = true;
    };
  };
}
