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

---@class Hndy.Color.Oklab : Hndy.Color.ColorBase
---@field l number
---@field gr number
---@field by number
---@field a number
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

---@param l number
---@param gr number
---@param by number
---@param a number | nil
---@return Hndy.Color.Oklab
---@overload fun(l: number, gr: number, by: number): Hndy.Color.Oklab
function ColorOklab.new(l, gr, by, a)
	return setmetatable({ l = l, gr = gr, by = by, a = a or 1.0 }, ColorOklab)
end

---@param l number
---@param gr number
---@param by number
---@param a integer | nil
---@return Hndy.Color.Oklab
---@overload fun(l: integer, gr: integer, by: integer): Hndy.Color.Oklab
function ColorOklab.new_from_css(l, gr, by, a)
	return ColorOklab.new(l, gr * 2.5, by * 2.5, a and to_unit(a, 100) or 1.0)
end

---@return number, number, number, integer
function ColorOklab:to_css()
	return self.l, self.gr * 0.4, self.by * 0.4, from_unit(self.a, 100)
end

---@return Hndy.Color.Oklab
function ColorOklab:clone()
	return ColorOklab.new(self.l, self.gr, self.by, self.a)
end

---@param target Hndy.Color.Oklab
---@return Hndy.Color.Oklab
function ColorOklab:copy_to(target)
	target.l = self.l
	target.gr = self.gr
	target.by = self.by
	target.a = self.a
	return target
end

---@return Hndy.Color.GameColor
function ColorOklab:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_oklab(self.l, self.gr, self.by))
end

---@return Hndy.Color.GameColor
function ColorOklab:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_oklab(self.l, self.gr, self.by))
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Oklab
function ColorOklab.from_game_color(color)
	local l, gr, by = to_oklab_from_srgb(color.r, color.g, color.b)
	return ColorOklab.new(l, gr, by, color.a or 1.0)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Oklab
function ColorOklab.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorOklab.new(0.0, 0.0, 0.0, a) end
	local l, gr, by = to_oklab_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorOklab.new(l, gr, by, a)
end

---@param components { l: number | nil, gr: number | nil, by: number | nil, a: number | nil }
---@return Hndy.Color.Oklab
function ColorOklab:with(components)
	return ColorOklab.new(components.l or self.l, components.gr or self.gr, components.by or self.by, components.a or self.a)
end

---@param lightness number
---@return Hndy.Color.Oklab
function ColorOklab:with_lightness(lightness)
	return ColorOklab.new(lightness, self.gr, self.by, self.a)
end

---@param green_red number
---@return Hndy.Color.Oklab
function ColorOklab:with_green_red(green_red)
	return ColorOklab.new(self.l, green_red, self.by, self.a)
end

---@param blue_yellow number
---@return Hndy.Color.Oklab
function ColorOklab:with_blue_yellow(blue_yellow)
	return ColorOklab.new(self.l, self.gr, blue_yellow, self.a)
end

---@param alpha number
---@return Hndy.Color.Oklab
function ColorOklab:with_alpha(alpha)
	return ColorOklab.new(self.l, self.gr, self.by, alpha)
end

---@return boolean
function ColorOklab:is_within_gamut()
	return self.l >= 0.0 and self.l <= 1.0
end

---@return Hndy.Color.Oklab
function ColorOklab:clamp_to_gamut()
	return ColorOklab.new(clamp(self.l, 0.0, 1.0), self.gr, self.by, self.a)
end

---@return Hndy.Color.Oklab
function ColorOklab:self_clamp_to_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	return self
end

---@return boolean
function ColorOklab:is_within_safe_gamut()
	return self.l >= 0.0 and self.l <= 1.0 and self.gr >= -1.0 and self.gr <= 1.0 and self.by >= -1.0 and self.by <= 1.0
end

---@return Hndy.Color.Oklab
function ColorOklab:clamp_to_safe_gamut()
	return ColorOklab.new(clamp(self.l, 0.0, 1.0), clamp(self.gr, -1.0, 1.0), clamp(self.by, -1.0, 1.0), self.a)
end

---@return Hndy.Color.Oklab
function ColorOklab:self_clamp_to_safe_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	self.gr = clamp(self.gr, -1.0, 1.0)
	self.by = clamp(self.by, -1.0, 1.0)
	return self
end

---@return boolean
function ColorOklab:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Oklab
function ColorOklab:normalize_alpha()
	return ColorOklab.new(self.l, self.gr, self.by, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Oklab
function ColorOklab:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorOklab:is_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Oklab
function ColorOklab:normalize()
	return ColorOklab.new(clamp(self.l, 0.0, 1.0), self.gr, self.by, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Oklab
function ColorOklab:self_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorOklab:is_safe_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.gr >= -1.0 and self.gr <= 1.0 and self.by >= -1.0 and self.by <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Oklab
function ColorOklab:safe_normalize()
	return ColorOklab.new(clamp(self.l, 0.0, 1.0), clamp(self.gr, -1.0, 1.0), clamp(self.by, -1.0, 1.0), clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Oklab
function ColorOklab:self_safe_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.gr = clamp(self.gr, -1.0, 1.0)
	self.by = clamp(self.by, -1.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@param target Hndy.Color.Oklab
---@param t number
---@return Hndy.Color.Oklab
function ColorOklab:interpolate(target, t)
	local l, gr, by, a = interpolate_three_components(self.l, target.l, self.gr, target.gr, self.by, target.by, self.a, target.a, t)
	return ColorOklab.new(l, gr, by, a)
end

---@param target Hndy.Color.Oklab
---@param t number
---@return Hndy.Color.Oklab
function ColorOklab:self_interpolate(target, t)
	self.l, self.gr, self.by, self.a = interpolate_three_components(self.l, target.l, self.gr, target.gr, self.by, target.by, self.a, target.a, t)
	return self
end

return ColorOklab
