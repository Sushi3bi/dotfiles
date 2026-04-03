local M = {}

local DARK_THEME = "tokyonight-moon"
local LIGHT_THEME = "tokyonight-day"

local function is_macos()
  return vim.fn.has "macunix" == 1
end

function M.current()
  if not is_macos() then return DARK_THEME end

  local output = vim.fn.system { "defaults", "read", "-g", "AppleInterfaceStyle" }
  if vim.v.shell_error == 0 and output:match "Dark" then return DARK_THEME end

  return LIGHT_THEME
end

function M.apply()
  local colorscheme = M.current()
  if vim.g.colors_name == colorscheme then return end

  vim.o.background = colorscheme == LIGHT_THEME and "light" or "dark"
  vim.cmd.colorscheme(colorscheme)
end

return M
