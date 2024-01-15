--  Fancy statusline
return {
	{
		"MunifTanjim/nougat.nvim",
		event = "VeryLazy",
		config = function()
			-- require("plugins/statusline/bubbly")
			require("plugins/statusline/pointy")
			-- require("plugins/statusline/slanty")
		end,
	},
}
