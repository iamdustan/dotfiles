return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{ "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
			{ "<leader>f/", "<cmd>Telescope live_grep<cr>", desc = "Grep" },

			-- NERDTree open bindings
			-- { "<leader>n", "<cmd>Telescope file_browser<cr><esc>", },
			-- Ctrl-p ftw
			{ "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
		},
		dependencies = {
			"nvim-telescope/telescope-file-browser.nvim",
		},

		config = function()
			local telescope = require("telescope")

			telescope.setup({
				defaults = {
					-- Show hidden + gitignored files everywhere, but never the noise.
					file_ignore_patterns = { "%.git/", "node_modules/" },
					-- live_grep / grep_string: ripgrep flags to include hidden + ignored.
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
					},
				},
				pickers = {
					find_files = {
						-- fd flags: --hidden shows dotfiles, but still respect .gitignore.
						hidden = true,
					},
				},
				extensions = {
					file_browser = {
						hidden = true,
						respect_gitignore = false,
					},
				},
			})

			telescope.load_extension("file_browser")
		end,
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sharkdp/fd",
		},
	},
}
