return {
	"ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- Installs `mcp-hub` node binary globally
	build = "npm install -g mcp-hub@latest",
	config = function()
		require("mcphub").setup({
			extensions = {
				avante = {
					-- make /slash commands from MCP server prompts
					make_slash_commands = true,
				},
			},
		})
	end,
}
