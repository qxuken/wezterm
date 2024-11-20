local wezterm = require("wezterm")
local act = wezterm.action

local cyberdream_colors = require("./coloschemes/cyberdream")
-- local spacedust_colors = require("./coloschemes/spacedust")
local colors = wezterm.color.get_builtin_schemes()["nightfox"]

local config = wezterm.config_builder()

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config, {
	padding = {
		top = 0,
	},
	separator = {
		space = 1,
		left_icon = "",
		right_icon = "",
	},
	modules = {
		workspace = {
			color = 5,
		},
		pane = {
			enabled = wezterm.target_triple == "x86_64-pc-windows-msvc",
			icon = "",
		},
		username = {
			enabled = false,
		},
		hostname = {
			enabled = false,
		},
		cwd = {
			enabled = false,
		},
		clock = {
			icon = "",
		},
	},
})

config.window_padding = {
	left = 1,
	right = 0,
	top = 0,
	bottom = 0,
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.window_background_opacity = 0.75
	-- config.win32_system_backdrop = "Acrylic"
	-- config.window_background_opacity = 0.0
	config.win32_system_backdrop = "Mica"
	-- config.win32_system_backdrop = "Tabbed"
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	config.window_background_opacity = 0.95
	config.macos_window_background_blur = 20
end

config.font = wezterm.font("SauceCodePro Nerd Font Mono")
config.font_size = 18.0
config.command_palette_font_size = 22.0
config.command_palette_bg_color = cyberdream_colors.background
config.command_palette_fg_color = cyberdream_colors.foreground

config.color_schemes = {
	CQS = colors,
}
config.colors = colors
config.color_scheme = "CQS"

config.colors.tab_bar = {
	background = "transparent",
	active_tab = {
		bg_color = "transparent",
		fg_color = colors.brights[6],
		intensity = "Bold",
	},
	inactive_tab = {
		bg_color = "transparent",
		fg_color = colors.selection_bg,
	},
	inactive_tab_hover = {
		bg_color = "transparent",
		fg_color = colors.selection_bg,
		italic = true,
	},
	new_tab = {
		bg_color = "transparent",
		fg_color = colors.selection_bg,
	},
	new_tab_hover = {
		bg_color = colors.cursor_bg,
		fg_color = colors.cursor_fg,
	},
}

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
if wezterm.target_triple == "aarch64-apple-darwin" then
	config.leader = { key = "b", mods = "SUPER", timeout_milliseconds = 1000 }
	-- config.send_composed_key_when_right_alt_is_pressed = true
	-- config.use_ime = true
end

config.keys = {
	{ key = "LeftArrow", mods = "OPT", action = act.SendString("\x1bb") },
	{ key = "RightArrow", mods = "OPT", action = act.SendString("\x1bf") },
	{ key = "LeftArrow", mods = "CMD", action = wezterm.action({ SendString = "\x1bOH" }) },
	{ key = "RightArrow", mods = "CMD", action = wezterm.action({ SendString = "\x1bOF" }) },
	{ key = "F11", action = wezterm.action.ToggleFullScreen },
	{ key = "(", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
	{ key = ")", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(1) },
	{ key = "l", mods = "LEADER", action = act.ShowLauncher },
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "n",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
	{
		key = "r",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter new name for tab" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- TODO report issue
	-- {
	-- 	key = "r",
	-- 	mods = "LEADER|SHIFT",
	-- 	action = act.PromptInputLine({
	-- 		description = wezterm.format({
	-- 			{ Attribute = { Intensity = "Bold" } },
	-- 			{ Foreground = { AnsiColor = "Fuchsia" } },
	-- 			{ Text = "Enter new name for workspace" },
	-- 		}),
	-- 		action = wezterm.action_callback(function(window, pane, line)
	-- 			if line then
	-- 				window:mux_window():set_workspace(line)
	-- 			end
	-- 		end),
	-- 	}),
	-- },
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- config.default_prog = { "pwsh", "-l", "-NoLogo" }
	config.default_prog = { "nu", "-l" }
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	-- config.set_environment_variables = { XDG_CONFIG_HOME = "/Users/qxuken/.config/" }
	-- config.default_prog = { "/opt/homebrew/bin/nu", "-l" }
end

config.front_end = "WebGpu"
config.max_fps = 144
config.animation_fps = 144

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.webgpu_power_preference = "HighPerformance"
end

return config
