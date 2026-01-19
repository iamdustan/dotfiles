return {
	-- Extend auto completion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{
				"Saecki/crates.nvim",
				event = { "BufRead Cargo.toml" },
				config = function()
					require("crates").setup()
				end,
			},
		},
		---@param opts cmp.ConfigSchema
		opts = function(_, opts)
			local cmp = require("cmp")
			opts.sources = opts.sources or {}
			opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
				{ name = "crates" },
			}))
		end,
	},
	-- Add Rust & related to treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "ron", "rust", "toml" })
		end,
	},

	-- Ensure Rust debugger is installed
	{
		"williamboman/mason.nvim",
		optional = true,
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "codelldb", "rust_analyzer" })
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy
		ft = { "rust" },
		opts = {
			server = {
				on_attach = function(client, bufnr)
					-- Rust-specific keymaps
					vim.keymap.set("n", "<leader>cR", function()
						vim.cmd.RustLsp("codeAction")
					end, {
						buffer = bufnr,
						desc = "Rust Code Action",
					})
					vim.keymap.set("n", "<leader>dr", function()
						vim.cmd.RustLsp("debuggables")
					end, {
						buffer = bufnr,
						desc = "Rust debuggables",
					})

					-- Attach navic for winbar (barbecue.nvim)
					-- Handle rust-analyzer client name
					if client.server_capabilities.documentSymbolProvider then
						local navic_ok, navic = pcall(require, "nvim-navic")
						if navic_ok and navic then
							-- Check if navic is already attached to this buffer
							-- If attached to a different client name (e.g., rust_analyzer vs rust-analyzer),
							-- clear the old attachment first
							local prev_client_name = vim.b[bufnr].navic_client_name
							if prev_client_name and prev_client_name ~= client.name then
								-- Clear the old attachment if it's a name mismatch (e.g., rust_analyzer -> rust-analyzer)
								vim.b[bufnr].navic_client_id = nil
								vim.b[bufnr].navic_client_name = nil
							end
							-- Only attach if not already attached to this client
							if not prev_client_name or prev_client_name ~= client.name then
								pcall(navic.attach, client, bufnr)
							end
						end
					end
				end,
				default_settings = {
					-- rust-analyzer language server configuration
					["rust-analyzer"] = {
						checkOnSave = true,
						check = {
							command = "clippy",
							allTargets = true,
							extraArgs = { "--no-deps" },
						},
						diagnostics = { enable = true },
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							runBuildScripts = true,
						},
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
					},
				},
			},
		},
		config = function(_, opts)
			-- rustaceanvim v6 uses vim.g.rustaceanvim for configuration
			-- Merge with any existing settings
			vim.g.rustaceanvim = vim.tbl_deep_extend("force", vim.g.rustaceanvim or {}, opts or {})
		end,
	},

	{
		"nwiizo/cargo.nvim",
		build = "cargo build --release",
		config = function()
			require("cargo").setup({
				float_window = true,
				window_width = 0.8,
				window_height = 0.8,
				border = "rounded",
				auto_close = true,
				close_timeout = 5000,
			})
		end,
		ft = { "rust" },
		cmd = {
			"CargoBench",
			"CargoBuild",
			"CargoClean",
			"CargoDoc",
			"CargoNew",
			"CargoRun",
			"CargoTest",
			"CargoUpdate",
		},
	},

	{
		"nvim-neotest/neotest",
		optional = true,
		opts = function(_, opts)
			opts.adapters = opts.adapters or {}
			vim.list_extend(opts.adapters, { require("rustaceanvim.neotest") })
		end,
	},
}
