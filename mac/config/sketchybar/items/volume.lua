local icons = {
	_100 = "",
	_66 = "",
	_33 = "",
	_10 = "",
	_0 = "󰖁",
}

local volume_icon = SBAR.add("item", "volume_icon", {
	position = "right",
	icon = {
		string = icons._33,
		font = { family = "Hack Nerd Font", style = "Regular", size = DEFAULT_ITEM.icon.font.size * 1.05 },
		padding_left = DEFAULT_ITEM.icon.padding_left * 0.65,
		padding_right = DEFAULT_ITEM.icon.padding_right * 0.35,
	},
	label = {
		drawing = true,
		string = "0%",
		font = { family = "Rounded Mplus 1c Bold", style = "Bold", size = DEFAULT_ITEM.label.font.size * 0.94 },
		padding_left = 1,
		padding_right = DEFAULT_ITEM.label.padding_right * 0.55,
	},
	background = { drawing = false },
})

volume_icon:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO) or 0
	local icon = icons._0

	if volume > 60 then
		icon = icons._100
	elseif volume > 30 then
		icon = icons._66
	elseif volume > 10 then
		icon = icons._33
	elseif volume > 0 then
		icon = icons._10
	end

	volume_icon:set({
		icon = { string = icon },
		label = { string = tostring(math.floor(volume)) .. "%" },
	})
end)

volume_icon:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "right" then
		SBAR.exec("open /System/Library/PreferencePanes/Sound.prefPane")
	else
		SBAR.exec("open -a 'System Settings'")
	end
end)

local function refresh_volume()
	SBAR.exec("osascript -e 'output volume of (get volume settings)'", function(out)
		local volume = tonumber((out or ""):gsub("%s+", "")) or 0
		local icon = icons._0
		if volume > 60 then
			icon = icons._100
		elseif volume > 30 then
			icon = icons._66
		elseif volume > 10 then
			icon = icons._33
		elseif volume > 0 then
			icon = icons._10
		end

		volume_icon:set({
			icon = { string = icon },
			label = { string = tostring(volume) .. "%" },
		})
	end)
end

volume_icon:subscribe({ "routine", "system_woke" }, refresh_volume)
volume_icon:set({ update_freq = 20 })
refresh_volume()

return volume_icon
