function()
  vim.cmd.normal({ "o", bang = true })
  local line = "- " .. os.date("%H:%M") .. " - "
  vim.api.nvim_set_current_line(line)
  vim.fn.cursor(vim.fn.line("."), #line + 1)
  vim.cmd.startinsert()
end
