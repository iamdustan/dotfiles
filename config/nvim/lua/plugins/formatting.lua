--- **Formatting Configuration**
---
--- This file configures
--- [conform.nvim](https://github.com/stevearc/conform.nvim), which is the primary formatter engine.
--- It defines which formatters to use for each filetype and sets up formatter
--- detection logic, based on my preferences (default) + project-specific configuration (overrides).

return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					rust = { "rustfmt" },
					-- C/C++
					c = { "clang_format" },
					cpp = { "clang_format" },
					-- TypeScript/JavaScript: auto-detect from project config
					javascript = { "biome", "prettierd", "prettier" },
					javascriptreact = { "biome", "prettierd", "prettier" },
					typescript = { "biome", "prettierd", "prettier" },
					typescriptreact = { "biome", "prettierd", "prettier" },
					json = { "biome", "prettierd", "prettier" },
					jsonc = { "biome", "prettierd", "prettier" },
				},

				-- Format on save is handled by plugins/lsp/format.lua
				-- which provides toggle functionality and respects autoformat setting
				format_on_save = false,

				-- Custom formatter detection based on project config files
				formatters = {
					biome = {
						condition = function(ctx)
							-- Only use biome if biome.json exists in project root
							local dir = vim.fs.dirname(ctx.filename)
							local root = vim.fs.find({ "biome.json", "biome.jsonc" }, { path = dir, upward = true })[1]
							return root ~= nil
						end,
					},
					prettierd = {
						condition = function(ctx)
							-- Use prettierd if prettier config exists but not biome
							local dir = vim.fs.dirname(ctx.filename)
							local has_biome = vim.fs.find(
								{ "biome.json", "biome.jsonc" },
								{ path = dir, upward = true }
							)[1] ~= nil
							if has_biome then
								return false
							end
							local prettier_configs = {
								".prettierrc",
								"prettier.config.js",
								"prettier.config.cjs",
								"prettier.config.mjs",
								".prettierrc.json",
								".prettierrc.yaml",
								".prettierrc.yml",
								".prettierrc.js",
								".prettierrc.cjs",
								".prettierrc.mjs",
								"package.json", -- might contain prettier config
							}
							for _, config in ipairs(prettier_configs) do
								if vim.fs.find(config, { path = dir, upward = true })[1] then
									return true
								end
							end
							return false
						end,
					},
					prettier = {
						condition = function(ctx)
							-- Fallback to prettier if no biome or prettierd config
							local dir = vim.fs.dirname(ctx.filename)
							local has_biome = vim.fs.find(
								{ "biome.json", "biome.jsonc" },
								{ path = dir, upward = true }
							)[1] ~= nil
							if has_biome then
								return false
							end
							-- If prettierd condition would be true, use prettierd instead
							-- This is a fallback, so return true for any JS/TS file
							return true
						end,
					},
				},
			})

			-- Keymaps
			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				conform.format({ async = true, lsp_fallback = true })
			end, { desc = "Format" })
		end,
	},
}
