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
			require("telescope").load_extension("file_browser")
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
