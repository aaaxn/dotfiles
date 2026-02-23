require("globals")
-- 1. Setup Bar and Defaults
SBAR.begin_config() -- Pauses redraw for faster loading

local separator_module = require("items.separator")

-- Left Side (restore original left side)
require("items.menus")
separator_module.create("menu_separator")

-- Right Side (Order: Right -> Left)
require("items.calendar")
require("items.battery")
require("items.volume")
require("items.wifi")

SBAR.add("bracket", "right_system_cluster", {
	"wifi",
	"volume_icon",
	"battery",
	"cal.time",
}, {
	background = {
		drawing = true,
		color = COLORS.background,
		border_color = COLORS.background_border,
		border_width = DEFAULT_ITEM.background.border_width,
		corner_radius = DEFAULT_ITEM.background.corner_radius,
		height = DEFAULT_ITEM.background.height,
	},
})

-- Spotify kept optional; disabled to keep cleaner image-like layout
-- require("items.spofity")
-- Kept disabled for performance: avoids killing/restarting AeroSpace on every unlock.
-- require("items.unlock_reset")

-- 4. Finalize
SBAR.end_config()

-- 5. Setup a "delayed loader" for Spaces
SBAR.add("event", "aerospace_is_ready")
local spaces_loader = SBAR.add("item", { drawing = false })

spaces_loader:subscribe("aerospace_is_ready", function()
	-- This code runs only when the background waiter finishes
	SBAR.begin_config()
	require("items.spaces")
	SBAR.end_config()

	spaces_loader:delete()
end)

-- 6. Run the wait loop in the BACKGROUND
-- We use bash to wait, so Lua can continue to the event_loop immediately
SBAR.exec([[bash -c '
    while ! /opt/homebrew/bin/aerospace list-workspaces --all > /dev/null 2>&1; do sleep 0.5; done
    /opt/homebrew/bin/sketchybar --trigger aerospace_is_ready
' &]])

SBAR.event_loop() -- This keeps the lua process alive
