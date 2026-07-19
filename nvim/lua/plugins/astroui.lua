---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = function(_, opts)
    opts.colorscheme = require("theme").current()
  end,
}
