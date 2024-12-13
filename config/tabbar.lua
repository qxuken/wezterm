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
	strip_extensions = {
		[".sh"] = true,
		[".exe"] = true,
	},
	known_aliases = {
		n = "nvim",
		hx = "helix",
		lz = "lazygit",
		y = "yazi",
	},
	hide_names = {
		nvim = true,
		lazygit = true,
	},
	known_programs = {
		Launcher = wezterm.nerdfonts.cod_rocket,
		Debug = wezterm.nerdfonts.cod_debug,
		launcher = wezterm.nerdfonts.md_rocket_launch,
		starship = wezterm.nerdfonts.md_rocket_launch_outline,
		debug = wezterm.nerdfonts.cod_debug,
		nu = wezterm.nerdfonts.seti_shell,
		wezterm = wezterm.nerdfonts.seti_shell,
		lazygit = utf8.char(0xf1d3),
		gh = wezterm.nerdfonts.cod_github_inverted,
		nvim = utf8.char(0xf36f),
		vim = wezterm.nerdfonts.custom_vim,
		node = wezterm.nerdfonts.dev_javascript,
		npm = utf8.char(0xf0399),
		yarn = utf8.char(0xe6a7),
		pnpm = utf8.char(0xe865),
		bun = utf8.char(0xe76f),
		deno = wezterm.nerdfonts.seti_typescript,
		go = wezterm.nerdfonts.seti_go,
		air = wezterm.nerdfonts.seti_go,
		rustc = wezterm.nerdfonts.dev_rust,
		cargo = wezterm.nerdfonts.dev_rust,
		python = wezterm.nerdfonts.dev_python,
		python3 = wezterm.nerdfonts.dev_python,
		pip = wezterm.nerdfonts.dev_python,
		pip3 = wezterm.nerdfonts.dev_python,
		ansible = wezterm.nerdfonts.md_ansible,
		sqlite3 = wezterm.nerdfonts.dev_sqllite,
		storybook = utf8.char(0xe8b3),
		yazi = utf8.char(0xf6e4),
	},
}

local function basename(possible_exe)
	local right = possible_exe:len()
	local left = 1
	for i = possible_exe:len(), 1, -1 do
		local ch = string.sub(possible_exe, i, i)
		if ch == "." then
			right = i
			break
		end
	end
	if right < 2 or config.strip_extensions[string.sub(possible_exe, right)] == nil then
		return possible_exe
	end
	return possible_exe:sub(left, right - 1)
end

local function nu_osc_fmt(title)
	local remote = ""
	local current_folder = ""
	local exe = ""
	local last_slash = 1
	for i = 1, title:len() do
		local ch = string.sub(title, i, i)
		if ch == ":" then
			remote = title:sub(1, i) .. " "
			goto continue
		end
		if ch == "/" or ch == "\\" then
			last_slash = i
			goto continue
		end
		if ch == ">" then
			current_folder = title:sub(last_slash + 1, i - 1)
			exe = title:sub(i + 2)
			break
		end
		::continue::
	end
	-- if there is no path elements print as is
	if last_slash == 1 then
		title = basename(title)
		local icon = config.known_programs[title] or wezterm.nerdfonts.md_egg
		return icon .. " " .. title
	end

	-- if no executables in string print last path segment
	if exe == "" then
		return wezterm.nerdfonts.cod_folder .. " " .. remote .. title:sub(last_slash + 1)
	end

	exe = basename(exe)
	exe = config.known_aliases[exe] or exe
	local icon = config.known_programs[exe] or wezterm.nerdfonts.cod_debug_start
	if config.hide_names[exe] then
		exe = ""
	else
		exe = " " .. exe
	end

	return icon .. " " .. remote .. current_folder .. exe
end

local function fmt_tab_title(title)
	if title == nil or title == "" then
		return nil
	end

	local exe = ""

	if title:sub(1, 1) == "!" then
		local space = 1
		for i = 2, title:len() do
			if string.sub(title, i, i) == " " then
				space = i
				break
			end
		end
		if space == 1 or space == title:len() then
			title = title:sub(2)
			exe = title
		else
			exe = title:sub(2, space - 1)
			title = title:sub(space + 1)
		end
	end
	exe = config.known_aliases[exe] or exe
	local icon = config.known_programs[exe] ~= nil and config.known_programs[exe] .. " " or ""
	return wezterm.nerdfonts.fa_bookmark .. " " .. icon .. title
end

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
	c.use_fancy_tab_bar = false
	c.tab_bar_at_bottom = config.position == "bottom"
	c.tab_max_width = config.max_width + 3
	c.show_new_tab_button_in_tab_bar = false

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

---@diagnostic disable-next-line: unused-local
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

	local tab_title = fmt_tab_title(tab.tab_title) or nu_osc_fmt(pane.title)
	local domain_icon = pane.domain_name:sub(1, 3) == "WSL" and wezterm.nerdfonts.linux_locos .. " " or ""

	return {
		{ Background = { Color = s_bg } },
		{ Foreground = { Color = s_fg } },
		{ Text = " " .. domain_icon .. tab_title .. " " },
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

	local workspace = wezterm.format({
		{ Background = { Color = inactive_bg } },
		{ Foreground = { Color = inactive_fg } },
		{ Text = " " .. window:active_workspace() .. " " },
	})

	local domain = wezterm.format({
		{ Background = { Color = inactive_bg } },
		{ Foreground = { Color = inactive_fg } },
		{ Text = " " .. pane:get_domain_name() .. " " },
	})
	local time_fmt = wezterm.format({
		{ Background = { Color = palette.ansi[6] } },
		{ Foreground = { Color = palette.background } },
		{ Text = " " .. time },
	})
	local time_right = wezterm.format({
		{ Background = { Color = "transparent" } },
		{ Foreground = { Color = palette.ansi[6] } },
		{ Text = "" },
	})

	window:set_right_status(domain_left .. workspace .. domain .. time_fmt .. time_right)
end)

return M
