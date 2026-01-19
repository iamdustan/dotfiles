return {
	disable_formatting = true,
	formatting = false,
	autoformat = false,
	on_attach = function(client, bufnr)
		-- Disable formatting - use conform.nvim or other formatter instead
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
