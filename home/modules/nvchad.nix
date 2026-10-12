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
            suggestion = {
              enabled = true,
              auto_trigger = true,
              keymap = {
                accept = "<M-l>",
                next = "<M-]>",
                prev = "<M-[>",
                dismiss = "<C-]>",
              },
            },
            panel = { enabled = false },
          },
        },
        {
          "CopilotC-Nvim/CopilotChat.nvim",
          dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim", branch = "master" },
          },
          lazy = false,
          opts = {
            tools = { "copilot" }, -- Enable workspace tools (bash console commands, file operations, diffs)
            trusted_tools = nil,   -- Require individual approval for every tool action
            window = {
              layout = "vertical", -- Vertical sidebar chat window
              width = 0.4,
            },
          },
          keys = {
            { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
            { "<leader>ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "Copilot Chat Explain" },
            { "<leader>cf", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, desc = "Copilot Chat Fix" },
            { "<leader>cr", "<cmd>CopilotChatReset<cr>", desc = "Reset Copilot Chat" },
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

      -- Setup LSP servers (vim.lsp.config, Neovim 0.11+)
      vim.lsp.config("rust_analyzer", {})
      vim.lsp.config("marksman", {})
      vim.lsp.enable({ "rust_analyzer", "marksman" })
    '';

    extraPackages = with pkgs; [
      # Tools needed specifically by NvChad, not included in development.nix
      ripgrep    # Required for Telescope search
      fd         # Fast file finder
      curl       # Required for CopilotChat HTTP requests
      
      # Optional: For render-markdown plugin
      vimPlugins.render-markdown-nvim
    ];
  };
}

