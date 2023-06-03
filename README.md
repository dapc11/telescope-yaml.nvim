# Telescope-yaml

Telescope extension for searching within YAML files. The finder comes with feature to copy the value or absolute YAML path (key).

## Requirements

- telescope.nvim (required)

## Setup

You can setup the extension by adding the following to your configuration:

```lua
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "dapc11/telescope-yaml.nvim" }
}
```

Load the extension somewhere in your configuration:

```lua
require("telescope").load_extension("telescope-yaml")
```

## Mappings

| Mapping (insert mode) | Description             |
| --------------------- | ----------------------- |
| Ctrl+k                | Copy current value      |
| Ctrl+v                | Copy absolute YAML path |

### Keymap

Add keymap for the utility:

```lua
vim.keymap.set("n", "<leader>fy", "<cmd>Telescope telescope-yaml")
```

## TODO

- Search for selected word
- Search for word under cursor
