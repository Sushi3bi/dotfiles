---@module "utils.class.layout"
---@author sravioli
---@license GNU-GPLv3.0

local wt = require "wezterm"

local attribute_mappings = {
  None = "ResetAttributes",
  NoUnderline = { Underline = "None" },
  Single = { Underline = "Single" },
  Double = { Underline = "Double" },
  Curly = { Underline = "Curly" },
  Dotted = { Underline = "Dotted" },
  Dashed = { Underline = "Dashed" },
  Normal = { Intensity = "Normal" },
  Bold = { Intensity = "Bold" },
  Half = { Intensity = "Half" },
  Italic = { Italic = true },
  NoItalic = { Italic = false },
}

-- stylua: ignore
local ansi_colors = {
  Black = true, Maroon  = true, Green = true, Olive = true, Navy = true, Purple = true,
  Teal  = true, Silver  = true, Grey  = true, Red   = true, Lime = true, Yellow = true,
  Blue  = true, Fuchsia = true, Aqua  = true, White = true,
}

local M = {}

function M:new(name)
  name = "Layout" .. (name and " > " .. name or "")
  return setmetatable(
    { layout = {}, name = name },
    { __index = self }
  )
end


function M:push(background, foreground, text, attributes)
  self = self or {}

  local function set_color(attr, color)
    if ansi_colors[color] then
      self[#self + 1] = { [attr] = { AnsiColor = color } }
    else
      self[#self + 1] = { [attr] = { Color = color } }
    end
  end

  set_color("Background", background)
  set_color("Foreground", foreground)

  if attributes then
    for k = 1, #attributes do
      local attribute = attributes[k]
      if attribute_mappings[attribute] then
        self[#self + 1] = { Attribute = attribute_mappings[attribute] }
      else
        wt.log_error("attribute '%s' is not defined!", attribute)
      end
    end
  end

  self[#self + 1] = { Text = text }

  return self
end

function M:clear()
  self.layout = {}
  return self
end

function M:format()
  return wt.format(self)
end

return M