{ inputs, pkgs, ... }:

{
  imports = [
    # This uses the 'nvchad' input from your flake.nix
    inputs.nvchad.homeManagerModules.default
  ];

  programs.nvchad = {
    enable = true;

    # Keep plugin definitions in NvChad-style custom Lua files.
    extraPlugins = ''
      return require("custom.plugins")
    '';

    extraConfig = ''
      require("custom.configs.copilotchat")
      require("custom.mappings")

      -- Prefer fd and ripgrep explicitly for Telescope finders/grep.
      pcall(function()
        require("telescope").setup {
          defaults = {
            vimgrep_arguments = {
              "rg",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
            },
          },
          pickers = {
            find_files = {
              find_command = {
                "fd",
                "--type",
                "f",
                "--hidden",
                "--follow",
                "--exclude",
                ".git",
              },
            },
          },
        }
      end)

      -- Protect terminal window from being overwritten
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
          vim.wo.winfixbuf = true
        end,
      })

      -- Use the system clipboard for all yank/paste operations.
      -- On macOS, Neovim auto-detects pbcopy/pbpaste automatically.
      vim.opt.clipboard = "unnamedplus"

      -- Fix file watchers (e.g. fluxMarkdown) losing track of the file after the first save.
      -- Neovim's default atomic save renames a temp file over the original, which changes
      -- the inode and breaks inode-based watchers on macOS. Setting backupcopy = "yes"
      -- makes Neovim write directly into the existing file instead, keeping the inode stable.
      vim.opt.backupcopy = "yes"
    '';
    extraPackages = with pkgs; [
      # --- Rust Essentials ---
      rust-analyzer      # The "Brain" (LSP) for code completion and errors
      rustfmt            # Automatically formats your code
      clippy             # Catches common mistakes (the Rust "Linter")
      cargo              # Package manager
      rustc              # The compiler

      # --- NvChad / Neovim Essentials ---
      gcc                # Needed for compiling some Neovim plugins (Treesitter)
      gnumake            # Required by avante.nvim build step ("make")
      nodejs_22          # Required by Copilot language server/client (copilot.lua needs Node >=22 for nodejs server)
      unzip              # Needed by copilot.lua to unpack copilot-language-server
      sqlite             # Enables auth.db token compatibility bridge for Avante Copilot provider

      # --- Version Control ---
      git                # Required for Git status, branches, and Gitsigns

      # --- Debugging ---
      lldb               # Debugger (works great with Rust)
    ];
  };

  home.file.".config/nvim/lua/custom/plugins.lua".source = ./nvchad/custom/plugins.lua;
  home.file.".config/nvim/lua/custom/mappings.lua".source = ./nvchad/custom/mappings.lua;
  home.file.".config/nvim/lua/custom/configs/copilotchat.lua".source = ./nvchad/custom/configs/copilotchat.lua;
  home.file.".config/nvim/lua/custom/configs/copilotchat_tools.lua".source = ./nvchad/custom/configs/copilotchat_tools.lua;
}
