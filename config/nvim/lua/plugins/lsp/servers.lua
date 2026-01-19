local M = {}

local lspconfig = require("lspconfig")

-- Map server names to their language configuration files
local server_configs = {
	lua_ls = require("plugins.lsp.lang.lua"),
	ts_ls = require("plugins.lsp.lang.typescript"),
	bashls = require("plugins.lsp.lang.bash"),
	dockerls = require("plugins.lsp.lang.docker"),
	clangd = require("plugins.lsp.lang.cpp"),
	taplo = require("plugins.lsp.lang.taplo"),
	harper_ls = require("plugins.lsp.lang.harper"),
	-- rust_analyzer is handled by rustaceanvim in extras/lang/rust.lua
	rust_analyzer = {},
}

local function lsp_attach(on_attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local bufnr = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client then
				on_attach(client, bufnr)
			end
		end,
	})
end

local function lsp_capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	return require("cmp_nvim_lsp").default_capabilities(capabilities)
end

function M.setup(_)
	local capabilities = lsp_capabilities()

	lsp_attach(function(client, buffer)
		require("plugins.lsp.format").on_attach(client, buffer)
		require("plugins.lsp.keymaps").on_attach(client, buffer)

		-- Handle server-specific on_attach if defined
		local server_name = client.name
		local server_config = server_configs[server_name]
		if server_config and server_config.on_attach then
			server_config.on_attach(client, buffer)
		end

		-- For harper_ls, send filetype-specific settings via workspace/didChangeConfiguration
		-- This is needed because harper_ls doesn't always pick up settings from initial config
		-- and we use different rules based on filetype
		if server_name == "harper_ls" and server_config then
			local function send_harper_settings()
				if client and not client.is_stopped() then
					-- Get filetype-specific settings if get_settings function is available
					local settings = server_config.settings
					if server_config.get_settings then
						local filetype = vim.bo[buffer].filetype
						local filetype_settings = server_config.get_settings(filetype)
						if filetype_settings then
							settings = filetype_settings
						end
					end

					if settings then
						client.notify("workspace/didChangeConfiguration", {
							settings = settings,
						})
					end
				end
			end

			-- Send settings after attach
			vim.defer_fn(send_harper_settings, 200)

			-- Also send settings when filetype changes
			vim.api.nvim_create_autocmd("FileType", {
				buffer = buffer,
				callback = function()
					vim.defer_fn(send_harper_settings, 100)
				end,
			})
		end

		-- Handle server-specific keys if defined
		if server_config and server_config.keys then
			local wk_ok, wk = pcall(require, "which-key")
			for _, keymap in ipairs(server_config.keys) do
				local mode = keymap.mode or "n"
				local lhs = keymap[1]
				local rhs = keymap[2] or keymap.rhs
				local desc = keymap.desc
				local opts = keymap.opts or {}

				if wk_ok and wk then
					wk.register({ [lhs] = { rhs, desc } }, { mode = mode, buffer = buffer })
				else
					vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = buffer, desc = desc }, opts))
				end
			end
		end
	end)

	require("mason-lspconfig").setup({
		ensure_installed = vim.tbl_keys(server_configs),
		handlers = {
			function(server_name)
				local config = server_configs[server_name]
				if not config then
					return
				end

				-- Build the server configuration and settings
				local server_opts = { capabilities = capabilities }
				if config.settings then
					server_opts.settings = config.settings
				end

				lspconfig[server_name].setup(server_opts)
			end,
		},
	})
end

return M
