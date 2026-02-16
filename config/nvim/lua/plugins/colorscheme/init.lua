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

			-- Start a server at a predictable path so bin/theme can send ThemeReload to this instance
			local theme_sock = (vim.fn.has("win32") == 1 and os.getenv("TEMP") or "/tmp")
				.. "/nvim-theme-sync-"
				.. vim.fn.getpid()
			pcall(vim.fn.serverstart, theme_sock)

			local function theme_flavour()
				local theme_mode_path = vim.fn.expand("~/.theme-mode")
				local content = ""
				if vim.fn.filereadable(theme_mode_path) == 1 then
					local lines = vim.fn.readfile(theme_mode_path)
					content = vim.trim(lines[1] or "")
				end
				if content == "light" then
					return "latte"
				end
				if content == "dark" then
					return "mocha"
				end
				-- Fallback: read OS (macOS)
				if vim.fn.has("mac") == 1 then
					local ok, result = pcall(vim.fn.system, "defaults read -g AppleInterfaceStyle 2>/dev/null")
					if ok and result and vim.trim(result):lower():match("dark") then
						return "mocha"
					end
				end
				return "mocha"
			end

			local flavour = theme_flavour()
			catpuccin.setup({ flavour = flavour })
			catpuccin.load()

			-- Reload theme from ~/.theme-mode (used by bin/theme to live-reload)
			vim.api.nvim_create_user_command("ThemeReload", function()
				local f = theme_flavour()
				require("catppuccin").load(f)
			end, {})
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
