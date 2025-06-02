local Arithmetic = require("__hndy-color__.util.arithmetic")
local clamp = Arithmetic.clamp

---@alias Hndy.Color.GameColor Color

---@param r number
---@param g number
---@param b number
---@return Hndy.Color.GameColor
local function to_game_color(r, g, b)
	return {
		r = clamp(r, 0.0, 1.0),
		g = clamp(g, 0.0, 1.0),
		b = clamp(b, 0.0, 1.0),
	}
end

---@param r number
---@param g number
---@param b number
---@return Hndy.Color.GameColor
local function to_alpha_game_color(a, r, g, b)
	return {
		r = clamp(r, 0.0, 1.0),
		g = clamp(g, 0.0, 1.0),
		b = clamp(b, 0.0, 1.0),
		a = clamp(a, 0.0, 1.0),
	}
end

---@param r number
---@param g number
---@param b number
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
