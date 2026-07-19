---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true,         -- sets vim.opt.number
        spell = false,         -- sets vim.opt.spell
        signcolumn = "yes",    -- sets vim.opt.signcolumn to yes
        wrap = true,           -- sets vim.opt.wrap
      },
    },
    diagnostics = {
      virtual_text = function(_, bufnr) return vim.bo[bufnr].filetype ~= "markdown" end,
    },
    autocmds = {
      markdown_display = {
        {
          event = "FileType",
          pattern = "markdown",
          callback = function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
          end,
        },
      },
    },
    mappings = {
      n = {
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        ["gy"] = { '"+y', desc = "Copy to system clipboard" },
        ["gp"] = { '"+p', desc = "Paste from system clipboard" },
      },
      v = {
        ["gy"] = { '"+y', desc = "Copy to system clipboard" },
        ["gp"] = { '"+p', desc = "Paste from system clipboard" },
      },
    },
  },
}
