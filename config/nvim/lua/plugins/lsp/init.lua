return {
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			-- 💼 Neovim plugin to manage global and project-local settings
			{ "folke/neoconf.nvim", cmd = "Neoconf", config = true },
			--  💻 Neovim setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API.
			{ "folke/neodev.nvim", config = true },
			-- Standalone UI for nvim-lsp progress. Eye candy for the impatient
			{ "j-hui/fidget.nvim", config = true },
			-- Incremental LSP renaming based on Neovim's command-preview feature.
			{ "smjonas/inc-rename.nvim", config = true },

			--  Tools for better development in rust using neovim's builtin lsp
			"simrat39/rust-tools.nvim",
			"rust-lang/rust.vim",

			--  Easily install and manage LSP servers, DAP servers, linters, and formatters.
			"williamboman/mason.nvim",
			-- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim. Strongly recommended for Windows users.
			"williamboman/mason-lspconfig.nvim",

			-- nvim-cmp source for neovim's built-in language server client.
			"hrsh7th/cmp-nvim-lsp",
			-- nvim-cmp source for displaying function signatures with the current parameter emphasized:
			"hrsh7th/cmp-nvim-lsp-signature-help",
		},
		config = function(plugin)
			require("plugins.lsp.servers").setup(plugin)
		end,
	},

	--  Easily install and manage LSP servers, DAP servers, linters, and formatters.
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		ensure_installed = {
			"stylua",
		},
		config = function(plugin)
			require("mason").setup()
			local mr = require("mason-registry")
			for _, tool in ipairs(plugin.ensure_installed) do
				local p = mr.get_package(tool)
				if not p:is_installed() then
					p:install()
				end
			end
		end,
	},

	-- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.

	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "BufReadPre",
		dependencies = { "mason.nvim" },
		config = function()
			local nls = require("null-ls")
			nls.setup({
				sources = {
					nls.builtins.formatting.stylua,
				},
			})
		end,
	},

	-- A VS Code like winbar for Neovim
	{
		"utilyre/barbecue.nvim",
		event = "VeryLazy",
		dependencies = {
			"neovim/nvim-lspconfig",
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		config = true,
	},
}
