return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {
      heading = { enabled = true },
      code = { enabled = true },
      dash = { enabled = true },
      bullet = { enabled = true },
      checkbox = { enabled = true },
      table = { enabled = true },
      link = { enabled = true },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      -- The default prebuilt binary can't run on NixOS; use Node.js (>= 22) from extraPackages.
      server = { type = "nodejs" },
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = false,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatFix",
      "CopilotChatTests",
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = {
      -- lazy.nvim kills build processes after `git.timeout` (120s by default),
      -- but compiling the Rust libraries with cargo takes several minutes.
      function()
        require("lazy.core.config").options.git.timeout = 1800
      end,
      "make",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "ColinKennedy/mega.cmdparse",
      "ColinKennedy/mega.logging",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- Reuse the Copilot login from `:Copilot auth` (see custom/configs/avante.lua).
      provider = "copilot",
      -- Keymaps are defined in custom/mappings.lua; avante's experimental auto suggestions stay off.
      behaviour = { auto_suggestions = false, auto_set_keymaps = false },
    },
    config = function(_, opts)
      require("custom.configs.avante").setup(opts)
    end,
  },
}
