local M = {}

local servers = {
	--[[
	-- FIXME copied from plugins/extras/lang/rust.lua
	["rust-analyzer"] = {
		check = { command = "clippy" },
		diagnostics = { enable = true },
		cargo = {
			allFeatures = true,
			loadOutDirsFromCheck = true,
			runBuildScripts = true,
		},
		-- Add clippy lints for Rust.
		checkOnSave = {
			allFeatures = true,
			command = "clippy",
			extraArgs = { "--no-deps" },
		},
		procMacro = {
			enable = true,
			ignored = {
				["async-trait"] = { "async_trait" },
				["napi-derive"] = { "napi" },
				["async-recursion"] = { "async_recursion" },
			},
		},
	},
  --]]

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

	require("mason-lspconfig").setup({
		ensure_installed = vim.tbl_keys(servers),
	})
end

return M
