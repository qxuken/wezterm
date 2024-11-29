local M = {}

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
	c.front_end = "WebGpu"
	c.max_fps = 144
	c.animation_fps = 144
	c.webgpu_power_preference = "HighPerformance"
end

return M
