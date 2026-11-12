-- Define the helper function locally
local function rgba(r, g, b, a)
    -- Hyprland color format: 0xRRGGBBAA
    return string.format("0x%02x%02x%02x%02x", r, g, b, math.floor(a * 255))
end

-- Create and populate the table
local M = {}

-- Background and Foreground
M.background = "0xff1a1b26"
M.foreground = "0xffc0caf5"
M.cursor     = "0xffc0caf5"

-- Colors
M.color0     = "0xff1a1b26"
M.color1     = "0xfff7768e"
M.color2     = "0xff9ece6a"
M.color3     = "0xffe0af68"
M.color4     = "0xff7aa2f7"
M.color5     = "0xffbb9af7"
M.color6     = "0xff7dcfff"
M.color7     = "0xffa9b1d6"
M.color8     = "0xff414868"
M.color9     = "0xffff899d"
M.color10    = "0xff9fe044"
M.color11    = "0xfffaba4a"
M.color12    = "0xff8db0ff"
M.color13    = "0xffc7a9ff"
M.color14    = "0xffa4daff"
M.color15    = "0xffc0caf5"

-- Return the table
return M
