local wezterm = require("wezterm")

local config = {
	theme = "nightfox",
	font_size = 18.0,
	font_family = "SauceCodePro Nerd Font Mono",
}

local M = {}

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
	c.window_padding = {
		left = 0,
		right = "1cell",
		top = 0,
		bottom = "0.25cell",
	}
	c.enable_scroll_bar = false

	if wezterm.target_triple == "x86_64-pc-windows-msvc" then
		c.window_background_opacity = 0.75
		-- config.win32_system_backdrop = "Acrylic"
		-- config.window_background_opacity = 0.0
		c.win32_system_backdrop = "Mica"
	-- config.win32_system_backdrop = "Tabbed"
	elseif wezterm.target_triple == "aarch64-apple-darwin" then
		c.window_background_opacity = 0.95
		c.macos_window_background_blur = 100
	end

	c.colors = wezterm.color.get_builtin_schemes()[config.theme]

	c.font = wezterm.font(config.font_family)
	c.font_size = config.font_size
	c.command_palette_font_size = 22.0
	c.command_palette_bg_color = c.colors.background
	c.command_palette_fg_color = c.colors.foreground
end

return M
