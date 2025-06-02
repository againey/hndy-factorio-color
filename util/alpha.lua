local Arithmetic = require("__hndy-color__.util.arithmetic")
local lerp = Arithmetic.lerp

local Alpha = {}

---@param source_component number
---@param target_component number
---@param source_alpha number
---@param target_alpha number
---@param t number
---@return number, number
function Alpha.interpolate_component(source_component, target_component, source_alpha, target_alpha, t)
	local interpolated_alpha = lerp(source_alpha, target_alpha, t)
	if interpolated_alpha ~= 0.0 then
		local interpolated_component = lerp(source_component * source_alpha, target_component * target_alpha, t) / interpolated_alpha
		return interpolated_component, interpolated_alpha
	else
		local interpolated_component = lerp(source_component, target_component, t)
		return interpolated_component, interpolated_alpha
	end
end

---@param source_component_1 number
---@param target_component_1 number
---@param source_component_2 number
---@param target_component_2 number
---@param source_alpha number
---@param target_alpha number
---@param t number
---@return number, number, number
function Alpha.interpolate_two_components(source_component_1, target_component_1, source_component_2, target_component_2, source_alpha, target_alpha, t)
	local interpolated_alpha = lerp(source_alpha, target_alpha, t)
	if interpolated_alpha ~= 0.0 then
		local interpolated_component_1 = lerp(source_component_1 * source_alpha, target_component_1 * target_alpha, t) / interpolated_alpha
		local interpolated_component_2 = lerp(source_component_2 * source_alpha, target_component_2 * target_alpha, t) / interpolated_alpha
		return interpolated_component_1, interpolated_component_2, interpolated_alpha
	else
		local interpolated_component_1 = lerp(source_component_1, target_component_1, t)
		local interpolated_component_2 = lerp(source_component_2, target_component_2, t)
		return interpolated_component_1, interpolated_component_2, interpolated_alpha
	end
end

---@param source_component_1 number
---@param target_component_1 number
---@param source_component_2 number
---@param target_component_2 number
---@param source_component_3 number
---@param target_component_3 number
---@param source_alpha number
---@param target_alpha number
---@param t number
---@return number, number, number, number
function Alpha.interpolate_three_components(source_component_1, target_component_1, source_component_2, target_component_2, source_component_3, target_component_3, source_alpha, target_alpha, t)
	local interpolated_alpha = lerp(source_alpha, target_alpha, t)
	if interpolated_alpha ~= 0.0 then
		local interpolated_component_1 = lerp(source_component_1 * source_alpha, target_component_1 * target_alpha, t) / interpolated_alpha
		local interpolated_component_2 = lerp(source_component_2 * source_alpha, target_component_2 * target_alpha, t) / interpolated_alpha
		local interpolated_component_3 = lerp(source_component_3 * source_alpha, target_component_3 * target_alpha, t) / interpolated_alpha
		return interpolated_component_1, interpolated_component_2, interpolated_component_3, interpolated_alpha
	else
		local interpolated_component_1 = lerp(source_component_1, target_component_1, t)
		local interpolated_component_2 = lerp(source_component_2, target_component_2, t)
		local interpolated_component_3 = lerp(source_component_3, target_component_3, t)
		return interpolated_component_1, interpolated_component_2, interpolated_component_3, interpolated_alpha
	end
end

return Alpha
