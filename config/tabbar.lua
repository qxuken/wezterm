local wezterm = require("wezterm")

local M = {}

local config = {
	max_width = 32,
	position = "bottom",
	modes = {
		resize_mode = "R",
		copy_mode = "C",
		search_mode = "S",
	},
	inactive_bg = "#303030", -- colors.inactive_tab.bg_color
	inactive_fg = "#c6c6c6", -- colors.inactive_tab.fg_color
}

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
	c.use_fancy_tab_bar = false
	c.tab_bar_at_bottom = config.position == "bottom"
	c.tab_max_width = config.max_width + 3

	local colors = c.colors
	colors.tab_bar = {
		background = "transparent",
		active_tab = {
			bg_color = "transparent",
			fg_color = colors.brights[6],
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = config.inactive_bg,
			fg_color = config.inactive_fg,
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
end

wezterm.on("format-tab-title", function(tab, tabs, _panes, conf, _hover, _max_width)
	local index_i = tab.tab_index + 1

	local palette = conf.resolved_palette
	local colors = palette.tab_bar

	local rainbow = {
		palette.ansi[2],
		palette.ansi[3],
		palette.ansi[4],
		palette.ansi[5],
		palette.ansi[6],
		palette.ansi[7],
	}

	local active_bg = rainbow[tab.tab_index % 6 + 1]
	local active_fg = colors.background
	local inactive_bg = colors.inactive_tab.bg_color
	local inactive_fg = colors.inactive_tab.fg_color

	local s_bg, s_fg, e_bg, e_fg

	if tab.is_active then
		s_bg = active_bg
		s_fg = active_fg
		e_bg = active_fg
		e_fg = active_bg
	else
		s_bg = inactive_bg
		s_fg = inactive_fg
		e_bg = active_fg
		e_fg = inactive_bg
	end

	local pane = tab.active_pane
	local proc = basename(pane.foreground_process_name)
	local tab_title = proc ~= "nu" and proc or pane.title

	return {
		{ Background = { Color = s_bg } },
		{ Foreground = { Color = s_fg } },
		{ Text = " " .. tab_title .. " " },
		{ Background = { Color = e_bg } },
		{ Foreground = { Color = e_fg } },
		{ Text = index_i == #tabs and "" or "" },
	}
end)

wezterm.on("update-status", function(window, pane)
	local present, conf = pcall(window.effective_config, window)
	if not present then
		return
	end

	local palette = conf.resolved_palette
	local colors = palette.tab_bar

	local inactive_bg = colors.inactive_tab.bg_color
	local inactive_fg = colors.inactive_tab.fg_color

	local leader_text = ""
	local leader_bg = palette.ansi[6]
	local active = window:active_key_table()
	if config.modes[active] ~= nil then
		leader_text = config.modes[active]
		leader_bg = palette.ansi[7]
	elseif window:leader_is_active() then
		leader_text = wezterm.nerdfonts.cod_circle_large_filled
		leader_bg = palette.ansi[4]
	else
		leader_text = wezterm.nerdfonts.cod_circle
	end

	local leader_left = wezterm.format({
		{ Background = { Color = "transparent" } },
		{ Foreground = { Color = leader_bg } },
		{ Text = "" },
	})
	local leader = wezterm.format({
		{ Foreground = { Color = colors.background } },
		{ Background = { Color = leader_bg } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = " " .. leader_text .. " " },
	})

	window:set_left_status(" " .. leader_left .. leader)

	local time = wezterm.time.now():format(" %H:%M ")

	local domain_left = wezterm.format({
		{ Background = { Color = "transparent" } },
		{ Foreground = { Color = inactive_bg } },
		{ Text = "" },
	})
	local domain = wezterm.format({
		{ Background = { Color = inactive_bg } },
		{ Foreground = { Color = inactive_fg } },
		{ Text = " " .. pane:get_domain_name() .. " " },
	})
	local time_fmt = wezterm.format({
		{ Background = { Color = palette.ansi[6] } },
		{ Foreground = { Color = palette.background } },
		{ Text = time },
	})
	local time_right = wezterm.format({
		{ Background = { Color = "transparent" } },
		{ Foreground = { Color = palette.ansi[6] } },
		{ Text = "" },
	})

	window:set_right_status(domain_left .. domain .. time_fmt .. time_right .. " ")
end)

return M
