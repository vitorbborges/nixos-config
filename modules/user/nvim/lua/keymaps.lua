function()
  vim.fn.system(string.format("tmux split-window -v -l 20 -c %s", vim.fn.shellescape(vim.fn.getcwd())))
end
