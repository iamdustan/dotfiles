return {
	-- The default mode for interaction. "agentic" uses tools to automatically generate code, "legacy" uses the old planning method to generate code.
	mode = "agentic",

	---@alias avante.ProviderName "claude" | "openai" | "azure" | "gemini" | "vertex" | "cohere" | "copilot" | "bedrock" | "ollama" | "watsonx_code_assistant" | string
	---@type avante.ProviderName
	provider = "gemini",
	-- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
	-- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
	-- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
	auto_suggestions_provider = nil,
	memory_summary_provider = nil,
	-- Used for counting tokens and encoding text.
	-- By default, we will use tiktoken.
	-- For most providers that we support we will determine this automatically.
	-- If you wish to use a given implementation, then you can override it here.
	tokenizer = "tiktoken",
	-- system_prompt as function ensures LLM always has latest MCP server state
	-- This is evaluated for every message, even in existing chats
	---@type string | fun(): string | nil
	system_prompt = function()
		local hub = require("mcphub").get_hub_instance()
		return hub and hub:get_active_servers_prompt() or ""
	end,
	---@type string | fun(): string | nil
	override_prompt_dir = nil,
	rules = {
		project_dir = nil, ---@type string | nil (could be relative dirpath)
		global_dir = nil, ---@type string | nil (absolute dirpath)
	},
	-- Using function prevents requiring mcphub before it's loaded
	custom_tools = function()
		return {
			require("mcphub.extensions.avante").mcp_tool(),
		}
	end,

	-- to prevent duplication with mcp hub
	disabled_tools = {
		"list_files", -- Built-in file operations
		"search_files",
		"read_file",
		"create_file",
		"rename_file",
		"delete_file",
		"create_dir",
		"rename_dir",
		"delete_dir",
		"bash", -- Built-in terminal access
	},

	-- dual_boost

	behaviour = {
		auto_suggestions = false, -- Experimental stage
		auto_set_highlight_group = true,
		auto_set_keymaps = true,
		auto_apply_diff_after_generation = false,
		support_paste_from_clipboard = false,
		minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
		enable_token_counting = true, -- Whether to enable token counting. Default to true.
		auto_approve_tool_permissions = true, -- Default: auto-approve all tools (no prompts)
	},
	prompt_logger = { -- logs prompts to disk (timestamped, for replay/debugging)
		enabled = true, -- toggle logging entirely
		log_dir = vim.fn.stdpath("cache") .. "/avante_prompts", -- directory where logs are saved
		fortune_cookie_on_success = false, -- shows a random fortune after each logged prompt (requires `fortune` installed)
		next_prompt = {
			normal = "<C-n>", -- load the next (newer) prompt log in normal mode
			insert = "<C-n>",
		},
		prev_prompt = {
			normal = "<C-p>", -- load the previous (older) prompt log in normal mode
			insert = "<C-p>",
		},
	},
	mappings = {
		--- @class AvanteConflictMappings
		diff = {
			ours = "co",
			theirs = "ct",
			all_theirs = "ca",
			both = "cb",
			cursor = "cc",
			next = "]x",
			prev = "[x",
		},
		suggestion = {
			accept = "<M-l>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
		jump = {
			next = "]]",
			prev = "[[",
		},
		submit = {
			normal = "<CR>",
			insert = "<C-s>",
		},
		sidebar = {
			apply_all = "A",
			apply_cursor = "a",
			switch_windows = "<Tab>",
			reverse_switch_windows = "<S-Tab>",
		},
	},
	hints = { enabled = true },
	windows = {
		---@type "right" | "left" | "top" | "bottom"
		position = "right", -- the position of the sidebar
		wrap = true, -- similar to vim.o.wrap
		width = 30, -- default % based on available width
		sidebar_header = {
			enabled = true, -- true, false to enable/disable the header
			align = "center", -- left, center, right for title
			rounded = true,
		},
		input = {
			spinner = {
				editing = {
					"⡀",
					"⠄",
					"⠂",
					"⠁",
					"⠈",
					"⠐",
					"⠠",
					"⢀",
					"⣀",
					"⢄",
					"⢂",
					"⢁",
					"⢈",
					"⢐",
					"⢠",
					"⣠",
					"⢤",
					"⢢",
					"⢡",
					"⢨",
					"⢰",
					"⣰",
					"⢴",
					"⢲",
					"⢱",
					"⢸",
					"⣸",
					"⢼",
					"⢺",
					"⢹",
					"⣹",
					"⢽",
					"⢻",
					"⣻",
					"⢿",
					"⣿",
				},
				generating = { "·", "✢", "✳", "∗", "✻", "✽" }, -- Spinner characters for the 'generating' state
				thinking = { "🤯", "🙄" }, -- Spinner characters for the 'thinking' state
			},
			prefix = "> ",
			height = 8, -- Height of the input window in vertical layout
			provider = "snacks", -- "native" | "dressing" | "snacks"
			provider_opts = {
				-- Snacks input configuration
				title = "Avante Input",
				icon = " ",
				placeholder = "Enter your API key...",
			},
		},
		edit = {
			border = "rounded",
			start_insert = true, -- Start insert mode when opening the edit window
		},
		ask = {
			floating = false, -- Open the 'AvanteAsk' prompt in a floating window
			start_insert = true, -- Start insert mode when opening the ask window
			border = "rounded",
			---@type "ours" | "theirs"
			focus_on_apply = "ours", -- which diff to focus after applying
		},
	},
	highlights = {
		---@type AvanteConflictHighlights
		diff = {
			current = "DiffText",
			incoming = "DiffAdd",
		},
	},
	--- @class AvanteConflictUserConfig
	diff = {
		autojump = true,
		---@type string | fun(): any
		list_opener = "copen",
		--- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
		--- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
		--- Disable by setting to -1.
		override_timeoutlen = 500,
	},
}
