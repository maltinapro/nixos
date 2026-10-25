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

-- Avante (<leader>a*); CopilotChat uses <leader>c*. Avante's own keymaps are disabled
-- (auto_set_keymaps = false) and its <Plug> mappings are bound here instead.
local function avante(modes, lhs, plug, desc)
  map(modes, lhs, plug, { remap = true, silent = true, desc = "Avante: " .. desc })
end
avante({ "n", "v" }, "<leader>aa", "<Plug>(AvanteAsk)", "Ask")
avante("v", "<leader>ae", "<Plug>(AvanteEdit)", "Edit")
avante("n", "<leader>aR", "<Plug>(AvanteRefresh)", "Refresh")
avante("n", "<leader>af", "<Plug>(AvanteFocus)", "Focus")
avante("n", "<leader>aS", "<Plug>(AvanteStop)", "Stop")
avante("n", "<leader>at", "<Plug>(AvanteToggle)", "Toggle sidebar")
avante("n", "<leader>ad", "<Plug>(AvanteToggleDebug)", "Toggle debug")
avante("n", "<leader>as", "<Plug>(AvanteToggleSuggestion)", "Toggle suggestions")
avante("n", "<leader>aM", "<Plug>(AvanteShowRepoMap)", "Show repo map")
avante("n", "<leader>aB", "<Plug>(AvanteAddAllBuffers)", "Add all buffers")
avante("n", "<leader>a?", "<Plug>(AvanteSelectModel)", "Select model")
avante("n", "<leader>aH", "<Plug>(AvanteSelectHistory)", "Select history")
map("n", "<leader>ac", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    require("avante.api").add_selected_file(file)
  end
end, { silent = true, desc = "Avante: Add current buffer" })
