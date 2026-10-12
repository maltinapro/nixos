{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nvchad.homeManagerModules.default
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
        {
          "zbirenbaum/copilot.lua",
          cmd = "Copilot",
          event = "InsertEnter",
          opts = {
            panel = { enabled = false },
            suggestion = { enabled = false },
          },
        },
        {
          "zbirenbaum/copilot-cmp",
          dependencies = { "zbirenbaum/copilot.lua" },
          config = function()
            require("copilot_cmp").setup()
          end,
        },
        {
          "nickjvandyke/opencode.nvim",
          event = "VeryLazy",
          opts = {},
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

      -- Setup LSP servers (vim.lsp.config, Neovim 0.11+)
      vim.lsp.config("rust_analyzer", {})
      vim.lsp.config("marksman", {})
      vim.lsp.enable({ "rust_analyzer", "marksman" })

      -- Copilot auth helpers
      vim.keymap.set("n", "<leader>ca", "<cmd>Copilot auth<CR>", { desc = "Copilot auth" })
      vim.keymap.set("n", "<leader>ci", "<cmd>Copilot auth info<CR>", { desc = "Copilot auth info" })
      vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ") end, { desc = "OpenCode ask" })
      vim.keymap.set({ "n", "x" }, "<leader>os", function() require("opencode").select() end, { desc = "OpenCode select" })

      -- Add Copilot as a cmp source when available
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp then
        local config = cmp.get_config()
        local has_copilot = false
        for _, source in ipairs(config.sources or {}) do
          if source.name == "copilot" then
            has_copilot = true
            break
          end
        end
        if not has_copilot then
          table.insert(config.sources, 1, { name = "copilot", group_index = 2 })
          cmp.setup(config)
        end
      end
    '';

    extraPackages = with pkgs; [
      # Tools needed specifically by NvChad, not included in development.nix
      ripgrep    # Required for Telescope search
      fd         # Fast file finder
      nodejs_22  # Copilot node runtime fallback
      
      # Optional: For render-markdown plugin
      vimPlugins.render-markdown-nvim
    ] ++ (if builtins.hasAttr "opencode" pkgs then [ pkgs.opencode ] else []);
  };
}
