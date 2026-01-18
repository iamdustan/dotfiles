local M = {}

local servers = {
	lua_ls = {
		settings = {
			Lua = {
				workspace = {
					checkThirdParty = false,
				},
				completion = { callSnippet = "Replace" },
				telemetry = { enable = false },
				hint = {
					enable = false,
				},
			},
		},
	},
	ts_ls = {
		disable_formatting = true,
		formatting = false,
		autoformat = false,
	},
	bashls = {},
	dockerls = {},
	clangd = {},
	harper_ls = {
		settings = {
			["harper-ls"] = {
				linters = {
					SentenceCapitalization = false,
					ToDoHyphen = false,
					SpellCheck = false,
				},
			},
		},
	},
}

local function lsp_attach(on_attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local bufnr = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			on_attach(client, bufnr)
		end,
	})
end

local function lsp_capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	return require("cmp_nvim_lsp").default_capabilities(capabilities)
end

function M.setup(_)
	lsp_attach(function(client, buffer)
		require("plugins.lsp.format").on_attach(client, buffer)
		require("plugins.lsp.keymaps").on_attach(client, buffer)
	end)

	require("mason-lspconfig").setup({ ensure_installed = vim.tbl_keys(servers) })
end

return M
