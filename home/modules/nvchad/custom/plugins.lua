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
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "ColinKennedy/mega.cmdparse",
      "ColinKennedy/mega.logging",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
    },
    opts = {
      -- Reuse the Copilot login from copilot.lua (:Copilot auth).
      provider = "copilot",
      -- Keymaps are defined in custom/mappings.lua.
      -- Copilot.lua already provides inline suggestions; keep avante's off.
      behaviour = { auto_suggestions = false, auto_set_keymaps = false },
    },
  },
}
