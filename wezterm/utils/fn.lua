---Various utility functions
---
---@module "utils.fn"
---@author sravioli
---@license GNU-GPLv3

local wt = require "wezterm"
local G = wt.GLOBAL ---@diagnostic disable-line: undefined-field

local Icon = require("utils").class.icon

local wcwidth, codes = require "utils.external.wcwidth", require("utf8").codes
local floor, ceil = math.floor, math.ceil

local M = {}

M.tbl_merge = function(t1, ...)
  local tables = { ... }

  for i = 1, #tables do
    local t2 = tables[i]
    for k, v in pairs(t2) do
      if type(v) == "table" then
        if type(t1[k] or false) == "table" then
          M.tbl_merge(t1[k] or {}, t2[k] or {})
        else
          t1[k] = v
        end
      else
        t1[k] = v
      end
    end
  end

  return t1
end

M.gmemoize = function(key, value)
  local is_fn = type(value) == "function"
  if G[key] == nil then
    G[key] = is_fn and value() or value
  end
  return is_fn and function()
    return G[key]
  end or value
end

M.fs = {}

M.fs.target_triple = M.gmemoize("target_triple", wt.target_triple)

M.fs.platform = M.gmemoize("plaftorm", function()
  local is_win = M.fs.target_triple:find "windows" ~= nil
  local is_linux = M.fs.target_triple:find "linux" ~= nil
  local is_mac = M.fs.target_triple:find "apple" ~= nil
  local os = is_win and "windows" or is_linux and "linux" or is_mac and "mac" or "unknown"
  return { os = os, is_win = is_win, is_linux = is_linux, is_mac = is_mac }
end)

local is_win = M.fs.platform().is_win

M.fs.home = M.gmemoize("home", function()
  return ((os.getenv "USERPROFILE" or os.getenv "HOME" or wt.home or ""):gsub("\\", "/"))
end)

M.fs.path_separator = M.gmemoize("path_separator", is_win and "\\" or "/")

M.fs.basename = function(path)
  local trimmed_path = path:gsub("[/\\]*$", "")
  local index = trimmed_path:find "[^/\\]*$"
  return index and trimmed_path:sub(index) or trimmed_path
end

M.fs.find_git_dir = function(directory)
  directory = directory:gsub("~", M.fs.home())

  while directory do
    local handle = io.open(directory .. "/.git/HEAD", "r")
    if handle then
      handle:close()
      directory = directory:gsub(M.fs.home(), "~")
      return directory
    elseif directory == "/" or directory == "" then
      break
    else
      directory = directory:match "(.+)/[^/]*"
    end
  end

  return nil
end

M.fs.get_cwd_hostname = function(pane, search_git_root_instead)
  local cwd, hostname = "", ""
  local cwd_uri = pane:get_current_working_dir()

  if cwd_uri then
    if type(cwd_uri) == "userdata" then
      cwd = cwd_uri.file_path
      hostname = cwd_uri.host or wt.hostname()
    else
      cwd_uri = cwd_uri:sub(8)
      local slash = cwd_uri:find "/"
      if slash then
        hostname = cwd_uri:sub(1, slash - 1)
        cwd = cwd_uri:gsub("%%(%x%x)", function(hex)
          return string.char(tonumber(hex, 16))
        end)
      end
    end

    local dot = hostname:find "[.]"
    if dot then
      hostname = hostname:sub(1, dot - 1)
    end
    if hostname == "" then
      hostname = wt.hostname()
    end
    hostname = hostname:gsub("^%l", string.upper)
  end

  if is_win then
    cwd = cwd:gsub("/" .. M.fs.home() .. "(.-)$", "~%1")
  else
    cwd = cwd:gsub(M.fs.home() .. "(.-)$", "~%1")
  end

  if search_git_root_instead then
    local git_root = M.fs.find_git_dir(cwd)
    cwd = git_root or cwd
  end

  return cwd, hostname
end

M.fs.pathshortener = function(path, len)
  local splitted_path = M.str.split(path, M.fs.path_separator)
  local short_path = ""
  for i = 1, #splitted_path do
    local dir = splitted_path[i]
    local short_dir = dir:sub(1, len)
    if short_dir == "" then
      break
    end
    short_path = short_path
      .. (short_dir == "." and dir:sub(1, len + 1) or short_dir)
      .. M.fs.path_separator
  end
  return short_path
end

M.fs.pathconcat = function(...)
  local paths = { ... }
  return table.concat(paths, M.fs.path_separator)
end

M.fs.read_dir = function(directory)
  if G.dirs_read and G.dirs_read[directory] then
    return G.dirs_read[directory]
  end

  local filename = M.fs.basename(directory) .. ".txt"
  local cmd = "find %s -maxdepth 1 -type f > %s"
  local tempfile = M.fs.pathconcat("/tmp", filename)
  if is_win then
    cmd = 'cmd /C "dir %s /B /S > %s"'
    tempfile = M.fs.pathconcat(os.getenv "TEMP", filename)
  end
  cmd = cmd:format(directory, tempfile)

  local files = {}
  local file = io.open(tempfile, "r")
  if file then
    for line in file:lines() do
      files[#files + 1] = line
    end
    file:close()
  else
    local success = os.execute(cmd)
    if not success then
      return wt.log_error "Unable to create temp file."
    end
    file = io.open(tempfile, "r")
    if file then
      for line in file:lines() do
        files[#files + 1] = line
      end
      file:close()
    end
  end

  G.dirs_read = { [directory] = files }
  return G.dirs_read[directory]
end

M.mt = {}

M.mt.round = function(number)
  return floor(number + 0.5)
end

M.mt.mround = function(number, multiple)
  local remainder = number % multiple
  return number - remainder + (remainder > multiple * 0.5 and multiple or 0)
end

M.mt.toint = function(number, increment)
  if increment then
    return floor(number / increment) * increment
  end
  return number >= 0 and floor(number + 0.5) or ceil(number - 0.5)
end

M.str = {}

M.str.strwidth = function(str, num)
  local cells = 0
  if num then
    local count = 0
    for _, rune in codes(str) do
      local w = wcwidth(rune)
      if w < 0 then
        return -1
      end
      count = count + 1
      if count >= num then
        break
      end
    end
  else
    for _, rune in codes(str) do
      local w = wcwidth(rune)
      if w < 0 then
        return -1
      end
      cells = cells + w
    end
  end
  return cells
end

M.str.pad = function(s, padding)
  s = type(s) ~= "string" and tostring(s) or s
  padding = padding or 1

  local pad = (" "):rep(padding)
  return ("%s%s%s"):format(pad, s, pad)
end

M.str.gsplit = function(s, sep, opts)
  local plain, trimempty
  opts = opts or {}
  plain, trimempty = opts.plain, opts.trimempty

  local start = 1
  local done = false

  -- For `trimempty`: queue of collected segments, to be emitted at next pass.
  local segs = {}
  local empty_start = true -- Only empty segments seen so far.

  local function _pass(i, j, ...)
    if i then
      assert(j + 1 > start, "Infinite loop detected")
      local seg = s:sub(start, i - 1)
      start = j + 1
      return seg, ...
    else
      done = true
      return s:sub(start)
    end
  end

  return function()
    if trimempty and #segs > 0 then
      -- trimempty: Pop the collected segments.
      return table.remove(segs)
    elseif done or (s == "" and sep == "") then
      return nil
    elseif sep == "" then
      if start == #s then
        done = true
      end
      return _pass(start + 1, start)
    end

    local seg = _pass(s:find(sep, start, plain))

    -- Trim empty segments from start/end.
    if trimempty and seg ~= "" then
      empty_start = false
    elseif trimempty and seg == "" then
      while not done and seg == "" do
        segs[1] = ""
        seg = _pass(s:find(sep, start, plain))
      end
      if done and seg == "" then
        return nil
      elseif empty_start then
        empty_start = false
        segs = {}
        return seg
      end
      if seg ~= "" then
        segs[1] = seg
      end
      return table.remove(segs)
    end

    return seg
  end
end

M.str.split = function(s, sep, opts)
  local t = {}
  for c in M.str.gsplit(s, sep, opts) do
    t[#t + 1] = c
  end
  return t
end

M.str.format_tab_title = function(tab, config, max_width)
  local pane = tab.active_pane

  local title = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title
    or tab.active_pane.title

  title = title:gsub("^Copy mode: ", "")
  local process, other = title:match "^(%S+)%s*%-?%s*%s*(.*)$"

  if Icon.Progs[process] then
    title = Icon.Progs[process] .. " " .. (other or "")
  end

  local proc = pane.foreground_process_name
  if proc:find "nvim" then
    proc = proc:sub(proc:find "nvim")
  end
  local is_truncation_needed = true
  if proc == "nvim" then
    ---full title truncation is not necessary since the dir name will be truncated
    is_truncation_needed = false
    local cwd = M.fs.basename(pane.current_working_dir.file_path)

    ---instead of truncating the whole title, truncate to length the cwd to ensure that the
    ---right parenthesis always closes.
    --if max_width == config.tab_max_width then
    if string.len(cwd) >= max_width then
      cwd = wt.truncate_right(cwd, max_width - 14) .. "..."
    end

    if string.len(cwd) >= config.tab_max_width then
      cwd = wt.truncate_right(cwd, config.tab_max_width - 14) .. "..."
    end

    title = ("%s ( %s)"):format(Icon.Progs[proc], cwd)
  end

  title = title:gsub(M.fs.basename(M.fs.home()) .. "/", "󰋜 /")
  title = title:gsub("~", "󰋜 ")

  if
    is_truncation_needed
    and (string.len(title) >= config.tab_max_width or string.len(title) >= max_width)
  then
    local folderName = M.fs.basename(pane.current_working_dir.file_path)

    if string.len(folderName) >= max_width then
      folderName = wt.truncate_right(folderName, max_width - 8) .. "..."
    end

    if string.len(folderName) >= config.tab_max_width then
      folderName = wt.truncate_right(folderName, config.tab_max_width - 8) .. "..."
    end

    title = folderName
  end

  return title
end

M.key = {
  aliases = {
    CR = "Enter",
    BS = "Backspace",
    ESC = "Escape",
    Bar = "|",
    k0 = "Numpad0",
    k1 = "Numpad1",
    k2 = "Numpad2",
    k3 = "Numpad3",
    k4 = "Numpad4",
    k5 = "Numpad5",
    k6 = "Numpad6",
    k7 = "Numpad7",
    k8 = "Numpad8",
    k9 = "Numpad9",
  },

  modifiers = { C = "CTRL", S = "SHIFT", W = "SUPER", M = "ALT" },
}

M.key.__has = function(lhs, pattern)
  return lhs:find(pattern) ~= nil
end

M.key.__has_leader = function(lhs, mods)
  if M.key.__has(lhs, "^<leader>") then ---leader should always be the fist keymap
    lhs = (lhs:gsub("^<leader>", ""))
    mods[#mods + 1] = "LEADER"
  end
  return lhs
end

M.key.map = function(lhs, rhs, tbl)
  local function __map(key, mods)
    tbl[#tbl + 1] = { key = key, mods = table.concat(mods or {}, "|"), action = rhs }
  end

  ---initialize the modifiers table
  local mods = {}

  ---dont'parse a single key
  if #lhs == 1 then
    return __map(lhs, mods)
  end

  local aliases, modifiers = M.key.aliases, M.key.modifiers
  lhs = M.key.__has_leader(lhs, mods)

  if not M.key.__has(lhs, "%b<>") then
    return __map(lhs, mods)
  end

  lhs = lhs:gsub("(%b<>)", function(str)
    return str:sub(2, -2)
  end)

  local keys = M.str.split(lhs, "%-")

  if #keys == 1 then
    return __map(aliases[keys[1]] or keys[1], mods)
  end

  local k = keys[#keys]
  if modifiers[k] then
    return wt.log_error "keymap cannot end with modifier!"
  else
    keys[#keys] = nil
  end
  k = aliases[k] or k

  for i = 1, #keys do
    mods[#mods + 1] = modifiers[keys[i]]
  end

  return __map(k, mods)
end

M.color = {}

M.color.set_tab_button = function(config, theme)
  config.tab_bar_style = {}
  local sep = require("utils.class.icon").Sep.tb

  for _, state in ipairs { "new_tab", "new_tab_hover" } do
    local style = theme.tab_bar[state]
    local sep_bg, sep_fg = style.bg_color, theme.tab_bar.background

    local ButtonLayout = require("utils.class.layout"):new()
    local attributes = {
      style.intensity
        or (style.italic and "Italic")
        or (style.strikethrough and "Strikethrough")
        or (style.underline ~= "None" and style.underline),
    }

    ButtonLayout:push(sep_bg, sep_fg, sep.right, attributes)
    ButtonLayout:push(sep_bg, style.fg_color, " + ", attributes)
    ButtonLayout:push(sep_bg, sep_fg, sep.left, attributes)

    config.tab_bar_style[state] = ButtonLayout:format()
  end
end

return M
