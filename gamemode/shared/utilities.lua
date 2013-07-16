--[[---------------------------------------------------------
Shared/uTilities.lua

 - Utilities
---------------------------------------------------------]]--

-- The minimal number of bits to encode with to reach said number
function min_bits(num)
	return math.ceil(math.log(math.abs(num) + 1)/math.log(2)) + 1
end

-- Merges a weapon table, safely:
function tmerge(into, from)
	if not into then return end
	
	for k, v in pairs(from) do
		if type(v) == "table" then
			into[k] = tmerge(into[k], v)
		else
			into[k] = v
		end
	end
	
	return into
end

-- returns a number that is moved partially towards another number:
function number_moveto(start, aim, move)
	if start ~= aim then
		if start < aim then
			start = start + move
			if start > aim then
				start = aim
			end
		else
			start = start - move
			if start < aim then
				start = aim
			end
		end
	end
	
	return start
end
