return {
	-- Add Clojure to treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "clojure" })
		end,
	},

	-- Conjure for interactive REPL-driven development
	{
		"Olical/conjure",
		ft = { "clojure" },
		lazy = true,
		init = function()
			-- Conjure configuration
			vim.g["conjure#filetypes"] = { "clojure" }
			-- Use comment characters for evaluation output prefix rather than semicolons
			vim.g["conjure#client#clojure#nrepl#eval__res_prefix"] = ";; "
		end,
	},

	-- Extend auto completion with Conjure source
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{
				"PaterJason/cmp-conjure",
				lazy = true,
			},
		},
		---@param opts cmp.ConfigSchema
		opts = function(_, opts)
			local cmp = require("cmp")
			opts.sources = opts.sources or {}
			opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
				{ name = "conjure" },
			}))
		end,
	},

	-- Structural editing for Lisp/Clojure (S-expressions)
	{
		"julienvincent/nvim-paredit",
		ft = { "clojure" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-paredit").setup({
				use_default_keys = true,
			})
		end,
	},

	-- LSP Setup for Clojure
	{
		"neovim/nvim-lspconfig",
		init = function()
			-- Setup clojure-lsp lazily only when Clojure or EDN files are opened
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "clojure", "edn" },
				callback = function()
					-- Dynamically install clojure-lsp if it's not installed via Mason
					local mason_registry_ok, mr = pcall(require, "mason-registry")
					if mason_registry_ok then
						local p = mr.get_package("clojure-lsp")
						if p and not p:is_installed() then
							vim.notify("Clojure LSP is not installed. Installing it automatically...", vim.log.levels.INFO)
							p:install({}, function(success)
								if success then
									vim.schedule(function()
										vim.notify("Clojure LSP installed successfully!", vim.log.levels.INFO)
										-- Start/attach the client to the current buffer
										vim.cmd("LspStart clojure_lsp")
									end)
								else
									vim.schedule(function()
										vim.notify("Failed to install Clojure LSP via Mason.", vim.log.levels.ERROR)
									end)
								end
							end)
						end
					end

					local lspconfig = require("lspconfig")
					if not lspconfig.clojure_lsp.document_config then
						local capabilities = vim.lsp.protocol.make_client_capabilities()
						local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
						if cmp_lsp_ok then
							capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
						end

						local on_attach = function(client, bufnr)
							local format_ok, format = pcall(require, "plugins.lsp.format")
							if format_ok then
								format.on_attach(client, bufnr)
							end
							local keymaps_ok, keymaps = pcall(require, "plugins.lsp.keymaps")
							if keymaps_ok then
								keymaps.on_attach(client, bufnr)
							end
							if client.server_capabilities.documentSymbolProvider then
								local navic_ok, navic = pcall(require, "nvim-navic")
								if navic_ok and navic then
									pcall(navic.attach, client, bufnr)
								end
							end
						end

						lspconfig.clojure_lsp.setup({
							capabilities = capabilities,
							on_attach = on_attach,
						})
					end
				end,
			})
		end,
	},
}
