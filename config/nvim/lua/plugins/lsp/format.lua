--- **LSP Formatting Integration**
---
--- This module provides the format-on-save functionality and bridges conform.nvim
--- with the LSP system. It is called when LSP clients attach to buffers and sets
--- up autocmds to format on save.
---
--- @see plugins/formatting.lua For conform.nvim formatter configuration
--- @see plugins/lsp/servers.lua For LSP client attachment and on_attach calls

local M = {}

M.autoformat = true

function M.toggle()
	M.autoformat = not M.autoformat
	vim.notify(M.autoformat and "Enabled format on save" or "Disabled format on save")
end

function M.format()
	local conform_ok, conform = pcall(require, "conform")
	if conform_ok then
		conform.format({ async = true, lsp_fallback = true })
	else
		-- Fallback to LSP formatting
		vim.lsp.buf.format({
			bufnr = vim.api.nvim_get_current_buf(),
		})
	end
end

function M.on_attach(client, buf)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("LspFormat." .. buf, {}),
			buffer = buf,
			callback = function()
				if M.autoformat then
					M.format()
				end
			end,
		})
	end
end

return M
