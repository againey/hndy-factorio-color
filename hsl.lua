require("__hndy-color__.color-base")
require("__hndy-color__.hue-base")

local GameColor = require("__hndy-color__.game-color")
local to_alpha_game_color = GameColor.to_alpha_game_color
local to_premultiplied_alpha_game_color = GameColor.to_premultiplied_alpha_game_color

local Arithmetic = require("__hndy-color__.util.arithmetic")
local clamp = Arithmetic.clamp
local modulo = Arithmetic.modulo
local to_unit = Arithmetic.scale_to_unit_from_integer
local from_unit = Arithmetic.scale_to_integer_from_unit

local Alpha = require("__hndy-color__.util.alpha")
local interpolate_two_components = Alpha.interpolate_two_components

local Hue = require("__hndy-color__.util.hue")
local interpolate_hue_linear = Hue.interpolate_linear
local interpolate_hue_shorter = Hue.interpolate_shorter
local interpolate_hue_longer = Hue.interpolate_longer
local interpolate_hue_increasing = Hue.interpolate_increasing
local interpolate_hue_decreasing = Hue.interpolate_decreasing
local to_unit_hue = Hue.from_integer_degrees
local from_unit_hue = Hue.to_integer_degrees

local RawConvert = require("__hndy-color__.util.raw-convert")
local to_srgb_from_hsl = RawConvert.to_srgb_from_hsl
local to_hsl_from_srgb = RawConvert.to_hsl_from_srgb

---@class Hndy.Color.Hsl : Hndy.Color.ColorBase, Hndy.Color.HueBase
---@field h number
---@field s number
---@field l number
---@field a number
local ColorHsl = {}
ColorHsl.__index = ColorHsl

ColorHsl.h_safe_min = 0.0
ColorHsl.h_safe_max = 1.0
ColorHsl.h_min = -math.huge
ColorHsl.h_max = math.huge

ColorHsl.s_min = 0.0
ColorHsl.s_max = 1.0

ColorHsl.l_min = 0.0
ColorHsl.l_max = 1.0

ColorHsl.a_min = 0.0
ColorHsl.a_max = 1.0

---@param h number
---@param s number
---@param l number
---@param a number | nil
---@return Hndy.Color.Hsl
---@overload fun(h: number, s: number, l: number): Hndy.Color.Hsl
function ColorHsl.new(h, s, l, a)
	return setmetatable({ h = h, s = s, l = l, a = a or 1.0 }, ColorHsl)
end

---@param h integer
---@param s integer
---@param l integer
---@param a integer | nil
---@return Hndy.Color.Hsl
---@overload fun(h: integer, s: integer, l: integer): Hndy.Color.Hsl
function ColorHsl.new_from_css(h, s, l, a)
	return ColorHsl.new(to_unit_hue(h), to_unit(s, 100), to_unit(l, 100), a and to_unit(a, 100) or 1.0)
end

---@return integer, integer, integer, integer
function ColorHsl:to_css()
	return from_unit_hue(self.h), from_unit(self.s, 100), from_unit(self.l, 100), from_unit(self.a, 100)
end

---@return Hndy.Color.Hsl
function ColorHsl:clone()
	return ColorHsl.new(self.h, self.s, self.l, self.a)
end

---@param target Hndy.Color.Hsl
---@return Hndy.Color.Hsl
function ColorHsl:copy_to(target)
	target.h = self.h
	target.s = self.s
	target.l = self.l
	target.a = self.a
	return target
end

---@return Hndy.Color.GameColor
function ColorHsl:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_hsl(self.h, self.s, self.l))
end

---@return Hndy.Color.GameColor
function ColorHsl:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_hsl(self.h, self.s, self.l))
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hsl
function ColorHsl.from_game_color(color)
	local h, s, l = to_hsl_from_srgb(color.r, color.g, color.b)
	return ColorHsl.new(h, s, l, color.a or 1.0)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hsl
function ColorHsl.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorHsl.new(0.0, 0.0, 0.0, a) end
	local h, s, l = to_hsl_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorHsl.new(h, s, l, a)
end

---@param components { h: number | nil, s: number | nil, l: number | nil, a: number | nil }
---@return Hndy.Color.Hsl
function ColorHsl:with(components)
	return ColorHsl.new(components.h or self.h, components.s or self.s, components.l or self.l, components.a or self.a)
end

---@param hue number
---@return Hndy.Color.Hsl
function ColorHsl:with_hue(hue)
	return ColorHsl.new(hue, self.s, self.l, self.a)
end

---@param saturation number
---@return Hndy.Color.Hsl
function ColorHsl:with_saturation(saturation)
	return ColorHsl.new(self.h, saturation, self.l, self.a)
end

---@param lightness number
---@return Hndy.Color.Hsl
function ColorHsl:with_lightness(lightness)
	return ColorHsl.new(self.h, self.s, lightness, self.a)
end

---@param alpha number
---@return Hndy.Color.Hsl
function ColorHsl:with_alpha(alpha)
	return ColorHsl.new(self.h, self.s, self.l, alpha)
end

---@return boolean
function ColorHsl:is_within_gamut()
	return self.s >= 0.0 and self.s <= 1.0 and self.l >= 0.0 and self.l <= 1.0
end

---@return Hndy.Color.Hsl
function ColorHsl:clamp_to_gamut()
	return ColorHsl.new(self.h, clamp(self.s, 0.0, 1.0), clamp(self.l, 0.0, 1.0), self.a)
end

---@return Hndy.Color.Hsl
function ColorHsl:self_clamp_to_gamut()
	self.s = clamp(self.s, 0.0, 1.0)
	self.l = clamp(self.l, 0.0, 1.0)
	return self
end

ColorHsl.is_within_safe_gamut = ColorHsl.is_within_gamut
ColorHsl.clamp_to_safe_gamut = ColorHsl.clamp_to_gamut
ColorHsl.self_clamp_to_safe_gamut = ColorHsl.self_clamp_to_gamut

---@return boolean
function ColorHsl:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Hsl
function ColorHsl:normalize_alpha()
	return ColorHsl.new(self.h, self.s, self.l, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Hsl
function ColorHsl:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorHsl:is_normal_hue()
	return self.h >= 0.0 and self.h <= 1.0
end

---@return Hndy.Color.Hsl
function ColorHsl:normalize_hue()
	return ColorHsl.new(modulo(self.h, 1.0), self.s, self.l, self.a)
end

---@return Hndy.Color.Hsl
function ColorHsl:self_normalize_hue()
	self.h = modulo(self.h, 1.0)
	return self
end

---@return boolean
function ColorHsl:is_normal()
	return self.h >= 0.0 and self.h <= 1.0 and self.s >= 0.0 and self.s <= 1.0 and self.l >= 0.0 and self.l <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Hsl
function ColorHsl:normalize()
	return ColorHsl.new(modulo(self.h, 1.0), clamp(self.s, 0.0, 1.0), clamp(self.l, 0.0, 1.0), clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Hsl
function ColorHsl:self_normalize()
	self.h = modulo(self.h, 1.0)
	self.s = clamp(self.s, 0.0, 1.0)
	self.l = clamp(self.l, 0.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

ColorHsl.is_safe_normal = ColorHsl.is_normal
ColorHsl.safe_normalize = ColorHsl.normalize
ColorHsl.self_safe_normalize = ColorHsl.self_normalize

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_linear_hue(target, t)
	local h = interpolate_hue_linear(self.h, target.h, self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_linear_hue(target, t)
	self.h = interpolate_hue_linear(self.h, target.h, self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_shorter_hue(target, t)
	local h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_shorter_hue(target, t)
	self.h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_longer_hue(target, t)
	local h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_longer_hue(target, t)
	self.h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_increasing_hue(target, t)
	local h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_increasing_hue(target, t)
	self.h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_decreasing_hue(target, t)
	local h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_decreasing_hue(target, t)
	self.h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

ColorHsl.interpolate = ColorHsl.interpolate_shorter_hue
ColorHsl.self_interpolate = ColorHsl.self_interpolate_shorter_hue

return ColorHsl
