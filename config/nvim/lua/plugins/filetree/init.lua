local M = {
	"nvim-tree/nvim-tree.lua",
	requires = {
		"nvim-tree/nvim-web-devicons", -- optional, for file icons
	},
	event = "VeryLazy",
	keys = {
		{ "<leader>n", "<cmd>NvimTreeToggle<cr>" },
	},
	config = function()
		local lib = require("nvim-tree.lib")
		local view = require("nvim-tree.view")

		local function collapse_all()
			require("nvim-tree.actions.tree-modifiers.collapse-all").fn()
		end

		local function edit_or_open()
			-- open as vsplit on current node
			local action = "edit"
			local node = lib.get_node_at_cursor()

			-- Just copy what's done normally with vsplit
			if node.link_to and not node.nodes then
				require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
				view.close() -- Close the tree if file was opened
			elseif node.nodes ~= nil then
				lib.expand_or_collapse(node)
			else
				require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
				view.close() -- Close the tree if file was opened
			end
		end

		local function vsplit_preview()
			-- open as vsplit on current node
			local action = "vsplit"
			local node = lib.get_node_at_cursor()

			-- Just copy what's done normally with vsplit
			if node.link_to and not node.nodes then
				require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
			elseif node.nodes ~= nil then
				lib.expand_or_collapse(node)
			else
				require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
			end

			-- Finally refocus on tree if it was lost
			view.focus()
		end

		local function vsplit()
			-- open as vsplit on current node
			local action = "vsplit"
			local node = lib.get_node_at_cursor()

			-- Just copy what's done normally with vsplit
			if node.link_to and not node.nodes then
				require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
			elseif node.nodes ~= nil then
				lib.expand_or_collapse(node)
			else
				require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
			end
		end

		local config = {
			view = {
				mappings = {
					custom_only = false,
					list = {
						{ key = "l", action = "edit", action_cb = edit_or_open },
						{ key = "L", action = "vsplit_preview", action_cb = vsplit_preview },
						{ key = "S", action = "vsplit", action_cb = vsplit },
						{ key = "h", action = "close_node" },
						{ key = "H", action = "collapse_all", action_cb = collapse_all },
					},
				},
			},
			actions = {
				-- open_file = {
				-- quit_on_open = false,
				-- },
			},
		}
		require("nvim-tree").setup(config)
	end,
}

return M
