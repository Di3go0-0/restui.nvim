local M = {}

function M.setup(opts)
    require("restui.config").setup(opts)
    local config = require("restui.config").options

    vim.api.nvim_create_user_command("Restui", function()
        require("restui.terminal").toggle()
    end, { desc = "Toggle restui HTTP client" })

    vim.api.nvim_create_user_command("RestuiKeybindings", function()
        require("restui.terminal").dump_keybindings()
    end, { desc = "Dump restui default keybindings" })

    if config.keymap then
        vim.keymap.set("n", config.keymap, function()
            require("restui.terminal").toggle()
        end, { desc = "Toggle restui HTTP client" })
    end

    -- Auto-open on .http files (only once per buffer)
    if config.open_on_http_file then
        local opened = {}
        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = { "*.http", "*.rest" },
            callback = function(ev)
                if not opened[ev.buf] then
                    opened[ev.buf] = true
                    require("restui.terminal").toggle()
                end
            end,
        })
    end
end

return M
