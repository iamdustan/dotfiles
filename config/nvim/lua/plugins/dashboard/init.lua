function get_plugin_status()
	local updates = require("lazy.status").updates()
	if updates then
		return " (" .. updates .. " available)"
	end
	return ""
end

function get_git()
	local cmds = {
		{
			title = "Notifications",
			cmd = "gh notify -s -a -n5",
			action = function()
				vim.ui.open("https://github.com/notifications")
			end,
			key = "n",
			icon = " ",
			height = 5,
			enabled = true,
		},
		{
			title = "Open Issues",
			cmd = "gh issue list -L 3",
			key = "i",
			action = function()
				vim.fn.jobstart("gh issue list --web", { detach = true })
			end,
			icon = " ",
			height = 7,
		},
		{
			icon = " ",
			title = "Open PRs",
			cmd = "gh pr list -L 3",
			key = "P",
			action = function()
				vim.fn.jobstart("gh pr list --web", { detach = true })
			end,
			height = 7,
		},
		{
			icon = " ",
			title = "Git Status",
			cmd = "git --no-pager diff --stat -B -M -C",
			height = 10,
		},
	}
	return cmds
end

return {
	"goolord/alpha-nvim",
	lazy = false,
	config = function()
		local dashboard = require("alpha.themes.dashboard")
		dashboard.section.header.val = require("plugins.dashboard.logos")["random"]

		local plugin_text = "  Plugins"

		-- Store reference to plugins button for updates
		local plugins_button = dashboard.button("p", plugin_text, ":Lazy<CR>")

		dashboard.section.buttons.val = {
			dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
			dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
			dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
			dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
			dashboard.button("l", "鈴" .. " Lazy", ":Lazy<CR>"),
			plugins_button,
			dashboard.button("q", " " .. " Quit", ":qa<CR>"),
		}
		for _, button in ipairs(dashboard.section.buttons.val) do
			button.opts.hl = "AlphaButtons"
			button.opts.hl_shortcut = "AlphaShortcut"
		end
		dashboard.section.footer.opts.hl = "Constant"
		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.buttons.opts.hl = "AlphaButtons"
		dashboard.opts.layout[1].val = 0

		if vim.o.filetype == "lazy" then
			-- close and re-open Lazy after showing alpha
			vim.notify("Missing plugins installed!", vim.log.levels.INFO, { title = "lazy.nvim" })
			vim.cmd.close()
			require("alpha").setup(dashboard.opts)
			require("lazy").show()

			local updates = require("lazy.status").updates()
			if updates == false then
				print("updates? " .. "nope")
			elseif type(updates) == "string" then
				print("updates? " .. updates)
			end
			print("updates? " .. "wtf")
		else
			require("alpha").setup(dashboard.opts)
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyVimStarted",
			callback = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

				-- local now = os.date "%d-%m-%Y %H:%M:%S"
				local version = "   v"
					.. vim.version().major
					.. "."
					.. vim.version().minor
					.. "."
					.. vim.version().patch
				local fortune = require("alpha.fortune")
				local quote = table.concat(fortune(), "\n")
				local plugins = "⚡Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"

				vim.defer_fn(function()
					if plugins_button then
						local plugin_status = get_plugin_status()
						plugins_button.val = "  Plugins" .. plugin_status
						pcall(vim.cmd.AlphaRedraw)
					end
				end, 500)

				local footer = "\t" .. version .. "\t" .. plugins .. "\n" .. quote

				local gh = get_git()
				local gh_footer = gh[2].icon .. gh[2].title .. " " .. vim.fn.jobstart(gh[2].cmd)
				dashboard.section.footer.val = footer
				pcall(vim.cmd.AlphaRedraw)
			end,
		})

		-- Update plugin status when lazy checker completes
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyCheck",
			callback = function()
				local plugin_status = get_plugin_status()
				plugins_button.val = "  Plugins" .. plugin_status
				pcall(vim.cmd.AlphaRedraw)
			end,
		})
	end,
}
