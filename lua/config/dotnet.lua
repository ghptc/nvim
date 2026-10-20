local M = {}

local function solution(name)
	return name:match("%.slnx?$") ~= nil
end

local function project(name)
	return name:match("%.csproj$") or name:match("%.fsproj$") or name:match("%.vbproj$")
end

local function find(root, predicate, recursive)
	local files = {}
	for name, kind in
		vim.fs.dir(root, {
			depth = recursive and math.huge or 1,
			skip = function(dir)
				return not vim.tbl_contains({ "bin", "obj", ".git", "node_modules" }, vim.fs.basename(dir))
			end,
		})
	do
		if kind == "file" and predicate(vim.fs.basename(name)) then
			files[#files + 1] = vim.fs.joinpath(root, name)
		end
	end
	table.sort(files)
	return files
end

function M.root()
	if vim.b.dotnet_root then
		return vim.b.dotnet_root
	end
	local file = vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) or ""
	local start = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
	local target = vim.fs.find(solution, { path = start, upward = true, type = "file" })[1]
	if target then
		return vim.fs.dirname(target)
	end
	return vim.fs.root(start, ".git")
		or vim.fs.dirname(vim.fs.find(project, { path = start, upward = true, type = "file" })[1] or (start .. "/."))
end

-- These helpers run in nvim-dap's configuration coroutine. Always schedule the
-- continuation: vim.ui.select implementations may call back synchronously.
local function await(start)
	local co = coroutine.running()
	start(function(value)
		vim.schedule(function()
			local ok, err = coroutine.resume(co, value)
			if not ok then
				vim.notify(tostring(err), vim.log.levels.ERROR)
			end
		end)
	end)
	return coroutine.yield()
end

local function select(items, prompt, format)
	if #items == 1 then
		return items[1]
	end
	return await(function(done)
		vim.ui.select(items, { prompt = prompt, format_item = format }, done)
	end)
end

local function properties(project, framework)
	local args = {
		"dotnet",
		"msbuild",
		project,
		"-nologo",
		"-p:Configuration=Debug",
		"-getProperty:OutputType,IsTestProject,TargetPath,TargetFramework,TargetFrameworks",
	}
	if framework then
		table.insert(args, "-p:TargetFramework=" .. framework)
	end
	local result = await(function(done)
		vim.system(args, { text = true, timeout = 30000 }, done)
	end)
	if result.code ~= 0 then
		return nil, result.stderr .. result.stdout
	end
	local ok, data = pcall(vim.json.decode, result.stdout)
	if not ok then
		return nil, result.stdout
	end
	return data.Properties
end

function M.debug_config(config)
	local result = vim.deepcopy(config)
	setmetatable(result, nil)
	result.program = require("dap").ABORT
	local projects = find(M.root(), project, true)
	if #projects == 0 then
		vim.notify("No .NET projects found in " .. M.root(), vim.log.levels.ERROR)
		return result
	end
	local project = select(projects, "Launch project (Debug):", function(path)
		return vim.fs.relpath(M.root(), path) or path
	end)
	if not project then
		return result
	end
	local props, err = properties(project)
	if not props then
		vim.notify("MSBuild could not evaluate " .. project .. ":\n" .. err, vim.log.levels.ERROR)
		return result
	end
	if props.TargetFrameworks ~= "" then
		local framework = select(vim.split(props.TargetFrameworks, ";", { trimempty = true }), "Target framework:")
		if not framework then
			return result
		end
		props, err = properties(project, framework)
		if not props then
			vim.notify("MSBuild evaluation failed: " .. err, vim.log.levels.ERROR)
			return result
		end
	end
	if props.IsTestProject == "true" or not vim.tbl_contains({ "Exe", "WinExe" }, props.OutputType) then
		vim.notify(
			"Select an executable project; libraries and test projects cannot be launched.",
			vim.log.levels.ERROR
		)
		return result
	end
	if vim.fn.filereadable(props.TargetPath) ~= 1 then
		vim.notify(
			"No build output at " .. props.TargetPath .. ". Run dotnet build " .. project .. " -c Debug first.",
			vim.log.levels.ERROR
		)
		return result
	end
	result.program = props.TargetPath
	result.cwd = vim.fs.dirname(project)
	return result
end

function M.task(action)
	local root = M.root()
	local targets = find(root, solution, false)
	if #targets == 0 then
		targets = find(root, project, true)
	end
	local function run(target)
		if not target then
			return
		end
		vim.cmd("botright new")
		vim.b.dotnet_root = root
		vim.fn.jobstart({ "dotnet", action, target }, { term = true, cwd = root })
	end
	if #targets == 1 then
		run(targets[1])
	elseif #targets > 1 then
		vim.ui.select(targets, { prompt = "dotnet " .. action .. ":" }, run)
	else
		vim.notify("No .NET solution or project in " .. root, vim.log.levels.ERROR)
	end
end

return M
