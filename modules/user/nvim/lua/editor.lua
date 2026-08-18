-- substitute.nvim
require("substitute").setup()
vim.keymap.set("n", "s",  require("substitute").operator, { desc = "Substitute (motion)" })
vim.keymap.set("n", "ss", require("substitute").line,     { desc = "Substitute line" })
vim.keymap.set("n", "S",  require("substitute").eol,      { desc = "Substitute to EOL" })
vim.keymap.set("x", "s",  require("substitute").visual,   { desc = "Substitute selection" })

-- Maximize / restore current split (no plugin needed)
local _maximized = false
vim.keymap.set("n", "<leader>sm", function()
  if _maximized then
    vim.cmd("wincmd =")
    _maximized = false
  else
    vim.cmd("wincmd _")
    vim.cmd("wincmd |")
    _maximized = true
  end
end, { desc = "Toggle maximize split" })
