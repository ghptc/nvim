vim.g.mapleader = " "

local keymap = vim.keymap.set

keymap("n", "<leader>w", "<cmd>w<CR>")
keymap("n", "<leader>q", "<cmd>q<CR>")

keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

keymap("n", "<leader>h", "<C-w>h")
keymap("n", "<leader>j", "<C-w>j")
keymap("n", "<leader>k", "<C-w>k")
keymap("n", "<leader>l", "<C-w>l")

vim.keymap.set("n", "<leader>ce", function()
	vim.diagnostic.open_float({
		scope = "cursor",
		border = "rounded",
		focusable = true,
	})
end, { desc = "Show code error" })

keymap("n", "<leader>db", function()
	require("config.dotnet").task("build")
end, { desc = "dotnet build" })
keymap("n", "<leader>dt", function()
	require("config.dotnet").task("test")
end, { desc = "dotnet test" })
keymap("n", "<leader>cf", function()
	require("conform").format({ lsp_format = "fallback", timeout_ms = 3000 })
end, { desc = "Format buffer" })

local function run_dotnet_project()
	local current_file = vim.api.nvim_buf_get_name(0)

	if current_file == "" then
		vim.notify("No file open", vim.log.levels.ERROR)
		return
	end

	local dir = vim.fs.dirname(current_file)
	local project

	-- Search upwards for the nearest .csproj
	while dir do
		local projects = vim.fn.globpath(dir, "*.csproj", false, true)

		if #projects > 0 then
			if #projects == 1 then
				project = projects[1]
			else
				project = vim.fn.inputlist(vim.list_extend(
					{ "Select .NET project:" },
					vim.tbl_map(function(p)
						return vim.fn.fnamemodify(p, ":t")
					end, projects)
				))

				project = projects[project]
			end
			break
		end

		local parent = vim.fs.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end

	if not project then
		vim.notify("No .csproj found", vim.log.levels.ERROR)
		return
	end

	-- Open terminal at the bottom
	vim.cmd("botright 12new")
	local command = "dotnet run --project " .. vim.fn.shellescape(project)
	vim.fn.termopen(command)
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>cr", run_dotnet_project, {
	desc = "Run current .NET project",
})
