-- Exercise cancellation, non-executable projects, and absent build output.
local root = assert(vim.env.NVIM_DOTNET_FIXTURE, "Set NVIM_DOTNET_FIXTURE")
vim.cmd.edit(root .. "/App/Program.cs")
local dap = require("dap")
local original_select, original_notify = vim.ui.select, vim.notify
local selected, message
vim.ui.select = function(items, _, done)
	for _, path in ipairs(items) do
		if selected and path:find(selected, 1, true) then
			return done(path)
		end
	end
	done(nil)
end
vim.notify = function(text)
	message = text
end
local function evaluate()
	local result
	local co = coroutine.create(function()
		result = require("config.dotnet").debug_config(dap.configurations.cs[1])
	end)
	local ok, err = coroutine.resume(co)
	assert(ok, err)
	assert(
		vim.wait(10000, function()
			return result ~= nil
		end, 20),
		"Project selector timed out"
	)
	return result
end
assert(evaluate().program == dap.ABORT, "Cancellation did not abort")
selected = "/Library/Library.csproj"
assert(evaluate().program == dap.ABORT and message:find("executable project"), "Library accepted")
selected = "/Tests/Tests.csproj"
assert(evaluate().program == dap.ABORT and message:find("executable project"), "Test project accepted")
selected = "/App/App.csproj"
local config = evaluate()
assert(config.program:match("/App/bin/Debug/net10.0/App.dll$"), "Incorrect assembly")
local readable = vim.fn.filereadable
vim.fn.filereadable = function()
	return 0
end
assert(evaluate().program == dap.ABORT and message:find("dotnet build"), "Missing build output not explained")
vim.fn.filereadable = readable
vim.ui.select, vim.notify = original_select, original_notify
print("PASS: .NET selection cancellation, library/test rejection, missing build output")
vim.cmd("qa!")
