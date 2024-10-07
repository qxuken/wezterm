local cyberdream_colors = require("./coloschemes/cyberdream")
local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.colors = cyberdream_colors

config.font = wezterm.font("SauceCodePro Nerd Font Mono")
config.font_size = 20.0

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "(", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },
	{ key = ")", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
	{ key = "l", mods = "LEADER", action = act.ShowLauncher },
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "pwsh", "-l", "-NoLogo" }
end

wezterm.plugin.require("https://github.com/yriveiro/wezterm-tabs").apply_to_config(config, {
	ui = {
		separators = {
			arrow_solid_left = "|",
			arrow_solid_right = "|",
			arrow_thin_left = "|",
			arrow_thin_right = "|",
		},
	},
})

config.colors.tab_bar = {
	background = cyberdream_colors.background,
	active_tab = {
		bg_color = cyberdream_colors.background,
		fg_color = cyberdream_colors.brights[6],
		intensity = "Bold",
	},
	inactive_tab = {
		bg_color = cyberdream_colors.background,
		fg_color = cyberdream_colors.selection_bg,
	},
	inactive_tab_hover = {
		bg_color = cyberdream_colors.indexed[16],
		fg_color = cyberdream_colors.selection_bg,
		italic = true,
	},
	new_tab = {
		bg_color = cyberdream_colors.background,
		fg_color = cyberdream_colors.selection_bg,
	},
	new_tab_hover = {
		bg_color = cyberdream_colors.cursor_bg,
		fg_color = cyberdream_colors.cursor_fg,
		italic = false,
	},
}

return config
