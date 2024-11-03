require "events.update-status"
require "events.format-tab-title"
require "events.new-tab-button-click"
require "events.augment-command-palette"

-- config is based on https://github.com/sravioli/wezterm
local spec = require "config"
local wez = require "wezterm"
local config = wez.config_builder()
config:set_strict_mode(true)

for key, value in pairs(spec) do
    if config[key] ~= nil then
      wez.log_warn("Duplicate found: ", { old = config[key], new = spec[key] })
    else
      config[key] = value
    end
end

return config