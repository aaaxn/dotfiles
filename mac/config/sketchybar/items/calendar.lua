-- Single-line clock + date
local cal_time = SBAR.add("item", "cal.time", {
	position = "right",
	y_offset = 0,
	padding_left = 2,
	padding_right = 4,
	label = {
		font = { family = "Rounded Mplus 1c Bold", style = "Bold", size = DEFAULT_ITEM.label.font.size * 0.98 },
		align = "right",
		padding_right = DEFAULT_ITEM.label.padding_right * 0.8,
		padding_left = DEFAULT_ITEM.icon.padding_left * 0.65,
	},
	icon = { drawing = false },
	background = { drawing = false },
})

-- UPDATE LOGIC
local function update_calendar()
	SBAR.exec(
		[[sh -c "LC_TIME=ja_JP.UTF-8 date '+%H:%M %a %d %-m月' 2>/dev/null || LC_TIME=ja_JP date '+%H:%M %a %d %-m月'"]],
		function(result)
			local text = result:gsub("%s+$", ""):gsub(" +", " ")
			if text == "" then
				text = os.date("%H:%M %a %d %m月")
			end
			cal_time:set({ label = { string = text } })
		end
	)
end

-- SUBSCRIPTIONS & INTERACTION
cal_time:subscribe({ "routine", "system_woke" }, update_calendar)
cal_time:set({ update_freq = 60 })

local function click_event()
	SBAR.exec("open -a Calendar")
end

-- Click to open calendar app
cal_time:subscribe("mouse.clicked", click_event)

update_calendar()
