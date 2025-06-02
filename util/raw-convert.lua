local Arithmetic = require("__hndy-color__.util.arithmetic")
local modulo = Arithmetic.modulo
local min = math.min
local max = math.max
local pow = math.pow

local unit_hue_60 = 60.0 / 360.0;
local unit_hue_120 = 120.0 / 360.0;
local unit_hue_180 = 180.0 / 360.0;
local unit_hue_240 = 240.0 / 360.0;

local function hue_to_component(p, q, t)
	if t >= 1.0 then t = t - 1.0 end
	if t < unit_hue_60 then return p + (q - p) * t / unit_hue_60 end
	if t < unit_hue_180 then return q end
	if t < unit_hue_240 then return p + (q - p) * (4.0 - t / unit_hue_60) end
	return p;
end

local function adjust_srgb_compontent_to_rgb(c)
	if c > 0.04045 then
		return pow((c + 0.055) / 1.055, 2.4)
	else
		return c / 12.92
	end
end

local function adjust_rgb_compontent_to_srgb(c)
	if c > 0.0031308 then
		return 1.055 * pow(c, 1.0 / 2.4) - 0.055
	else
		return 12.92 * c
	end
end

------------------------
-- Direct Conversions --
------------------------

--------------
-- from_rgb --
--------------

---@param red number
---@param green number
---@param blue number
---@return number, number, number
local function to_srgb_from_rgb(red, green, blue)
	return
		adjust_rgb_compontent_to_srgb(red),
		adjust_rgb_compontent_to_srgb(green),
		adjust_rgb_compontent_to_srgb(blue)
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
local function to_lab_from_rgb(red, green, blue)
	-- Based on https://www.w3.org/TR/css-color-4/#color-conversion-code
	-- Uses the following steps:
	-- * lin_sRGB_to_XYZ()
	-- * D65_to_D50()
	-- * XYZ_to_Lab()

	local x1 = red * 0.4123908 + green * 0.3575843 + blue * 0.1804808
	local y1 = red * 0.2126390 + green * 0.7151687 + blue * 0.0721923
	local z1 = red * 0.0193308 + green * 0.1191948 + blue * 0.9505321

	local x2 = x1 * 1.047930 + y1 * 0.02294679 + z1 * -0.05019223
	local y2 = x1 * 0.02962782 + y1 * 0.9904345 + z1 * -0.01707383
	local z2 = x1 * -0.009243058 + y1 * 0.01505514 + z1 * 0.7518743

	local x3 = x2 / 0.96429567642956764295676429567643
	local y3 = y2
	local z3 = z2 / 0.82510460251046025104602510460251

	local f0 = (x3 > 0.008856452) and pow(x3, 0.333333333333333333) or (x3 * 903.2963 + 16.0) / 116.0
	local f1 = (y3 > 0.008856452) and pow(y3, 0.333333333333333333) or (y3 * 903.2963 + 16.0) / 116.0
	local f2 = (z3 > 0.008856452) and pow(z3, 0.333333333333333333) or (z3 * 903.2963 + 16.0) / 116.0

	local green_red = (f0 - f1) * 4.0
	local blue_yellow = (f1 - f2) * 1.6

	local lightness = (f1 * 116.0 - 16.0) / 100.0

	return lightness, green_red, blue_yellow
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
local function to_oklab_from_rgb(red, green, blue)
	local l = math.pow(0.4122214708 * red + 0.5363325363 * green + 0.0514459929 * blue, 0.333333333333333333)
	local m = math.pow(0.2119034982 * red + 0.6806995451 * green + 0.1073969566 * blue, 0.333333333333333333)
	local s = math.pow(0.0883024619 * red + 0.2817188376 * green + 0.6299787005 * blue, 0.333333333333333333)

	local lightness = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
	local green_red = (1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s) * 2.5
	local blue_yellow = (0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s) * 2.5

	return lightness, green_red, blue_yellow
end

---------------
-- from_srgb --
---------------

---@param red number
---@param green number
---@param blue number
---@return number, number, number
local function to_rgb_from_srgb(red, green, blue)
	return
		adjust_srgb_compontent_to_rgb(red),
		adjust_srgb_compontent_to_rgb(green),
		adjust_srgb_compontent_to_rgb(blue)
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
local function to_hsl_from_srgb(red, green, blue)
	local min = min(red, green, blue)
	local max = max(red, green, blue)
	local twice_average = max + min

	local lightness = twice_average * 0.5

	if min == max then return 0.0, 0.0, lightness end

	local diff = max - min
	local saturation
	if lightness > 0.5 then
		saturation = diff / (2.0 - twice_average)
	else
		saturation = diff / twice_average
	end

	local hue
	if max == red then
		hue = (green - blue) / (diff * 6.0)
		if green < blue then
			hue = hue + 1.0
		end
	elseif max == blue then
		hue = (blue - red) / (diff * 6.0)
	else
		hue = (red - green) / (diff * 6.0)
	end

	return hue, saturation, lightness
end

--------------
-- from_hsl --
--------------

---@param hue number
---@param saturation number
---@param lightness number
---@return number, number, number
local function to_srgb_from_hsl(hue, saturation, lightness)
	--[[
	if saturation == 0.0 then
		return lightness, lightness, lightness
	end

	local n = lightness * saturation
	local q
	if lightness < 0.5 then
		q = lightness + n
	else
		q = lightness + saturation - n
	end
	local p = 2.0 * lightness - q

	hue = modulo(hue, 1.0)
	local red = hue_to_component(p, q, hue + unit_hue_120)
	local green = hue_to_component(p, q, hue)
	local blue = hue_to_component(p, q, hue + unit_hue_240)

	return red, green, blue
	]]

	local hue12 = hue * 12
	local a = saturation * min(lightness, 1.0 - lightness)

	local red_k = modulo(hue12, 12)
	local green_k = modulo(8 + hue12, 12)
	local blue_k = modulo(4 + hue12, 12)

	local red = lightness - a * max(-1.0, min(red_k - 3, 9 - red_k, 1))
	local green = lightness - a * max(-1.0, min(green_k - 3, 9 - green_k, 1))
	local blue = lightness - a * max(-1.0, min(blue_k - 3, 9 - blue_k, 1))

	return red, green, blue
	--[[
	    function f(n) {
        let k = (n + hue/30) % 12;
        let a = sat * Math.min(light, 1 - light);
        return light - a * Math.max(-1, Math.min(k - 3, 9 - k, 1));
    }

    return [f(0), f(8), f(4)];
	]]
end

---@param hue number
---@param saturation number
---@param lightness number
---@return number, number, number
local function to_hsv_from_hsl(hue, saturation, lightness)
	local value = lightness + saturation * min(lightness, 1.0 - lightness)
	if value ~= 0.0 then
		saturation = 2.0 * (1.0 - lightness / value)
	else
		saturation = 0.0
	end

	return hue, saturation, value
end

--------------
-- from_hsv --
--------------

---@param hue number
---@param saturation number
---@param value number
---@return number, number, number
local function to_hsl_from_hsv(hue, saturation, value)
	local lightness = value * (1.0 - saturation / 2.0)

	if lightness == 0.0 or lightness == 1.0 or lightness == value then
		return hue, 0.0, lightness
	end

	saturation = (value - lightness) / min(lightness, 1.0 - lightness)

	return hue, saturation, lightness
end

---@param hue number
---@param saturation number
---@param value number
---@return number, number, number
local function to_hwb_from_hsv(hue, saturation, value)
	local whiteness = (1.0 - saturation) * value
	local blackness = 1.0 - value
	return hue, whiteness, blackness
end

--------------
-- from_hwb --
--------------

---@param hue number
---@param whiteness number
---@param blackness number
---@return number, number, number
local function to_hsv_from_hwb(hue, whiteness, blackness)
	local value = 1.0 - blackness
	local saturation = 1.0 - whiteness / value
	return hue, saturation, value
end

--------------
-- from_lab --
--------------

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
local function to_rgb_from_lab(lightness, green_red, blue_yellow)
	-- Based on https://www.w3.org/TR/css-color-4/#color-conversion-code
	-- Uses the following steps:
	-- * Lab_to_XYZ
	-- * D50_to_D65
	-- * XYZ_to_lin_sRGB

	local f1 = (lightness * 100.0 + 16.0) / 116.0
	local f0 = green_red * 0.25 + f1
	local f2 = f1 - blue_yellow * 0.625

	local x3 = (f0 > 0.2068966) and (f0 * f0 * f0) or ((f0 * 116.0 - 16.0) / 903.2963)
	local y3 = (f1 > 0.2068966) and (f1 * f1 * f1) or ((f1 * 116.0 - 16.0) / 903.2963)
	local z3 = (f2 > 0.2068966) and (f2 * f2 * f2) or ((f2 * 116.0 - 16.0) / 903.2963)

	local x2 = x3 * 0.96429567642956764295676429567643
	local y2 = y3
	local z2 = z3 * 0.82510460251046025104602510460251

	local x1 = x2 * 0.9554735 + y2 * -0.02309854 + z2 * 0.06325931
	local y1 = x2 * -0.02836971 + y2 * 1.009995 + z2 * 0.02104140
	local z1 = x2 * 0.01231400 + y2 * -0.02050770 + z2 * 1.330366

	local red = x1 * 3.240970 + y1 * -1.537383 + z1 * -0.4986108
	local green = x1 * -0.9692436 + y1 * 1.875968 + z1 * 0.04155506
	local blue = x1 * 0.05563008 + y1 * -0.2039770 + z1 * 1.056972

	return red, green, blue
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
local function to_lch_from_lab(lightness, green_red, blue_yellow)
	local chroma = math.sqrt(green_red * green_red + blue_yellow * blue_yellow) * 0.833333333333333333;
	local hue = math.atan2(blue_yellow, green_red) / (2.0 * math.pi);

	return lightness, chroma, (hue >= 0.0) and hue or hue + 1.0
end

--------------
-- from_lch --
--------------

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
local function to_lab_from_lch(lightness, chroma, hue)
	local hue_in_radians = hue * 2.0 * math.pi
	local green_red = chroma * 1.2 * math.cos(hue_in_radians)
	local blue_yellow = chroma * 1.2 * math.sin(hue_in_radians)

	return lightness, green_red, blue_yellow
end

----------------
-- from_oklab --
----------------

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
local function to_rgb_from_oklab(lightness, green_red, blue_yellow)
	local aStar = green_red / 2.5
	local bStar = blue_yellow / 2.5

	local l = math.pow(lightness + 0.3963377774 * aStar + 0.2158037573 * bStar, 3.0);
	local m = math.pow(lightness - 0.1055613458 * aStar - 0.0638541728 * bStar, 3.0);
	local s = math.pow(lightness - 0.0894841775 * aStar - 1.2914855480 * bStar, 3.0);

	local red = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
	local green = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
	local blue = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

	return red, green, blue
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
local function to_oklch_from_oklab(lightness, green_red, blue_yellow)
	local chroma = math.sqrt(green_red * green_red + blue_yellow * blue_yellow);
	local hue = math.atan2(blue_yellow, green_red) / (2.0 * math.pi);

	return lightness, chroma, (hue >= 0.0) and hue or hue + 1.0
end

----------------
-- from_oklch --
----------------

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
local function to_oklab_from_oklch(lightness, chroma, hue)
	local hue_in_radians = hue * 2.0 * math.pi
	local green_red = chroma * math.cos(hue_in_radians)
	local blue_yellow = chroma * math.sin(hue_in_radians)

	return lightness, green_red, blue_yellow
end

local RawConvert = {
	to_rgb_from_srgb = to_rgb_from_srgb,
	to_rgb_from_lab = to_rgb_from_lab,
	to_rgb_from_oklab = to_rgb_from_oklab,

	to_srgb_from_rgb = to_srgb_from_rgb,
	to_srgb_from_hsl = to_srgb_from_hsl,

	to_hsl_from_srgb = to_hsl_from_srgb,
	to_hsl_from_hsv = to_hsl_from_hsv,

	to_hsv_from_hsl = to_hsv_from_hsl,
	to_hsv_from_hwb = to_hsv_from_hwb,

	to_hwb_from_hsv = to_hwb_from_hsv,

	to_lab_from_rgb = to_lab_from_rgb,
	to_lab_from_lch = to_lab_from_lch,

	to_lch_from_lab = to_lch_from_lab,

	to_oklab_from_rgb = to_oklab_from_rgb,
	to_oklab_from_oklch = to_oklab_from_oklch,

	to_oklch_from_oklab = to_oklch_from_oklab,
}

--------------------------
-- Indirect Conversions --
--------------------------

--------------
-- from_rgb --
--------------

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_hsl_from_rgb(red, green, blue)
	return
		to_hsl_from_srgb(
			to_srgb_from_rgb(red, green, blue))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_hsv_from_rgb(red, green, blue)
	return
		to_hsv_from_hsl(
			to_hsl_from_srgb(
				to_srgb_from_rgb(red, green, blue)))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_hwb_from_rgb(red, green, blue)
	return
		to_hwb_from_hsv(
			to_hsv_from_hsl(
				to_hsl_from_srgb(
					to_srgb_from_rgb(red, green, blue))))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_lch_from_rgb(red, green, blue)
	return
		to_lch_from_lab(
			to_lab_from_rgb(red, green, blue))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_oklch_from_rgb(red, green, blue)
	return
		to_oklch_from_oklab(
			to_oklab_from_rgb(red, green, blue))
end

---------------
-- from_srgb --
---------------

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_hsv_from_srgb(red, green, blue)
	return
		to_hsv_from_hsl(
			to_hsl_from_srgb(red, green, blue))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_hwb_from_srgb(red, green, blue)
	return
		to_hwb_from_hsv(
			to_hsv_from_hsl(
				to_hsl_from_srgb(red, green, blue)))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_lab_from_srgb(red, green, blue)
	return
		to_lab_from_rgb(
			to_rgb_from_srgb(red, green, blue))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_lch_from_srgb(red, green, blue)
	return
		to_lch_from_lab(
			to_lab_from_rgb(
				to_rgb_from_srgb(red, green, blue)))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_oklab_from_srgb(red, green, blue)
	return
		to_oklab_from_rgb(
			to_rgb_from_srgb(red, green, blue))
end

---@param red number
---@param green number
---@param blue number
---@return number, number, number
function RawConvert.to_oklch_from_srgb(red, green, blue)
	return
		to_oklch_from_oklab(
			to_oklab_from_rgb(
				to_rgb_from_srgb(red, green, blue)))
end

--------------
-- from_hsl --
--------------

---@param hue number
---@param saturation number
---@param lightness number
---@return number, number, number
function RawConvert.to_rgb_from_hsl(hue, saturation, lightness)
	return
		to_rgb_from_srgb(
			to_srgb_from_hsl(hue, saturation, lightness))
end

---@param hue number
---@param saturation number
---@param lightness number
---@return number, number, number
function RawConvert.to_hwb_from_hsl(hue, saturation, lightness)
	return
		to_hwb_from_hsv(
			to_hsv_from_hsl(hue, saturation, lightness))
end

---@param hue number
---@param saturation number
---@param lightness number
---@return number, number, number
function RawConvert.to_lab_from_hsl(hue, saturation, lightness)
	return
		to_lab_from_rgb(
			to_rgb_from_srgb(
				to_srgb_from_hsl(hue, saturation, lightness)))
end

---@param hue number
---@param saturation number
---@param lightness number
---@return number, number, number
function RawConvert.to_lch_from_hsl(hue, saturation, lightness)
	return
		to_lch_from_lab(
			to_lab_from_rgb(
				to_rgb_from_srgb(
					to_srgb_from_hsl(hue, saturation, lightness))))
end

---@param hue number
---@param saturation number
---@param lightness number
---@return number, number, number
function RawConvert.to_oklab_from_hsl(hue, saturation, lightness)
	return
		to_oklab_from_rgb(
			to_rgb_from_srgb(
				to_srgb_from_hsl(hue, saturation, lightness)))
end

---@param hue number
---@param saturation number
---@param lightness number
---@return number, number, number
function RawConvert.to_oklch_from_hsl(hue, saturation, lightness)
	return
		to_oklch_from_oklab(
			to_oklab_from_rgb(
				to_rgb_from_srgb(
					to_srgb_from_hsl(hue, saturation, lightness))))
end

--------------
-- from_hsv --
--------------

---@param hue number
---@param saturation number
---@param value number
---@return number, number, number
function RawConvert.to_rgb_from_hsv(hue, saturation, value)
	return
		to_rgb_from_srgb(
			to_srgb_from_hsl(
				to_hsl_from_hsv(hue, saturation, value)))
end

---@param hue number
---@param saturation number
---@param value number
---@return number, number, number
function RawConvert.to_srgb_from_hsv(hue, saturation, value)
	return
		to_srgb_from_hsl(
			to_hsl_from_hsv(hue, saturation, value))
end

---@param hue number
---@param saturation number
---@param value number
---@return number, number, number
function RawConvert.to_lab_from_hsv(hue, saturation, value)
	return
		to_lab_from_rgb(
			to_rgb_from_srgb(
				to_srgb_from_hsl(
					to_hsl_from_hsv(hue, saturation, value))))
end

---@param hue number
---@param saturation number
---@param value number
---@return number, number, number
function RawConvert.to_lch_from_hsv(hue, saturation, value)
	return
		to_lch_from_lab(
			to_lab_from_rgb(
				to_rgb_from_srgb(
					to_srgb_from_hsl(
						to_hsl_from_hsv(hue, saturation, value)))))
end

---@param hue number
---@param saturation number
---@param value number
---@return number, number, number
function RawConvert.to_oklab_from_hsv(hue, saturation, value)
	return
		to_oklab_from_rgb(
			to_rgb_from_srgb(
				to_srgb_from_hsl(
					to_hsl_from_hsv(hue, saturation, value))))
end

---@param hue number
---@param saturation number
---@param value number
---@return number, number, number
function RawConvert.to_oklch_from_hsv(hue, saturation, value)
	return
		to_oklch_from_oklab(
			to_oklab_from_rgb(
				to_rgb_from_srgb(
					to_srgb_from_hsl(
						to_hsl_from_hsv(hue, saturation, value)))))
end

--------------
-- from_hwb --
--------------

---@param hue number
---@param whiteness number
---@param blackness number
---@return number, number, number
function RawConvert.to_rgb_from_hwb(hue, whiteness, blackness)
	return
		to_rgb_from_srgb(
			to_srgb_from_hsl(
				to_hsl_from_hsv(
					to_hsv_from_hwb(hue, whiteness, blackness))))
end

---@param hue number
---@param whiteness number
---@param blackness number
---@return number, number, number
function RawConvert.to_srgb_from_hwb(hue, whiteness, blackness)
	return
		to_srgb_from_hsl(
			to_hsl_from_hsv(
				to_hsv_from_hwb(hue, whiteness, blackness)))
end

---@param hue number
---@param whiteness number
---@param blackness number
---@return number, number, number
function RawConvert.to_hsl_from_hwb(hue, whiteness, blackness)
	return
		to_hsl_from_hsv(
			to_hsv_from_hwb(hue, whiteness, blackness))
end

---@param hue number
---@param whiteness number
---@param blackness number
---@return number, number, number
function RawConvert.to_lab_from_hwb(hue, whiteness, blackness)
	return
		to_lab_from_rgb(
			to_rgb_from_srgb(
				to_srgb_from_hsl(
					to_hsl_from_hsv(
						to_hsv_from_hwb(hue, whiteness, blackness)))))
end

---@param hue number
---@param whiteness number
---@param blackness number
---@return number, number, number
function RawConvert.to_lch_from_hwb(hue, whiteness, blackness)
	return
		to_lch_from_lab(
			to_lab_from_rgb(
				to_rgb_from_srgb(
					to_srgb_from_hsl(
						to_hsl_from_hsv(
							to_hsv_from_hwb(hue, whiteness, blackness))))))
end

---@param hue number
---@param whiteness number
---@param blackness number
---@return number, number, number
function RawConvert.to_oklab_from_hwb(hue, whiteness, blackness)
	return
		to_oklab_from_rgb(
			to_rgb_from_srgb(
				to_srgb_from_hsl(
					to_hsl_from_hsv(
						to_hsv_from_hwb(hue, whiteness, blackness)))))
end

---@param hue number
---@param whiteness number
---@param blackness number
---@return number, number, number
function RawConvert.to_oklch_from_hwb(hue, whiteness, blackness)
	return
		to_oklch_from_oklab(
			to_oklab_from_rgb(
				to_rgb_from_srgb(
					to_srgb_from_hsl(
					to_hsl_from_hsv(
							to_hsv_from_hwb(hue, whiteness, blackness))))))
end

--------------
-- from_lab --
--------------

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_srgb_from_lab(lightness, green_red, blue_yellow)
	return
		to_srgb_from_rgb(
			to_rgb_from_lab(lightness, green_red, blue_yellow))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_hsl_from_lab(lightness, green_red, blue_yellow)
	return
		to_hsl_from_srgb(
			to_srgb_from_rgb(
				to_rgb_from_lab(lightness, green_red, blue_yellow)))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_hsv_from_lab(lightness, green_red, blue_yellow)
	return
		to_hsv_from_hsl(
			to_hsl_from_srgb(
				to_srgb_from_rgb(
					to_rgb_from_lab(lightness, green_red, blue_yellow))))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_hwb_from_lab(lightness, green_red, blue_yellow)
	return
		to_hwb_from_hsv(
			to_hsv_from_hsl(
				to_hsl_from_srgb(
					to_srgb_from_rgb(
						to_rgb_from_lab(lightness, green_red, blue_yellow)))))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_oklab_from_lab(lightness, green_red, blue_yellow)
	return
		to_oklab_from_rgb(
			to_rgb_from_lab(lightness, green_red, blue_yellow))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_oklch_from_lab(lightness, green_red, blue_yellow)
	return
		to_oklch_from_oklab(
			to_oklab_from_rgb(
				to_rgb_from_lab(lightness, green_red, blue_yellow)))
end

--------------
-- from_lch --
--------------

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_rgb_from_lch(lightness, chroma, hue)
	return
		to_rgb_from_lab(
			to_lab_from_lch(lightness, chroma, hue))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_srgb_from_lch(lightness, chroma, hue)
	return
		to_srgb_from_rgb(
			to_rgb_from_lab(
				to_lab_from_lch(lightness, chroma, hue)))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_hsl_from_lch(lightness, chroma, hue)
	return
		to_hsl_from_srgb(
			to_srgb_from_rgb(
				to_rgb_from_lab(
					to_lab_from_lch(lightness, chroma, hue))))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_hsv_from_lch(lightness, chroma, hue)
	return
		to_hsv_from_hsl(
			to_hsl_from_srgb(
				to_srgb_from_rgb(
					to_rgb_from_lab(
						to_lab_from_lch(lightness, chroma, hue)))))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_hwb_from_lch(lightness, chroma, hue)
	return
		to_hsv_from_hwb(
			to_hsv_from_hsl(
				to_hsl_from_srgb(
					to_srgb_from_rgb(
						to_rgb_from_lab(
							to_lab_from_lch(lightness, chroma, hue))))))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_oklab_from_lch(lightness, chroma, hue)
	return
		to_oklab_from_rgb(
			to_rgb_from_lab(
				to_lab_from_lch(lightness, chroma, hue)))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_oklch_from_lch(lightness, chroma, hue)
	return
		to_oklch_from_oklab(
			to_oklab_from_rgb(
				to_rgb_from_lab(
					to_lab_from_lch(lightness, chroma, hue))))
end

----------------
-- from_oklab --
----------------

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_srgb_from_oklab(lightness, green_red, blue_yellow)
	return
		to_srgb_from_rgb(
			to_rgb_from_oklab(lightness, green_red, blue_yellow))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_hsl_from_oklab(lightness, green_red, blue_yellow)
	return
		to_hsl_from_srgb(
			to_srgb_from_rgb(
				to_rgb_from_oklab(lightness, green_red, blue_yellow)))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_hsv_from_oklab(lightness, green_red, blue_yellow)
	return
		to_hsv_from_hsl(
			to_hsl_from_srgb(
				to_srgb_from_rgb(
					to_rgb_from_oklab(lightness, green_red, blue_yellow))))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_hwb_from_oklab(lightness, green_red, blue_yellow)
	return
		to_hwb_from_hsv(
			to_hsv_from_hsl(
				to_hsl_from_srgb(
					to_srgb_from_rgb(
						to_rgb_from_oklab(lightness, green_red, blue_yellow)))))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_lab_from_oklab(lightness, green_red, blue_yellow)
	return
		to_lab_from_rgb(
			to_rgb_from_oklab(lightness, green_red, blue_yellow))
end

---@param lightness number
---@param green_red number
---@param blue_yellow number
---@return number, number, number
function RawConvert.to_lch_from_oklab(lightness, green_red, blue_yellow)
	return
		to_lch_from_lab(
			to_lab_from_rgb(
				to_rgb_from_oklab(lightness, green_red, blue_yellow)))
end

----------------
-- from_oklch --
----------------

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_rgb_from_oklch(lightness, chroma, hue)
	return
		to_rgb_from_oklab(
			to_oklab_from_oklch(lightness, chroma, hue))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_srgb_from_oklch(lightness, chroma, hue)
	return
		to_srgb_from_rgb(
			to_rgb_from_oklab(
				to_oklab_from_oklch(lightness, chroma, hue)))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_hsl_from_oklch(lightness, chroma, hue)
	return
		to_hsl_from_srgb(
			to_srgb_from_rgb(
				to_rgb_from_oklab(
					to_oklab_from_oklch(lightness, chroma, hue))))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_hsv_from_oklch(lightness, chroma, hue)
	return
		to_hsv_from_hsl(
			to_hsl_from_srgb(
				to_srgb_from_rgb(
					to_rgb_from_oklab(
						to_oklab_from_oklch(lightness, chroma, hue)))))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_hwb_from_oklch(lightness, chroma, hue)
	return
		to_hsv_from_hwb(
			to_hsv_from_hsl(
				to_hsl_from_srgb(
					to_srgb_from_rgb(
						to_rgb_from_oklab(
							to_oklab_from_oklch(lightness, chroma, hue))))))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_lab_from_oklch(lightness, chroma, hue)
	return
		to_lab_from_rgb(
			to_rgb_from_oklab(
				to_oklab_from_oklch(lightness, chroma, hue)))
end

---@param lightness number
---@param chroma number
---@param hue number
---@return number, number, number
function RawConvert.to_lch_from_oklch(lightness, chroma, hue)
	return
		to_lch_from_lab(
			to_lab_from_rgb(
				to_rgb_from_oklab(
					to_oklab_from_oklch(lightness, chroma, hue))))
end

return RawConvert
