local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local tools = require("custom.configs.copilotchat_tools")

-- Open chat window
map("n", "<leader>co", function()
  tools.approve_and_run("CopilotChatOpen")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Open" }))
map("n", "<leader>cw", tools.run_workspace_context, vim.tbl_extend("force", opts, { desc = "CopilotChat: Workspace Context" }))
map("n", "<leader>cx", tools.exec_last_shell_block, vim.tbl_extend("force", opts, { desc = "CopilotChat: Exec Last Shell Block" }))

-- Chat actions for normal and visual mode.
map({ "n", "v" }, "<leader>ce", function()
  tools.approve_and_run("CopilotChatExplain")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Explain" }))
map({ "n", "v" }, "<leader>cr", function()
  tools.approve_and_run("CopilotChatReview")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Review" }))
map({ "n", "v" }, "<leader>cf", function()
  tools.approve_and_run("CopilotChatFix")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Fix" }))
map({ "n", "v" }, "<leader>ct", function()
  tools.approve_and_run("CopilotChatTests")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Tests" }))
