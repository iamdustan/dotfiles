-- http://writewithharper.com/
-- Local grammar checker
--
-- Config has markdown (full grammar checking) and code/comment based
-- configurations.
local M = {}

M.default_settings = {
	["harper-ls"] = {
		linters = {
			SentenceCapitalization = false,
			ToDoHyphen = false,
			SpellCheck = false,
		},
	},
}

M.markdown_settings = {
	["harper-ls"] = {
		linters = {
			SentenceCapitalization = true,
			ToDoHyphen = true,
			SpellCheck = true,
			SpelledNumbers = true,
			AnA = true,
			UnclosedQuotes = true,
			WrongQuotes = true,
			LongSentences = true,
			RepeatedWords = true,
			Spaces = true,
			Matcher = true,
			CorrectNumberSuffix = true,
		},
	},
}

function M.get_settings(filetype)
	if filetype == "markdown" then
		return M.markdown_settings
	end
	return M.default_settings
end

return {
	settings = M.default_settings,
	get_settings = M.get_settings,
}
