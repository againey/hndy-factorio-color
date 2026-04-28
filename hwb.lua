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

---A class to handle instances of colors represented as hue, whiteness, and blackness, plus alpha for transparency.
---
---The most vibrant colors occur with zero whiteness and zero blackness.
---If either whiteness or blackness are at their maximum value, hue has no effect and the result is white, black, or some shade of gray depending on the component that is not at its maximum.
---For more details, see [Wikipedia: HWB color model](https://en.wikipedia.org/wiki/HWB_color_model)
---@class Hndy.Color.Hwb : Hndy.Color.ColorBase, Hndy.Color.HueBase
---@field h number Hue, ranging from 0 to 1 (corresponding to the full 360° circular spectrum); values outside this range are allowed but should be handled carefully
---@field w number Whiteness, ranging from 0 to 1
---@field b number Blackness, ranging from 0 to 1
---@field a number Alpha, representing opacity, ranging from 0 (fully transparent) to 1 (fully opaque)
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

---Constructs a new ColorHwb instance using the provided components. If not supplied, alpha is assumed to be 1 (fully opaque).
---@param h number
---@param w number
---@param b number
---@param a number | nil
---@return Hndy.Color.Hwb
---@overload fun(h: number, w: number, b: number): Hndy.Color.Hwb
function ColorHwb.new(h, w, b, a)
	return setmetatable({ h = h, w = w, b = b, a = a or 1.0 }, ColorHwb)
end

---Constructs a new ColorHwb instance using a subset of the values accepted by the [hwb() CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/hwb).
---@param h integer Hue in degrees, usually from 0 to 360
---@param w integer Whiteness as a percentage from 0 to 100
---@param b integer Blackness as a percentage from 0 to 100
---@param a integer | nil Alpha as a percentage from 0 to 100
---@return Hndy.Color.Hwb
---@overload fun(h: integer, w: integer, b: integer): Hndy.Color.Hwb
function ColorHwb.new_from_css(h, w, b, a)
	return ColorHwb.new(to_unit_hue(h), to_unit(w, 100), to_unit(b, 100), a and to_unit(a, 100) or 1.0)
end

---Returns the four color components inverting the range conversions of [new_from_css](lua://Hndy.Color.Hwb.new_from_css).
---@return integer, integer, integer, integer
function ColorHwb:to_css()
	return from_unit_hue(self.h), from_unit(self.w, 100), from_unit(self.b, 100), from_unit(self.a, 100)
end

---Creates and returns a new instance of ColorHwb with the exact same values as self.
---@return Hndy.Color.Hwb
function ColorHwb:clone()
	return ColorHwb.new(self.h, self.w, self.b, self.a)
end

---Copies all color components to another existing instance of ColorHwb so that the target becomes identical to self.
---@param target Hndy.Color.Hwb
---@return Hndy.Color.Hwb
function ColorHwb:copy_to(target)
	target.h = self.h
	target.w = self.w
	target.b = self.b
	target.a = self.a
	return target
end

---Returns a game color representation of this color converted to sRGB without premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColor
function ColorHwb:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_hwb(self.h, self.w, self.b))
end

---Returns a game color representation of this color converted to sRGB after premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColor
function ColorHwb:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_hwb(self.h, self.w, self.b))
end

---Constructs a new ColorHwb instance from a game color whose components are presumed to not be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hwb
function ColorHwb.from_game_color(color)
	local h, w, b = to_hwb_from_srgb(color.r, color.g, color.b)
	return ColorHwb.new(h, w, b, color.a or 1.0)
end

---Constructs a new ColorHwb instance from a game color whose components are presumed to be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hwb
function ColorHwb.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorHwb.new(0.0, 0.0, 0.0, a) end
	local h, w, b = to_hwb_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorHwb.new(h, w, b, a)
end

---Creates and returns a new instance of ColorHwb with the same values as self, but with any specified components replaced with new values.
---@param components { h: number | nil, w: number | nil, b: number | nil, a: number | nil }
---@return Hndy.Color.Hwb
function ColorHwb:with(components)
	return ColorHwb.new(components.h or self.h, components.w or self.w, components.b or self.b, components.a or self.a)
end

---Creates and returns a new instance of ColorHwb with the same values as self, but with the hue component replaced with a new value.
---@param hue number
---@return Hndy.Color.Hwb
function ColorHwb:with_hue(hue)
	return ColorHwb.new(hue, self.w, self.b, self.a)
end

---Creates and returns a new instance of ColorHwb with the same values as self, but with the whiteness component replaced with a new value.
---@param whiteness number
---@return Hndy.Color.Hwb
function ColorHwb:with_whiteness(whiteness)
	return ColorHwb.new(self.h, whiteness, self.b, self.a)
end

---Creates and returns a new instance of ColorHwb with the same values as self, but with the blackness component replaced with a new value.
---@param blackness number
---@return Hndy.Color.Hwb
function ColorHwb:with_blackness(blackness)
	return ColorHwb.new(self.h, self.w, blackness, self.a)
end

---Creates and returns a new instance of ColorHwb with the same values as self, but with the alpha component replaced with a new value.
---@param alpha number
---@return Hndy.Color.Hwb
function ColorHwb:with_alpha(alpha)
	return ColorHwb.new(self.h, self.w, self.b, alpha)
end

---Evaluates whether the color is within the acceptable gamut based on its whiteness and blackness components.
---@return boolean
function ColorHwb:is_within_gamut()
	return self.w >= 0.0 and self.b >= 0.0 and self.w + self.b <= 1.0
end

---Clamps whiteness and blackness components to the acceptable gamut and returns the adjusted color as a new instance of ColorHwb.
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

---Clamps whiteness and blackness components to the acceptable gamut and applies those changes in place.
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

---Evaluates whether the alpha component is within the acceptable range.
---@return boolean
function ColorHwb:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---Clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorHwb.
---@return Hndy.Color.Hwb
function ColorHwb:normalize_alpha()
	return ColorHwb.new(self.h, self.w, self.b, clamp(self.a, 0.0, 1.0))
end

---Clamps the alpha component to the acceptable range and applies that change in place.
---@return Hndy.Color.Hwb
function ColorHwb:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---Evaluates whether the hue component is within the standard range.
---@return boolean
function ColorHwb:is_normal_hue()
	return self.h >= 0.0 and self.h <= 1.0
end

---Wraps the hue component to the standard range and returns the adjusted color as a new instance of ColorHwb.
---@return Hndy.Color.Hwb
function ColorHwb:normalize_hue()
	return ColorHwb.new(modulo(self.h, 1.0), self.w, self.b, self.a)
end

---Wraps the hue component to the standard range and applies that change in place.
---@return Hndy.Color.Hwb
function ColorHwb:self_normalize_hue()
	self.h = modulo(self.h, 1.0)
	return self
end

---Evaluates whether the color is within the acceptable gamut, the hue is in the standard range, and the alpha component is within the acceptable range.
---@return boolean
function ColorHwb:is_normal()
	return self.h >= 0.0 and self.h <= 1.0 and self.w >= 0.0 and self.b >= 0.0 and self.w + self.b <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---Clamps the color to the acceptable gamut, wraps the hue to the standard range, and clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorHwb.
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

---Clamps the color to the acceptable gamut, wraps the hue to the standard range, and clamps the alpha component to the acceptable range and applies those changes in place.
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

---Linearly interpolates all color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHwb.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_linear_hue(target, t)
	local h = interpolate_hue_linear(self.h, target.h, self.a, target.a, t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---Linearly interpolates all color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_linear_hue(target, t)
	self.h = interpolate_hue_linear(self.h, target.h, self.a, target.a, t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the shortest path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHwb.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_shorter_hue(target, t)
	local h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---Circularly interpolates hue along the shortest path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_shorter_hue(target, t)
	self.h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the longest path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHwb.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_longer_hue(target, t)
	local h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---Circularly interpolates hue along the longest path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_longer_hue(target, t)
	self.h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the forward path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHwb.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_increasing_hue(target, t)
	local h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---Circularly interpolates hue along the forward path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_increasing_hue(target, t)
	self.h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the backward path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHwb.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:interpolate_decreasing_hue(target, t)
	local h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local w, b, a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return ColorHwb.new(h, w, b, a)
end

---Circularly interpolates hue along the backward path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hwb
---@param t number
---@return Hndy.Color.Hwb
function ColorHwb:self_interpolate_decreasing_hue(target, t)
	self.h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.w, self.b, self.a = interpolate_two_components(self.w, target.w, self.b, target.b, self.a, target.a, t)
	return self
end

ColorHwb.interpolate = ColorHwb.interpolate_shorter_hue
ColorHwb.self_interpolate = ColorHwb.self_interpolate_shorter_hue

return ColorHwb
