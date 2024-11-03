local Layout = {}

function Layout:new()
  return setmetatable({ layout = {} }, { __index = self })
end

function Layout:push(background, foreground, text, attributes)
  self = self or {}
  local insert = table.insert
  insert(self, { Background = { Color = background } })
  insert(self, { Foreground = { Color = foreground } })

  local attribute_mappings = {
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

  if attributes then
    for _, attribute in ipairs(attributes) do
      if attribute_mappings[attribute] then
        insert(self, { Attribute = attribute_mappings[attribute] })
      end
    end
  end

  table.insert(self, { Text = text })

  return self
end

return Layout
