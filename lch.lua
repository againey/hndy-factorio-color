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
local to_srgb_from_lch = RawConvert.to_srgb_from_lch
local to_lch_from_srgb = RawConvert.to_lch_from_srgb

---@class Hndy.Color.Lch : Hndy.Color.ColorBase, Hndy.Color.HueBase
---@field l number
---@field c number
---@field h number
---@field a number
local ColorLch = {}
ColorLch.__index = ColorLch

ColorLch.l_min = 0.0
ColorLch.l_max = 1.0

ColorLch.c_safe_min = 0.0
ColorLch.c_safe_max = 1.0
ColorLch.c_min = 0.0
ColorLch.c_max = math.huge

ColorLch.h_safe_min = 0.0
ColorLch.h_safe_max = 1.0
ColorLch.h_min = -math.huge
ColorLch.h_max = math.huge

ColorLch.a_min = 0.0
ColorLch.a_max = 1.0

---@param l number
---@param c number
---@param h number
---@param a number | nil
---@return Hndy.Color.Lch
---@overload fun(l: number, c: number, h: number): Hndy.Color.Lch
function ColorLch.new(l, c, h, a)
	return setmetatable({ l = l, c = c, h = h, a = a or 1.0 }, ColorLch)
end

---@param l integer
---@param c integer
---@param h integer
---@param a integer | nil
---@return Hndy.Color.Lch
---@overload fun(l: integer, c: integer, h: integer): Hndy.Color.Lch
function ColorLch.new_from_css(l, c, h, a)
	return ColorLch.new(to_unit(l, 100), to_unit(c, 150), to_unit_hue(h), a and to_unit(a, 100) or 1.0)
end

---@return integer, integer, integer, integer
function ColorLch:to_css()
	return from_unit(self.l, 100), from_unit(self.c, 150), from_unit_hue(self.h), from_unit(self.a, 100)
end

---@return Hndy.Color.Lch
function ColorLch:clone()
	return ColorLch.new(self.l, self.c, self.h, self.a)
end

---@param target Hndy.Color.Lch
---@return Hndy.Color.Lch
function ColorLch:copy_to(target)
	target.l = self.l
	target.c = self.c
	target.h = self.h
	target.a = self.a
	return target
end

---@return Hndy.Color.GameColor
function ColorLch:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_lch(self.l, self.c, self.h))
end

---@return Hndy.Color.GameColor
function ColorLch:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_lch(self.l, self.c, self.h))
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Lch
function ColorLch.from_game_color(color)
	local l, c, h = to_lch_from_srgb(color.r, color.g, color.b)
	return ColorLch.new(l, c, h, color.a or 1.0)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Lch
function ColorLch.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorLch.new(0.0, 0.0, 0.0, a) end
	local l, c, h = to_lch_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorLch.new(l, c, h, a)
end

---@param components { l: number | nil, c: number | nil, h: number | nil, a: number | nil }
---@return Hndy.Color.Lch
function ColorLch:with(components)
	return ColorLch.new(components.l or self.l, components.c or self.c, components.h or self.h, components.a or self.a)
end

---@param lightness number
---@return Hndy.Color.Lch
function ColorLch:with_lightness(lightness)
	return ColorLch.new(lightness, self.c, self.h, self.a)
end

---@param chroma number
---@return Hndy.Color.Lch
function ColorLch:with_chroma(chroma)
	return ColorLch.new(self.l, chroma, self.h, self.a)
end

---@param hue number
---@return Hndy.Color.Lch
function ColorLch:with_hue(hue)
	return ColorLch.new(self.l, self.c, hue, self.a)
end

---@param alpha number
---@return Hndy.Color.Lch
function ColorLch:with_alpha(alpha)
	return ColorLch.new(self.l, self.c, self.h, alpha)
end

---@return boolean
function ColorLch:is_within_gamut()
	return self.l >= 0.0 and self.l <= 1.0 and self.c >= 0.0
end

---@return Hndy.Color.Lch
function ColorLch:clamp_to_gamut()
	return ColorLch.new(clamp(self.l, 0.0, 1.0), max(self.c, 0.0), self.h, self.a)
end

---@return Hndy.Color.Lch
function ColorLch:self_clamp_to_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	self.c = max(self.c, 0.0)
	return self
end

---@return boolean
function ColorLch:is_within_safe_gamut()
	return self.l >= 0.0 and self.l <= 1.0 and self.c >= 0.0 and self.c <= 1.0
end

---@return Hndy.Color.Lch
function ColorLch:clamp_to_safe_gamut()
	return ColorLch.new(clamp(self.l, 0.0, 1.0), clamp(self.c, 0.0, 1.0), self.h, self.a)
end

---@return Hndy.Color.Lch
function ColorLch:self_clamp_to_safe_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	self.c = max(self.c, 0.0)
	return self
end

---@return boolean
function ColorLch:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Lch
function ColorLch:normalize_alpha()
	return ColorLch.new(self.l, self.c, self.h, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Lch
function ColorLch:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorLch:is_normal_hue()
	return self.h >= 0.0 and self.h <= 1.0
end

---@return Hndy.Color.Lch
function ColorLch:normalize_hue()
	return ColorLch.new(self.l, self.c, modulo(self.h, 1.0), self.a)
end

---@return Hndy.Color.Lch
function ColorLch:self_normalize_hue()
	self.h = modulo(self.h, 1.0)
	return self
end

---@return boolean
function ColorLch:is_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.c >= 0.0 and self.h >= 0.0 and self.h <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Lch
function ColorLch:normalize()
	return ColorLch.new(clamp(self.l, 0.0, 1.0), max(self.c, 0.0), modulo(self.h, 1.0), clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Lch
function ColorLch:self_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.c = max(self.c, 0.0)
	self.h = modulo(self.h, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorLch:is_safe_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.c >= 0.0 and self.c <= 1.0 and self.h >= 0.0 and self.h <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Lch
function ColorLch:safe_normalize()
	return ColorLch.new(clamp(self.l, 0.0, 1.0), clamp(self.c, 0.0, 1.0), modulo(self.h, 1.0), clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Lch
function ColorLch:self_safe_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.c = clamp(self.c, 0.0, 1.0)
	self.h = modulo(self.h, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_linear_hue(target, t)
	local h = interpolate_hue_linear(self.h, target.h, t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_linear_hue(target, t)
	self.h = interpolate_hue_linear(self.h, target.h, t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_shorter_hue(target, t)
	local h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_shorter_hue(target, t)
	self.h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_longer_hue(target, t)
	local h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_longer_hue(target, t)
	self.h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_increasing_hue(target, t)
	local h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_increasing_hue(target, t)
	self.h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_decreasing_hue(target, t)
	local h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_decreasing_hue(target, t)
	self.h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

ColorLch.interpolate = ColorLch.interpolate_shorter_hue
ColorLch.self_interpolate = ColorLch.self_interpolate_shorter_hue

return ColorLch
