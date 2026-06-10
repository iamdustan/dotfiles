-- Requires Neovim 0.12+, tree-sitter CLI >= 0.26.1, and a C compiler.

local ensure_installed = {
	"bash",
	"vimdoc",
	"html",
	"graphql",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"query",
	"regex",
	"tsx",
	"typescript",
	"vim",
	"yaml",
}

local indent_disabled = {
	python = true,
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		opts = { ensure_installed = ensure_installed },
		config = function(_, opts)
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			if opts.ensure_installed and #opts.ensure_installed > 0 then
				require("nvim-treesitter").install(opts.ensure_installed)
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("dustan.treesitter", { clear = true }),
				callback = function(ev)
					local ft = ev.match
					local lang = vim.treesitter.language.get_lang(ft) or ft
					if not lang or lang == "" then
						return
					end

					local ok = pcall(vim.treesitter.get_parser, ev.buf, lang)
					if not ok then
						return
					end

					pcall(vim.treesitter.start, ev.buf, lang)

					if not indent_disabled[ft] then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- Incremental selection (gnn / grn / grc / grm).
			local sel_stack = {}

			local function node_to_visual(node)
				if not node then
					return
				end
				local srow, scol, erow, ecol = node:range()
				vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
				vim.cmd("normal! v")
				if ecol == 0 then
					vim.api.nvim_win_set_cursor(0, { erow, 0 })
					vim.cmd("normal! h")
				else
					vim.api.nvim_win_set_cursor(0, { erow + 1, math.max(ecol - 1, 0) })
				end
			end

			vim.keymap.set("n", "gnn", function()
				local node = vim.treesitter.get_node()
				if not node then
					return
				end
				sel_stack = { node }
				node_to_visual(node)
			end, { desc = "TS: init selection" })

			vim.keymap.set("x", "grn", function()
				local node = sel_stack[#sel_stack] or vim.treesitter.get_node()
				local parent = node and node:parent()
				if not parent then
					return
				end
				table.insert(sel_stack, parent)
				node_to_visual(parent)
			end, { desc = "TS: expand to parent node" })

			vim.keymap.set("x", "grc", function()
				local node = sel_stack[#sel_stack] or vim.treesitter.get_node()
				if not node then
					return
				end
				local target = node:parent()
				while target and target:parent() and target:start() == node:start() and target:end_() == node:end_() do
					target = target:parent()
				end
				if target then
					table.insert(sel_stack, target)
					node_to_visual(target)
				end
			end, { desc = "TS: expand to scope" })

			vim.keymap.set("x", "grm", function()
				if #sel_stack > 1 then
					table.remove(sel_stack)
				end
				node_to_visual(sel_stack[#sel_stack])
			end, { desc = "TS: shrink selection" })
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
				},
				move = {
					set_jumps = true,
				},
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")
			local swap = require("nvim-treesitter-textobjects.swap")

			local select_maps = {
				aa = "@parameter.outer",
				ia = "@parameter.inner",
				af = "@function.outer",
				["if"] = "@function.inner",
				ac = "@class.outer",
				ic = "@class.inner",
			}
			for lhs, query in pairs(select_maps) do
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(query, "textobjects")
				end, { desc = "TS select " .. query })
			end

			local move_maps = {
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			}
			for fn, maps in pairs(move_maps) do
				for lhs, query in pairs(maps) do
					vim.keymap.set({ "n", "x", "o" }, lhs, function()
						move[fn](query, "textobjects")
					end, { desc = "TS " .. fn .. " " .. query })
				end
			end

			local swap_objects = {
				p = "@parameter.inner",
				f = "@function.outer",
				c = "@class.outer",
			}
			for key, query in pairs(swap_objects) do
				vim.keymap.set("n", "<leader>cx" .. key, function()
					swap.swap_next(query)
				end, { desc = "TS swap next " .. query })
				vim.keymap.set("n", "<leader>cX" .. key, function()
					swap.swap_previous(query)
				end, { desc = "TS swap prev " .. query })
			end
		end,
	},
}
