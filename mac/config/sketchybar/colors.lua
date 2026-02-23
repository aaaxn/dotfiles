local colors = {}
local config_dir = os.getenv("CONFIG_DIR")
local theme_file = config_dir .. "/helpers/active_theme.txt"

-- Create the directory once when the script loads if not available yet
os.execute("mkdir -p " .. config_dir .. "/helpers")

-- 1. Define Common Colors
colors.white = 0xffffffff
colors.transparent = 0x00000000
colors.red = 0xffff4444
colors.orange = 0xffffa500
colors.charging = 0xffffd700

-- 2. Define Your Schemes
local schemes = {
	gruvbox = {
		bar_color = 0x70282828,
		accent_color = 0xffd79921,
		secondary_accent = 0xfffabd2f,
		disabled_color = 0xffd3d3d3,
		background = 0xfa1e1e2e,
		background_border = 0xff45475a,
		popup_background = 0xff282828,
		popup_border = 0xffd79921,
	},
	teal = {
		bar_color = 0x40001f30,
		accent_color = 0xfa001f30,
		secondary_accent = 0xff397d89,
		disabled_color = 0xff397d89,
		background = 0xff2cf9ed,
		background_border = 0xfa001f30,
		popup_background = 0xff2cf9ed,
		popup_border = 0xfa001f30,
	},
	blacknwhite = {
		bar_color = 0x40000000,
		accent_color = 0xffffffff,
		secondary_accent = 0xffa9cce3,
		disabled_color = 0xffb0b0b0,
		background = 0xfa101314,
		background_border = 0xffffffff,
		popup_background = 0xff101314,
		popup_border = 0xffffffff,
	},
	purple = {
		bar_color = 0x70140c42,
		accent_color = 0xffeb46f9,
		secondary_accent = 0xffa569bd,
		disabled_color = 0xffb8a1d9,
		background = 0xfa140c42,
		background_border = 0xff2e2a5a,
		popup_background = 0xff140c42,
		popup_border = 0xffeb46f9,
	},
	red = {
		bar_color = 0x7023090e,
		accent_color = 0xffff2453,
		secondary_accent = 0xffc0392b,
		disabled_color = 0xffe1a2a6,
		background = 0xfa23090e,
		background_border = 0xff3c1a22,
		popup_background = 0xff23090e,
		popup_border = 0xffff2453,
	},
	blue = {
		bar_color = 0x70021254,
		accent_color = 0xff15bdf9,
		secondary_accent = 0xff5dade2,
		disabled_color = 0xffaac5e0,
		background = 0xfa021254,
		background_border = 0xff223973,
		popup_background = 0xff021254,
		popup_border = 0xff15bdf9,
	},
	green = {
		bar_color = 0x70003315,
		accent_color = 0xff1dfca1,
		secondary_accent = 0xff52be80,
		disabled_color = 0xffa1e0c0,
		background = 0xfa003315,
		background_border = 0xff0f4d2b,
		popup_background = 0xff003315,
		popup_border = 0xff1dfca1,
	},
	orange = {
		bar_color = 0x70381c02,
		accent_color = 0xfff97716,
		secondary_accent = 0xffeb984e,
		disabled_color = 0xffe0bfa1,
		background = 0xfa381c02,
		background_border = 0xff4f2e11,
		popup_background = 0xff381c02,
		popup_border = 0xfff97716,
	},
	yellow = {
		bar_color = 0x702d2b02,
		accent_color = 0xfff7fc17,
		secondary_accent = 0xfff4d03f,
		disabled_color = 0xffe9dea1,
		background = 0xfa2d2b02,
		background_border = 0xff4e4b13,
		popup_background = 0xff2d2b02,
		popup_border = 0xfff7fc17,
	},
	liquid_glass = {
		bar_color = 0x16000000,
		accent_color = 0xffffffff,
		secondary_accent = 0xffd6eaf8,
		disabled_color = 0xff777777,
		background = 0x20ffffff,
		background_border = 0x40ffffff,
		popup_background = 0xee1a1d1e,
		popup_border = 0x80ffffff,
	},
}

-- 3. Select Active Scheme (fixed)
local active_name = "liquid_glass"
local active_scheme_data = schemes[active_name]

-- 4. Merge (Now simple and direct)
for k, v in pairs(active_scheme_data) do
	colors[k] = v
end

local function with_alpha(color, alpha)
	return ((alpha & 0xff) << 24) | (color & 0x00ffffff)
end

-- Soften bar/popup border visibility across all themes.
colors.background_border = with_alpha(colors.background_border, 0x66)
colors.popup_border = with_alpha(colors.popup_border, 0x77)

-- 5. Export Metadata
colors.active_scheme_name = active_name
colors.all_schemes = schemes

colors.border_palette = {
	default_active = colors.accent_color & 0x00ffffff,
	default_inactive = colors.disabled_color & 0x00ffffff,
	floating_active = 0x00f5c2e7, -- Catppuccin pink
	floating_inactive = 0x00cba6f7, -- Catppuccin mauve
	active_alpha = 0xb8,
	inactive_alpha = 0x72,
	width = 4.5,
}

local function apply_borders(active_rgb, inactive_rgb)
	local active_hex = string.format("0x%02x%06x", colors.border_palette.active_alpha, active_rgb & 0x00ffffff)
	local inactive_hex = string.format("0x%02x%06x", colors.border_palette.inactive_alpha, inactive_rgb & 0x00ffffff)

	os.execute(
		"command -v borders >/dev/null 2>&1 && borders active_color="
			.. active_hex
			.. " inactive_color="
			.. inactive_hex
			.. " width="
			.. colors.border_palette.width
			.. " hidpi=on &"
	)
end

function colors.apply_borders(is_floating)
	if is_floating then
		apply_borders(colors.border_palette.floating_active, colors.border_palette.floating_inactive)
	else
		apply_borders(colors.border_palette.default_active, colors.border_palette.default_inactive)
	end
end

-- Start with the default (non-floating) border state.
colors.apply_borders(false)

return colors
