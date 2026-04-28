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

---A class to handle instances of colors represented as lightness, chroma, and hue, plus alpha for transparency.
---
---This color space handles lightness and chroma such that they appear stable even while hue is altered.
---For more details, see [Wikipedia: Oklab color space](https://en.wikipedia.org/wiki/Oklab_color_space).
---
---For information about the scale of chroma values, see [Mozilla Developer Network: lch() CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/lch).
---@class Hndy.Color.Lch : Hndy.Color.ColorBase, Hndy.Color.HueBase
---@field l number Lightness, ranging from 0 to 1
---@field c number Chroma which determines vibrancy, usually ranging from 0 to 1 (which corresponds to 100% in the CSS specification), though any value greater than 1 is technically valid
---@field h number Hue, ranging from 0 to 1 (corresponding to the full 360° circular spectrum); values outside this range are allowed but should be handled carefully
---@field a number Alpha, representing opacity, ranging from 0 (fully transparent) to 1 (fully opaque)
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

---Constructs a new ColorLch instance using the provided components. If not supplied, alpha is assumed to be 1 (fully opaque).
---@param l number
---@param c number
---@param h number
---@param a number | nil
---@return Hndy.Color.Lch
---@overload fun(l: number, c: number, h: number): Hndy.Color.Lch
function ColorLch.new(l, c, h, a)
	return setmetatable({ l = l, c = c, h = h, a = a or 1.0 }, ColorLch)
end

---Constructs a new ColorLch instance using a subset of the values accepted by the [lch() CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/lch).
---@param l integer Lightness as a percentage from 0 to 100
---@param c integer Chroma, usually in the range from 0 to 150
---@param h integer Hue in degrees, usually from 0 to 360
---@param a integer | nil Alpha as a percentage from 0 to 100
---@return Hndy.Color.Lch
---@overload fun(l: integer, c: integer, h: integer): Hndy.Color.Lch
function ColorLch.new_from_css(l, c, h, a)
	return ColorLch.new(to_unit(l, 100), to_unit(c, 150), to_unit_hue(h), a and to_unit(a, 100) or 1.0)
end

---Returns the four color components inverting the range conversions of [new_from_css](lua://Hndy.Color.lch.new_from_css).
---@return integer, integer, integer, integer
function ColorLch:to_css()
	return from_unit(self.l, 100), from_unit(self.c, 150), from_unit_hue(self.h), from_unit(self.a, 100)
end

---Creates and returns a new instance of ColorLch with the exact same values as self.
---@return Hndy.Color.Lch
function ColorLch:clone()
	return ColorLch.new(self.l, self.c, self.h, self.a)
end

---Copies all color components to another existing instance of ColorLch so that the target becomes identical to self.
---@param target Hndy.Color.Lch
---@return Hndy.Color.Lch
function ColorLch:copy_to(target)
	target.l = self.l
	target.c = self.c
	target.h = self.h
	target.a = self.a
	return target
end

---Returns a game color representation of this color converted to sRGB without premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColor
function ColorLch:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_lch(self.l, self.c, self.h))
end

---Returns a game color representation of this color converted to sRGB after premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColor
function ColorLch:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_lch(self.l, self.c, self.h))
end

---Constructs a new ColorLch instance from a game color whose components are presumed to not be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Lch
function ColorLch.from_game_color(color)
	local l, c, h = to_lch_from_srgb(color.r, color.g, color.b)
	return ColorLch.new(l, c, h, color.a or 1.0)
end

---Constructs a new ColorLch instance from a game color whose components are presumed to be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Lch
function ColorLch.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorLch.new(0.0, 0.0, 0.0, a) end
	local l, c, h = to_lch_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorLch.new(l, c, h, a)
end

---Creates and returns a new instance of ColorLch with the same values as self, but with any specified components replaced with new values.
---@param components { l: number | nil, c: number | nil, h: number | nil, a: number | nil }
---@return Hndy.Color.Lch
function ColorLch:with(components)
	return ColorLch.new(components.l or self.l, components.c or self.c, components.h or self.h, components.a or self.a)
end

---Creates and returns a new instance of ColorLch with the same values as self, but with the lightness component replaced with a new value.
---@param lightness number
---@return Hndy.Color.Lch
function ColorLch:with_lightness(lightness)
	return ColorLch.new(lightness, self.c, self.h, self.a)
end

---Creates and returns a new instance of ColorLch with the same values as self, but with the chroma component replaced with a new value.
---@param chroma number
---@return Hndy.Color.Lch
function ColorLch:with_chroma(chroma)
	return ColorLch.new(self.l, chroma, self.h, self.a)
end

---Creates and returns a new instance of ColorLch with the same values as self, but with the hue component replaced with a new value.
---@param hue number
---@return Hndy.Color.Lch
function ColorLch:with_hue(hue)
	return ColorLch.new(self.l, self.c, hue, self.a)
end

---Creates and returns a new instance of ColorLch with the same values as self, but with the alpha component replaced with a new value.
---@param alpha number
---@return Hndy.Color.Lch
function ColorLch:with_alpha(alpha)
	return ColorLch.new(self.l, self.c, self.h, alpha)
end

---Evaluates whether the color is within the acceptable gamut based on its lightness and chroma components.
---@return boolean
function ColorLch:is_within_gamut()
	return self.l >= 0.0 and self.l <= 1.0 and self.c >= 0.0
end

---Clamps lightness and chroma components to the acceptable gamut and returns the adjusted color as a new instance of ColorLch.
---@return Hndy.Color.Lch
function ColorLch:clamp_to_gamut()
	return ColorLch.new(clamp(self.l, 0.0, 1.0), max(self.c, 0.0), self.h, self.a)
end

---Clamps lightness and chroma components to the acceptable gamut and applies those changes in place.
---@return Hndy.Color.Lch
function ColorLch:self_clamp_to_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	self.c = max(self.c, 0.0)
	return self
end

---Evaluates whether the color is within the safe gamut based on its lightness and chroma components.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return boolean
function ColorLch:is_within_safe_gamut()
	return self.l >= 0.0 and self.l <= 1.0 and self.c >= 0.0 and self.c <= 1.0
end

---Clamps lightness and chroma components to the safe gamut and returns the adjusted color as a new instance of ColorLch.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return Hndy.Color.Lch
function ColorLch:clamp_to_safe_gamut()
	return ColorLch.new(clamp(self.l, 0.0, 1.0), clamp(self.c, 0.0, 1.0), self.h, self.a)
end

---Clamps lightness and chroma components to the safe gamut and applies those changes in place.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return Hndy.Color.Lch
function ColorLch:self_clamp_to_safe_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	self.c = max(self.c, 0.0)
	return self
end

---Evaluates whether the alpha component is within the acceptable range.
---@return boolean
function ColorLch:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---Clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorLch.
---@return Hndy.Color.Lch
function ColorLch:normalize_alpha()
	return ColorLch.new(self.l, self.c, self.h, clamp(self.a, 0.0, 1.0))
end

---Clamps the alpha component to the acceptable range and applies that change in place.
---@return Hndy.Color.Lch
function ColorLch:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---Evaluates whether the hue component is within the standard range.
---@return boolean
function ColorLch:is_normal_hue()
	return self.h >= 0.0 and self.h <= 1.0
end

---Wraps the hue component to the standard range and returns the adjusted color as a new instance of ColorLch.
---@return Hndy.Color.Lch
function ColorLch:normalize_hue()
	return ColorLch.new(self.l, self.c, modulo(self.h, 1.0), self.a)
end

---Wraps the hue component to the standard range and applies that change in place.
---@return Hndy.Color.Lch
function ColorLch:self_normalize_hue()
	self.h = modulo(self.h, 1.0)
	return self
end

---Evaluates whether the color is within the acceptable gamut, the hue is in the standard range, and the alpha component is within the acceptable range.
---@return boolean
function ColorLch:is_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.c >= 0.0 and self.h >= 0.0 and self.h <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---Clamps the color to the acceptable gamut, wraps the hue to the standard range, and clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorLch.
---@return Hndy.Color.Lch
function ColorLch:normalize()
	return ColorLch.new(clamp(self.l, 0.0, 1.0), max(self.c, 0.0), modulo(self.h, 1.0), clamp(self.a, 0.0, 1.0))
end

---Clamps the color to the acceptable gamut, wraps the hue to the standard range, and clamps the alpha component to the acceptable range and applies those changes in place.
---@return Hndy.Color.Lch
function ColorLch:self_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.c = max(self.c, 0.0)
	self.h = modulo(self.h, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---Evaluates whether the color is within the safe gamut, the hue is in the standard range, and the alpha component is within the acceptable range.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return boolean
function ColorLch:is_safe_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.c >= 0.0 and self.c <= 1.0 and self.h >= 0.0 and self.h <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---Clamps the color to the safe gamut, wraps the hue to the standard range, and clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorLch.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return Hndy.Color.Lch
function ColorLch:safe_normalize()
	return ColorLch.new(clamp(self.l, 0.0, 1.0), clamp(self.c, 0.0, 1.0), modulo(self.h, 1.0), clamp(self.a, 0.0, 1.0))
end

---Clamps the color to the safe gamut, wraps the hue to the standard range, and clamps the alpha component to the acceptable range and applies those changes in place.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return Hndy.Color.Lch
function ColorLch:self_safe_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.c = clamp(self.c, 0.0, 1.0)
	self.h = modulo(self.h, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---Linearly interpolates all color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorLch.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_linear_hue(target, t)
	local h = interpolate_hue_linear(self.h, target.h, self.a, target.a, t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---Linearly interpolates all color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_linear_hue(target, t)
	self.h = interpolate_hue_linear(self.h, target.h, self.a, target.a, t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the shortest path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorLch.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_shorter_hue(target, t)
	local h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---Circularly interpolates hue along the shortest path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_shorter_hue(target, t)
	self.h = interpolate_hue_shorter(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the longest path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorLch.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_longer_hue(target, t)
	local h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---Circularly interpolates hue along the longest path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_longer_hue(target, t)
	self.h = interpolate_hue_longer(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the forward path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_increasing_hue(target, t)
	local h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---Circularly interpolates hue along the forward path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_increasing_hue(target, t)
	self.h = interpolate_hue_increasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

---Circularly interpolates hue along the backward path and linearly interpolates all other color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorLch.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:interpolate_decreasing_hue(target, t)
	local h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	local l, c, a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return ColorLch.new(l, c, h, a)
end

---Circularly interpolates hue along the backward path and linearly interpolates all other color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Lch
---@param t number
---@return Hndy.Color.Lch
function ColorLch:self_interpolate_decreasing_hue(target, t)
	self.h = interpolate_hue_decreasing(modulo(self.h, 1.0), modulo(target.h, 1.0), self.a, target.a, t)
	self.l, self.c, self.a = interpolate_two_components(self.l, target.l, self.c, target.c, self.a, target.a, t)
	return self
end

ColorLch.interpolate = ColorLch.interpolate_shorter_hue
ColorLch.self_interpolate = ColorLch.self_interpolate_shorter_hue

return ColorLch
