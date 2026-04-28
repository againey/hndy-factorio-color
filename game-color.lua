local Arithmetic = require("__hndy-color__.util.arithmetic")
local clamp = Arithmetic.clamp

---@alias Hndy.Color.GameColor Color

---Creates a table following the Factorio specification for colors using the red, green, and blue components provided.
---
---Alpha is left unspecified, and whether or not the other components are treated as premultiplied by alpha depends on where the game color instance is used.
---@field r number Red, ranging from 0 to 1
---@field g number Green, ranging from 0 to 1
---@field b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColor
local function to_game_color(r, g, b)
	return {
		r = clamp(r, 0.0, 1.0),
		g = clamp(g, 0.0, 1.0),
		b = clamp(b, 0.0, 1.0),
	}
end

---Creates a table following the Factorio specification for colors using the alpha, red, green, and blue components provided.
---
---The resulting game color instance should only be used in places where the Factorio API is expecting non-premultiplied colors.
---@field a number Alpha, ranging from 0 to 1
---@field r number Red, ranging from 0 to 1
---@field g number Green, ranging from 0 to 1
---@field b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColor
local function to_alpha_game_color(a, r, g, b)
	return {
		r = clamp(r, 0.0, 1.0),
		g = clamp(g, 0.0, 1.0),
		b = clamp(b, 0.0, 1.0),
		a = clamp(a, 0.0, 1.0),
	}
end

---Creates a table following the Factorio specification for colors using the alpha, red, green, and blue components provided.
---
---The resulting game color instance should only be used in places where the Factorio API is expecting premultiplied alpha colors.
---@field a number Alpha, ranging from 0 to 1
---@field r number Red, ranging from 0 to 1
---@field g number Green, ranging from 0 to 1
---@field b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColor
local function to_premultiplied_alpha_game_color(a, r, g, b)
	return {
		r = clamp(r * a, 0.0, 1.0),
		g = clamp(g * a, 0.0, 1.0),
		b = clamp(b * a, 0.0, 1.0),
		a = clamp(a, 0.0, 1.0),
	}
end

return {
	to_game_color = to_game_color,
	to_alpha_game_color = to_alpha_game_color,
	to_premultiplied_alpha_game_color = to_premultiplied_alpha_game_color,
}
