require("__hndy-color__.color-base")

local GameColor = require("__hndy-color__.game-color")
local to_alpha_game_color = GameColor.to_alpha_game_color
local to_premultiplied_alpha_game_color = GameColor.to_premultiplied_alpha_game_color

local Arithmetic = require("__hndy-color__.util.arithmetic")
local clamp = Arithmetic.clamp
local to_unit = Arithmetic.scale_to_unit_from_integer
local from_unit = Arithmetic.scale_to_integer_from_unit
local to_signed_unit = Arithmetic.scale_to_signed_unit_from_integer
local from_signed_unit = Arithmetic.scale_to_integer_from_signed_unit

local Alpha = require("__hndy-color__.util.alpha")
local interpolate_three_components = Alpha.interpolate_three_components

local RawConvert = require("__hndy-color__.util.raw-convert")
local to_srgb_from_oklab = RawConvert.to_srgb_from_oklab
local to_oklab_from_srgb = RawConvert.to_oklab_from_srgb

local math_abs = math.abs
local math_max = math.max

---A class to handle instances of colors represented as lightness, green-red axis, and blue-yellow axis, plus alpha for transparency.
---
---For more details, see [Wikipedia: Oklab color space](https://en.wikipedia.org/wiki/Oklab_color_space).
---
---For information about the scale of the gr and by values, see [Mozilla Developer Network: oklab() CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/oklab).
---@class Hndy.Color.Oklab : Hndy.Color.ColorBase
---@field l number Lightness, ranging from 0 to 1
---@field gr number The green-red axis, usually ranging from -1 (green) to +1 (red) (which correspond to -100% and +100% in the CSS specification), though any value outside that range is technically valid
---@field by number The blue-yellow axis, usually ranging from -1 (blue) to +1 (yellow) (which correspond to -100% and +100% in the CSS specification), though any value outside that range is technically valid
---@field a number Alpha, representing opacity, ranging from 0 (fully transparent) to 1 (fully opaque)
local ColorOklab = {}
ColorOklab.__index = ColorOklab

ColorOklab.l_min = 0.0
ColorOklab.l_max = 1.0

ColorOklab.gr_safe_min = -1.0
ColorOklab.gr_safe_max = 1.0
ColorOklab.gr_min = -math.huge
ColorOklab.gr_max = math.huge

ColorOklab.by_safe_min = -1.0
ColorOklab.by_safe_max = 1.0
ColorOklab.by_min = -math.huge
ColorOklab.by_max = math.huge

ColorOklab.a_min = 0.0
ColorOklab.a_max = 1.0

---Constructs a new ColorOklab instance using the provided components. If not supplied, alpha is assumed to be 1 (fully opaque).
---@param l number
---@param gr number
---@param by number
---@param a number | nil
---@return Hndy.Color.Oklab
---@overload fun(l: number, gr: number, by: number): Hndy.Color.Oklab
function ColorOklab.new(l, gr, by, a)
	return setmetatable({ l = l, gr = gr, by = by, a = a or 1.0 }, ColorOklab)
end

---Constructs a new ColorLab instance using a subset of the values accepted by the [oklab() CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/oklab).
---@param l integer Lightness in the range from 0 to 1
---@param gr integer Green-red axis value, usually in the range from -0.4 to +0.4
---@param by integer Blue-red axis value, usually in the range from -0.4 to +0.4
---@param a integer | nil Alpha as a percentage from 0 to 100
---@return Hndy.Color.Oklab
---@overload fun(l: integer, gr: integer, by: integer): Hndy.Color.Oklab
function ColorOklab.new_from_css(l, gr, by, a)
	return ColorOklab.new(l, gr * 2.5, by * 2.5, a and to_unit(a, 100) or 1.0)
end

---Returns the four color components inverting the range conversions of [new_from_css](lua://Hndy.Color.Oklab.new_from_css).
---@return number, number, number, integer
function ColorOklab:to_css()
	return self.l, self.gr * 0.4, self.by * 0.4, from_unit(self.a, 100)
end

---Creates and returns a new instance of ColorOklab with the exact same values as self.
---@return Hndy.Color.Oklab
function ColorOklab:clone()
	return ColorOklab.new(self.l, self.gr, self.by, self.a)
end

---Copies all color components to another existing instance of ColorOklab so that the target becomes identical to self.
---@param target Hndy.Color.Oklab
---@return Hndy.Color.Oklab
function ColorOklab:copy_to(target)
	target.l = self.l
	target.gr = self.gr
	target.by = self.by
	target.a = self.a
	return target
end

---Returns a game color representation of this color converted to sRGB without premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColor
function ColorOklab:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_oklab(self.l, self.gr, self.by))
end

---Returns a game color representation of this color converted to sRGB after premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColor
function ColorOklab:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_oklab(self.l, self.gr, self.by))
end

---Constructs a new ColorOklab instance from a game color whose components are presumed to not be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Oklab
function ColorOklab.from_game_color(color)
	local l, gr, by = to_oklab_from_srgb(color.r, color.g, color.b)
	return ColorOklab.new(l, gr, by, color.a or 1.0)
end

---Constructs a new ColorOklab instance from a game color whose components are presumed to be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Oklab
function ColorOklab.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorOklab.new(0.0, 0.0, 0.0, a) end
	local l, gr, by = to_oklab_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorOklab.new(l, gr, by, a)
end

---Creates and returns a new instance of ColorOklab with the same values as self, but with any specified components replaced with new values.
---@param components { l: number | nil, gr: number | nil, by: number | nil, a: number | nil }
---@return Hndy.Color.Oklab
function ColorOklab:with(components)
	return ColorOklab.new(components.l or self.l, components.gr or self.gr, components.by or self.by, components.a or self.a)
end

---Creates and returns a new instance of ColorOklab with the same values as self, but with the lightness component replaced with a new value.
---@param lightness number
---@return Hndy.Color.Oklab
function ColorOklab:with_lightness(lightness)
	return ColorOklab.new(lightness, self.gr, self.by, self.a)
end

---Creates and returns a new instance of ColorOklab with the same values as self, but with the green-red component replaced with a new value.
---@param green_red number
---@return Hndy.Color.Oklab
function ColorOklab:with_green_red(green_red)
	return ColorOklab.new(self.l, green_red, self.by, self.a)
end

---Creates and returns a new instance of ColorOklab with the same values as self, but with the blue-yellow component replaced with a new value.
---@param blue_yellow number
---@return Hndy.Color.Oklab
function ColorOklab:with_blue_yellow(blue_yellow)
	return ColorOklab.new(self.l, self.gr, blue_yellow, self.a)
end

---Creates and returns a new instance of ColorOklab with the same values as self, but with the alpha component replaced with a new value.
---@param alpha number
---@return Hndy.Color.Oklab
function ColorOklab:with_alpha(alpha)
	return ColorOklab.new(self.l, self.gr, self.by, alpha)
end

---Evaluates whether the color is within the acceptable gamut based on its lightness component.
---@return boolean
function ColorOklab:is_within_gamut()
	return self.l >= 0.0 and self.l <= 1.0
end

---Clamps lightness component to the acceptable gamut and returns the adjusted color as a new instance of ColorOklab.
---@return Hndy.Color.Oklab
function ColorOklab:clamp_to_gamut()
	return ColorOklab.new(clamp(self.l, 0.0, 1.0), self.gr, self.by, self.a)
end

---Clamps lightness component to the acceptable gamut and applies those changes in place.
---@return Hndy.Color.Oklab
function ColorOklab:self_clamp_to_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	return self
end

---Evaluates whether the color is within the safe gamut based on its lightness component.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return boolean
function ColorOklab:is_within_safe_gamut()
	return self.l >= 0.0 and self.l <= 1.0 and self.gr >= -1.0 and self.gr <= 1.0 and self.by >= -1.0 and self.by <= 1.0
end

---Clamps lightness component to the safe gamut and returns the adjusted color as a new instance of ColorOklab.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return Hndy.Color.Oklab
function ColorOklab:clamp_to_safe_gamut()
	return self:clone():self_clamp_to_safe_gamut()
end

---Clamps lightness component to the safe gamut and applies those changes in place.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return Hndy.Color.Oklab
function ColorOklab:self_clamp_to_safe_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	local max = math_max(math_abs(self.gr), math_abs(self.by))
	if max > 1.0 then
		self.gr = self.gr / max
		self.by = self.by / max
	end
	return self
end

---Evaluates whether the alpha component is within the acceptable range.
---@return boolean
function ColorOklab:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---Clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorOklab.
---@return Hndy.Color.Oklab
function ColorOklab:normalize_alpha()
	return ColorOklab.new(self.l, self.gr, self.by, clamp(self.a, 0.0, 1.0))
end

---Clamps the alpha component to the acceptable range and applies that change in place.
---@return Hndy.Color.Oklab
function ColorOklab:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---Evaluates both whether the color is within the acceptable gamut and the alpha component is within the acceptable range.
---@return boolean
function ColorOklab:is_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---Clamps both the color to the acceptable gamut and the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorOklab.
---@return Hndy.Color.Oklab
function ColorOklab:normalize()
	return ColorOklab.new(clamp(self.l, 0.0, 1.0), self.gr, self.by, clamp(self.a, 0.0, 1.0))
end

---Clamps both the color to the acceptable gamut and the alpha component to the acceptable range and applies those changes in place.
---@return Hndy.Color.Oklab
function ColorOklab:self_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---Evaluates both whether the color is within the safe gamut and the alpha component is within the acceptable range.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return boolean
function ColorOklab:is_safe_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.gr >= -1.0 and self.gr <= 1.0 and self.by >= -1.0 and self.by <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---Clamps both the color to the safe gamut and the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorOklab.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return Hndy.Color.Oklab
function ColorOklab:safe_normalize()
	return self:clone():self_clamp_to_safe_gamut():self_normalize_alpha()
end

---Clamps both the color to the safe gamut and the alpha component to the acceptable range and applies those changes in place.
---
---The safe gamut is more restricted than the full gamut to avoid colors that cannot be accurately presented on many phsyical display devices.
---@return Hndy.Color.Oklab
function ColorOklab:self_safe_normalize()
	return self:self_clamp_to_safe_gamut():self_normalize_alpha()
end

---Linearly interpolates all color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorOklab.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Oklab
---@param t number
---@return Hndy.Color.Oklab
function ColorOklab:interpolate(target, t)
	local l, gr, by, a = interpolate_three_components(self.l, target.l, self.gr, target.gr, self.by, target.by, self.a, target.a, t)
	return ColorOklab.new(l, gr, by, a)
end

---Linearly interpolates all color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Oklab
---@param t number
---@return Hndy.Color.Oklab
function ColorOklab:self_interpolate(target, t)
	self.l, self.gr, self.by, self.a = interpolate_three_components(self.l, target.l, self.gr, target.gr, self.by, target.by, self.a, target.a, t)
	return self
end

return ColorOklab
