local border_width = 1
local corner_raduis = 16
local item_padding = 10
local height = 34
local size = 15.0
-- Define default item properties
local default_item = {
	-- always the left object
	icon = {
		font = {
			family = "Hack Nerd Font",
			size = size,
		},
		color = COLORS.accent_color,
		padding_left = item_padding,
		padding_right = item_padding,
		y_offset = 1,
	},
	-- always the right object
	label = {
		font = {
			family = "Rounded Mplus 1c Bold",
			style = "Bold",
			size = size,
		},
		color = COLORS.accent_color,
		padding_right = item_padding,
	},
	background = {
		color = COLORS.background,
		border_color = COLORS.background_border,
		border_width = border_width,
		corner_radius = corner_raduis,
		height = height,
	},
	popup = {
		background = {
			corner_radius = corner_raduis,
			color = COLORS.popup_background,
			border_width = border_width,
			border_color = COLORS.popup_border,
		},
	},
}

SBAR.default(default_item)
SBAR.default({ background = { drawing = false } })
-- Add Bar
SBAR.bar({
	-- position = "top",
	height = height,
	color = COLORS.transparent,  -- barra invisível; os islands fornecem o visual
	margin = 8,                  -- margem lateral da tela
	blur_radius = 32,
})

return default_item
