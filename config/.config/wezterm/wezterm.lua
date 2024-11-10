-- Pull in the wezterm API
local wezterm = require 'wezterm'

local config = {}

config = wezterm.config_builder()

-- colors
config.color_scheme = "iceberg"
config.window_background_opacity = 0.5
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
-- font
config.font = wezterm.font("UDEV Gothic NFLG")
config.font_size = 16 

return config
