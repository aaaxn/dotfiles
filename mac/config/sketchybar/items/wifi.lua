local wifi = SBAR.add("item", "wifi", {
	position = "right",
	icon = {
		string = "",
		font = { family = "Hack Nerd Font", style = "Regular", size = DEFAULT_ITEM.icon.font.size * 1.05 },
		padding_left = DEFAULT_ITEM.icon.padding_left * 0.85,
		padding_right = DEFAULT_ITEM.icon.padding_right * 0.85,
	},
	label = { drawing = false },
	background = { drawing = false },
	click_script = "open -a 'System Settings'",
})

return wifi
