return {
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			-- 💼 Neovim plugin to manage global and project-local settings
			{ "folke/neoconf.nvim", cmd = "Neoconf", config = true },
			-- Standalone UI for nvim-lsp progress. Eye candy for the impatient
			{ "j-hui/fidget.nvim", tag = "legacy", event = "LspAttach", config = true },
			-- Incremental LSP renaming based on Neovim's command-preview feature.
			{ "smjonas/inc-rename.nvim", config = true },

			--  Easily install and manage LSP servers, DAP servers, linters, and formatters.
			"williamboman/mason.nvim",
			-- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim.
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
			require("mason").setup({
				PATH = "append",
			})
			local mr = require("mason-registry")
			for _, tool in ipairs(plugin.ensure_installed) do
				local p = mr.get_package(tool)
				if not p:is_installed() then
					p:install()
				end
			end
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
		opts = {
			attach_navic = false, -- Disable auto-attach to avoid conflicts with rustaceanvim
			create_autocmd = true, -- Auto-update winbar
			-- Exclude certain filetypes if needed
			exclude_filetypes = { "netrw", "toggleterm" },
		},
		config = function(_, opts)
			-- Explicitly set up navic with auto-attach disabled
			-- This prevents navic from creating its own LspAttach autocmd
			local navic_ok, navic = pcall(require, "nvim-navic")
			if navic_ok and navic then
				navic.setup({
					lsp = {
						auto_attach = false, -- Disable auto-attach, we'll handle it manually
					},
				})
			end
			require("barbecue").setup(opts)
		end,
	},

	{ import = "plugins.extras.lang" },
}
