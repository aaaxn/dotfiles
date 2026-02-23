local config_dir = os.getenv("CONFIG_DIR")
local menu_bin = config_dir .. "/helpers/menus/bin/menus"
SBAR.add("item", "control_center", {
	position = "right",
	icon = {
		string = "",
		font = { family = "Hack Nerd Font", style = "Regular", size = DEFAULT_ITEM.icon.font.size * 1.05 },
		padding_left = DEFAULT_ITEM.icon.padding_left * 0.85,
		padding_right = DEFAULT_ITEM.icon.padding_right * 0.85,
	},
	label = { drawing = false },
	background = { drawing = false },
	click_script = menu_bin .. " -s 'Kontrollzentrum,BentoBox-0'",
})
