local wez = require "wezterm"

local icons = require "utils.icons"
local fs = require("utils.fn").fs

local Config = {}

Config.default_cwd = fs.home()
Config.default_prog = { "/opt/homebrew/bin/nu" }
Config.front_end = "WebGpu"
Config.animation_fps = 60
Config.max_fps = 120 --60
Config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"

return Config
