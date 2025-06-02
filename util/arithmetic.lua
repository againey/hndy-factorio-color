local math_min = math.min
local floor = math.floor
local ceil = math.ceil

local Arithmetic = {}

---@param value number
---@return number
function Arithmetic.trunc(value)
	return value >= 0.0 and floor(value) or ceil(value)
end
local trunc = Arithmetic.trunc

---@param value number
---@return number
function Arithmetic.round(value)
	return value >= 0.0 and floor(value + 0.5) or ceil(value - 0.5)
end

---@param n number
---@param min number
---@param max number
---@return number
function Arithmetic.clamp(n, min, max)
	if n < min then return min end
	if n > max then return max end
	return n
end
local clamp = Arithmetic.clamp

---@param n number
---@param range number
---@return number
function Arithmetic.modulo(n, range)
	return ((n % range) + range) % range
end

---@param source number
---@param target number
---@param t number
---@return number
function Arithmetic.lerp(source, target, t)
	return (target - source) * t + source
end

---@param value number
---@param max integer
---@return integer
function Arithmetic.scale_to_integer_from_unit(value, max)
	return math_min(floor(value * (max + 1.0)), max)
end

---@param value integer
---@param max integer
---@return number
function Arithmetic.scale_to_unit_from_integer(value, max)
	return value / max
end

---@param value number
---@param max integer
---@return number
function Arithmetic.scale_to_integer_from_signed_unit(value, max)
	return clamp(trunc(value * (max + 1.0)), -max, max)
end

---@param value integer
---@param max integer
---@return number
function Arithmetic.scale_to_signed_unit_from_integer(value, max)
	return value / max
end

return Arithmetic
