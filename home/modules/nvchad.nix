{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nvchad.homeManagerModules
  ];

  programs.nvchad = {
    enable = true;

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
        { "tpope/vim-fugitive", lazy = false },
      }
    ''; 

    extraConfig = ''
      -- Protect terminal window from being overwritten
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
          vim.wo.winfixbuf = true
        end,
      })

      -- Fix file watchers
      vim.opt.backupcopy = "yes"

      -- Setup LSP servers (vim.lsp.config, Neovim 0.11+)
      vim.lsp.config("rust_analyzer", {})
      vim.lsp.config("marksman", {})
      vim.lsp.enable({ "rust_analyzer", "marksman" })
    '';

    extraPackages = with pkgs; [
      # Tools needed specifically by NvChad, not included in development.nix
      ripgrep    # Required for Telescope search
      fd         # Fast file finder
      
      # Optional: For render-markdown plugin
      vimPlugins.render-markdown-nvim
    ];
  };
}

