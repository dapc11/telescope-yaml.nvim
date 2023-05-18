local M = {}

local action_layout = require("telescope.actions.layout")

function M.yaml_find(opts)
	opts = opts or {}
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

return M
