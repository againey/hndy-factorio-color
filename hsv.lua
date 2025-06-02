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
local to_srgb_from_hsv = RawConvert.to_srgb_from_hsv
local to_hsv_from_srgb = RawConvert.to_hsv_from_srgb

---@class Hndy.Color.Hsv : Hndy.Color.ColorBase, Hndy.Color.HueBase
---@field h number
---@field s number
---@field v number
---@field a number
local ColorHsv = {}
ColorHsv.__index = ColorHsv

ColorHsv.h_safe_min = 0.0
ColorHsv.h_safe_max = 1.0
ColorHsv.h_min = -math.huge
ColorHsv.h_max = math.huge

ColorHsv.s_min = 0.0
ColorHsv.s_max = 1.0

ColorHsv.v_min = 0.0
ColorHsv.v_max = 1.0

ColorHsv.a_min = 0.0
ColorHsv.a_max = 1.0

---@param h number
---@param s number
---@param v number
---@param a number | nil
---@return Hndy.Color.Hsv
---@overload fun(h: number, s: number, v: number): Hndy.Color.Hsv
function ColorHsv.new(h, s, v, a)
	return setmetatable({ h = h, s = s, v = v, a = a or 1.0 }, ColorHsv)
end

---@param h integer
---@param s integer
---@param v integer
---@param a integer | nil
---@return Hndy.Color.Hsv
---@overload fun(h: integer, s: integer, v: integer): Hndy.Color.Hsv
function ColorHsv.new_from_css(h, s, v, a)
	return ColorHsv.new(to_unit_hue(h), to_unit(s, 100), to_unit(v, 100), a and to_unit(a, 100) or 1.0)
end

---@return integer, integer, integer, integer
function ColorHsv:to_css()
	return from_unit_hue(self.h), from_unit(self.s, 100), from_unit(self.v, 100), from_unit(self.a, 100)
end

---@return Hndy.Color.Hsv
function ColorHsv:clone()
	return ColorHsv.new(self.h, self.s, self.v, self.a)
end

---@param target Hndy.Color.Hsv
---@return Hndy.Color.Hsv
function ColorHsv:copy_to(target)
	target.h = self.h
	target.s = self.s
	target.v = self.v
	target.a = self.a
	return target
end

---@return Hndy.Color.GameColor
function ColorHsv:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_hsv(self.h, self.s, self.v))
end

---@return Hndy.Color.GameColor
function ColorHsv:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_hsv(self.h, self.s, self.v))
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hsv
function ColorHsv.from_game_color(color)
	local h, s, v = to_hsv_from_srgb(color.r, color.g, color.b)
	return ColorHsv.new(h, s, v, color.a or 1.0)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hsv
function ColorHsv.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorHsv.new(0.0, 0.0, 0.0, a) end
	local h, s, v = to_hsv_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorHsv.new(h, s, v, a)
end

---@param components { h: number | nil, s: number | nil, v: number | nil, a: number | nil }
---@return Hndy.Color.Hsv
function ColorHsv:with(components)
	return ColorHsv.new(components.h or self.h, components.s or self.s, components.v or self.v, components.a or self.a)
end

---@param hue number
---@return Hndy.Color.Hsv
function ColorHsv:with_hue(hue)
	return ColorHsv.new(hue, self.s, self.v, self.a)
end

---@param saturation number
---@return Hndy.Color.Hsv
function ColorHsv:with_saturation(saturation)
	return ColorHsv.new(self.h, saturation, self.v, self.a)
end

---@param value number
---@return Hndy.Color.Hsv
function ColorHsv:with_value(value)
	return ColorHsv.new(self.h, self.s, value, self.a)
end

---@param alpha number
---@return Hndy.Color.Hsv
function ColorHsv:with_alpha(alpha)
	return ColorHsv.new(self.h, self.s, self.v, alpha)
end

---@return boolean
function ColorHsv:is_within_gamut()
	return self.s >= 0.0 and self.s <= 1.0 and self.v >= 0.0 and self.v <= 1.0
end

---@return Hndy.Color.Hsv
function ColorHsv:clamp_to_gamut()
	return ColorHsv.new(self.h, clamp(self.s, 0.0, 1.0), clamp(self.v, 0.0, 1.0), self.a)
end

---@return Hndy.Color.Hsv
function ColorHsv:self_clamp_to_gamut()
	self.s = clamp(self.s, 0.0, 1.0)
	self.v = clamp(self.v, 0.0, 1.0)
	return self
end

ColorHsv.is_within_safe_gamut = ColorHsv.is_within_gamut
ColorHsv.clamp_to_safe_gamut = ColorHsv.clamp_to_gamut
ColorHsv.self_clamp_to_safe_gamut = ColorHsv.self_clamp_to_gamut

---@return boolean
function ColorHsv:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Hsv
function ColorHsv:normalize_alpha()
	return ColorHsv.new(self.h, self.s, self.v, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Hsv
function ColorHsv:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorHsv:is_normal_hue()
	return self.h >= 0.0 and self.h <= 1.0
end

---@return Hndy.Color.Hsv
function ColorHsv:normalize_hue()
	return ColorHsv.new(modulo(self.h, 1.0), self.s, self.v, self.a)
end

---@return Hndy.Color.Hsv
function ColorHsv:self_normalize_hue()
	self.h = modulo(self.h, 1.0)
	return self
end

---@return boolean
function ColorHsv:is_normal()
	return self.h >= 0.0 and self.h <= 1.0 and self.s >= 0.0 and self.s <= 1.0 and self.v >= 0.0 and self.v <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Hsv
function ColorHsv:normalize()
	return ColorHsv.new(modulo(self.h, 1.0), clamp(self.s, 0.0, 1.0), clamp(self.v, 0.0, 1.0), clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Hsv
function ColorHsv:self_normalize()
	self.h = modulo(self.h, 1.0)
	self.s = clamp(self.s, 0.0, 1.0)
	self.v = clamp(self.v, 0.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

ColorHsv.is_safe_normal = ColorHsv.is_normal
ColorHsv.safe_normalize = ColorHsv.normalize
ColorHsv.self_safe_normalize = ColorHsv.self_normalize

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:interpolate_linear_hue(target, t)
	local h = interpolate_hue_linear(self.h, target.h, t)
	local s, v, a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return ColorHsv.new(h, s, v, a)
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:self_interpolate_linear_hue(target, t)
	self.h = interpolate_hue_linear(self.h, target.h, t)
	self.s, self.v, self.a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:interpolate_shorter_hue(target, t)
	local h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local s, v, a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return ColorHsv.new(h, s, v, a)
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:self_interpolate_shorter_hue(target, t)
	self.h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.s, self.v, self.a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:interpolate_longer_hue(target, t)
	local h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local s, v, a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return ColorHsv.new(h, s, v, a)
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:self_interpolate_longer_hue(target, t)
	self.h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.s, self.v, self.a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:interpolate_increasing_hue(target, t)
	local h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local s, v, a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return ColorHsv.new(h, s, v, a)
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:self_interpolate_increasing_hue(target, t)
	self.h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.s, self.v, self.a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:interpolate_decreasing_hue(target, t)
	local h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local s, v, a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return ColorHsv.new(h, s, v, a)
end

---@param target Hndy.Color.Hsv
---@param t number
---@return Hndy.Color.Hsv
function ColorHsv:self_interpolate_decreasing_hue(target, t)
	self.h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.s, self.v, self.a = interpolate_two_components(self.s, target.s, self.v, target.v, self.a, target.a, t)
	return self
end

ColorHsv.interpolate = ColorHsv.interpolate_shorter_hue
ColorHsv.self_interpolate = ColorHsv.self_interpolate_shorter_hue

return ColorHsv
