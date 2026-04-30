require("__hndy-color__.color-base")
require("__hndy-color__.hue-base")

local GameColor = require("__hndy-color__.game-color")
local to_game_color = GameColor.to_game_color
local to_alpha_game_color = GameColor.to_alpha_game_color
local to_premultiplied_alpha_game_color = GameColor.to_premultiplied_alpha_game_color
local to_game_color_array = GameColor.to_game_color_array
local to_alpha_game_color_array = GameColor.to_alpha_game_color_array
local to_premultiplied_alpha_game_color_array = GameColor.to_premultiplied_alpha_game_color_array
local to_unit_srgb_components_from_game_color = GameColor.to_unit_srgb_components_from_game_color
local to_unit_srgb_components_from_premultiplied_game_color = GameColor.to_unit_srgb_components_from_premultiplied_game_color

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

---A class to handle instances of colors represented as hue, saturation, and lightness, plus alpha for transparency.
---
---Zero lightness is always black regardless of saturation, and full lightness is always white.
---The most vibrant colors occur with full saturation and half lightness.
---If saturation is zero, hue has no effect and the result is white, black, or some shade of gray depending on lightness.
---For more details, see [Wikipedia: HSL and HSV](https://en.wikipedia.org/wiki/HSL_and_HSV)
---@class Hndy.Color.Hsl : Hndy.Color.ColorBase, Hndy.Color.HueBase
---@field h number Hue, ranging from 0 to 1 (corresponding to the full 360° circular spectrum); values outside this range are allowed but should be handled carefully
---@field s number Saturation, ranging from 0 to 1
---@field l number Lightness, ranging from 0 to 1
---@field a number Alpha, representing opacity, ranging from 0 (fully transparent) to 1 (fully opaque)
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

---Constructs a new ColorHsl instance using the provided components. If not supplied, alpha is assumed to be 1 (fully opaque).
---@param h number
---@param s number
---@param l number
---@param a number | nil
---@return Hndy.Color.Hsl
---@overload fun(h: number, s: number, l: number): Hndy.Color.Hsl
function ColorHsl.new(h, s, l, a)
	return setmetatable({ h = h, s = s, l = l, a = a or 1.0 }, ColorHsl)
end

---Constructs a new ColorHsl instance using a subset of the values accepted by the [hsl() CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/hsl).
---@param h integer Hue in degrees, usually from 0 to 360
---@param s integer Saturation as a percentage from 0 to 100
---@param l integer Lightness as a percentage from 0 to 100
---@param a integer | nil Alpha as a percentage from 0 to 100
---@return Hndy.Color.Hsl
---@overload fun(h: integer, s: integer, l: integer): Hndy.Color.Hsl
function ColorHsl.new_from_css(h, s, l, a)
	return ColorHsl.new(to_unit_hue(h), to_unit(s, 100), to_unit(l, 100), a and to_unit(a, 100) or 1.0)
end

---Returns the four color components inverting the range conversions of [new_from_css](lua://Hndy.Color.Hsl.new_from_css).
---@return integer, integer, integer, integer
function ColorHsl:to_css()
	return from_unit_hue(self.h), from_unit(self.s, 100), from_unit(self.l, 100), from_unit(self.a, 100)
end

---Creates and returns a new instance of ColorHsl with the exact same values as self.
---@return Hndy.Color.Hsl
function ColorHsl:clone()
	return ColorHsl.new(self.h, self.s, self.l, self.a)
end

---Copies all color components to another existing instance of ColorHsl so that the target becomes identical to self.
---@param target Hndy.Color.Hsl
---@return Hndy.Color.Hsl
function ColorHsl:copy_to(target)
	target.h = self.h
	target.s = self.s
	target.l = self.l
	target.a = self.a
	return target
end

---Returns a game color representation of this color converted to sRGB without any alpha component.
---@return Hndy.Color.GameColorTableRgb
function ColorHsl:to_game_color()
	return to_game_color(self.a, to_srgb_from_hsl(self.h, self.s, self.l))
end

---Returns a game color representation of this color converted to sRGB without premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColorTableRgba
function ColorHsl:to_alpha_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_hsl(self.h, self.s, self.l))
end

---Returns a game color representation of this color converted to sRGB after premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColorTableRgba
function ColorHsl:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_hsl(self.h, self.s, self.l))
end

---Returns a game color array representation of this color converted to sRGB without any alpha component.
---@return Hndy.Color.GameColorArrayRgb
function ColorHsl:to_game_color_array()
	return to_game_color_array(self.a, to_srgb_from_hsl(self.h, self.s, self.l))
end

---Returns a game color array representation of this color converted to sRGB without premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColorArrayRgba
function ColorHsl:to_alpha_game_color_array()
	return to_alpha_game_color_array(self.a, to_srgb_from_hsl(self.h, self.s, self.l))
end

---Returns a game color array representation of this color converted to sRGB after premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColorArrayRgba
function ColorHsl:to_premultiplied_game_color_array()
	return to_premultiplied_alpha_game_color_array(self.a, to_srgb_from_hsl(self.h, self.s, self.l))
end

---Constructs a new ColorHsl instance from a game color whose components are presumed to not be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hsl
function ColorHsl.from_game_color(color)
	local r, g, b, a = to_unit_srgb_components_from_game_color(color)
	local h, s, l = to_hsl_from_srgb(r, g, b)
	return ColorHsl.new(h, s, l, a)
end

---Constructs a new ColorHsl instance from a game color whose components are presumed to be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Hsl
function ColorHsl.from_premultiplied_game_color(color)
	local r, g, b, a = to_unit_srgb_components_from_premultiplied_game_color(color)
	local h, s, l = to_hsl_from_srgb(r, g, b)
	return ColorHsl.new(h, s, l, a)
end

---Creates and returns a new instance of ColorHsl with the same values as self, but with any specified components replaced with new values.
---@param components { h: number | nil, s: number | nil, l: number | nil, a: number | nil }
---@return Hndy.Color.Hsl
function ColorHsl:with(components)
	return ColorHsl.new(components.h or self.h, components.s or self.s, components.l or self.l, components.a or self.a)
end

---Creates and returns a new instance of ColorHsl with the same values as self, but with the hue component replaced with a new value.
---@param hue number
---@return Hndy.Color.Hsl
function ColorHsl:with_hue(hue)
	return ColorHsl.new(hue, self.s, self.l, self.a)
end

---Creates and returns a new instance of ColorHsl with the same values as self, but with the saturation component replaced with a new value.
---@param saturation number
---@return Hndy.Color.Hsl
function ColorHsl:with_saturation(saturation)
	return ColorHsl.new(self.h, saturation, self.l, self.a)
end

---Creates and returns a new instance of ColorHsl with the same values as self, but with the lightness component replaced with a new value.
---@param lightness number
---@return Hndy.Color.Hsl
function ColorHsl:with_lightness(lightness)
	return ColorHsl.new(self.h, self.s, lightness, self.a)
end

---Creates and returns a new instance of ColorHsl with the same values as self, but with the alpha component replaced with a new value.
---@param alpha number
---@return Hndy.Color.Hsl
function ColorHsl:with_alpha(alpha)
	return ColorHsl.new(self.h, self.s, self.l, alpha)
end

---Evaluates whether the color is within the acceptable gamut based on its saturation and lightness components.
---@return boolean
function ColorHsl:is_within_gamut()
	return self.s >= 0.0 and self.s <= 1.0 and self.l >= 0.0 and self.l <= 1.0
end

---Clamps saturation and lightness components to the acceptable gamut and returns the adjusted color as a new instance of ColorHsl.
---@return Hndy.Color.Hsl
function ColorHsl:clamp_to_gamut()
	return ColorHsl.new(self.h, clamp(self.s, 0.0, 1.0), clamp(self.l, 0.0, 1.0), self.a)
end

---Clamps saturation and lightness components to the acceptable gamut and applies those changes in place.
---@return Hndy.Color.Hsl
function ColorHsl:self_clamp_to_gamut()
	self.s = clamp(self.s, 0.0, 1.0)
	self.l = clamp(self.l, 0.0, 1.0)
	return self
end

ColorHsl.is_within_safe_gamut = ColorHsl.is_within_gamut
ColorHsl.clamp_to_safe_gamut = ColorHsl.clamp_to_gamut
ColorHsl.self_clamp_to_safe_gamut = ColorHsl.self_clamp_to_gamut

---Evaluates whether the alpha component is within the acceptable range.
---@return boolean
function ColorHsl:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---Clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorHsl.
---@return Hndy.Color.Hsl
function ColorHsl:normalize_alpha()
	return ColorHsl.new(self.h, self.s, self.l, clamp(self.a, 0.0, 1.0))
end

---Clamps the alpha component to the acceptable range and applies that change in place.
---@return Hndy.Color.Hsl
function ColorHsl:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---Evaluates whether the hue component is within the standard range.
---@return boolean
function ColorHsl:is_normal_hue()
	return self.h >= 0.0 and self.h <= 1.0
end

---Wraps the hue component to the standard range and returns the adjusted color as a new instance of ColorHsl.
---@return Hndy.Color.Hsl
function ColorHsl:normalize_hue()
	return ColorHsl.new(modulo(self.h, 1.0), self.s, self.l, self.a)
end

---Wraps the hue component to the standard range and applies that change in place.
---@return Hndy.Color.Hsl
function ColorHsl:self_normalize_hue()
	self.h = modulo(self.h, 1.0)
	return self
end

---Evaluates whether the color is within the acceptable gamut, the hue is in the standard range, and the alpha component is within the acceptable range.
---@return boolean
function ColorHsl:is_normal()
	return self.h >= 0.0 and self.h <= 1.0 and self.s >= 0.0 and self.s <= 1.0 and self.l >= 0.0 and self.l <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---Clamps the color to the acceptable gamut, wraps the hue to the standard range, and clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorHsl.
---@return Hndy.Color.Hsl
function ColorHsl:normalize()
	return ColorHsl.new(modulo(self.h, 1.0), clamp(self.s, 0.0, 1.0), clamp(self.l, 0.0, 1.0), clamp(self.a, 0.0, 1.0))
end

---Clamps the color to the acceptable gamut, wraps the hue to the standard range, and clamps the alpha component to the acceptable range and applies those changes in place.
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


---Linearly interpolates all color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHsl.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_linear_hue(target, t)
	local h = interpolate_hue_linear(self.h, target.h, self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---Linearly interpolates all color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_linear_hue(target, t)
	self.h = interpolate_hue_linear(self.h, target.h, self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the shortest path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHsl.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_shorter_hue(target, t)
	local h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---Circularly interpolates hue along the shortest path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_shorter_hue(target, t)
	self.h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the longest path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHsl.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_longer_hue(target, t)
	local h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---Circularly interpolates hue along the longest path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_longer_hue(target, t)
	self.h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the forward path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHsl.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_increasing_hue(target, t)
	local h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---Circularly interpolates hue along the forward path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:self_interpolate_increasing_hue(target, t)
	self.h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.s, self.l, self.a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the backward path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorHsl.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Hsl
---@param t number
---@return Hndy.Color.Hsl
function ColorHsl:interpolate_decreasing_hue(target, t)
	local h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local s, l, a = interpolate_two_components(self.s, target.s, self.l, target.l, self.a, target.a, t)
	return ColorHsl.new(h, s, l, a)
end

---Circularly interpolates hue along the backward path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
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
