-- Look And Feel Configuration
local theme = require("modules.colors")

hl.config({
    general = {gaps_in = 10,gaps_out = 10,border_size = 2,
        col = { active_border = { colors = { theme.color2, theme.color2 }, angle = 45 }, inactive_border = theme.color15 },
    resize_on_border = true, allow_tearing = false, },
    decoration = {rounding = 10,
rounding_power = 10,
active_opacity = 1,
inactive_opacity = 1,
    shadow = {enabled = false, range = 0, render_power = 1, color = 0xee1a1a1a },

    blur = {enabled = true,
             size = 8,
passes = 6,
vibrancy = 0.6, },},

    animations = {
enabled   = true, },})
