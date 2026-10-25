local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local tools = require("custom.configs.copilotchat_tools")

-- Avante actions
map({ "n", "v" }, "<leader>aa", "<cmd>AvanteAsk<cr>", vim.tbl_extend("force", opts, { desc = "Avante: Ask" }))
map({ "n", "v" }, "<leader>ae", "<cmd>AvanteEdit<cr>", vim.tbl_extend("force", opts, { desc = "Avante: Edit" }))
map("n", "<leader>at", "<cmd>AvanteToggle<cr>", vim.tbl_extend("force", opts, { desc = "Avante: Toggle" }))
map("n", "<leader>ar", "<cmd>AvanteRefresh<cr>", vim.tbl_extend("force", opts, { desc = "Avante: Refresh" }))

-- CopilotChat actions
map("n", "<leader>co", function()
  tools.approve_and_run("CopilotChatOpen")
end, vim.tbl_extend("force", opts, { desc = "CopilotChat: Open" }))
map("n", "<leader>cw", tools.run_workspace_context, vim.tbl_extend("force", opts, { desc = "CopilotChat: Workspace Context" }))
map("n", "<leader>cx", tools.exec_last_shell_block, vim.tbl_extend("force", opts, { desc = "CopilotChat: Exec Last Shell Block" }))

-- CopilotChat actions for normal and visual mode
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
