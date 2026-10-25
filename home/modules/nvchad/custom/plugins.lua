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
    commit = "b1482409cefe8b201f89122c682189fabf0436da",
    lazy = true,
    event = "VeryLazy",
    cmd = { "Copilot" },
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

      local client_ok, client = pcall(require, "copilot.client")
      if client_ok and client and type(client.use_client) == "function" and not client._maltina_use_client_patched then
        local original_use_client = client.use_client
        local function wait_for_client_ready(callback, timeout_ms)
          local start = vim.loop.now()
          local interval_ms = 250

          local function tick()
            local started = client.get and client.get() or nil
            local initialized = client.initialized == true
            if started and initialized then
              callback(started)
              return
            end

            if (vim.loop.now() - start) >= timeout_ms then
              vim.notify(
                "Copilot client is not ready yet. Run :Copilot status and retry :Copilot auth signin.",
                vim.log.levels.WARN
              )
              return
            end

            vim.defer_fn(tick, interval_ms)
          end

          tick()
        end

        client.use_client = function(callback)
          local existing = client.get and client.get() or nil
          if existing and client.initialized == true then
            return original_use_client(callback)
          end

          if type(client.ensure_client_started) == "function" then
            client.ensure_client_started()
          end

          wait_for_client_ready(callback, 12000)
        end
        client._maltina_use_client_patched = true
      end
    end,
  },
  {
    "yetone/avante.nvim",
    lazy = true,
    version = false,
    build = "make luajit-tokenizers luajit-templates luajit-repo-map",
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
        local so_ok = vim.fn.filereadable(plugin_dir .. "/lua/avante_templates.so") == 1
        local dylib_ok = vim.fn.filereadable(plugin_dir .. "/lua/avante_templates.dylib") == 1
        local dll_ok = vim.fn.filereadable(plugin_dir .. "/lua/avante_templates.dll") == 1
        return so_ok or dylib_ok or dll_ok
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

      ensure_avante_prompt_sign()
      pcall(function()
        require("lazy").load({ plugins = { "copilot.lua" } })
      end)
      local plugin_dir = get_avante_plugin_dir()
      if not ensure_avante_templates(plugin_dir) then
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
      end
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
