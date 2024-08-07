local indent = 2

vim.o.formatoptions = "jcroqlnt"
-- vim.o.shortmess = "filnxtToOFWIcC"
vim.opt.breakindent = true
vim.opt.cmdheight = 0
vim.opt.completeopt = "menuone,noselect"
vim.opt.conceallevel = 3
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.inccommand = "nosplit"
vim.opt.joinspaces = false
vim.opt.laststatus = 0
vim.opt.list = true
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
vim.opt.shiftround = true
vim.opt.shiftwidth = indent
vim.opt.showmode = false
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
-- vim.opt.splitkeep = "screen"
vim.opt.splitright = true
vim.opt.tabstop = indent
vim.opt.textwidth = 80
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.opt.wildmode = "longest:full,full"
vim.opt.laststatus = 2 -- always display the status line

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- make error diagnositcs only appear in float window when focused with `[d`
vim.diagnostic.config({
	underline = true,
	signs = true,
	virtual_text = false,
	float = {
		show_header = true,
		source = "if_many",
		border = "rounded",
		focusable = false,
	},
	update_in_insert = false,
	severity_sort = false,
})
