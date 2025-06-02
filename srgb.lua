require("__hndy-color__.color-base")

local GameColor = require("__hndy-color__.game-color")
local to_alpha_game_color = GameColor.to_alpha_game_color
local to_premultiplied_alpha_game_color = GameColor.to_premultiplied_alpha_game_color

local Arithmetic = require("__hndy-color__.util.arithmetic")
local clamp = Arithmetic.clamp
local to_unit = Arithmetic.scale_to_unit_from_integer
local from_unit = Arithmetic.scale_to_integer_from_unit

local Alpha = require("__hndy-color__.util.alpha")
local interpolate_three_components = Alpha.interpolate_three_components

---@class Hndy.Color.Srgb : Hndy.Color.ColorBase
---@field r number
---@field g number
---@field b number
---@field a number
local ColorSrgb = {}
ColorSrgb.__index = ColorSrgb

ColorSrgb.r_min = 0.0
ColorSrgb.r_max = 1.0

ColorSrgb.g_min = 0.0
ColorSrgb.g_max = 1.0

ColorSrgb.b_min = 0.0
ColorSrgb.b_max = 1.0

ColorSrgb.a_min = 0.0
ColorSrgb.a_max = 1.0

---@param r number
---@param g number
---@param b number
---@param a number | nil
---@return Hndy.Color.Srgb
---@overload fun(r: number, g: number, b: number): Hndy.Color.Srgb
function ColorSrgb.new(r, g, b, a)
	return setmetatable({ r = r, g = g, b = b, a = a or 1.0 }, ColorSrgb)
end

---@param r integer
---@param g integer
---@param b integer
---@param a integer | nil
---@return Hndy.Color.Srgb
---@overload fun(r: integer, g: integer, b: integer): Hndy.Color.Srgb
function ColorSrgb.new_from_css(r, g, b, a)
	return ColorSrgb.new(to_unit(r, 255), to_unit(g, 255), to_unit(b, 255), a and to_unit(a, 100) or 1.0)
end

---@return integer, integer, integer, integer
function ColorSrgb:to_css()
	return from_unit(self.r, 255), from_unit(self.g, 255), from_unit(self.b, 255), from_unit(self.a, 100)
end

---@return Hndy.Color.Srgb
function ColorSrgb:clone()
	return ColorSrgb.new(self.r, self.g, self.b, self.a)
end

---@param target Hndy.Color.Srgb
---@return Hndy.Color.Srgb
function ColorSrgb:copy_to(target)
	target.r = self.r
	target.g = self.g
	target.b = self.b
	target.a = self.a
	return target
end

---@return Hndy.Color.GameColor
function ColorSrgb:to_game_color()
	return to_alpha_game_color(self.a, self.r, self.g, self.b)
end

---@return Hndy.Color.GameColor
function ColorSrgb:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, self.r, self.g, self.b)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Srgb
function ColorSrgb.from_game_color(color)
	return ColorSrgb.new(color.r, color.g, color.b, color.a or 1.0)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Srgb
function ColorSrgb.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorSrgb.new(0.0, 0.0, 0.0, a) end
	return ColorSrgb.new(color.r / a, color.g / a, color.b / a, a)
end

---@param components { r: number | nil, g: number | nil, b: number | nil, a: number | nil }
---@return Hndy.Color.Srgb
function ColorSrgb:with(components)
	return ColorSrgb.new(components.r or self.r, components.g or self.g, components.b or self.b, components.a or self.a)
end

---@param red number
---@return Hndy.Color.Srgb
function ColorSrgb:with_red(red)
	return ColorSrgb.new(red, self.g, self.b, self.a)
end

---@param green number
---@return Hndy.Color.Srgb
function ColorSrgb:with_green(green)
	return ColorSrgb.new(self.r, green, self.b, self.a)
end

---@param blue number
---@return Hndy.Color.Srgb
function ColorSrgb:with_blue(blue)
	return ColorSrgb.new(self.r, self.g, blue, self.a)
end

---@param alpha number
---@return Hndy.Color.Srgb
function ColorSrgb:with_alpha(alpha)
	return ColorSrgb.new(self.r, self.g, self.b, alpha)
end

---@return boolean
function ColorSrgb:is_within_gamut()
	return self.r >= 0.0 and self.r <= 1.0 and self.g >= 0.0 and self.g <= 1.0 and self.b >= 0.0 and self.b <= 1.0
end

---@return Hndy.Color.Srgb
function ColorSrgb:clamp_to_gamut()
	return ColorSrgb.new(clamp(self.r, 0.0, 1.0), clamp(self.g, 0.0, 1.0), clamp(self.b, 0.0, 1.0), self.a)
end

---@return Hndy.Color.Srgb
function ColorSrgb:self_clamp_to_gamut()
	self.r = clamp(self.r, 0.0, 1.0)
	self.g = clamp(self.g, 0.0, 1.0)
	self.b = clamp(self.b, 0.0, 1.0)
	return self
end

ColorSrgb.is_within_safe_gamut = ColorSrgb.is_within_gamut
ColorSrgb.clamp_to_safe_gamut = ColorSrgb.clamp_to_gamut
ColorSrgb.self_clamp_to_safe_gamut = ColorSrgb.self_clamp_to_gamut

---@return boolean
function ColorSrgb:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Srgb
function ColorSrgb:normalize_alpha()
	return ColorSrgb.new(self.r, self.g, self.b, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Srgb
function ColorSrgb:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorSrgb:is_normal()
	return self.r >= 0.0 and self.r <= 1.0 and self.g >= 0.0 and self.g <= 1.0 and self.b >= 0.0 and self.b <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Srgb
function ColorSrgb:normalize()
	return ColorSrgb.new(clamp(self.r, 0.0, 1.0), clamp(self.g, 0.0, 1.0), clamp(self.b, 0.0, 1.0), clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Srgb
function ColorSrgb:self_normalize()
	self.r = clamp(self.r, 0.0, 1.0)
	self.g = clamp(self.g, 0.0, 1.0)
	self.b = clamp(self.b, 0.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

ColorSrgb.is_safe_normal = ColorSrgb.is_normal
ColorSrgb.safe_normalize = ColorSrgb.normalize
ColorSrgb.self_safe_normalize = ColorSrgb.self_normalize

---@param target Hndy.Color.Srgb
---@param t number
---@return Hndy.Color.Srgb
function ColorSrgb:interpolate(target, t)
	local r, g, b, a = interpolate_three_components(self.r, target.r, self.g, target.g, self.b, target.b, self.a, target.a, t)
	return ColorSrgb.new(r, g, b, a)
end

---@param target Hndy.Color.Srgb
---@param t number
---@return Hndy.Color.Srgb
function ColorSrgb:self_interpolate(target, t)
	self.r, self.g, self.b, self.a = interpolate_three_components(self.r, target.r, self.g, target.g, self.b, target.b, self.a, target.a, t)
	return self
end

return ColorSrgb
