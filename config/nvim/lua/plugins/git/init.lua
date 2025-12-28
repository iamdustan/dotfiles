return {
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = true,
	},
	{
		"TimUntersberger/neogit",
		cmd = "Neogit",
		opts = {
			integrations = { diffview = true },
		},
		keys = {
			{ "<leader>gs", "<cmd>Neogit kind=floating<cr>", desc = "Status" },
		},
	},
	{
		"kdheepak/lazygit.vim",
		event = "VeryLazy",
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	-- :GBrowse
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
		keys = {
			{ "<leader>gb", "<cmd>GBrowse<cr>", desc = "Open file in GitHub" },
		},
	},
	{ "tpope/vim-rhubarb", event = "VeryLazy" },
}
