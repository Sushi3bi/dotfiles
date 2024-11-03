---Nerd fonts aggregated by type/class/etc.

local M = {}

local wez = require "wezterm"

M.Separators = {
  StatusBar = {
    left = wez.nerdfonts.pl_left_hard_divider,
    right = wez.nerdfonts.pl_right_hard_divider,
  },

  TabBar = {
    leftmost = "▐",
    left = wez.nerdfonts.ple_upper_right_triangle,
    right = wez.nerdfonts.ple_lower_left_triangle,
  },

  FullBlock = "█",
}

M.Vim = ""

M.Pwsh = wez.nerdfonts.md_powershell

M.Bash = wez.nerdfonts.md_bash

M.Git = wez.nerdfonts.md_git

M.Battery = {
  Full = {
    ["100"] = wez.nerdfonts.md_battery,
  },
  Charging = {
    ["00"] = wez.nerdfonts.md_battery_alert,
    ["10"] = wez.nerdfonts.md_battery_charging_10,
    ["20"] = wez.nerdfonts.md_battery_charging_20,
    ["30"] = wez.nerdfonts.md_battery_charging_30,
    ["40"] = wez.nerdfonts.md_battery_charging_40,
    ["50"] = wez.nerdfonts.md_battery_charging_50,
    ["60"] = wez.nerdfonts.md_battery_charging_60,
    ["70"] = wez.nerdfonts.md_battery_charging_70,
    ["80"] = wez.nerdfonts.md_battery_charging_80,
    ["90"] = wez.nerdfonts.md_battery_charging_90,
    ["100"] = wez.nerdfonts.md_battery_charging_100,
  },

  Discharging = {
    ["00"] = wez.nerdfonts.md_battery_outline,
    ["10"] = wez.nerdfonts.md_battery_10,
    ["20"] = wez.nerdfonts.md_battery_20,
    ["30"] = wez.nerdfonts.md_battery_30,
    ["40"] = wez.nerdfonts.md_battery_40,
    ["50"] = wez.nerdfonts.md_battery_50,
    ["60"] = wez.nerdfonts.md_battery_60,
    ["70"] = wez.nerdfonts.md_battery_70,
    ["80"] = wez.nerdfonts.md_battery_80,
    ["90"] = wez.nerdfonts.md_battery_90,
    ["100"] = wez.nerdfonts.md_battery,
  },
}

M.Admin = wez.nerdfonts.md_lightning_bolt

M.UnseenNotification = wez.nerdfonts.cod_circle_small_filled

M.Numbers = {
  wez.nerdfonts.md_numeric_1,
  wez.nerdfonts.md_numeric_2,
  wez.nerdfonts.md_numeric_3,
  wez.nerdfonts.md_numeric_4,
  wez.nerdfonts.md_numeric_5,
  wez.nerdfonts.md_numeric_6,
  wez.nerdfonts.md_numeric_7,
  wez.nerdfonts.md_numeric_8,
  wez.nerdfonts.md_numeric_9,
  wez.nerdfonts.md_numeric_10,
}

return M
