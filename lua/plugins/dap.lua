return {
	{
		"mfussenegger/nvim-dap",

		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim",
			{
				"Joakker/lua-json5",
				lazy = true,
			},
		},

		config = function()
			local dap = require("dap")

			pcall(function()
				require("dap.ext.vscode").load_launchjs(nil, {
					["pwa-node"] = {
						"javascript",
						"typescript",
					},
					["pwa-chrome"] = {
						"javascriptreact",
						"typescriptreact",
					},
					["coreclr"] = {
						"cs",
					},
				})
			end)

			local function find_dotnet_dll()
				local cwd = vim.fn.getcwd()

				local dlls = vim.fn.glob(cwd .. "/bin/Debug/net*/*.dll", false, true)

				if #dlls == 0 then
					vim.notify("No DLL found. Run dotnet build first.", vim.log.levels.ERROR)
					return nil
				end

				if #dlls == 1 then
					return dlls[1]
				end

				return vim.fn.input("DLL: ", dlls[1], "file")
			end

			dap.adapters.coreclr = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch .NET",
					request = "launch",
					program = find_dotnet_dll,
				},
			}

			dap.configurations.fsharp = dap.configurations.cs
			dap.configurations.vb = dap.configurations.cs

			dap.adapters["pwa-node"] = {
				type = "server",
				host = "127.0.0.1",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
						"127.0.0.1",
					},
				},
			}

			for _, language in ipairs({
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
			}) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch current file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
				}
			end

			local dapui = require("dapui")

			require("dapui").setup()

			require("nvim-dap-virtual-text").setup()

			require("mason-nvim-dap").setup({
				automatic_installation = true,
			})

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end

			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end

			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end

			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			local map = vim.keymap.set

			map("n", "<F5>", dap.continue)
			map("n", "<F10>", dap.step_over)
			map("n", "<F11>", dap.step_into)
			map("n", "<F12>", dap.step_out)

			map("n", "<leader>b", dap.toggle_breakpoint)
			map("n", "<leader>dr", dap.repl.open)
			map("n", "<leader>du", dapui.toggle)
		end,
	},
}
