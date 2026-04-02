# restui.nvim

A Neovim plugin to open [restui](https://github.com/Di3go0-0/restui) in a floating terminal window, similar to how lazygit.nvim wraps lazygit.

## Requirements

- Neovim >= 0.8
- [restui](https://github.com/Di3go0-0/restui) binary in your `PATH`

Install restui via [crates.io](https://crates.io/crates/restui):

```sh
cargo install restui
```

Or build from source:

```sh
git clone https://github.com/Di3go0-0/restui.git
cd restui
cargo install --path .
```

## Installation

### [folke/lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "Di3go0-0/restui.nvim",
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
    "Di3go0-0/restui.nvim",
    config = function()
        require("restui").setup()
    end,
}
```

### [junegunn/vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Di3go0-0/restui.nvim'

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

    -- Auto-open restui when entering .http/.rest files (once per buffer)
    open_on_http_file = false,

    -- Path to environment file (optional)
    env_file = nil,

    -- Keymap to toggle restui (set to nil to disable)
    keymap = "<leader>rr",

    -- Enable debug logging (writes to ~/.local/share/restui/restui.log)
    debug = false,

    -- Extra arguments to pass to the restui CLI
    extra_args = {},
})
```

## Usage

| Command               | Description                                  |
|-----------------------|----------------------------------------------|
| `:Restui`             | Toggle restui window                         |
| `:RestuiKeybindings`  | Dump default keybindings to a new buffer     |

Default keymap: `<leader>rr`

### Context-aware

When you open restui from a `.http`, `.yaml`, or `.yml` file, the plugin automatically passes the current file to restui via `--file`. The current working directory is always passed via `--dir`.

### Colorscheme integration

The plugin automatically extracts your Neovim colorscheme and passes it to restui via `--colors`. This means restui inherits your editor's colors out of the box — no manual theme configuration needed.

### Keybindings

Run `:RestuiKeybindings` to view all default keybindings in a new buffer (TOML format). You can save this as `~/.config/restui/keybindings.toml` and customize any key. See [KEYBINDINGS.md](https://github.com/Di3go0-0/restui/blob/main/KEYBINDINGS.md) for full documentation.

### Debug mode

Enable `debug = true` in setup to write logs to `~/.local/share/restui/restui.log`. Useful for troubleshooting.

### Extra arguments

Pass any additional CLI flags via `extra_args`:

```lua
require("restui").setup({
    extra_args = { "--dump-keybindings" },
})
```

## License

MIT
