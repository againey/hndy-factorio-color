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

---Wraps n to \[0, range)
---
---Note that this is different from the built-in remainder operator % when n is negative.
---With the remainder operator, -n % range is equivalent to -(n % range), mirroring and negating the result when n is positive.
---This does not play nicely when we are treating the range as a standard portion of a repeating cycle, such as with circular hue values.
---Modulo works with both positive and negative n values to shift them either upward or downward by some integer multiple of range
---so that the result is within the standard range delimited by \[0, range).
---@param n number
---@param range number
---@return number
function Arithmetic.modulo(n, range)
	return ((n % range) + range) % range
end

---Linearly interpolates from source to target by the porportion t.
---@param source number
---@param target number
---@param t number
---@return number
function Arithmetic.lerp(source, target, t)
	return (target - source) * t + source
end

---Scale a floating point value presumed to be in the range \[0, 1\] such that the result is an integer in the range \[0, max\].
---@param value number
---@param max integer
---@return integer
function Arithmetic.scale_to_integer_from_unit(value, max)
	return math_min(floor(value * (max + 1.0)), max)
end

---Scale an integer presumed to be in the range \[0, max\] such that the result is a floating point value in the range \[0, 1\].
---@param value integer
---@param max integer
---@return number
function Arithmetic.scale_to_unit_from_integer(value, max)
	return value / max
end

---Scale a floating point value presumed to be in the range \[-1, +1\] such that the result is an integer in the range \[-max, +max\].
---@param value number
---@param max integer
---@return number
function Arithmetic.scale_to_integer_from_signed_unit(value, max)
	return clamp(trunc(value * (max + 1.0)), -max, max)
end

---Scale an integer presumed to be in the range \[-max, +max\] such that the result is a floating point value in the range \[-1, +1\].
---@param value integer
---@param max integer
---@return number
function Arithmetic.scale_to_signed_unit_from_integer(value, max)
	return value / max
end

return Arithmetic
