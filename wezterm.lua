local wezterm = require("wezterm")

local config = wezterm.config_builder()

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- config.default_prog = { "pwsh", "-l", "-NoLogo" }
	config.default_prog = { "nu", "-l" }
elseif wezterm.target_triple == "aarch64-apple-darwin" then
	-- config.set_environment_variables = { XDG_CONFIG_HOME = "/Users/qxuken/.config/" }
	-- config.default_prog = { "/opt/homebrew/bin/nu", "-l" }
end

require("config.ui").apply_to_config(config)

require("config.rendering").apply_to_config(config)

require("config.tabbar").apply_to_config(config)

require("config.keybinds").apply_to_config(config)

return config
