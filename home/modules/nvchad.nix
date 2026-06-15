{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nvchad.homeManagerModule 
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

      -- Setup LSP servers
      local lspconfig = require("lspconfig")
      
      lspconfig.rust_analyzer.setup({})
      lspconfig.marksman.setup({})
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

