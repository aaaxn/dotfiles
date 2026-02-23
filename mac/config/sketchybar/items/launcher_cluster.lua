local function glass_background()
	return {
		drawing = true,
		color = COLORS.background,
		border_color = COLORS.background_border,
		border_width = DEFAULT_ITEM.background.border_width,
		corner_radius = DEFAULT_ITEM.background.corner_radius,
		height = DEFAULT_ITEM.background.height,
	}
end

local function noop()
	return "true"
end

local function open_app(app_name)
	return "open -a '" .. app_name .. "' >/dev/null 2>&1 || true"
end

local function aerospace_cmd(cmd)
	return "/opt/homebrew/bin/aerospace " .. cmd .. " >/dev/null 2>&1 || true"
end

local function add_icon_item(name, icon_string, opts)
	opts = opts or {}
	local item = SBAR.add("item", name, {
		position = "left",
		icon = {
			string = icon_string,
			font = opts.font or { family = "Hack Nerd Font", style = "Regular", size = DEFAULT_ITEM.icon.font.size * 1.0 },
			color = opts.color or COLORS.accent_color,
			padding_left = opts.padding_left or (DEFAULT_ITEM.icon.padding_left * 0.75),
			padding_right = opts.padding_right or (DEFAULT_ITEM.icon.padding_right * 0.75),
		},
		label = { drawing = false },
		background = opts.background or { drawing = false },
		click_script = opts.click_script or noop(),
	})

	return item
end

local traffic_red = add_icon_item("left.traffic.red", "●", {
	color = 0xffff5f57,
	font = { family = "Hack Nerd Font", style = "Regular", size = DEFAULT_ITEM.icon.font.size * 0.92 },
	click_script = noop(),
	padding_left = DEFAULT_ITEM.icon.padding_left * 0.85,
	padding_right = DEFAULT_ITEM.icon.padding_right * 0.45,
})

local traffic_yellow = add_icon_item("left.traffic.yellow", "●", {
	color = 0xfffebc2e,
	font = { family = "Hack Nerd Font", style = "Regular", size = DEFAULT_ITEM.icon.font.size * 0.92 },
	click_script = noop(),
	padding_left = 0,
	padding_right = DEFAULT_ITEM.icon.padding_right * 0.45,
})

local traffic_green = add_icon_item("left.traffic.green", "●", {
	color = 0xff28c840,
	font = { family = "Hack Nerd Font", style = "Regular", size = DEFAULT_ITEM.icon.font.size * 0.92 },
	click_script = noop(),
	padding_left = 0,
	padding_right = DEFAULT_ITEM.icon.padding_right * 0.85,
})

local nav_prev = add_icon_item("left.nav.prev", "", {
	click_script = aerospace_cmd("workspace-back-and-forth"),
})

local nav_next = add_icon_item("left.nav.next", "", {
	click_script = aerospace_cmd("move-workspace-to-monitor --wrap-around next"),
})

SBAR.add("bracket", "left_controls_cluster", {
	traffic_red.name,
	traffic_yellow.name,
	traffic_green.name,
	"left.nav.prev",
	"left.nav.next",
}, {
	background = glass_background(),
})

local ring_style = {
	drawing = true,
	color = COLORS.transparent,
	border_color = 0xa0ff5f57,
	border_width = 1,
	corner_radius = 999,
	height = DEFAULT_ITEM.background.height * 0.68,
}

local wm_focus = add_icon_item("left.wm.focus", "󰘳", {
	background = ring_style,
	click_script = aerospace_cmd("mode service"),
})

local wm_layout = add_icon_item("left.wm.layout", "󰙅", {
	click_script = aerospace_cmd("layout accordion"),
})

local app_code = add_icon_item("left.app.code", "", {
	background = ring_style,
	click_script = open_app("Visual Studio Code"),
})

local app_term = add_icon_item("left.app.term", "", {
	click_script = open_app("Ghostty"),
})

local app_chat = add_icon_item("left.app.chat", "󰭹", {
	background = ring_style,
	click_script = open_app("Discord"),
})

local app_music = add_icon_item("left.app.music", "", {
	click_script = open_app("Spotify"),
})

SBAR.add("bracket", "left_apps_cluster", {
	wm_focus.name,
	wm_layout.name,
	app_code.name,
	app_term.name,
	app_chat.name,
	app_music.name,
}, {
	background = glass_background(),
})
