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
					-- register which-key mappings
					local wk = require("which-key")

					wk.add({
						["<leader>cR"] = {
							function()
								vim.cmd.RustLsp("codeAction")
							end,
							"Code Action",
						},
						["<leader>dr"] = {
							function()
								vim.cmd.RustLsp("debuggables")
							end,
							"Rust debuggables",
						},
					}, { mode = "n", buffer = bufnr })
				end,
				default_settings = {
					-- rust-analyzer language server configuration
					["rust-analyzer"] = {
						check = { command = "clippy" },
						diagnostics = { enable = true },
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							runBuildScripts = true,
						},
						-- Add clippy lints for Rust.
						checkOnSave = {
							allFeatures = true,
							command = "clippy",
							extraArgs = { "--no-deps" },
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
			vim.g.rustaceanvim = vim.tbl_deep_extend("force", {}, opts or {})
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

	-- Correctly setup lspconfig for Rust 🚀
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				rust_analyzer = {},
				taplo = {
					keys = {
						{
							"K",
							function()
								local c = require("crate")
								if vim.fn.expand("%:t") == "Cargo.toml" and c.popup_available() then
									c.show_popup()
								else
									vim.lsp.buf.hover()
								end
							end,
							desc = "Show Crate Documentation",
						},
					},
				},
			},
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
