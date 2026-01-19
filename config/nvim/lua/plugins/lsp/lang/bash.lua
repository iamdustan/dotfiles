return {
	settings = {
		bashIde = {
			-- Enable glob pattern support
			globPattern = "**/*@(.sh|.inc|.bash|.command)",
			-- Enable shellcheck integration if available
			explainshellEndpoint = "",
			-- Enable highlighting of variables
			highlightVariables = true,
			-- Debug setting to verify config is loaded
			debug = true,
		},
	},
}
