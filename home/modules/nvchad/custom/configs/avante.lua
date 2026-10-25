-- Avante only reads the Copilot login from the legacy
-- ~/.config/github-copilot/{hosts,apps}.json files. Since copilot.lua 3.0 the language
-- server (`:Copilot auth`) keeps the login in ~/.config/github-copilot/auth.db instead,
-- so hand that token (or the one Copilot Chat cached) to Avante's copilot provider.
local M = {}

local function usable(token)
  return type(token) == "string" and token ~= "" and not token:find("[%s%c]")
end

local function auth_db_path()
  -- Same lookup as the language server.
  local xdg = vim.env.XDG_CONFIG_HOME
  local base = xdg and vim.startswith(xdg, "/") and xdg or (vim.uv.os_homedir() .. "/.config")
  return base .. "/github-copilot/auth.db"
end

local function token_from_auth_db()
  local db = auth_db_path()
  if vim.fn.filereadable(db) == 0 or vim.fn.executable("sqlite3") == 0 then
    return nil
  end

  -- token_schema_version 0 is plaintext; version 1 is AES encrypted with a key from the
  -- OS keyring, which can't be read from here.
  local query = [[
    SELECT CAST(token_ciphertext AS TEXT) FROM oauth_tokens
    WHERE token_schema_version = 0
      AND (instr(auth_authority, 'github.com') > 0 OR instr(auth_authority, 'ghe.com') > 0)
    ORDER BY last_used_at DESC, token_id DESC
    LIMIT 1;
  ]]
  local result = vim
    .system({ "sqlite3", "-readonly", "-batch", "-cmd", ".timeout 2000", db, query }, { text = true })
    :wait(5000)
  if result.code ~= 0 then
    return nil
  end

  local token = vim.trim(result.stdout or "")
  return usable(token) and token or nil
end

-- Copilot Chat runs its own device flow and caches the token (same OAuth app as Copilot).
local function token_from_copilotchat()
  local file = io.open(vim.fn.stdpath("data") .. "/copilot_chat/tokens.json", "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()

  local ok, tokens = pcall(vim.json.decode, content)
  local token = ok and type(tokens) == "table" and tokens.github_copilot or nil
  return usable(token) and token or nil
end

-- Seed the provider's state before Avante's own lookup, which would raise an error.
local function with_token(opts, token)
  return vim.tbl_deep_extend("force", opts, {
    providers = {
      copilot = {
        setup = function()
          local copilot = require("avante.providers.copilot")
          copilot.state = copilot.state or { oauth_token = token }
          copilot.setup()
        end,
        is_env_set = function()
          return true
        end,
      },
    },
  })
end

function M.setup(opts)
  opts = opts or {}

  local token = token_from_auth_db() or token_from_copilotchat()
  if token then
    opts = with_token(opts, token)
  end

  local ok, err = pcall(require("avante").setup, opts)
  if ok then
    return
  end

  if tostring(err):find("You must setup copilot", 1, true) then
    vim.notify(
      "No usable GitHub Copilot login found. Run :Copilot auth and restart Neovim.\n"
        .. "Avante reads it from "
        .. auth_db_path()
        .. " (needs the sqlite3 command) or from the Copilot Chat login (:CopilotChatModels).",
      vim.log.levels.WARN,
      { title = "avante.nvim" }
    )
    return
  end

  error(err, 0)
end

return M
