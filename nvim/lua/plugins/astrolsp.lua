---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    mappings = {
      v = {
        ["<Leader>la"] = {
          function()
            require("actions-preview").code_actions()
          end,
          desc = "Code actions",
        },
      },
    },
  },
}
