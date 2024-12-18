local wezterm = require("wezterm")

local fira_features = {
	"zero",
	"cv01",
	"cv02",
	"cv06",
	"ss05",
	"ss03",
	"cv16",
	"cv31",
	"cv29",
	"cv30",
	"ss08",
	"cv24",
	"ss09",
	"cv25",
	"cv26",
	"cv32",
	"cv27",
	"cv28",
	"ss06",
}

local config = {
	theme = "Rosé Pine (Gogh)",
	font_size = 19.0,
	font_families = {
		{
			family = "FiraCode Nerd Font",
			harfbuzz_features = fira_features,
		},
		{
			family = "FiraCode",
			harfbuzz_features = fira_features,
		},
		"SauceCodePro Nerd Font Mono",
		"SourceCodePro",
	},
}

local M = {}

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
	c.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
	c.enable_scroll_bar = false

	c.color_scheme = config.theme
	c.colors = wezterm.color.get_builtin_schemes()[config.theme]

	c.font = wezterm.font_with_fallback(config.font_families)
	c.font_size = config.font_size
	c.command_palette_font_size = 22.0
	c.command_palette_bg_color = c.colors.background
	c.command_palette_fg_color = c.colors.foreground
end

return M
