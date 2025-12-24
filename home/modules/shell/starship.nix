{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      nix_shell = {
        symbol = " ";
      };

      git_status = {
        format = "([\$all_status$ahead_behind\]($style) )";
        modified = "󰇂 ";
        ahead = " $\{count}";
        conflicted = "󱚝 ";
        behind = " $\{count}";
        diverged = "󰹺   $\{ahead_count}  $\{behind_count}";
        up_to_date = " ";
        deleted = "󰮉 ";
        untracked = "󱚠 ";
        stashed = " ";
        staged = " ";
        style = "bold blue";
      };
    };
  };
}

