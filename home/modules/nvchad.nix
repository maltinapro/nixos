{ inputs, pkgs, ... }:

{
  imports = [
    # This uses the 'nvchad' input from your flake.nix
    inputs.nvchad.homeManagerModule 
  ];

  programs.nvchad = {
    enable = true;

    # extraPlugins is injected as a lazy.nvim plugin spec (plugins/init-2.lua)
    # This is the correct way to add plugins — extraConfig runs AFTER lazy is initialized
    extraPlugins = ''
      return {
        {
          "MeanderingProgrammer/render-markdown.nvim",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          ft = { "markdown" },
          opts = {
            heading  = { enabled = true },
            code     = { enabled = true },
            dash     = { enabled = true },
            bullet   = { enabled = true },
            checkbox = { enabled = true },
            table    = { enabled = true },
            link     = { enabled = true },
          },
        },
      }
    ''; 

    extraConfig = ''
      -- Protect terminal window from being overwritten
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
          vim.wo.winfixbuf = true
        end,
      })

      -- Fix file watchers (e.g. live-preview tools) losing track of the file after the first save.
      -- Neovim's default atomic save renames a temp file over the original, which changes
      -- the inode and breaks inode-based watchers. Setting backupcopy = "yes"
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
      ripgrep            # Required for NvChad's "Telescope" search
      fd                 # Fast file finder
      gcc                # Needed for compiling some Neovim plugins (Treesitter)
      
      # --- Version Control ---
      git                # Required for Git status, branches, and Gitsigns
      
      # --- Debugging ---
      lldb               # Debugger (works great with Rust)

      # --- Markdown ---
      vimPlugins.render-markdown-nvim  # Plugin managed by Nix, placed on rtp
      marksman                         # Markdown LSP (go-to-definition, link checking)
    ];
  };
}
