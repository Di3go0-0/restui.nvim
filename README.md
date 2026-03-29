# restui.nvim

A Neovim plugin to open [restui](https://github.com/diegomontoya/restui) in a floating terminal window, similar to how lazygit.nvim wraps lazygit.

## Requirements

- Neovim >= 0.8
- [restui](https://github.com/diegomontoya/restui) binary in your `PATH`

```sh
cargo install restui
```

## Installation

### [folke/lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "diegomontoya/restui.nvim",
    dependencies = {},
    config = function()
        require("restui").setup()
    end,
    keys = {
        { "<leader>rr", "<cmd>Restui<cr>", desc = "Toggle restui" },
    },
}
```

### [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "diegomontoya/restui.nvim",
    config = function()
        require("restui").setup()
    end,
}
```

### [junegunn/vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'diegomontoya/restui.nvim'

" In your init.vim, after plug#end():
lua require("restui").setup()
```

## Configuration

```lua
require("restui").setup({
    -- Path to restui binary (default: "restui")
    restui_cmd = "restui",

    -- Floating window options
    float_opts = {
        width = 0.9,     -- 90% of editor width
        height = 0.9,    -- 90% of editor height
        border = "rounded",
    },

    -- Auto-open restui when entering .http/.rest files
    open_on_http_file = false,

    -- Path to environment file (optional)
    env_file = nil,

    -- Keymap to toggle restui (set to nil to disable)
    keymap = "<leader>rr",
})
```

## Usage

| Command    | Description           |
|------------|-----------------------|
| `:Restui`  | Toggle restui window  |

Default keymap: `<leader>rr`

### Context-aware

When you open restui from a `.http` or `.yaml` file, the plugin automatically passes the current file to restui via `--file`. The current working directory is also passed via `--dir`.

## License

MIT
