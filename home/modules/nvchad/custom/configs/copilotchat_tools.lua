local M = {}

local strict_mode = true

local action_descriptions = {
  CopilotChat = "Open/send prompt to chat",
  CopilotChatOpen = "Open chat window",
  CopilotChatExplain = "Explain selection/code",
  CopilotChatReview = "Review code",
  CopilotChatFix = "Fix code",
  CopilotChatTests = "Generate tests",
  CopilotChatCommit = "Generate commit message",
  CopilotChatCommitStaged = "Generate commit message from staged changes",
  CopilotChatExec = "Run shell command (approval)",
  CopilotChatExecLast = "Run last shell snippet from chat (approval)",
  CopilotChatRun = "Generate runnable shell command from prompt",
}

local blocked_patterns = {
  "rm%s+%-rf",
  "sudo%s+",
  "curl.-|",
  "wget.-|",
  ">%s*/dev/sd",
  "mkfs",
  "dd%s+if=",
  "chmod%s+777",
  "chown%s+root",
  ":%s*%(%s*%){%s*:%s*|%s*:%s*&%s*}%s*;%s*:", -- fork bomb
}

local function check_strict_policy(shell_cmd)
  if not strict_mode then
    return true
  end

  local lowered = shell_cmd:lower()
  for _, pattern in ipairs(blocked_patterns) do
    if lowered:match(pattern) then
      return false, pattern
    end
  end

  return true
end

local function confirm_action(title, body)
  local msg = title .. "\n\n" .. body
  local choice = vim.fn.confirm(msg, "&Cancel\n&Approve", 1)
  return choice == 2
end

local function send_to_chat(message)
  local ok, chat = pcall(require, "CopilotChat")
  if ok and type(chat.ask) == "function" then
    chat.ask(message)
    return true
  end

  vim.fn.setreg("+", message)
  pcall(vim.cmd, "CopilotChatOpen")
  vim.notify("Output copied to clipboard. Paste it into CopilotChat.", vim.log.levels.WARN)
  return false
end

local function run_shell_with_approval(description, shell_cmd, prompt_prefix)
  local allowed, reason = check_strict_policy(shell_cmd)
  if not allowed then
    vim.notify(
      "Blocked by strict mode (pattern: " .. reason .. "). Use safer command or disable strict mode.",
      vim.log.levels.ERROR
    )
    return
  end

  local details = table.concat({
    "Action: " .. description,
    "Will run shell command:",
    "  " .. shell_cmd,
    "Strict mode: " .. (strict_mode and "ON" or "OFF"),
  }, "\n")

  if not confirm_action("CopilotChat shell action", details) then
    vim.notify("Action canceled", vim.log.levels.INFO)
    return
  end

  local output = vim.fn.systemlist(shell_cmd)
  local exit_code = vim.v.shell_error
  local body = (#output > 0 and table.concat(output, "\n") or "(no output)")
  local message = table.concat({
    prompt_prefix,
    "",
    "Exit code: " .. tostring(exit_code),
    "Command: " .. shell_cmd,
    "",
    body,
  }, "\n")

  send_to_chat(message)
end

local function extract_last_shell_block(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local close_idx = nil

  for i = #lines, 1, -1 do
    if lines[i]:match("^```%s*$") then
      close_idx = i
      break
    end
  end

  if not close_idx then
    return nil
  end

  local open_idx = nil
  local lang = nil
  for i = close_idx - 1, 1, -1 do
    local l = lines[i]
    local code_lang = l:match("^```([%w_+-]+)%s*$")
    if code_lang then
      open_idx = i
      lang = code_lang:lower()
      break
    elseif l:match("^```%s*$") then
      open_idx = i
      lang = ""
      break
    end
  end

  if not open_idx or close_idx - open_idx <= 1 then
    return nil
  end

  local allowed = {
    bash = true,
    sh = true,
    zsh = true,
    shell = true,
    [""] = true,
  }

  if not allowed[lang] then
    return nil
  end

  local cmd_lines = {}
  for i = open_idx + 1, close_idx - 1 do
    table.insert(cmd_lines, lines[i])
  end

  local cmd = table.concat(cmd_lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
  if cmd == "" then
    return nil
  end

  return cmd
end

function M.exec_shell_command(shell_cmd)
  if type(shell_cmd) ~= "string" or shell_cmd:gsub("%s+", "") == "" then
    vim.notify("No shell command provided", vim.log.levels.ERROR)
    return
  end

  run_shell_with_approval(
    "Run explicit shell command and send output to CopilotChat",
    shell_cmd,
    "Shell command output for analysis:"
  )
end

function M.exec_last_shell_block()
  local shell_cmd = extract_last_shell_block(vim.api.nvim_get_current_buf())
  if not shell_cmd then
    vim.notify("No runnable shell block found (expected ```bash ... ```)", vim.log.levels.WARN)
    return
  end

  M.exec_shell_command(shell_cmd)
end

function M.run_prompt(prompt)
  if type(prompt) ~= "string" or prompt:gsub("%s+", "") == "" then
    vim.notify("No prompt provided", vim.log.levels.ERROR)
    return
  end

  local cwd = vim.loop.cwd()
  local details = table.concat({
    "Action: ask Copilot to generate one shell command",
    "Working directory: " .. cwd,
    "Execution is NOT automatic. You must approve via :CopilotChatExecLast.",
    "",
    "Prompt:",
    "  " .. prompt,
  }, "\n")

  if not confirm_action("CopilotChat run request", details) then
    vim.notify("Action canceled", vim.log.levels.INFO)
    return
  end

  local request = table.concat({
    "Generate exactly one shell command for zsh on macOS.",
    "Rules:",
    "- Return only one fenced code block with language bash.",
    "- No explanation text before or after the code block.",
    "- Keep the command safe and non-destructive.",
    "- Use current working directory context when relevant.",
    "",
    "Current working directory: " .. cwd,
    "User request: " .. prompt,
  }, "\n")

  send_to_chat(request)
  vim.notify("When Copilot responds, run :CopilotChatExecLast to execute with approval.", vim.log.levels.INFO)
end

function M.confirm_chat_action(command_name, description, args)
  local final_args = args or ""
  local cmdline = command_name
  if final_args ~= "" then
    cmdline = cmdline .. " " .. final_args
  end

  local details = ("Action: %s\nWill run: :%s"):format(description, cmdline)
  if not confirm_action("CopilotChat confirmation", details) then
    vim.notify("Action canceled", vim.log.levels.INFO)
    return
  end

  vim.cmd(cmdline)
end

function M.approve_and_run(action, args)
  if type(action) ~= "string" or not action:match("^CopilotChat") or action == "CopilotChatApprove" then
    vim.notify("Only CopilotChat* actions are allowed", vim.log.levels.ERROR)
    return
  end

  local description = action_descriptions[action] or "Run CopilotChat action"
  M.confirm_chat_action(action, description, args)
end

function M.run_workspace_context()
  local cwd = vim.loop.cwd()
  local preview = table.concat({
    "Action: collect local workspace context before sending to CopilotChat",
    "Working directory: " .. cwd,
    "Commands:",
    "  1) git --no-pager status --short --branch",
    "  2) fd --type f --hidden --follow --exclude .git . | head -n 200",
  }, "\n")

  if not confirm_action("CopilotChat workspace context", preview) then
    vim.notify("Action canceled", vim.log.levels.INFO)
    return
  end

  local git_status = vim.fn.systemlist("git --no-pager -C " .. vim.fn.shellescape(cwd) .. " status --short --branch")
  local files = vim.fn.systemlist("cd " .. vim.fn.shellescape(cwd) .. " && fd --type f --hidden --follow --exclude .git . | head -n 200")

  local context = table.concat({
    "Workspace: " .. cwd,
    "",
    "## Git status",
    (#git_status > 0 and table.concat(git_status, "\n") or "(no output)"),
    "",
    "## File tree sample (fd)",
    (#files > 0 and table.concat(files, "\n") or "(no output)"),
    "",
    "Please analyze this workspace context and suggest next steps.",
  }, "\n")

  local ok, chat = pcall(require, "CopilotChat")
  if ok and type(chat.ask) == "function" then
    chat.ask(context)
    return
  end

  -- Fallback: open chat and copy generated context to clipboard for manual paste.
  vim.fn.setreg("+", context)
  pcall(vim.cmd, "CopilotChatOpen")
  vim.notify("Context copied to clipboard. Paste it into CopilotChat.", vim.log.levels.WARN)
end

function M.setup_commands()
  vim.api.nvim_create_user_command("CopilotChatApprove", function(opts)
    local action = opts.fargs[1]
    if not action then
      vim.notify("Usage: :CopilotChatApprove CopilotChat<Action> [args]", vim.log.levels.ERROR)
      return
    end

    local args = table.concat(vim.list_slice(opts.fargs, 2), " ")
    M.approve_and_run(action, args)
  end, {
    nargs = "+",
    desc = "Run CopilotChat command with approval",
  })

  vim.api.nvim_create_user_command("CopilotChatWorkspace", function()
    M.run_workspace_context()
  end, { desc = "Collect workspace context for CopilotChat (with approval)" })

  vim.api.nvim_create_user_command("CopilotChatExec", function(opts)
    M.exec_shell_command(opts.args)
  end, {
    nargs = "+",
    desc = "Run shell command with approval and send output to CopilotChat",
  })

  vim.api.nvim_create_user_command("CopilotChatExecLast", function()
    M.exec_last_shell_block()
  end, {
    desc = "Run last shell snippet from current buffer with approval",
  })

  vim.api.nvim_create_user_command("CopilotChatRun", function(opts)
    M.run_prompt(opts.args)
  end, {
    nargs = "+",
    desc = "Ask Copilot for one bash command (execution remains approval-gated)",
  })

  vim.api.nvim_create_user_command("CopilotChatStrictMode", function(opts)
    local mode = (opts.args or "status"):lower()

    if mode == "on" then
      strict_mode = true
    elseif mode == "off" then
      strict_mode = false
    elseif mode == "toggle" then
      strict_mode = not strict_mode
    elseif mode ~= "status" then
      vim.notify("Usage: :CopilotChatStrictMode [on|off|toggle|status]", vim.log.levels.ERROR)
      return
    end

    vim.notify("CopilotChat strict mode: " .. (strict_mode and "ON" or "OFF"), vim.log.levels.INFO)
  end, {
    nargs = "?",
    complete = function()
      return { "on", "off", "toggle", "status" }
    end,
    desc = "Manage strict mode for approval-based shell execution",
  })

  -- Rewrite common CopilotChat commands to approval-gated execution.
  -- Example: :CopilotChatExplain -> :CopilotChatApprove CopilotChatExplain
  local approve_targets = {
    "CopilotChat",
    "CopilotChatOpen",
    "CopilotChatExplain",
    "CopilotChatReview",
    "CopilotChatFix",
    "CopilotChatTests",
    "CopilotChatCommit",
    "CopilotChatCommitStaged",
  }

  for _, cmd in ipairs(approve_targets) do
    vim.cmd(string.format(
      [[cnoreabbrev <expr> %s (getcmdtype() == ':' && getcmdline() =~# '^%s\%%(\s\|$\)') ? 'CopilotChatApprove %s' : '%s']],
      cmd,
      cmd,
      cmd,
      cmd
    ))
  end
end

return M
