function()
  local line = vim.api.nvim_get_current_line()
  if line:match("%[x%]") then
    vim.api.nvim_set_current_line(line:gsub("%[x%]", "[ ]", 1))
  elseif line:match("%[ %]") then
    vim.api.nvim_set_current_line(line:gsub("%[ %]", "[x]", 1))
  end
end
