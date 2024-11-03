---@module "utils.class.config"
---@author sravioli
---@license GNU-GPLv3

local wt = require "wezterm"

local M = {}

function M:new()
  self.config = {}
  self.config = wt.config_builder()
  self.config:set_strict_mode(true)
  self = setmetatable(self.config, { __index = M })
  return self
end

function M:add(spec)
  if type(spec) == "string" then
    if not (pcall(require, spec)) then
      return self
    end
    spec = require(spec)
  end

  for key, value in pairs(spec) do
    self.config[key] = value
  end

  return self
end

return M