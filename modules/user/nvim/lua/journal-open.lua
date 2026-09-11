function()
  local file = vim.trim(vim.fn.system("journal-open"))
  if vim.v.shell_error ~= 0 or file == "" then
    vim.notify("journal-open failed", vim.log.levels.ERROR)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(file))
end
