-- Run after creating the fixture (see README.md).
local root = assert(vim.env.NVIM_DOTNET_FIXTURE, "Set NVIM_DOTNET_FIXTURE")
vim.cmd.edit(root .. "/App/Program.cs")
assert(
	vim.wait(30000, function()
		return #vim.lsp.get_clients({ name = "roslyn", bufnr = 0 }) == 1
	end, 100),
	"Roslyn did not attach"
)
local client = vim.lsp.get_clients({ name = "roslyn", bufnr = 0 })[1]
assert(
	client.config.settings["csharp|background_analysis"].dotnet_compiler_diagnostics_scope == "openFiles",
	"Running client missed Roslyn settings"
)
assert(client.config.capabilities.textDocument.completion.completionItem.snippetSupport, "Missing Blink capabilities")
assert(client.config.root_dir == root, "Wrong solution root: " .. client.config.root_dir)
assert(vim.g.roslyn_nvim_selected_solution == root .. "/Validation.slnx", "Wrong solution target")
assert(#vim.lsp.get_clients({ bufnr = 0 }) == 1, "Duplicate C# clients")
local buf = vim.api.nvim_get_current_buf()
local function params(line, char)
	return { textDocument = { uri = vim.uri_from_bufnr(buf) }, position = { line = line, character = char } }
end
local function request(method, p)
	local r, err = client:request_sync(method, p, 10000, buf)
	assert(r and not r.err, vim.inspect(r and r.err or err))
	return r.result
end
local definition
assert(
	vim.wait(45000, function()
		definition = request("textDocument/definition", params(1, 25))
		return definition and #definition > 0
	end, 500),
	"No cross-project definition"
)
assert(vim.inspect(definition):find("Library/Class1.cs", 1, true), vim.inspect(definition))
local refs = params(1, 25)
refs.context = { includeDeclaration = true }
assert(
	vim.wait(30000, function()
		return #(request("textDocument/references", refs) or {}) >= 3
	end, 200),
	"Missing solution references"
)
local hover = request("textDocument/hover", params(1, 25))
assert(hover and hover.contents, "No hover documentation")
local completion = request("textDocument/completion", params(2, 8))
assert(completion and #(completion.items or completion) > 0, "No semantic completion")
assert(
	vim.iter(completion.items or completion):any(function(item)
		return item.label:find("WriteLine", 1, true) ~= nil
	end),
	"Console completion omitted WriteLine"
)
assert(request("textDocument/signatureHelp", params(1, 30)), "No signature help")
assert(
	request(
		"textDocument/formatting",
		{ textDocument = { uri = vim.uri_from_bufnr(buf) }, options = { tabSize = 4, insertSpaces = true } }
	),
	"No formatting response"
)
vim.api.nvim_buf_set_lines(buf, 1, 2, false, { "var answer=Calculator.Add(20,22);" })
require("conform").format({ bufnr = buf, async = false, timeout_ms = 3000 })
assert(
	vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1] == "var answer = Calculator.Add(20, 22);",
	"Conform did not format through Roslyn"
)
local actions = request("textDocument/codeAction", {
	textDocument = { uri = vim.uri_from_bufnr(buf) },
	range = { start = { line = 1, character = 0 }, ["end"] = { line = 1, character = 35 } },
	context = { diagnostics = {} },
})
assert(actions and #actions > 0, "No code actions")
local caps = client.server_capabilities
assert(caps.codeActionProvider and caps.semanticTokensProvider, "Missing actions or semantic tokens")
vim.api.nvim_buf_set_lines(buf, -1, -1, false, { 'int broken = "not an integer";' })
assert(
	vim.wait(30000, function()
		for _, d in ipairs(vim.diagnostic.get(buf)) do
			if tostring(d.code) == "CS0029" then
				return true
			end
		end
	end, 100),
	"No compiler diagnostic CS0029"
)
vim.api.nvim_buf_set_lines(buf, -2, -1, false, {})
local rename = params(1, 25)
rename.newName = "Sum"
local edit = request("textDocument/rename", rename)
assert(edit and (edit.changes or edit.documentChanges), "No rename edits")
vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding)
local lib = vim.fn.bufnr(root .. "/Library/Class1.cs")
assert(
	lib > 0 and table.concat(vim.api.nvim_buf_get_lines(lib, 0, -1, false), "\n"):find("Sum", 1, true),
	"Rename did not update the referenced library"
)
print(
	"PASS: one Roslyn client, slnx solution, completion, definition, references, hover, signature, format, diagnostics, rename"
)
vim.cmd("qa!")
