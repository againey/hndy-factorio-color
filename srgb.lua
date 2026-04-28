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

---A class to handle instances of colors represented as gamma-corrected red, green, and blue channels, plus alpha for transparency.
---
---For more details, see [Wikipedia: sRGB](https://en.wikipedia.org/wiki/SRGB).
---@class Hndy.Color.Srgb : Hndy.Color.ColorBase
---@field r number Red, ranging from 0 to 1
---@field g number Green, ranging from 0 to 1
---@field b number Blue, ranging from 0 to 1
---@field a number Alpha, representing opacity, ranging from 0 (fully transparent) to 1 (fully opaque)
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

---Constructs a new ColorSrgb instance using the provided components. If not supplied, alpha is assumed to be 1 (fully opaque).
---@param r number
---@param g number
---@param b number
---@param a number | nil
---@return Hndy.Color.Srgb
---@overload fun(r: number, g: number, b: number): Hndy.Color.Srgb
function ColorSrgb.new(r, g, b, a)
	return setmetatable({ r = r, g = g, b = b, a = a or 1.0 }, ColorSrgb)
end

---Constructs a new ColorSrgb instance using a subset of the values accepted by the [rgb() CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/rgb).
---@param r integer Red as a byte value from 0 to 255
---@param g integer Green as a byte value from 0 to 255
---@param b integer Blue as a byte value from 0 to 255
---@param a integer | nil Alpha as a percentage from 0 to 100
---@return Hndy.Color.Srgb
---@overload fun(r: integer, g: integer, b: integer): Hndy.Color.Srgb
function ColorSrgb.new_from_css(r, g, b, a)
	return ColorSrgb.new(to_unit(r, 255), to_unit(g, 255), to_unit(b, 255), a and to_unit(a, 100) or 1.0)
end

---Returns the four color components inverting the range conversions of [new_from_css](lua://Hndy.Color.Srgb.new_from_css).
---@return integer, integer, integer, integer
function ColorSrgb:to_css()
	return from_unit(self.r, 255), from_unit(self.g, 255), from_unit(self.b, 255), from_unit(self.a, 100)
end

---Creates and returns a new instance of ColorSrgb with the exact same values as self.
---@return Hndy.Color.Srgb
function ColorSrgb:clone()
	return ColorSrgb.new(self.r, self.g, self.b, self.a)
end

---Copies all color components to another existing instance of ColorSrgb so that the target becomes identical to self.
---@param target Hndy.Color.Srgb
---@return Hndy.Color.Srgb
function ColorSrgb:copy_to(target)
	target.r = self.r
	target.g = self.g
	target.b = self.b
	target.a = self.a
	return target
end

---Returns a game color representation of this color without premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColor
function ColorSrgb:to_game_color()
	return to_alpha_game_color(self.a, self.r, self.g, self.b)
end

---Returns a game color representation of this color after premultiplying the RGB components by the alpha component.
---@return Hndy.Color.GameColor
function ColorSrgb:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, self.r, self.g, self.b)
end

---Constructs a new ColorSrgb instance from a game color whose components are presumed to not be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Srgb
function ColorSrgb.from_game_color(color)
	return ColorSrgb.new(color.r, color.g, color.b, color.a or 1.0)
end

---Constructs a new ColorSrgb instance from a game color whose components are presumed to be premultiplied by the alpha component.
---@param color Hndy.Color.GameColor
---@return Hndy.Color.Srgb
function ColorSrgb.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorSrgb.new(0.0, 0.0, 0.0, a) end
	return ColorSrgb.new(color.r / a, color.g / a, color.b / a, a)
end

---Creates and returns a new instance of ColorSrgb with the same values as self, but with any specified components replaced with new values.
---@param components { r: number | nil, g: number | nil, b: number | nil, a: number | nil }
---@return Hndy.Color.Srgb
function ColorSrgb:with(components)
	return ColorSrgb.new(components.r or self.r, components.g or self.g, components.b or self.b, components.a or self.a)
end

---Creates and returns a new instance of ColorSrgb with the same values as self, but with the red component replaced with a new value.
---@param red number
---@return Hndy.Color.Srgb
function ColorSrgb:with_red(red)
	return ColorSrgb.new(red, self.g, self.b, self.a)
end

---Creates and returns a new instance of ColorSrgb with the same values as self, but with the green component replaced with a new value.
---@param green number
---@return Hndy.Color.Srgb
function ColorSrgb:with_green(green)
	return ColorSrgb.new(self.r, green, self.b, self.a)
end

---Creates and returns a new instance of ColorSrgb with the same values as self, but with the blue component replaced with a new value.
---@param blue number
---@return Hndy.Color.Srgb
function ColorSrgb:with_blue(blue)
	return ColorSrgb.new(self.r, self.g, blue, self.a)
end

---Creates and returns a new instance of ColorSrgb with the same values as self, but with the alpha component replaced with a new value.
---@param alpha number
---@return Hndy.Color.Srgb
function ColorSrgb:with_alpha(alpha)
	return ColorSrgb.new(self.r, self.g, self.b, alpha)
end

---Evaluates whether the color is within the acceptable gamut based on its red, green, and blue components.
---@return boolean
function ColorSrgb:is_within_gamut()
	return self.r >= 0.0 and self.r <= 1.0 and self.g >= 0.0 and self.g <= 1.0 and self.b >= 0.0 and self.b <= 1.0
end

---Clamps red, green, and blue components to the acceptable gamut and returns the adjusted color as a new instance of ColorSrgb.
---@return Hndy.Color.Srgb
function ColorSrgb:clamp_to_gamut()
	return ColorSrgb.new(clamp(self.r, 0.0, 1.0), clamp(self.g, 0.0, 1.0), clamp(self.b, 0.0, 1.0), self.a)
end

---Clamps red, green, and blue components to the acceptable gamut and applies those changes in place.
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

---Evaluates whether the alpha component is within the acceptable range.
---@return boolean
function ColorSrgb:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---Clamps the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorSrgb.
---@return Hndy.Color.Srgb
function ColorSrgb:normalize_alpha()
	return ColorSrgb.new(self.r, self.g, self.b, clamp(self.a, 0.0, 1.0))
end

---Clamps the alpha component to the acceptable range and applies that change in place.
---@return Hndy.Color.Srgb
function ColorSrgb:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---Evaluates both whether the color is within the acceptable gamut and the alpha component is within the acceptable range.
---@return boolean
function ColorSrgb:is_normal()
	return self.r >= 0.0 and self.r <= 1.0 and self.g >= 0.0 and self.g <= 1.0 and self.b >= 0.0 and self.b <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---Clamps both the color to the acceptable gamut and the alpha component to the acceptable range and returns the adjusted color as a new instance of ColorSrgb.
---@return Hndy.Color.Srgb
function ColorSrgb:normalize()
	return ColorSrgb.new(clamp(self.r, 0.0, 1.0), clamp(self.g, 0.0, 1.0), clamp(self.b, 0.0, 1.0), clamp(self.a, 0.0, 1.0))
end

---Clamps both the color to the acceptable gamut and the alpha component to the acceptable range and applies those changes in place.
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

---Linearly interpolates all color components between self and target by the provided amount and returns the interpolated color as a new instance of ColorSrgb.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Srgb The target color toward which self will be interpolated
---@param t number The interpolation amount, in a range from 0 to 1
---@return Hndy.Color.Srgb
function ColorSrgb:interpolate(target, t)
	local r, g, b, a = interpolate_three_components(self.r, target.r, self.g, target.g, self.b, target.b, self.a, target.a, t)
	return ColorSrgb.new(r, g, b, a)
end

---Linearly interpolates all color components between self and target by the provided amount and applies those changes in place.
---
---The alpha channel is taken into account so that more opaque colors have a strong pull on the interpolation than more transparent colors.
---@param target Hndy.Color.Srgb The target color toward which self will be interpolated
---@param t number The interpolation amount, in a range from 0 to 1
---@return Hndy.Color.Srgb
function ColorSrgb:self_interpolate(target, t)
	self.r, self.g, self.b, self.a = interpolate_three_components(self.r, target.r, self.g, target.g, self.b, target.b, self.a, target.a, t)
	return self
end

return ColorSrgb
