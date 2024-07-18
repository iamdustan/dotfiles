return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")
		wk.setup({
			show_help = false,
			plugins = { spelling = true },
			key_labels = { ["<leader>"] = "SPC" },
			triggers = "auto",
		})
		wk.add({

			{
				{ "<leader>c", group = "Code" },
				{ "<leader>cX", group = "Swap Previous" },
				{ "<leader>cXc", desc = "Class" },
				{ "<leader>cXf", desc = "Function" },
				{ "<leader>cXp", desc = "Parameter" },
				{ "<leader>cx", group = "Swap Next" },
				{ "<leader>cxc", desc = "Class" },
				{ "<leader>cxf", desc = "Function" },
				{ "<leader>cxp", desc = "Parameter" },
				{ "<leader>d", group = "Debugger" },
				{ "<leader>f", group = "File" },
				{ "<leader>g", group = "Git" },
				{ "<leader>q", "<cmd>lua require('util').smart_quit()<CR>", desc = "Quit" },
				{ "<leader>t", group = "VimTest" },
				{ "<leader>w", "<cmd>update!<CR>", desc = "Save" },
			},
		})
	end,
}
