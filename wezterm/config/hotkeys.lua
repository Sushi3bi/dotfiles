local wezterm = require "wezterm"
local sessionizer = require "sessionizer"

local Config = {}
Config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
Config.keys = {
    { key = "f", mods = "LEADER", action = wezterm.action_callback(sessionizer.toggle) },
    --{ key = "F", mods = "LEADER", action = wezterm.action_callback(sessionizer.resetCacheAndToggle) },
}

return Config

