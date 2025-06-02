require("__hndy-color__.color-base")

local GameColor = require("__hndy-color__.game-color")
local to_alpha_game_color = GameColor.to_alpha_game_color
local to_premultiplied_alpha_game_color = GameColor.to_premultiplied_alpha_game_color

local Arithmetic = require("__hndy-color__.util.arithmetic")
local clamp = Arithmetic.clamp

local Alpha = require("__hndy-color__.util.alpha")
local interpolate_three_components = Alpha.interpolate_three_components

local RawConvert = require("__hndy-color__.util.raw-convert")
local to_srgb_from_lab = RawConvert.to_srgb_from_lab
local to_lab_from_srgb = RawConvert.to_lab_from_srgb
local to_unit = Arithmetic.scale_to_unit_from_integer
local from_unit = Arithmetic.scale_to_integer_from_unit
local to_signed_unit = Arithmetic.scale_to_signed_unit_from_integer
local from_signed_unit = Arithmetic.scale_to_integer_from_signed_unit

---@class Hndy.Color.Lab : Hndy.Color.ColorBase
---@field l number
---@field gr number
---@field by number
---@field a number
local ColorLab = {}
ColorLab.__index = ColorLab

ColorLab.l_min = 0.0
ColorLab.l_max = 1.0

ColorLab.gr_safe_min = -1.0
ColorLab.gr_safe_max = 1.0
ColorLab.gr_min = -math.huge
ColorLab.gr_max = math.huge

ColorLab.by_safe_min = -1.0
ColorLab.by_safe_max = 1.0
ColorLab.by_min = -math.huge
ColorLab.by_max = math.huge

ColorLab.a_min = 0.0
ColorLab.a_max = 1.0

---@param l number
---@param gr number
---@param by number
---@param a number | nil
---@return Hndy.Color.Lab
---@overload fun(l: number, gr: number, by: number): Hndy.Color.Lab
function ColorLab.new(l, gr, by, a)
	return setmetatable({ l = l, gr = gr, by = by, a = a or 1.0 }, ColorLab)
end

---@param l integer
---@param gr integer
---@param by integer
---@param a integer | nil
---@return Hndy.Color.Lab
---@overload fun(l: integer, gr: integer, by: integer): Hndy.Color.Lab
function ColorLab.new_from_css(l, gr, by, a)
	return ColorLab.new(to_unit(l, 100), to_signed_unit(gr, 125), to_signed_unit(by, 125), a and to_unit(a, 100) or 1.0)
end

---@return integer, integer, integer, integer
function ColorLab:to_css()
	return from_unit(self.l, 100), from_signed_unit(self.gr, 125), from_signed_unit(self.by, 125), from_unit(self.a, 100)
end

---@return Hndy.Color.Lab
function ColorLab:clone()
	return ColorLab.new(self.l, self.gr, self.by, self.a)
end

---@param target Hndy.Color.Lab
---@return Hndy.Color.Lab
function ColorLab:copy_to(target)
	target.l = self.l
	target.gr = self.gr
	target.by = self.by
	target.a = self.a
	return target
end

---@return Hndy.Color.GameColor
function ColorLab:to_game_color()
	return to_alpha_game_color(self.a, to_srgb_from_lab(self.l, self.gr, self.by))
end

---@return Hndy.Color.GameColor
function ColorLab:to_premultiplied_game_color()
	return to_premultiplied_alpha_game_color(self.a, to_srgb_from_lab(self.l, self.gr, self.by))
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Lab
function ColorLab.from_game_color(color)
	local l, gr, by = to_lab_from_srgb(color.r, color.g, color.b)
	return ColorLab.new(l, gr, by, color.a or 1.0)
end

---@param color Hndy.Color.GameColor
---@return Hndy.Color.Lab
function ColorLab.from_premultiplied_game_color(color)
	local a = color.a or 1.0
	if a == 0.0 then return ColorLab.new(0.0, 0.0, 0.0, a) end
	local l, gr, by = to_lab_from_srgb(color.r / a, color.g / a, color.b / a)
	return ColorLab.new(l, gr, by, a)
end

---@param components { l: number | nil, gr: number | nil, by: number | nil, a: number | nil }
---@return Hndy.Color.Lab
function ColorLab:with(components)
	return ColorLab.new(components.l or self.l, components.gr or self.gr, components.by or self.by, components.a or self.a)
end

---@param lightness number
---@return Hndy.Color.Lab
function ColorLab:with_lightness(lightness)
	return ColorLab.new(lightness, self.gr, self.by, self.a)
end

---@param green_red number
---@return Hndy.Color.Lab
function ColorLab:with_green_red(green_red)
	return ColorLab.new(self.l, green_red, self.by, self.a)
end

---@param blue_yellow number
---@return Hndy.Color.Lab
function ColorLab:with_blue_yellow(blue_yellow)
	return ColorLab.new(self.l, self.gr, blue_yellow, self.a)
end

---@param alpha number
---@return Hndy.Color.Lab
function ColorLab:with_alpha(alpha)
	return ColorLab.new(self.l, self.gr, self.by, alpha)
end

---@return boolean
function ColorLab:is_within_gamut()
	return self.l >= 0.0 and self.l <= 1.0
end

---@return Hndy.Color.Lab
function ColorLab:clamp_to_gamut()
	return ColorLab.new(clamp(self.l, 0.0, 1.0), self.gr, self.by, self.a)
end

---@return Hndy.Color.Lab
function ColorLab:self_clamp_to_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	return self
end

---@return boolean
function ColorLab:is_within_safe_gamut()
	return self.l >= 0.0 and self.l <= 1.0 and self.gr >= -1.0 and self.gr <= 1.0 and self.by >= -1.0 and self.by <= 1.0
end

---@return Hndy.Color.Lab
function ColorLab:clamp_to_safe_gamut()
	return ColorLab.new(clamp(self.l, 0.0, 1.0), clamp(self.gr, -1.0, 1.0), clamp(self.by, -1.0, 1.0), self.a)
end

---@return Hndy.Color.Lab
function ColorLab:self_clamp_to_safe_gamut()
	self.l = clamp(self.l, 0.0, 1.0)
	self.gr = clamp(self.gr, -1.0, 1.0)
	self.by = clamp(self.by, -1.0, 1.0)
	return self
end

---@return boolean
function ColorLab:is_normal_alpha()
	return self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Lab
function ColorLab:normalize_alpha()
	return ColorLab.new(self.l, self.gr, self.by, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Lab
function ColorLab:self_normalize_alpha()
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorLab:is_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Lab
function ColorLab:normalize()
	return ColorLab.new(clamp(self.l, 0.0, 1.0), self.gr, self.by, clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Lab
function ColorLab:self_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@return boolean
function ColorLab:is_safe_normal()
	return self.l >= 0.0 and self.l <= 1.0 and self.gr >= -1.0 and self.gr <= 1.0 and self.by >= -1.0 and self.by <= 1.0 and self.a >= 0.0 and self.a <= 1.0
end

---@return Hndy.Color.Lab
function ColorLab:safe_normalize()
	return ColorLab.new(clamp(self.l, 0.0, 1.0), clamp(self.gr, -1.0, 1.0), clamp(self.by, -1.0, 1.0), clamp(self.a, 0.0, 1.0))
end

---@return Hndy.Color.Lab
function ColorLab:self_safe_normalize()
	self.l = clamp(self.l, 0.0, 1.0)
	self.gr = clamp(self.gr, -1.0, 1.0)
	self.by = clamp(self.by, -1.0, 1.0)
	self.a = clamp(self.a, 0.0, 1.0)
	return self
end

---@param target Hndy.Color.Lab
---@param t number
---@return Hndy.Color.Lab
function ColorLab:interpolate(target, t)
	local l, gr, by, a = interpolate_three_components(self.l, target.l, self.gr, target.gr, self.by, target.by, self.a, target.a, t)
	return ColorLab.new(l, gr, by, a)
end

---@param target Hndy.Color.Lab
---@param t number
---@return Hndy.Color.Lab
function ColorLab:self_interpolate(target, t)
	self.l, self.gr, self.by, self.a = interpolate_three_components(self.l, target.l, self.gr, target.gr, self.by, target.by, self.a, target.a, t)
	return self
end

return ColorLab
