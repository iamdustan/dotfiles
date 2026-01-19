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

	-- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
	{
		"nvimtools/none-ls.nvim",
		event = "BufReadPre",
		dependencies = { "mason.nvim", "nvimtools/none-ls-extras.nvim" },
		config = function()
			local nls = require("null-ls")
			nls.setup({
				sources = {
					-- lua
					nls.builtins.formatting.stylua,

					-- javascript
					-- nls.builtins.formatting.prettier,
					-- require("none-ls.diagnostics.eslint_d"),
					-- clojure
					-- nls.builtins.formatting.cljstyle,

					-- cpp
					nls.builtins.diagnostics.cppcheck,
					nls.builtins.formatting.clang_format,
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

	{ import = "plugins.extras.lang" },
}
