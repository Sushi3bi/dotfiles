-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

local cmd = vim.api.nvim_create_autocmd

--au BufNewFile,BufRead Jenkinsfile setf groovy
cmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.jenkinsfile",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, "filetype", "groovy")
  end,
})