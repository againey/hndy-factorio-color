local Arithmetic = require("__hndy-color__.util.arithmetic")
local modulo = Arithmetic.modulo
local lerp = Arithmetic.lerp
local round = Arithmetic.round

local Hue = {}

---@param hue number
---@return number
function Hue.normalize(hue)
	return modulo(hue, 1.0)
end

---@param source_hue number
---@param target_hue number
---@param t number
---@return number
function Hue.interpolate_linear(source_hue, target_hue, t)
	return modulo(lerp(source_hue, target_hue, t), 1.0);
end

---@param source_hue number
---@param target_hue number
---@param t number
---@return number
function Hue.interpolate_shorter(source_hue, target_hue, t)
	if modulo(target_hue - source_hue, 1.0) <= modulo(source_hue - target_hue, 1.0) then
		return Hue.interpolate_increasing(source_hue, target_hue, t)
	else
		return Hue.interpolate_decreasing(source_hue, target_hue, t)
	end
end

---@param source_hue number
---@param target_hue number
---@param t number
---@return number
function Hue.interpolate_longer(source_hue, target_hue, t)
	if modulo(target_hue - source_hue, 1.0) > modulo(source_hue - target_hue, 1.0) then
		return Hue.interpolate_increasing(source_hue, target_hue, t)
	else
		return Hue.interpolate_decreasing(source_hue, target_hue, t)
	end
end

---@param source_hue number
---@param target_hue number
---@param t number
---@return number
function Hue.interpolate_increasing(source_hue, target_hue, t)
	if target_hue >= source_hue then
		return lerp(source_hue, target_hue, t)
	else
		return lerp(source_hue, target_hue + 1.0, t)
	end
end

---@param source_hue number
---@param target_hue number
---@param t number
---@return number
function Hue.interpolate_decreasing(source_hue, target_hue, t)
	if target_hue <= source_hue then
		return lerp(source_hue, target_hue, t)
	else
		return lerp(source_hue, target_hue - 1.0, t)
	end
end

---@param hue number
---@return integer
function Hue.to_integer_degrees(hue)
	return round(hue * 360.0)
end

---@param hue integer
---@return number
function Hue.from_integer_degrees(hue)
	return hue / 360.0
end

return Hue
