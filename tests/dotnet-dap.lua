local root = assert(vim.env.NVIM_DOTNET_FIXTURE, "Set NVIM_DOTNET_FIXTURE")
vim.cmd.edit(root .. "/App/Program.cs")
local dap = require("dap")
local select = vim.ui.select
vim.ui.select = function(items, opts, done)
	for _, item in ipairs(items) do
		if type(item) == "string" and item:match("/App/App.csproj$") then
			return done(item)
		end
	end
	select(items, opts, done)
end
local stopped = 0
local reason
dap.listeners.after.event_stopped.validation = function(_, event)
	stopped = stopped + 1
	reason = event.reason
end
vim.api.nvim_win_set_cursor(0, { 2, 0 })
dap.toggle_breakpoint()
dap.run(dap.configurations.cs[1])
assert(
	vim.wait(30000, function()
		return stopped > 0
	end, 100),
	"Debugger did not stop at a breakpoint"
)
assert(reason == "breakpoint", "Expected breakpoint stop, got " .. tostring(reason))
local session = assert(dap.session())
assert(session.config.program == root .. "/App/bin/Debug/net10.0/App.dll", "Wrong selected assembly")
assert(session.config.cwd == root .. "/App", "Wrong launch directory")
local function request(method, args)
	local done, result, err
	session:request(method, args, function(e, r)
		err, result, done = e, r, true
	end)
	assert(
		vim.wait(10000, function()
			return done
		end, 20),
		method .. " timed out"
	)
	assert(not err, vim.inspect(err))
	return result
end
assert(
	vim.wait(5000, function()
		return session.stopped_thread_id ~= nil
	end, 20),
	"No stopped thread"
)
local stack = request("stackTrace", { threadId = session.stopped_thread_id })
assert(#stack.stackFrames > 0, "No call stack")
local scopes = request("scopes", { frameId = stack.stackFrames[1].id })
assert(#scopes.scopes > 0, "No scopes")
local variables = request("variables", { variablesReference = scopes.scopes[1].variablesReference })
assert(#variables.variables > 0, "No variables response")
local function step(fn)
	local before = stopped
	fn()
	assert(
		vim.wait(10000, function()
			return stopped > before
		end, 20),
		"Step did not stop"
	)
end
step(dap.step_into)
assert(vim.wait(5000, function()
	return session.stopped_thread_id ~= nil
end, 20))
local library_stack = request("stackTrace", { threadId = session.stopped_thread_id })
assert(library_stack.stackFrames[1].source.path == root .. "/Library/Class1.cs", "Step Into missed library")
step(dap.step_out)
step(dap.step_over)
assert(vim.wait(5000, function()
	return session.stopped_thread_id ~= nil
end, 20))
local current_stack = request("stackTrace", { threadId = session.stopped_thread_id })
local current_scopes = request("scopes", { frameId = current_stack.stackFrames[1].id })
local found_answer = false
for _, scope in ipairs(current_scopes.scopes) do
	local values = request("variables", { variablesReference = scope.variablesReference })
	for _, value in ipairs(values.variables) do
		if value.name == "answer" and value.value == "42" then
			found_answer = true
		end
	end
end
assert(found_answer, "Could not inspect answer = 42")
dap.continue()
assert(
	vim.wait(10000, function()
		return dap.session() == nil
	end, 20),
	"Debuggee did not exit"
)
print("PASS: project/assembly selection, breakpoint, call stack, variables, step into/out/over, continue")
vim.cmd("qa!")
