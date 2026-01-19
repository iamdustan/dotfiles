--- **Tailwind CSS Language Server Configuration**
---
--- Should only activate in projects that use Tailwind CSS
--- Checks for tailwind config files or tailwindcss dependency.
return {
	-- Returns nil if no Tailwind indicators found, else returns project root
	root_dir = function(fname)
		-- Handle both bufnr (number) and filename (string)
		local start_path
		if type(fname) == "number" then
			start_path = vim.api.nvim_buf_get_name(fname)
		else
			start_path = fname
		end

		if not start_path or start_path == "" then
			return nil
		end

		local root_markers = {
			"tailwind.config.ts",
			"tailwind.config.mjs",
			"tailwind.config.json",
			"tailwind.config.js",
			"tailwind.config.cjs",
			"postcss.config.ts",
			"postcss.config.mjs",
			"postcss.config.js",
			"postcss.config.cjs",
		}

		-- Check for tailwind config files
		for _, marker in ipairs(root_markers) do
			local found = vim.fs.find(marker, { path = vim.fs.dirname(start_path), upward = true })[0]
			if found then
				return vim.fs.dirname(found)
			end
		end

		-- Check package.json for tailwindcss dependency
		local package_json = vim.fs.find("package.json", { path = vim.fs.dirname(start_path), upward = true })[1]
		if package_json then
			local ok, content = pcall(vim.fn.readfile, package_json)
			if ok and content then
				local content_str = table.concat(content, "\n")
				if content_str:match('"tailwindcss"') or content_str:match("'tailwindcss'") then
					return vim.fs.dirname(package_json)
				end
			end
		end

		return nil
	end,
}
