local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
vim.fn.writefile({ "{}" }, root .. "/package.json")
vim.fn.writefile({ "{}" }, root .. "/.luarc.json")
vim.fn.writefile({ "local answer = 42", "print(answer)" }, root .. "/main.lua")
vim.fn.writefile({ "const answer: number = 42;", "console.log(answer);" }, root .. "/main.ts")
vim.fn.writefile({ "int main() { int answer = 42; return answer; }" }, root .. "/main.cpp")
vim.fn.writefile({ "-std=c++17" }, root .. "/compile_flags.txt")
for _, item in ipairs({ { "lua", "lua_ls", 1, 8 }, { "ts", "ts_ls", 0, 8 }, { "cpp", "clangd", 0, 17 } }) do
	vim.cmd.edit(root .. "/main." .. item[1])
	assert(
		vim.wait(20000, function()
			return #vim.lsp.get_clients({ name = item[2], bufnr = 0 }) == 1
		end, 100),
		item[2] .. " did not attach"
	)
	local client = vim.lsp.get_clients({ name = item[2], bufnr = 0 })[1]
	local hover
	assert(
		vim.wait(10000, function()
			local r = client:request_sync(
				"textDocument/hover",
				{ textDocument = { uri = vim.uri_from_bufnr(0) }, position = { line = item[3], character = item[4] } },
				5000,
				0
			)
			hover = r and r.result
			return hover and hover ~= vim.NIL
		end, 100),
		item[2] .. " hover failed"
	)
	print("PASS: " .. item[2] .. " attach and hover")
end
vim.cmd("qa!")
