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

local RawConvert = require("__hndy-color__.util.raw-convert")
local to_srgb_from_rgb = RawConvert.to_srgb_from_rgb
local to_rgb_from_srgb = RawConvert.to_rgb_from_srgb

---@class Hndy.Color.Rgb : Hndy.Color.ColorBase
---@field r number
---@field g number
---@field b number
---@field a number
local ColorRgb = {}
ColorRgb.__index = ColorRgb

ColorRgb.r_min = 0.0
ColorRgb.r_max = 1.0

ColorRgb.g_min = 0.0
ColorRgb.g_max = 1.0

ColorRgb.b_min = 0.0
ColorRgb.b_max = 1.0

ColorRgb.a_min = 0.0
ColorRgb.a_max = 1.0

---@param r number
---@param g number
---@param b number
---@param a number | nil
---@return Hndy.Color.Rgb
---@overload fun(r: number, g: number, b: number): Hndy.Color.Rgb
function ColorRgb.new(r, g, b, a)
	return setmetatable({ r = r, g = g, b = b, a = a or 1.0 }, ColorRgb)
end

---@param r integer
---@param g integer
---@param b integer
---@param a integer | nil
---@return Hndy.Color.Rgb
---@overload fun(r: integer, g: integer, b: integer): Hndy.Color.Rgb
function ColorRgb.new_from_css(r, g, b, a)
	return ColorRgb.new(to_unit(r, 255), to_unit(g, 255), to_unit(b, 255), a and to_unit(a, 100) or 1.0)
end

---@return integer, integer, integer, integer
function ColorRgb:to_css()
	return from_unit(self.r, 255), from_unit(self.g, 255), from_unit(self.b, 255), from_unit(self.a, 100)
end

---@return Hndy.Color.Rgb
function ColorRgb:clone()
	return ColorRgb.new(self.r, self.g, self.b, self.a)
end

---@param target Hndy.Color.Rgb
---@return Hndy.Color.Rgb
function ColorRgb:copy_to(target)
	target.r = self.r
	target.g = self.g
	target.b = self.b
	target.a = self.a
	return target
end

---@return Hndy.Color.GameColor
function ColorRgb:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_rgb(self.r, self.g, self.b))
end

---@return Hndy.Color.GameColor
function ColorRgb:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_rgb(self.r, self.g, self.b))
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Rgb
function ColorRgb.from_game_color(color)
	local r, g, b = to_rgb_from_srgb(color.r, color.g, color.b)
	return ColorRgb.new(r, g, b, color.a or 1.0)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Rgb
function ColorRgb.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorRgb.new(0.0, 0.0, 0.0, a) end
	local r, g, b = to_rgb_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorRgb.new(r, g, b, a)
end

---@param components { r: number | nil, g: number | nil, b: number | nil, a: number | nil }
---@return Hndy.Color.Rgb
function ColorRgb:with(components)
	return ColorRgb.new(components.r or self.r, components.g or self.g, components.b or self.b, components.a or self.a)
end

---@param red number
---@return Hndy.Color.Rgb
function ColorRgb:with_red(red)
	return ColorRgb.new(red, self.g, self.b, self.a)
end

---@param green number
---@return Hndy.Color.Rgb
function ColorRgb:with_green(green)
	return ColorRgb.new(self.r, green, self.b, self.a)
end

---@param blue number
---@return Hndy.Color.Rgb
function ColorRgb:with_blue(blue)
	return ColorRgb.new(self.r, self.g, blue, self.a)
end

---@param alpha number
---@return Hndy.Color.Rgb
function ColorRgb:with_alpha(alpha)
	return ColorRgb.new(self.r, self.g, self.b, alpha)
end

---@return boolean
function ColorRgb:is_within_gamut()
	return self.r >= 0.0 and self.r <= 1.0 and self.g >= 0.0 and self.g <= 1.0 and self.b >= 0.0 and self.b <= 1.0
end

---@return Hndy.Color.Rgb
function ColorRgb:clamp_to_gamut()
	return ColorRgb.new(clamp(self.r, 0.0, 1.0), clamp(self.g, 0.0, 1.0), clamp(self.b, 0.0, 1.0), self.a)
end

---@return Hndy.Color.Rgb
function ColorRgb:self_clamp_to_gamut()
	self.r = clamp(self.r, 0.0, 1.0)
	self.g = clamp(self.g, 0.0, 1.0)
	self.b = clamp(self.b, 0.0, 1.0)
	return self
end

ColorRgb.is_within_safe_gamut = ColorRgb.is_within_gamut
ColorRgb.clamp_to_safe_gamut = ColorRgb.clamp_to_gamut
ColorRgb.self_clamp_to_safe_gamut = ColorRgb.self_clamp_to_gamut

---@return boolean
function ColorRgb:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Rgb
function ColorRgb:normalize_alpha()
	return ColorRgb.new(self.r, self.g, self.b, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Rgb
function ColorRgb:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorRgb:is_normal()
	return self.r >= 0.0 and self.r <= 1.0 and self.g >= 0.0 and self.g <= 1.0 and self.b >= 0.0 and self.b <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Rgb
function ColorRgb:normalize()
	return ColorRgb.new(clamp(self.r, 0.0, 1.0), clamp(self.g, 0.0, 1.0), clamp(self.b, 0.0, 1.0), clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Rgb
function ColorRgb:self_normalize()
	self.r = clamp(self.r, 0.0, 1.0)
	self.g = clamp(self.g, 0.0, 1.0)
	self.b = clamp(self.b, 0.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

ColorRgb.is_safe_normal = ColorRgb.is_normal
ColorRgb.safe_normalize = ColorRgb.normalize
ColorRgb.self_safe_normalize = ColorRgb.self_normalize

---@param target Hndy.Color.Rgb
---@param t number
---@return Hndy.Color.Rgb
function ColorRgb:interpolate(target, t)
	local r, g, b, a = interpolate_three_components(self.r, target.r, self.g, target.g, self.b, target.b, self.a, target.a, t)
	return ColorRgb.new(r, g, b, a)
end

---@param target Hndy.Color.Rgb
---@param t number
---@return Hndy.Color.Rgb
function ColorRgb:self_interpolate(target, t)
	self.r, self.g, self.b, self.a = interpolate_three_components(self.r, target.r, self.g, target.g, self.b, target.b, self.a, target.a, t)
	return self
end

return ColorRgb
