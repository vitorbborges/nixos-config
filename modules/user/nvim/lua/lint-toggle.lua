function()
  local config = vim.diagnostic.config()
  if config.virtual_text then
    vim.diagnostic.config({ virtual_text = false, underline = false })
    vim.notify("Inline diagnostics hidden")
  else
    vim.diagnostic.config({
      virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
      underline = true,
    })
    vim.notify("Inline diagnostics shown")
  end
end
