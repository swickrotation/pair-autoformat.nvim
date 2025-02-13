-- delimiterAutoFormat - Automatically formated wrap-around tags/delimiters
-- on carriage return.
--
-- i.e. it turns <xyz></xyz> into:
--
-- <xyz>
--    | <- your cursor here!
-- </xyz>
--
-- Should pair very nicely with any autoclosing scripts or remaps.

-- Maintainer: William Gertler
-- Version: 0.0.1



local function format_between_tags_and_delimiters()
local line = vim.api.nvim_get_current_line()
local cursor_pos = vim.api.nvim_win_get_cursor(0) -- Get cursor position
local col = cursor_pos[2] -- Cursor column

-- Extract parts of the line before and after the cursor
local before_cursor = line:sub(1, col) -- string indexes at 1
local after_cursor = line:sub(col + 1)

-- Patterns for matching delimiters and HTML tags
local patterns = {
  { open = "<%w+>", close = "</%w+>" }, -- HTML tags
  { open = "\\begin%b{}", close = "\\end%b{}" }, -- LaTeX \begin{...} and \end{...}
  { open = "{", close = "}" },
  { open = "%(", close = "%)" },       -- % escapes special Lua pattern characters
  { open = "%[", close = "%]" },
}

for _, pair in ipairs(patterns) do
  local open_match = before_cursor:match(pair.open .. "%s*$")
  local close_match = after_cursor:match("^%s*" .. pair.close)

  if open_match and close_match then
    -- Get the current indentation level
    local indent = string.match(before_cursor, "^%s*") or ""

    -- Prepare new lines with indentation
    local new_lines = {
      before_cursor,
      indent .. "  ",
      indent .. after_cursor,
    }

    -- Replace the current line with the new lines
    local row = cursor_pos[1] - 1 -- Lua uses 0-based indexing for buffer rows
    vim.api.nvim_buf_set_lines(0, row, row + 1, false, new_lines)

    -- Move the cursor to the indented line
    vim.api.nvim_win_set_cursor(0, { row + 2, #indent + 2 })
    return
  end
end

-- Default behavior (normal enter key) if no match is found
return 
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
end

-- Map the Enter key in insert mode
vim.keymap.set("i", "<CR>", format_between_tags_and_delimiters, { silent = true, expr = false })
