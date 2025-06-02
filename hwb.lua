require("__hndy-color__.color-base")
require("__hndy-color__.hue-base")

local GameColor = require("__hndy-color__.game-color")
local to_alpha_game_color = GameColor.to_alpha_game_color
local to_premultiplied_alpha_game_color = GameColor.to_premultiplied_alpha_game_color

local Arithmetic = require("__hndy-color__.util.arithmetic")
local clamp = Arithmetic.clamp
local modulo = Arithmetic.modulo
local max = math.max
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
local to_srgb_from_hwb = RawConvert.to_srgb_from_hwb
local to_hwb_from_srgb = RawConvert.to_hwb_from_srgb

---@class Hndy.Color.Hwb : Hndy.Color.ColorBase, Hndy.Color.HueBase
---@field h number
---@field w number
---@field b number
---@field a number
local ColorHwb = {}
ColorHwb.__index = ColorHwb

ColorHwb.h_safe_min = 0.0
ColorHwb.h_safe_max = 1.0
ColorHwb.h_min = -math.huge
ColorHwb.h_max = math.huge

ColorHwb.w_min = 0.0
ColorHwb.w_max = 1.0

ColorHwb.b_min = 0.0
ColorHwb.b_max = 1.0

ColorHwb.a_min = 0.0
ColorHwb.a_max = 1.0

---@param h number
---@param w number
---@param b number
---@param a number | nil
---@return Hndy.Color.Hwb
---@overload fun(h: number, w: number, b: number): Hndy.Color.Hwb
function ColorHwb.new(h, w, b, a)
	return setmetatable({ h = h, w = w, b = b, a = a or 1.0 }, ColorHwb)
end

---@param h integer
---@param w integer
---@param b integer
---@param a integer | nil
---@return Hndy.Color.Hwb
---@overload fun(h: integer, w: integer, b: integer): Hndy.Color.Hwb
function ColorHwb.new_from_css(h, w, b, a)
	return ColorHwb.new(to_unit_hue(h), to_unit(w, 100), to_unit(b, 100), a and to_unit(a, 100) or 1.0)
end

---@return integer, integer, integer, integer
function ColorHwb:to_css()
	return from_unit_hue(self.h), from_unit(self.w, 100), from_unit(self.b, 100), from_unit(self.a, 100)
end

---@return Hndy.Color.Hwb
function ColorHwb:clone()
	return ColorHwb.new(self.h, self.w, self.b, self.a)
end

---@param target Hndy.Color.Hwb
---@return Hndy.Color.Hwb
function ColorHwb:copy_to(target)
	target.h = self.h
	target.w = self.w
	target.b = self.b
	target.a = self.a
	return target
end

---@return Hndy.Color.GameColor
function ColorHwb:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_hwb(self.h, self.w, self.b))
end

---@return Hndy.Color.GameColor
function ColorHwb:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_hwb(self.h, self.w, self.b))
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hwb
function ColorHwb.from_game_color(color)
	local h, w, b = to_hwb_from_srgb(color.r, color.g, color.b)
	return ColorHwb.new(h, w, b, color.a or 1.0)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hwb
function ColorHwb.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorHwb.new(0.0, 0.0, 0.0, a) end
	local h, w, b = to_hwb_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorHwb.new(h, w, b, a)
end

---@param components { h: number | nil, w: number | nil, b: number | nil, a: number | nil }
---@return Hndy.Color.Hwb
function ColorHwb:with(components)
	return ColorHwb.new(components.h or self.h, components.w or self.w, components.b or self.b, components.a or self.a)
end

---@param hue number
---@return Hndy.Color.Hwb
function ColorHwb:with_hue(hue)
	return ColorHwb.new(hue, self.w, self.b, self.a)
end

---@param whiteness number
---@return Hndy.Color.Hwb
function ColorHwb:with_whiteness(whiteness)
	return ColorHwb.new(self.h, whiteness, self.b, self.a)
end

---@param blackness number
---@return Hndy.Color.Hwb
function ColorHwb:with_blackness(blackness)
	return ColorHwb.new(self.h, self.w, blackness, self.a)
end

---@param alpha number
---@return Hndy.Color.Hwb
function ColorHwb:with_alpha(alpha)
	return ColorHwb.new(self.h, self.w, self.b, alpha)
end

---@return boolean
function ColorHwb:is_within_gamut()
	return self.w >= 0.0 and self.b >= 0.0 and self.w + self.b <= 1.0
end

---@return Hndy.Color.Hwb
function ColorHwb:clamp_to_gamut()
	local w = max(self.w, 0.0)
	local b = max(self.b, 0.0)
	local sum = w + b
	if sum > 1.0 then
		w = w / sum
		b = b / sum
	end
	return ColorHwb.new(self.h, w, b, self.a)
end

---@return Hndy.Color.Hwb
function ColorHwb:self_clamp_to_gamut()
	self.w = max(self.w, 0.0)
	self.b = max(self.b, 0.0)
	local sum = self.w + self.b
	if sum > 1.0 then
		self.w = self.w / sum
		self.b = self.b / sum
	end
	return self
end

ColorHwb.is_within_safe_gamut = ColorHwb.is_within_gamut
ColorHwb.clamp_to_safe_gamut = ColorHwb.clamp_to_gamut
ColorHwb.self_clamp_to_safe_gamut = ColorHwb.self_clamp_to_gamut

---@return boolean
function ColorHwb:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Hwb
function ColorHwb:normalize_alpha()
	return ColorHwb.new(self.h, self.w, self.b, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Hwb
function ColorHwb:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorHwb:is_normal_hue()
	return self.h >= 0.0 and self.h <= 1.0
end

---@return Hndy.Color.Hwb
function ColorHwb:normalize_hue()
	return ColorHwb.new(modulo(self.h, 1.0), self.w, self.b, self.a)
end

---@return Hndy.Color.Hwb
function ColorHwb:self_normalize_hue()
	self.h = modulo(self.h, 1.0)
	return self
end

---@return boolean
function ColorHwb:is_normal()
	return self.h >= 0.0 and self.h <= 1.0 and self.w >= 0.0 and self.b >= 0.0 and self.w + self.b <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Hwb
function ColorHwb:normalize()
	local w = max(self.w, 0.0)
	local b = max(self.b, 0.0)
	local sum = w + b
	if sum > 1.0 then
		w = w / sum
		b = b / sum
	end
	return ColorHwb.new(modulo(self.h, 1.0), w, b, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Hwb
function ColorHwb:self_normalize()
	self.h = modulo(self.h, 1.0)
	self.w = max(self.w, 0.0)
	self.b = max(self.b, 0.0)
	local sum = self.w + self.b
	if sum > 1.0 then
		self.w = self.w / sum
		self.b = self.b / sum
	end
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

ColorHwb.is_safe_normal = ColorHwb.is_normal
ColorHwb.safe_normalize = ColorHwb.normalize
ColorHwb.self_safe_normalize = ColorHwb.self_normalize

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_linear_hue(target, t)
	local h = interpolate_hue_linear(self.h, target.h, t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_linear_hue(target, t)
	self.h = interpolate_hue_linear(self.h, target.h, t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_shorter_hue(target, t)
	local h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_shorter_hue(target, t)
	self.h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_longer_hue(target, t)
	local h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_longer_hue(target, t)
	self.h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_increasing_hue(target, t)
	local h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_increasing_hue(target, t)
	self.h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_decreasing_hue(target, t)
	local h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_decreasing_hue(target, t)
	self.h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

ColorHwb.interpolate = ColorHwb.interpolate_shorter_hue
ColorHwb.self_interpolate = ColorHwb.self_interpolate_shorter_hue

return ColorHwb
