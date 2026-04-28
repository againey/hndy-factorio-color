local ColorRgb = require("__hndy-color__.rgb")
local ColorSrgb = require("__hndy-color__.srgb")
local ColorHsl = require("__hndy-color__.hsl")
local ColorHsv = require("__hndy-color__.hsv")
local ColorHwb = require("__hndy-color__.hwb")
local ColorLab = require("__hndy-color__.lab")
local ColorLch = require("__hndy-color__.lch")
local ColorOklab = require("__hndy-color__.oklab")
local ColorOklch = require("__hndy-color__.oklch")

local RawConvert = require("__hndy-color__.util.raw-convert")
local raw_to_rgb_from_srgb = RawConvert.to_rgb_from_srgb
local raw_to_rgb_from_hsl = RawConvert.to_rgb_from_hsl
local raw_to_rgb_from_hsv = RawConvert.to_rgb_from_hsv
local raw_to_rgb_from_hwb = RawConvert.to_rgb_from_hwb
local raw_to_rgb_from_lab = RawConvert.to_rgb_from_lab
local raw_to_rgb_from_lch = RawConvert.to_rgb_from_lch
local raw_to_rgb_from_oklab = RawConvert.to_rgb_from_oklab
local raw_to_rgb_from_oklch = RawConvert.to_rgb_from_oklch
local raw_to_srgb_from_rgb = RawConvert.to_srgb_from_rgb
local raw_to_srgb_from_hsl = RawConvert.to_srgb_from_hsl
local raw_to_srgb_from_hsv = RawConvert.to_srgb_from_hsv
local raw_to_srgb_from_hwb = RawConvert.to_srgb_from_hwb
local raw_to_srgb_from_lab = RawConvert.to_srgb_from_lab
local raw_to_srgb_from_lch = RawConvert.to_srgb_from_lch
local raw_to_srgb_from_oklab = RawConvert.to_srgb_from_oklab
local raw_to_srgb_from_oklch = RawConvert.to_srgb_from_oklch
local raw_to_hsl_from_rgb = RawConvert.to_hsl_from_rgb
local raw_to_hsl_from_srgb = RawConvert.to_hsl_from_srgb
local raw_to_hsl_from_hsv = RawConvert.to_hsl_from_hsv
local raw_to_hsl_from_hwb = RawConvert.to_hsl_from_hwb
local raw_to_hsl_from_lab = RawConvert.to_hsl_from_lab
local raw_to_hsl_from_lch = RawConvert.to_hsl_from_lch
local raw_to_hsl_from_oklab = RawConvert.to_hsl_from_oklab
local raw_to_hsl_from_oklch = RawConvert.to_hsl_from_oklch
local raw_to_hsv_from_rgb = RawConvert.to_hsv_from_rgb
local raw_to_hsv_from_srgb = RawConvert.to_hsv_from_srgb
local raw_to_hsv_from_hsl = RawConvert.to_hsv_from_hsl
local raw_to_hsv_from_hwb = RawConvert.to_hsv_from_hwb
local raw_to_hsv_from_lab = RawConvert.to_hsv_from_lab
local raw_to_hsv_from_lch = RawConvert.to_hsv_from_lch
local raw_to_hsv_from_oklab = RawConvert.to_hsv_from_oklab
local raw_to_hsv_from_oklch = RawConvert.to_hsv_from_oklch
local raw_to_hwb_from_rgb = RawConvert.to_hwb_from_rgb
local raw_to_hwb_from_srgb = RawConvert.to_hwb_from_srgb
local raw_to_hwb_from_hsl = RawConvert.to_hwb_from_hsl
local raw_to_hwb_from_hsv = RawConvert.to_hwb_from_hsv
local raw_to_hwb_from_lab = RawConvert.to_hwb_from_lab
local raw_to_hwb_from_lch = RawConvert.to_hwb_from_lch
local raw_to_hwb_from_oklab = RawConvert.to_hwb_from_oklab
local raw_to_hwb_from_oklch = RawConvert.to_hwb_from_oklch
local raw_to_lab_from_rgb = RawConvert.to_lab_from_rgb
local raw_to_lab_from_srgb = RawConvert.to_lab_from_srgb
local raw_to_lab_from_hsl = RawConvert.to_lab_from_hsl
local raw_to_lab_from_hsv = RawConvert.to_lab_from_hsv
local raw_to_lab_from_hwb = RawConvert.to_lab_from_hwb
local raw_to_lab_from_lch = RawConvert.to_lab_from_lch
local raw_to_lab_from_oklab = RawConvert.to_lab_from_oklab
local raw_to_lab_from_oklch = RawConvert.to_lab_from_oklch
local raw_to_lch_from_rgb = RawConvert.to_lch_from_rgb
local raw_to_lch_from_srgb = RawConvert.to_lch_from_srgb
local raw_to_lch_from_hsl = RawConvert.to_lch_from_hsl
local raw_to_lch_from_hsv = RawConvert.to_lch_from_hsv
local raw_to_lch_from_hwb = RawConvert.to_lch_from_hwb
local raw_to_lch_from_lab = RawConvert.to_lch_from_lab
local raw_to_lch_from_oklab = RawConvert.to_lch_from_oklab
local raw_to_lch_from_oklch = RawConvert.to_lch_from_oklch
local raw_to_oklab_from_rgb = RawConvert.to_oklab_from_rgb
local raw_to_oklab_from_srgb = RawConvert.to_oklab_from_srgb
local raw_to_oklab_from_hsl = RawConvert.to_oklab_from_hsl
local raw_to_oklab_from_hsv = RawConvert.to_oklab_from_hsv
local raw_to_oklab_from_hwb = RawConvert.to_oklab_from_hwb
local raw_to_oklab_from_lab = RawConvert.to_oklab_from_lab
local raw_to_oklab_from_lch = RawConvert.to_oklab_from_lch
local raw_to_oklab_from_oklch = RawConvert.to_oklab_from_oklch
local raw_to_oklch_from_rgb = RawConvert.to_oklch_from_rgb
local raw_to_oklch_from_srgb = RawConvert.to_oklch_from_srgb
local raw_to_oklch_from_hsl = RawConvert.to_oklch_from_hsl
local raw_to_oklch_from_hsv = RawConvert.to_oklch_from_hsv
local raw_to_oklch_from_hwb = RawConvert.to_oklch_from_hwb
local raw_to_oklch_from_lab = RawConvert.to_oklch_from_lab
local raw_to_oklch_from_lch = RawConvert.to_oklch_from_lch
local raw_to_oklch_from_oklab = RawConvert.to_oklch_from_oklab

---@alias Hndy.Color.Any Hndy.Color.Rgb | Hndy.Color.Srgb | Hndy.Color.Hsl | Hndy.Color.Hsv | Hndy.Color.Hwb | Hndy.Color.Lab | Hndy.Color.Lch | Hndy.Color.Oklab | Hndy.Color.Oklch

local Convert = {}

--------------------
-- Convert.to_rgb --
--------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Rgb
local function to_rgb_from_rgb(color)
	return color:clone()
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Rgb
function Convert.to_rgb_from_srgb(color)
	local r, g, b = raw_to_rgb_from_srgb(color.r, color.g, color.b)
	return ColorRgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Rgb
function Convert.to_rgb_from_hsl(color)
	local r, g, b = raw_to_rgb_from_hsl(color.h, color.s, color.l)
	return ColorRgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Rgb
function Convert.to_rgb_from_hsv(color)
	local r, g, b = raw_to_rgb_from_hsv(color.h, color.s, color.v)
	return ColorRgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Rgb
function Convert.to_rgb_from_hwb(color)
	local r, g, b = raw_to_rgb_from_hwb(color.h, color.w, color.b)
	return ColorRgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Rgb
function Convert.to_rgb_from_lab(color)
	local r, g, b = raw_to_rgb_from_lab(color.l, color.gr, color.by)
	return ColorRgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Rgb
function Convert.to_rgb_from_lch(color)
	local r, g, b = raw_to_rgb_from_lch(color.l, color.c, color.h)
	return ColorRgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Rgb
function Convert.to_rgb_from_oklab(color)
	local r, g, b = raw_to_rgb_from_oklab(color.l, color.gr, color.by)
	return ColorRgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Rgb
function Convert.to_rgb_from_oklch(color)
	local r, g, b = raw_to_rgb_from_oklch(color.l, color.c, color.h)
	return ColorRgb.new(r, g, b, color.a)
end

local ConvertToRgb = {
	[ColorRgb] = to_rgb_from_rgb,
	[ColorSrgb] = Convert.to_rgb_from_srgb,
	[ColorHsl] = Convert.to_rgb_from_hsl,
	[ColorHsv] = Convert.to_rgb_from_hsv,
	[ColorHwb] = Convert.to_rgb_from_hwb,
	[ColorLab] = Convert.to_rgb_from_lab,
	[ColorLch] = Convert.to_rgb_from_lch,
	[ColorOklab] = Convert.to_rgb_from_oklab,
	[ColorOklch] = Convert.to_rgb_from_oklch,
}

---Creates and returns a new ColorRgb instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Rgb
function Convert.to_rgb(color)
	local convert = ConvertToRgb[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

---------------------
-- Convert.to_srgb --
---------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Srgb
function Convert.to_srgb_from_rgb(color)
	local r, g, b = raw_to_srgb_from_rgb(color.r, color.g, color.b)
	return ColorSrgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Srgb
local function to_srgb_from_srgb(color)
	return color:clone()
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Srgb
function Convert.to_srgb_from_hsl(color)
	local r, g, b = raw_to_srgb_from_hsl(color.h, color.s, color.l)
	return ColorSrgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Srgb
function Convert.to_srgb_from_hsv(color)
	local r, g, b = raw_to_srgb_from_hsv(color.h, color.s, color.v)
	return ColorSrgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Srgb
function Convert.to_srgb_from_hwb(color)
	local r, g, b = raw_to_srgb_from_hwb(color.h, color.w, color.b)
	return ColorSrgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Srgb
function Convert.to_srgb_from_lab(color)
	local r, g, b = raw_to_srgb_from_lab(color.l, color.gr, color.by)
	return ColorSrgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Srgb
function Convert.to_srgb_from_lch(color)
	local r, g, b = raw_to_srgb_from_lch(color.l, color.c, color.h)
	return ColorSrgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Srgb
function Convert.to_srgb_from_oklab(color)
	local r, g, b = raw_to_srgb_from_oklab(color.l, color.gr, color.by)
	return ColorSrgb.new(r, g, b, color.a)
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Srgb
function Convert.to_srgb_from_oklch(color)
	local r, g, b = raw_to_srgb_from_oklch(color.l, color.c, color.h)
	return ColorSrgb.new(r, g, b, color.a)
end

local ConvertToSrgb = {
	[ColorRgb] = Convert.to_srgb_from_rgb,
	[ColorSrgb] = to_srgb_from_srgb,
	[ColorHsl] = Convert.to_srgb_from_hsl,
	[ColorHsv] = Convert.to_srgb_from_hsv,
	[ColorHwb] = Convert.to_srgb_from_hwb,
	[ColorLab] = Convert.to_srgb_from_lab,
	[ColorLch] = Convert.to_srgb_from_lch,
	[ColorOklab] = Convert.to_srgb_from_oklab,
	[ColorOklch] = Convert.to_srgb_from_oklch,
}

---Creates and returns a new ColorSrgb instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Srgb
function Convert.to_srgb(color)
	local convert = ConvertToSrgb[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

--------------------
-- Convert.to_hsl --
--------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Hsl
function Convert.to_hsl_from_rgb(color)
	local h, s, l = raw_to_hsl_from_rgb(color.r, color.g, color.b)
	return ColorHsl.new(h, s, l, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Hsl
function Convert.to_hsl_from_srgb(color)
	local h, s, l = raw_to_hsl_from_srgb(color.r, color.g, color.b)
	return ColorHsl.new(h, s, l, color.a)
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Hsl
local function to_hsl_from_hsl(color)
	return color:clone()
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Hsl
function Convert.to_hsl_from_hsv(color)
	local h, s, l = raw_to_hsl_from_hsv(color.h, color.s, color.v)
	return ColorHsl.new(h, s, l, color.a)
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Hsl
function Convert.to_hsl_from_hwb(color)
	local h, s, l = raw_to_hsl_from_hwb(color.h, color.w, color.b)
	return ColorHsl.new(h, s, l, color.a)
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Hsl
function Convert.to_hsl_from_lab(color)
	local h, s, l = raw_to_hsl_from_lab(color.l, color.gr, color.by)
	return ColorHsl.new(h, s, l, color.a)
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Hsl
function Convert.to_hsl_from_lch(color)
	local h, s, l = raw_to_hsl_from_lch(color.l, color.c, color.h)
	return ColorHsl.new(h, s, l, color.a)
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Hsl
function Convert.to_hsl_from_oklab(color)
	local h, s, l = raw_to_hsl_from_oklab(color.l, color.gr, color.by)
	return ColorHsl.new(h, s, l, color.a)
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Hsl
function Convert.to_hsl_from_oklch(color)
	local h, s, l = raw_to_hsl_from_oklch(color.l, color.c, color.h)
	return ColorHsl.new(h, s, l, color.a)
end

local ConvertToHsl = {
	[ColorRgb] = Convert.to_hsl_from_rgb,
	[ColorSrgb] = Convert.to_hsl_from_srgb,
	[ColorHsl] = to_hsl_from_hsl,
	[ColorHsv] = Convert.to_hsl_from_hsv,
	[ColorHwb] = Convert.to_hsl_from_hwb,
	[ColorLab] = Convert.to_hsl_from_lab,
	[ColorLch] = Convert.to_hsl_from_lch,
	[ColorOklab] = Convert.to_hsl_from_oklab,
	[ColorOklch] = Convert.to_hsl_from_oklch,
}

---Creates and returns a new ColorHsl instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Hsl
function Convert.to_hsl(color)
	local convert = ConvertToHsl[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

--------------------
-- Convert.to_hsv --
--------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Hsv
function Convert.to_hsv_from_rgb(color)
	local h, s, v = raw_to_hsv_from_rgb(color.r, color.g, color.b)
	return ColorHsv.new(h, s, v, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Hsv
function Convert.to_hsv_from_srgb(color)
	local h, s, v = raw_to_hsv_from_srgb(color.r, color.g, color.b)
	return ColorHsv.new(h, s, v, color.a)
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Hsv
function Convert.to_hsv_from_hsl(color)
	local h, s, v = raw_to_hsv_from_hsl(color.h, color.s, color.l)
	return ColorHsv.new(h, s, v, color.a)
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Hsv
local function to_hsv_from_hsv(color)
	return color:clone()
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Hsv
function Convert.to_hsv_from_hwb(color)
	local h, s, v = raw_to_hsv_from_hwb(color.h, color.w, color.b)
	return ColorHsv.new(h, s, v, color.a)
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Hsv
function Convert.to_hsv_from_lab(color)
	local h, s, v = raw_to_hsv_from_lab(color.l, color.gr, color.by)
	return ColorHsv.new(h, s, v, color.a)
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Hsv
function Convert.to_hsv_from_lch(color)
	local h, s, v = raw_to_hsv_from_lch(color.l, color.c, color.h)
	return ColorHsv.new(h, s, v, color.a)
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Hsv
function Convert.to_hsv_from_oklab(color)
	local h, s, v = raw_to_hsv_from_oklab(color.l, color.gr, color.by)
	return ColorHsv.new(h, s, v, color.a)
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Hsv
function Convert.to_hsv_from_oklch(color)
	local h, s, v = raw_to_hsv_from_oklch(color.l, color.c, color.h)
	return ColorHsv.new(h, s, v, color.a)
end

local ConvertToHsv = {
	[ColorRgb] = Convert.to_hsv_from_rgb,
	[ColorSrgb] = Convert.to_hsv_from_srgb,
	[ColorHsl] = Convert.to_hsv_from_hsl,
	[ColorHsv] = to_hsv_from_hsv,
	[ColorHwb] = Convert.to_hsv_from_hwb,
	[ColorLab] = Convert.to_hsv_from_lab,
	[ColorLch] = Convert.to_hsv_from_lch,
	[ColorOklab] = Convert.to_hsv_from_oklab,
	[ColorOklch] = Convert.to_hsv_from_oklch,
}

---Creates and returns a new ColorHsv instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Hsv
function Convert.to_hsv(color)
	local convert = ConvertToHsv[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

--------------------
-- Convert.to_hwb --
--------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Hwb
function Convert.to_hwb_from_rgb(color)
	local h, w, b = raw_to_hwb_from_rgb(color.r, color.g, color.b)
	return ColorHwb.new(h, w, b, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Hwb
function Convert.to_hwb_from_srgb(color)
	local h, w, b = raw_to_hwb_from_srgb(color.r, color.g, color.b)
	return ColorHwb.new(h, w, b, color.a)
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Hwb
function Convert.to_hwb_from_hsl(color)
	local h, w, b = raw_to_hwb_from_hsl(color.h, color.s, color.l)
	return ColorHwb.new(h, w, b, color.a)
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Hwb
function Convert.to_hwb_from_hsv(color)
	local h, w, b = raw_to_hwb_from_hsv(color.h, color.s, color.v)
	return ColorHwb.new(h, w, b, color.a)
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Hwb
local function to_hwb_from_hwb(color)
	return color:clone()
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Hwb
function Convert.to_hwb_from_lab(color)
	local h, w, b = raw_to_hwb_from_lab(color.l, color.gr, color.by)
	return ColorHwb.new(h, w, b, color.a)
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Hwb
function Convert.to_hwb_from_lch(color)
	local h, w, b = raw_to_hwb_from_lch(color.l, color.c, color.h)
	return ColorHwb.new(h, w, b, color.a)
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Hwb
function Convert.to_hwb_from_oklab(color)
	local h, w, b = raw_to_hwb_from_oklab(color.l, color.gr, color.by)
	return ColorHwb.new(h, w, b, color.a)
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Hwb
function Convert.to_hwb_from_oklch(color)
	local h, w, b = raw_to_hwb_from_oklch(color.l, color.c, color.h)
	return ColorHwb.new(h, w, b, color.a)
end

local ConvertToHwb = {
	[ColorRgb] = Convert.to_hwb_from_rgb,
	[ColorSrgb] = Convert.to_hwb_from_srgb,
	[ColorHsl] = Convert.to_hwb_from_hsl,
	[ColorHsv] = Convert.to_hwb_from_hsv,
	[ColorHwb] = to_hwb_from_hwb,
	[ColorLab] = Convert.to_hwb_from_lab,
	[ColorLch] = Convert.to_hwb_from_lch,
	[ColorOklab] = Convert.to_hwb_from_oklab,
	[ColorOklch] = Convert.to_hwb_from_oklch,
}

---Creates and returns a new ColorHwb instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Hwb
function Convert.to_hwb(color)
	local convert = ConvertToHwb[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

--------------------
-- Convert.to_lab --
--------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Lab
function Convert.to_lab_from_rgb(color)
	local l, gr, by = raw_to_lab_from_rgb(color.r, color.g, color.b)
	return ColorLab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Lab
function Convert.to_lab_from_srgb(color)
	local l, gr, by = raw_to_lab_from_srgb(color.r, color.g, color.b)
	return ColorLab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Lab
function Convert.to_lab_from_hsl(color)
	local l, gr, by = raw_to_lab_from_hsl(color.h, color.s, color.l)
	return ColorLab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Lab
function Convert.to_lab_from_hsv(color)
	local l, gr, by = raw_to_lab_from_hsv(color.h, color.s, color.v)
	return ColorLab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Lab
function Convert.to_lab_from_hwb(color)
	local l, gr, by = raw_to_lab_from_hwb(color.h, color.w, color.b)
	return ColorLab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Lab
local function to_lab_from_lab(color)
	return color:clone()
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Lab
function Convert.to_lab_from_lch(color)
	local l, gr, by = raw_to_lab_from_lch(color.l, color.c, color.h)
	return ColorLab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Lab
function Convert.to_lab_from_oklab(color)
	local l, gr, by = raw_to_lab_from_oklab(color.l, color.gr, color.by)
	return ColorLab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Lab
function Convert.to_lab_from_oklch(color)
	local l, gr, by = raw_to_lab_from_oklch(color.l, color.c, color.h)
	return ColorLab.new(l, gr, by, color.a)
end

local ConvertToLab = {
	[ColorRgb] = Convert.to_lab_from_rgb,
	[ColorSrgb] = Convert.to_lab_from_srgb,
	[ColorHsl] = Convert.to_lab_from_hsl,
	[ColorHsv] = Convert.to_lab_from_hsv,
	[ColorHwb] = Convert.to_lab_from_hwb,
	[ColorLab] = to_lab_from_lab,
	[ColorLch] = Convert.to_lab_from_lch,
	[ColorOklab] = Convert.to_lab_from_oklab,
	[ColorOklch] = Convert.to_lab_from_oklch,
}

---Creates and returns a new ColorLab instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Lab
function Convert.to_lab(color)
	local convert = ConvertToLab[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

--------------------
-- Convert.to_lch --
--------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Lch
function Convert.to_lch_from_rgb(color)
	local l, c, h = raw_to_lch_from_rgb(color.r, color.g, color.b)
	return ColorLch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Lch
function Convert.to_lch_from_srgb(color)
	local l, c, h = raw_to_lch_from_srgb(color.r, color.g, color.b)
	return ColorLch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Lch
function Convert.to_lch_from_hsl(color)
	local l, c, h = raw_to_lch_from_hsl(color.h, color.s, color.l)
	return ColorLch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Lch
function Convert.to_lch_from_hsv(color)
	local l, c, h = raw_to_lch_from_hsv(color.h, color.s, color.v)
	return ColorLch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Lch
function Convert.to_lch_from_hwb(color)
	local l, c, h = raw_to_lch_from_hwb(color.h, color.w, color.b)
	return ColorLch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Lch
function Convert.to_lch_from_lab(color)
	local l, c, h = raw_to_lch_from_lab(color.l, color.gr, color.by)
	return ColorLch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Lch
local function to_lch_from_lch(color)
	return color:clone()
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Lch
function Convert.to_lch_from_oklab(color)
	local l, c, h = raw_to_lch_from_oklab(color.l, color.gr, color.by)
	return ColorLch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Lch
function Convert.to_lch_from_oklch(color)
	local l, c, h = raw_to_lch_from_oklch(color.l, color.c, color.h)
	return ColorLch.new(l, c, h, color.a)
end

local ConvertToLch = {
	[ColorRgb] = Convert.to_lch_from_rgb,
	[ColorSrgb] = Convert.to_lch_from_srgb,
	[ColorHsl] = Convert.to_lch_from_hsl,
	[ColorHsv] = Convert.to_lch_from_hsv,
	[ColorHwb] = Convert.to_lch_from_hwb,
	[ColorLab] = Convert.to_lch_from_lab,
	[ColorLch] = to_lch_from_lch,
	[ColorOklab] = Convert.to_lch_from_oklab,
	[ColorOklch] = Convert.to_lch_from_oklch,
}

---Creates and returns a new ColorLch instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Lch
function Convert.to_lch(color)
	local convert = ConvertToLch[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

--------------------
-- Convert.to_oklab --
--------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Oklab
function Convert.to_oklab_from_rgb(color)
	local l, gr, by = raw_to_oklab_from_rgb(color.r, color.g, color.b)
	return ColorOklab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Oklab
function Convert.to_oklab_from_srgb(color)
	local l, gr, by = raw_to_oklab_from_srgb(color.r, color.g, color.b)
	return ColorOklab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Oklab
function Convert.to_oklab_from_hsl(color)
	local l, gr, by = raw_to_oklab_from_hsl(color.h, color.s, color.l)
	return ColorOklab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Oklab
function Convert.to_oklab_from_hsv(color)
	local l, gr, by = raw_to_oklab_from_hsv(color.h, color.s, color.v)
	return ColorOklab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Oklab
function Convert.to_oklab_from_hwb(color)
	local l, gr, by = raw_to_oklab_from_hwb(color.h, color.w, color.b)
	return ColorOklab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Oklab
function Convert.to_oklab_from_lab(color)
	local l, gr, by = raw_to_oklab_from_lab(color.l, color.gr, color.by)
	return ColorOklab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Oklab
function Convert.to_oklab_from_lch(color)
	local l, gr, by = raw_to_oklab_from_lch(color.l, color.c, color.h)
	return ColorOklab.new(l, gr, by, color.a)
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Oklab
local function to_oklab_from_oklab(color)
	return color:clone()
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Oklab
function Convert.to_oklab_from_oklch(color)
	local l, gr, by = raw_to_oklab_from_oklch(color.l, color.c, color.h)
	return ColorOklab.new(l, gr, by, color.a)
end

local ConvertToOklab = {
	[ColorRgb] = Convert.to_oklab_from_rgb,
	[ColorSrgb] = Convert.to_oklab_from_srgb,
	[ColorHsl] = Convert.to_oklab_from_hsl,
	[ColorHsv] = Convert.to_oklab_from_hsv,
	[ColorHwb] = Convert.to_oklab_from_hwb,
	[ColorLab] = Convert.to_oklab_from_lab,
	[ColorLch] = Convert.to_oklab_from_lch,
	[ColorOklab] = to_oklab_from_oklab,
	[ColorOklch] = Convert.to_oklab_from_oklch,
}

---Creates and returns a new ColorOklab instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Oklab
function Convert.to_oklab(color)
	local convert = ConvertToOklab[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

--------------------
-- Convert.to_oklch --
--------------------

---@param color Hndy.Color.Rgb
---@return Hndy.Color.Oklch
function Convert.to_oklch_from_rgb(color)
	local l, c, h = raw_to_oklch_from_rgb(color.r, color.g, color.b)
	return ColorOklch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Srgb
---@return Hndy.Color.Oklch
function Convert.to_oklch_from_srgb(color)
	local l, c, h = raw_to_oklch_from_srgb(color.r, color.g, color.b)
	return ColorOklch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Hsl
---@return Hndy.Color.Oklch
function Convert.to_oklch_from_hsl(color)
	local l, c, h = raw_to_oklch_from_hsl(color.h, color.s, color.l)
	return ColorOklch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Hsv
---@return Hndy.Color.Oklch
function Convert.to_oklch_from_hsv(color)
	local l, c, h = raw_to_oklch_from_hsv(color.h, color.s, color.v)
	return ColorOklch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Hwb
---@return Hndy.Color.Oklch
function Convert.to_oklch_from_hwb(color)
	local l, c, h = raw_to_oklch_from_hwb(color.h, color.w, color.b)
	return ColorOklch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Lab
---@return Hndy.Color.Oklch
function Convert.to_oklch_from_lab(color)
	local l, c, h = raw_to_oklch_from_lab(color.l, color.gr, color.by)
	return ColorOklch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Lch
---@return Hndy.Color.Oklch
function Convert.to_oklch_from_lch(color)
	local l, c, h = raw_to_oklch_from_lch(color.l, color.c, color.h)
	return ColorOklch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Oklab
---@return Hndy.Color.Oklch
function Convert.to_oklch_from_oklab(color)
	local l, c, h = raw_to_oklch_from_oklab(color.l, color.gr, color.by)
	return ColorOklch.new(l, c, h, color.a)
end

---@param color Hndy.Color.Oklch
---@return Hndy.Color.Oklch
local function to_oklch_from_oklch(color)
	return color:clone()
end

local ConvertToOklch = {
	[ColorRgb] = Convert.to_oklch_from_rgb,
	[ColorSrgb] = Convert.to_oklch_from_srgb,
	[ColorHsl] = Convert.to_oklch_from_hsl,
	[ColorHsv] = Convert.to_oklch_from_hsv,
	[ColorHwb] = Convert.to_oklch_from_hwb,
	[ColorLab] = Convert.to_oklch_from_lab,
	[ColorLch] = Convert.to_oklch_from_lch,
	[ColorOklab] = Convert.to_oklch_from_oklab,
	[ColorOklch] = to_oklch_from_oklch,
}

---Creates and returns a new ColorOklch instance by converting from whatever color space was provided.
---@param color Hndy.Color.Any
---@return Hndy.Color.Oklch
function Convert.to_oklch(color)
	local convert = ConvertToOklch[getmetatable(color)]
	if convert == nil then error("Color object was not a recognized color type.") end
	return convert(color)
end

return Convert
