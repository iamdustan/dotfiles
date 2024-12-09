return {
	{
		"folke/styler.nvim",
		event = "VeryLazy",
		config = function()
			require("styler").setup({
				themes = {
					markdown = { colorscheme = "gruvbox" },
					help = { colorscheme = "gruvbox" },
				},
			})
		end,
	},

	---
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			local tokyonight = require("tokyonight")
			tokyonight.setup({ style = "storm" })
			tokyonight.load()
		end,
	},
	---
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 999,
		config = function()
			local catpuccin = require("catppuccin")
			-- catpuccin.setup({ flavour = "latte" })
			--catpuccin.setup({ flavour = "frappe" })
			catpuccin.setup({ flavour = "macchiato" })
			-- catpuccin.setup({ flavour = "mocha" })
			catpuccin.load()
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("gruvbox").setup()
		end,
	},
}
