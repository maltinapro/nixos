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
    lazy = true,
    cmd = { "Copilot", "CopilotAuth", "CopilotStatus" },
    opts = {
      server = { type = "nodejs" },
      copilot_node_command = "node",
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = false,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },
  {
    "yetone/avante.nvim",
    lazy = true,
    version = false,
    build = "make",
    opts = {
      provider = "copilot",
      auto_suggestions_provider = "copilot",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "ColinKennedy/mega.logging",
      "ColinKennedy/mega.cmdparse",
      "nvim-treesitter/nvim-treesitter",
      "zbirenbaum/copilot.lua",
      "MeanderingProgrammer/render-markdown.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = {
      "Avante",
      "AvanteAsk",
      "AvanteEdit",
      "AvanteRefresh",
      "AvanteToggle",
    },
    config = function(_, opts)
      vim.g.avante_ready = false

      local function ensure_avante_prompt_sign()
        local existing = vim.fn.sign_getdefined("AvanteInputPromptSign")
        if existing and #existing > 0 then
          return
        end

        vim.fn.sign_define("AvanteInputPromptSign", {
          text = "󰜥",
          texthl = "AvanteInputPrompt",
        })
      end

      local function ensure_copilot_hosts_json()
        local config_dir = vim.env.XDG_CONFIG_HOME
        if not config_dir or config_dir == "" then
          config_dir = vim.fn.expand("~/.config")
        end

        local copilot_dir = config_dir .. "/github-copilot"
        local hosts_path = copilot_dir .. "/hosts.json"
        local apps_path = copilot_dir .. "/apps.json"
        if vim.fn.filereadable(hosts_path) == 1 or vim.fn.filereadable(apps_path) == 1 then
          return
        end

        local token = vim.env.GH_COPILOT_TOKEN
        if not token or token == "" then
          token = vim.env.GITHUB_COPILOT_TOKEN
        end

        if (not token or token == "") and vim.fn.executable("sqlite3") == 1 then
          local auth_db_path = copilot_dir .. "/auth.db"
          if vim.fn.filereadable(auth_db_path) == 1 then
            local dump = table.concat(vim.fn.systemlist({ "sqlite3", auth_db_path, ".dump" }), "\n")
            token = dump:match([["oauth_token"%s*:%s*"([^"]+)"]])
              or dump:match([["token"%s*:%s*"([^"]+)"]])
          end
        end

        if token and token ~= "" then
          vim.fn.mkdir(copilot_dir, "p")
          local payload = vim.json.encode({
            ["github.com"] = {
              oauth_token = token,
            },
          })
          vim.fn.writefile({ payload }, hosts_path)
        end
      end

      local function get_avante_plugin_dir()
        local lazy_ok, lazy_config = pcall(require, "lazy.core.config")
        if not lazy_ok or not lazy_config.options or not lazy_config.options.root then
          return nil
        end
        return lazy_config.options.root .. "/avante.nvim"
      end

      local function has_avante_templates(plugin_dir)
        if not plugin_dir or plugin_dir == "" then
          return false
        end
        return vim.fn.isdirectory(plugin_dir .. "/avante_templates") == 1
      end

      local function ensure_avante_templates(plugin_dir)
        if has_avante_templates(plugin_dir) then
          return true
        end

        vim.schedule(function()
          vim.notify(
            "Avante build files are missing. Run :Lazy build avante.nvim and restart Neovim.",
            vim.log.levels.ERROR
          )
        end)
        return false
      end

      local function ensure_copilot_ready()
        local client_ok, client = pcall(require, "copilot.client")
        if not client_ok or not client then
          return false
        end

        if type(client.is_disabled) == "function" and client.is_disabled() then
          return false
        end

        return true
      end

      ensure_avante_prompt_sign()
      ensure_copilot_hosts_json()
      local plugin_dir = get_avante_plugin_dir()
      if not ensure_avante_templates(plugin_dir) then
        return
      end
      if not ensure_copilot_ready() then
        vim.schedule(function()
          vim.notify(
            "Copilot is not ready. Run :Copilot auth and restart Neovim.",
            vim.log.levels.ERROR
          )
        end)
        return
      end
      local ok, avante = pcall(require, "avante")
      if not ok then
        return
      end

      local setup_ok, err = pcall(avante.setup, opts)
      if not setup_ok then
        vim.schedule(function()
          vim.notify(
            "Avante setup failed (Copilot auth). Run :Copilot auth and restart Neovim.\n" .. tostring(err),
            vim.log.levels.ERROR
          )
        end)
        return
      end

      vim.g.avante_ready = true
    end,
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
}
