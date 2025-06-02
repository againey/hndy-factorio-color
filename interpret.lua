local ColorRgb = require("__hndy-color__.rgb")
local ColorSrgb = require("__hndy-color__.srgb")

local Interpret = {}

----------------------
-- Interpret.as_rgb --
----------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Rgb
local function as_rgb_from_rgb(color)
	return color:clone()
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Rgb
function Interpret.as_rgb_from_srgb(color)
	return ColorRgb.new(color.r, color.g, color.b, color.a)
end

local InterpretAsRgb = {
	[ColorRgb] = as_rgb_from_rgb,
	[ColorSrgb] = Interpret.as_rgb_from_srgb,
}

---@param color Hndy.Color.Rgb | Hndy.Color.Srgb
---@return Hndy.Color.Rgb
function Interpret.as_rgb(color)
	local convert = InterpretAsRgb[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type that can be reinterpreted as RGB.") end
	return convert(color)
end

-----------------------
-- Interpret.as_srgb --
-----------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Srgb
function Interpret.as_srgb_from_rgb(color)
	return ColorSrgb.new(color.r, color.g, color.b, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Srgb
local function as_srgb_from_srgb(color)
	return color:clone()
end

local InterpretAsSrgb = {
	[ColorRgb] = Interpret.as_srgb_from_rgb,
	[ColorSrgb] = as_srgb_from_srgb,
}

---@param color Hndy.Color.Rgb | Hndy.Color.Srgb
---@return Hndy.Color.Srgb
function Interpret.as_srgb(color)
	local convert = InterpretAsSrgb[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type that can be reinterpreted as sRGB.") end
	return convert(color)
end

return Interpret
