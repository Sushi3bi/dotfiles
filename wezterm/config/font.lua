local wt = require "wezterm"
local Config = {}

Config.adjust_window_size_when_changing_font_size = false
Config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
Config.anti_alias_custom_block_glyphs = true

local monaspace_features = {
  "calt",
  "liga",
  "dlig",
  "ss01",
  "ss02",
  "ss03",
  "ss04",
  "ss05",
  "ss06",
  "ss07",
  "ss08",
  -- "cv01", ---styles: a
  -- "cv02", ---styles: g
  "cv06", ---styles: i (03..06)
  -- "cv09", ---styles: l (07..10)
  "cv12", ---styles: 0 (11..13, zero)
  "cv14", ---styles: 3
  "cv16", ---styles: * (15..16)
  -- "cv17", ---styles: ~
  -- "cv18", ---styles: %
  -- "cv19", ---styles: <= (19..20)
  -- "cv21", ---styles: =< (21..22)
  -- "cv23", ---styles: >=
  -- "cv24", ---styles: /=
  "cv25", ---styles: .-
  "cv26", ---styles: :-
  -- "cv27", ---styles: []
  "cv28", ---styles: {. .}
  "cv29", ---styles: { }
  -- "cv30", ---styles: |
  "cv31", ---styles: ()
  "cv32", ---styles: .=
}

Config.font = wt.font_with_fallback {
  {
    family = "MonaspiceNe Nerd Font",
    weight = "Regular",
    stretch = "Normal",
    style = "Normal",
    harfbuzz_features = monaspace_features,
  },
  { family = "Noto Color Emoji" },
  { family = "LegacyComputing" },
  { family = "Symbols Nerd Font" },
}

Config.font_size = 11.5
--Config.cell_width = 1.0
--Config.line_height = 1.2

--Config.underline_position = -2.5
--Config.underline_thickness = "2px"
Config.warn_about_missing_glyphs = false

return Config
