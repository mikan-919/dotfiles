-- Pull in the wezterm API
local wezterm = require 'wezterm'

local config = {}

config = wezterm.config_builder()

-- colors
config.color_scheme = "iceberg-light"
config.window_background_opacity = 0.5
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- font
config.font = wezterm.font("UDEV Gothic NFLG")
config.font_size = 16 

return config
