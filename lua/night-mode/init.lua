M = {}

local state = 0
local STATE_DAY = 1
local STATE_NIGHT = 2
local config = require("night-mode.config")

function M.init() end

function M.getCurrentConfig()
	return config
end

local function timer_update()
	local SunUp = true
	local h = tonumber(vim.fn.strftime("%H"))
	if (h < config.hour_sunrise) or (h >= config.hour_sunset) then
		SunUp = false
	end

	local change = false
	local col = "NOT SET"
	local bg = "not set"
	if SunUp then
		if state ~= STATE_DAY then
			change = true
			col = config.day_colourscheme
			bg = config.day_bg
			if config.day_lualine_theme ~= "" then
				require("lualine").setup({ options = { theme = config.day_lualine_theme } })
			end
			state = STATE_DAY
		end
	else
		if state ~= STATE_NIGHT then
			change = true
			col = config.night_colourscheme
			bg = config.night_bg
			if config.night_lualine_theme ~= "" then
				require("lualine").setup({ options = { theme = config.night_lualine_theme } })
			end
			state = STATE_NIGHT
		end
	end

	if change then
		vim.notify("Night-Mode: Changing colorscheme to " .. col .. " (bg=" .. bg .. ")")
		vim.cmd("colorscheme " .. col)
		vim.cmd("set bg=" .. bg)
	end

	vim.defer_fn(timer_update, 60000)
end

function M.setup(opts)
	for i, v in pairs(opts) do
		config[i] = v
	end

	if config.enabled then
		if (config.day_colourscheme == "") or (config.night_colourscheme == "") then
			config.enabled = false
			vim.notify("Missing colourscheme for Night-Mode plugin")
		else
			timer_update()
		end
	end
end

return M
