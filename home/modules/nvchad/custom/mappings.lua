local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local tools = require("custom.configs.copilotchat_tools")

-- Open chat window
map("n", "<leader>ao", function()
  tools.approve_and_run("CopilotChatOpen")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Open" }))
map("n", "<leader>aw", tools.run_workspace_context, vim.tbl_extend("force", opts, { desc = "CopilotChat: Workspace Context" }))
map("n", "<leader>ax", tools.exec_last_shell_block, vim.tbl_extend("force", opts, { desc = "CopilotChat: Exec Last Shell Block" }))

-- Chat actions for normal and visual mode.
map({ "n", "v" }, "<leader>ae", function()
  tools.approve_and_run("CopilotChatExplain")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Explain" }))
map({ "n", "v" }, "<leader>ar", function()
  tools.approve_and_run("CopilotChatReview")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Review" }))
map({ "n", "v" }, "<leader>af", function()
  tools.approve_and_run("CopilotChatFix")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Fix" }))
map({ "n", "v" }, "<leader>at", function()
  tools.approve_and_run("CopilotChatTests")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Tests" }))
