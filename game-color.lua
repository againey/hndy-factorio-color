local Arithmetic = require("__hndy-color__.util.arithmetic")
local clamp = Arithmetic.clamp

---@alias Hndy.Color.GameColor Color
---@alias Hndy.Color.GameColorTableRgb { r: number, g: number, b: number }
---@alias Hndy.Color.GameColorTableRgba { r: number, g: number, b: number, a: number }
---@alias Hndy.Color.GameColorArrayRgb [number, number, number]
---@alias Hndy.Color.GameColorArrayRgba [number, number, number, number]
---@alias Hndy.Color.GameColorTable Hndy.Color.GameColorTableRgb | Hndy.Color.GameColorTableRgba
---@alias Hndy.Color.GameColorArray Hndy.Color.GameColorArrayRgb | Hndy.Color.GameColorArrayRgba

---Creates a table following the Factorio specification for colors using the red, green, and blue components provided.
---
---Alpha is left unspecified, and whether or not the other components are treated as premultiplied by alpha depends on where the game color instance is used.
---@param r number Red, ranging from 0 to 1
---@param g number Green, ranging from 0 to 1
---@param b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColorTableRgb
local function to_game_color(r, g, b)
	return {
		r = clamp(r, 0.0, 1.0),
		g = clamp(g, 0.0, 1.0),
		b = clamp(b, 0.0, 1.0),
	}
end

---Creates a table following the Factorio specification for colors as arrays using the red, green, and blue components provided.
---
---Alpha is left unspecified, and whether or not the other components are treated as premultiplied by alpha depends on where the game color instance is used.
---@param r number Red, ranging from 0 to 1
---@param g number Green, ranging from 0 to 1
---@param b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColorArrayRgb
local function to_game_color_array(r, g, b)
	return {
		clamp(r, 0.0, 1.0),
		clamp(g, 0.0, 1.0),
		clamp(b, 0.0, 1.0),
	}
end

---Creates a table following the Factorio specification for colors using the alpha, red, green, and blue components provided.
---
---The resulting game color instance should only be used in places where the Factorio API is expecting non-premultiplied colors.
---@param a number Alpha, ranging from 0 to 1
---@param r number Red, ranging from 0 to 1
---@param g number Green, ranging from 0 to 1
---@param b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColorTableRgba
local function to_alpha_game_color(a, r, g, b)
	return {
		r = clamp(r, 0.0, 1.0),
		g = clamp(g, 0.0, 1.0),
		b = clamp(b, 0.0, 1.0),
		a = clamp(a, 0.0, 1.0),
	}
end

---Creates a table following the Factorio specification for color arrays using the alpha, red, green, and blue components provided.
---
---The resulting game color instance should only be used in places where the Factorio API is expecting non-premultiplied colors.
---@param a number Alpha, ranging from 0 to 1
---@param r number Red, ranging from 0 to 1
---@param g number Green, ranging from 0 to 1
---@param b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColorArrayRgba
local function to_alpha_game_color_array(a, r, g, b)
	return {
		clamp(r, 0.0, 1.0),
		clamp(g, 0.0, 1.0),
		clamp(b, 0.0, 1.0),
		clamp(a, 0.0, 1.0),
	}
end

---Creates a table following the Factorio specification for colors using the alpha, red, green, and blue components provided.
---
---The resulting game color instance should only be used in places where the Factorio API is expecting premultiplied alpha colors.
---@param a number Alpha, ranging from 0 to 1
---@param r number Red, ranging from 0 to 1
---@param g number Green, ranging from 0 to 1
---@param b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColorTableRgba
local function to_premultiplied_alpha_game_color(a, r, g, b)
	return {
		r = clamp(r * a, 0.0, 1.0),
		g = clamp(g * a, 0.0, 1.0),
		b = clamp(b * a, 0.0, 1.0),
		a = clamp(a, 0.0, 1.0),
	}
end

---Creates a table following the Factorio specification for color arrays using the alpha, red, green, and blue components provided.
---
---The resulting game color instance should only be used in places where the Factorio API is expecting premultiplied alpha colors.
---@param a number Alpha, ranging from 0 to 1
---@param r number Red, ranging from 0 to 1
---@param g number Green, ranging from 0 to 1
---@param b number Blue, ranging from 0 to 1
---@return Hndy.Color.GameColorArrayRgba
local function to_premultiplied_alpha_game_color_array(a, r, g, b)
	return {
		clamp(r * a, 0.0, 1.0),
		clamp(g * a, 0.0, 1.0),
		clamp(b * a, 0.0, 1.0),
		clamp(a, 0.0, 1.0),
	}
end

---Extracts the three or four components from a game color whether it is in array or labeled table format.
---
---@overload fun(color: Hndy.Color.GameColorTableRgb): number, number, number, number
---@overload fun(color: Hndy.Color.GameColorTableRgba): number, number, number, number
---@overload fun(color: Hndy.Color.GameColorArrayRgb): number, number, number, number
---@overload fun(color: Hndy.Color.GameColorArrayRgba): number, number, number, number
local function to_unit_srgb_components_from_game_color(color)
	local r, g, b, a
	if #color >= 3 then
		r = color[1]
		g = color[2]
		b = color[3]
		if #color >= 4 then
			a = color[4]
		else
			a = 1.0
		end
	else
		r = color.r
		g = color.g
		b = color.b
		if color.a ~= nil then
			a = color.a
		else
			a = 1.0
		end
	end

	if r > 1.0 or g > 1.0 or b > 1.0 or a > 1.0 then
		return r / 255.0, g / 255.0, b / 255.0, a / 255.0
	else
		return r, g, b, a
	end
end

---Extracts the three or four components from a game color whether it is in array or labeled table format.
---
---@param color Hndy.Color.GameColor
---@return number, number, number, number
---@overload fun(color: Hndy.Color.GameColorTableRgba): number, number, number
---@overload fun(color: Hndy.Color.GameColorTableRgba): number, number, number, number
---@overload fun(color: Hndy.Color.GameColorArrayRgb): number, number, number
---@overload fun(color: Hndy.Color.GameColorArrayRgba): number, number, number, number
local function to_unit_srgb_components_from_premultiplied_game_color(color)
	local r, g, b, a
	if #color >= 3 then
		r = color[1]
		g = color[2]
		b = color[3]
		if #color >= 4 then
			a = color[4]
		else
			a = 1.0
		end
	else
		r = color.r
		g = color.g
		b = color.b
		if color.a ~= nil then
			a = color.a
		else
			a = 1.0
		end
	end

	if r > 1.0 or g > 1.0 or b > 1.0 or a > 1.0 then
		if a > 0 then
			a = a / 255.0
			return r / a, g / a, b / a, a
		else
			return r / 255.0, g / 255.0, b / 255.0, 0.0
		end
	else
		if a > 0 then
			return r / a, g / a, b / a, a
		else
			return r, g, b, 0.0
		end
	end
end

return {
	to_game_color = to_game_color,
	to_alpha_game_color = to_alpha_game_color,
	to_premultiplied_alpha_game_color = to_premultiplied_alpha_game_color,
	to_game_color_array = to_game_color_array,
	to_alpha_game_color_array = to_alpha_game_color_array,
	to_premultiplied_alpha_game_color_array = to_premultiplied_alpha_game_color_array,
	to_unit_srgb_components_from_game_color = to_unit_srgb_components_from_game_color,
	to_unit_srgb_components_from_premultiplied_game_color = to_unit_srgb_components_from_premultiplied_game_color,
}
