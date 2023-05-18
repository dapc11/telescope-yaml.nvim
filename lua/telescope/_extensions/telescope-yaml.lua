local strings = require("plenary.strings")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")
local make_entry = require("telescope.make_entry")

local width = 0

local function visit_yaml_node(node, _, yaml_path, result, file_path, bufnr)
	local key = ""
	local value = ""
	if node:type() == "block_mapping_pair" then
		local field_key = node:field("key")[1]
		local field_value = node:field("value")[1]
		key = vim.treesitter.get_node_text(field_key, bufnr)
		value = ""
		if field_value ~= nil then
			value = vim.treesitter.get_node_text(field_value, bufnr)
		end
	end

	if key ~= nil and string.len(key) > 0 then
		table.insert(yaml_path, key)
		local full_path = table.concat(yaml_path, ".")
		width = math.max(width, strings.strdisplaywidth(full_path or ""))
		local line, col = node:start()
		table.insert(result, {
			lnum = line + 1,
			col = col + 1,
			bufnr = bufnr,
			filename = file_path,
			value = value,
			text = full_path,
		})
	end

	for node, name in node:iter_children() do
		visit_yaml_node(node, name, yaml_path, result, file_path, bufnr)
	end

	if key ~= nil and string.len(key) > 0 then
		table.remove(yaml_path, table.maxn(yaml_path))
	end
end

local function gen_from_yaml_nodes(opts)
	local displayer = entry_display.create({
		separator = " │ ",
		items = {
			{ width = 5 },
			{ width = width },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		return displayer({
			{ entry.lnum, "TelescopeResultsSpecialComment" },
			{
				entry.text,
				function()
					return {}
				end,
			},
			{ entry.value },
		})
	end

	return function(entry)
		return make_entry.set_default_entry_mt({
			ordinal = entry.text .. ":" .. entry.value,
			display = make_display,
			filename = entry.filename,
			lnum = entry.lnum,
			text = entry.text,
			value = entry.value,
			col = entry.col,
		}, opts)
	end
end

function find()
	opts = {}
	local yaml_path = {}
	local result = {}
	local word = opts.search or vim.fn.expand("<cword>") -- TODO: populate selected text in input
	local bufnr = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_buf_get_option(bufnr, "ft")
	local tree = vim.treesitter.get_parser(bufnr, ft):parse()[1]
	local file_path = vim.api.nvim_buf_get_name(bufnr)
	local root = tree:root()
	for node, name in root:iter_children() do
		visit_yaml_node(node, name, yaml_path, result, file_path, bufnr)
	end

	-- return result
	pickers
		.new(opts, {
			attach_mappings = function(_, map)
				map("i", "<c-v>", function(prompt_bufnr)
					local action_state = require("telescope.actions.state")
					local action_utils = require("telescope.actions.utils")
					vim.fn.setreg("+", action_state.get_selected_entry()["value"])
				end)
				map("i", "<c-k>", function(prompt_bufnr)
					local action_state = require("telescope.actions.state")
					local action_utils = require("telescope.actions.utils")
					vim.fn.setreg("+", action_state.get_selected_entry()["text"])
				end)
				return true
			end,
			prompt_title = "YAML symbols ",
			-- theme = "dropdown",
			finder = finders.new_table({
				results = result,
				entry_maker = opts.entry_maker or gen_from_yaml_nodes(opts),
			}),
			layout_config = {
				height = 0.85,
				width = 0.75,
			},
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

return require("telescope").register_extension({
	exports = {
		["telescope-yaml"] = find,
	},
})
