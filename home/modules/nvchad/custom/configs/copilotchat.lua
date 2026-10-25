local ok, copilotchat = pcall(require, "CopilotChat")
if not ok then
  return
end

copilotchat.setup {
  model = "gpt-5.3-codex",
  debug = false,
  show_help = "yes",
  auto_follow_cursor = true,
  question_header = "## User ",
  answer_header = "## Copilot ",
  window = {
    layout = "vertical",
    width = 0.4,
    border = "rounded",
    title = " Copilot Chat ",
  },
}

vim.api.nvim_create_user_command("CopilotChatOpen", function()
  copilotchat.open()
end, { desc = "Open Copilot Chat" })

pcall(function()
  require("custom.configs.copilotchat_tools").setup_commands()
end)
