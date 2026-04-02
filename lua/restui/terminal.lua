local M = {}
local config = require("restui.config")

local buf, win

local function get_hl_fg(name)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl.fg then return string.format("#%06x", hl.fg) end
    return nil
end

local function get_hl_bg(name)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl.bg then return string.format("#%06x", hl.bg) end
    return nil
end

local function build_colors_arg()
    local colors = {}

    local function add(key, val)
        if val then table.insert(colors, key .. "=" .. val) end
    end

    add("bg", get_hl_bg("Normal"))
    add("fg", get_hl_fg("Normal"))
    add("accent", get_hl_fg("Function") or get_hl_fg("DiagnosticInfo"))
    add("dim", get_hl_fg("Comment"))
    add("border", get_hl_fg("FloatBorder") or get_hl_fg("NonText"))
    add("green", get_hl_fg("DiagnosticOk") or get_hl_fg("String"))
    add("yellow", get_hl_fg("DiagnosticWarn") or get_hl_fg("WarningMsg"))
    add("red", get_hl_fg("DiagnosticError") or get_hl_fg("ErrorMsg"))
    add("blue", get_hl_fg("Function"))
    add("magenta", get_hl_fg("Statement") or get_hl_fg("Keyword"))
    add("cyan", get_hl_fg("Special") or get_hl_fg("Type"))
    add("orange", get_hl_fg("Number") or get_hl_fg("Constant"))
    add("bg_hl", get_hl_bg("CursorLine"))
    add("gutter", get_hl_fg("LineNr"))
    add("gutter_active", get_hl_fg("CursorLineNr"))
    add("string", get_hl_fg("String"))
    add("number", get_hl_fg("Number"))
    add("keyword", get_hl_fg("Keyword") or get_hl_fg("@keyword"))
    add("boolean", get_hl_fg("Boolean"))

    if #colors == 0 then return nil end
    return table.concat(colors, ",")
end

--- Check if the restui binary is available in PATH.
local function check_binary()
    local cmd = config.options.restui_cmd
    if vim.fn.executable(cmd) == 0 then
        vim.notify(
            "restui not found in PATH. Install with: cargo install restui",
            vim.log.levels.ERROR,
            { title = "restui.nvim" }
        )
        return false
    end
    return true
end

function M.toggle()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
        win = nil
        return
    end

    if not check_binary() then return end

    local opts = config.options.float_opts
    local width = math.floor(vim.o.columns * opts.width)
    local height = math.floor(vim.o.lines * opts.height)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    buf = vim.api.nvim_create_buf(false, true)
    win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = opts.border,
        style = "minimal",
    })

    -- Build command with context
    local cmd = config.options.restui_cmd
    local file = vim.fn.expand("%:p")
    if file:match("%.http$") or file:match("%.yaml$") or file:match("%.yml$") then
        cmd = cmd .. " --file " .. vim.fn.shellescape(file)
    end

    if config.options.env_file then
        cmd = cmd .. " --env-file " .. vim.fn.shellescape(config.options.env_file)
    end

    -- Pass current working directory
    local cwd = vim.fn.getcwd()
    cmd = cmd .. " --dir " .. vim.fn.shellescape(cwd)

    -- Debug flag
    if config.options.debug then
        cmd = cmd .. " --debug"
    end

    -- Pass nvim colorscheme colors
    local colors = build_colors_arg()
    if colors then
        cmd = cmd .. " --colors " .. vim.fn.shellescape(colors)
    end

    -- Extra user-defined arguments
    for _, arg in ipairs(config.options.extra_args) do
        cmd = cmd .. " " .. arg
    end

    vim.fn.termopen(cmd, {
        on_exit = function()
            if win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
                win = nil
            end
        end,
    })

    -- Block mouse scroll to prevent terminal scrollback from corrupting the TUI
    vim.api.nvim_buf_set_keymap(buf, "t", "<ScrollWheelUp>", "<Nop>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "t", "<ScrollWheelDown>", "<Nop>", { noremap = true, silent = true })

    vim.cmd("startinsert")
end

--- Dump default keybindings to a new buffer.
function M.dump_keybindings()
    if not check_binary() then return end

    local cmd = config.options.restui_cmd .. " --dump-keybindings"
    local output = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to dump keybindings: " .. output, vim.log.levels.ERROR)
        return
    end

    vim.cmd("enew")
    vim.bo.filetype = "toml"
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    local lines = vim.split(output, "\n")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.modified = false
end

return M
