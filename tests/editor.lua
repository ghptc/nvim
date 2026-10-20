-- Run from this repository: nvim --headless -i NONE -c "luafile tests/editor.lua"
local function wait_for(fn, message)
	assert(vim.wait(10000, fn, 20), message)
end
local function picker()
	return require("telescope.actions.state").get_current_picker(vim.api.nvim_get_current_buf())
end
for _, key in ipairs({ "ff", "fg", "fb", "fh", "fr" }) do
	assert(vim.fn.maparg(" " .. key, "n") ~= "", "Missing Space " .. key)
end
-- Use the registered mapping, including preview and actual selection.
vim.fn.maparg(" ff", "n", false, true).callback()
local files = picker()
wait_for(function()
	return files.manager and files.manager:num_results() > 0
end, "No find_files results")
vim.wait(200) -- allow the preview callback to run too
assert(vim.v.errmsg == "", vim.v.errmsg)
require("telescope.actions").select_default(files.prompt_bufnr)
assert(vim.fn.filereadable(vim.api.nvim_buf_get_name(0)) == 1, "Selection did not open a file")
require("telescope.builtin").live_grep({ default_text = "require" })
local grep = picker()
wait_for(function()
	return grep.manager and grep.manager:num_results() > 0
end, "No live_grep results")
require("telescope.actions").close(grep.prompt_bufnr)
local b = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(b, 0, -1, false, { "local answer = 42" })
assert(pcall(require("telescope.previewers.utils").ts_highlighter, b, "lua"), "Tree-sitter preview failed")
for _, name in ipairs({ "lua_ls", "ts_ls", "clangd" }) do
	assert(vim.lsp.is_enabled(name), name .. " disabled")
	assert(
		vim.lsp.config[name].capabilities.textDocument.completion.completionItem.snippetSupport,
		name .. " missing Blink capabilities"
	)
end
assert(require("dap").adapters.coreclr, "Missing coreclr adapter")
assert(getmetatable(require("dap").configurations.cs[1]).__call, "Missing .NET project selector")
assert(vim.v.errmsg == "", vim.v.errmsg)
print("PASS: Telescope mappings, preview, file selection, live grep, LSP config, DAP config")
vim.cmd("qa!")
