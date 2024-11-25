return require("utils.fn").tbl.merge(
  (require "config.hotkeys.default"),
  (require "config.hotkeys.modes")[1]
)
