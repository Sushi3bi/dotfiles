local fs = require("utils.fn").fs

local Config = {}

Config.default_cwd = fs.home()
Config.default_prog = { "/opt/homebrew/bin/nu" }
Config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"

-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
Config.ssh_domains = {}

-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
Config.unix_domains = {}

return Config
