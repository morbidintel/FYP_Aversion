function printTable(s, l, i) -- recursive Print (structure, limit, indent)

	l = (l) or 5
	i = i or ""	-- default item limit, indent string

	if (l<1) then
		print "Item limit reached."
		return l-1
	end

	local ts = type(s)

	if ts ~= "table" then
		print(i, ts, s)
		return l + 1
	else
		print (i .. tostring(s))		   -- print "table"
	end

	for k,v in pairs(s) do  -- print "[KEY] VALUE"

		if tostring(k) == "__index" then

			print(i.."\t["..k.."]", ts, s)

		else

			l = printTable(v, l-1, i.."["..k.."]\t")

			if (l < 0) then break end

		end

	end

	return l

end

function clone(t, target) -- deep-copy a table

	if type(t) ~= "table" then return t end

	local meta = getmetatable(t)

	target = target or {}

	for k, v in pairs(t) do

		if type(v) == "table" and k ~= "__index" then
			target[k] = clone(v)
		else
			target[k] = v
		end

	end

	setmetatable(target, meta)

	return target
 
end

function copy(t, target) -- shallow-copy a table

	if type(t) ~= "table" then return t end

	local meta = getmetatable(t)
	target = target or {}

	for k, v in pairs(t) do target[k] = v end

	setmetatable(target, meta)

	return target

end

-- Merges two tables and returns the result
function mergeTable(t1, t2)

	local tempTable = {}

	tempTable = clone(t1, tempTable)
	tempTable = clone(t2, tempTable)

	return tempTable

end

-- Create a table with unmodifiable values
-- Values in a table inside of a const_table are modifiable
-- Returns the table created
function const_table(table)

	return setmetatable(
		{},
		{
			__index = table,
			__newindex = 
				function(table, key, value)
					error("Attempt to modify read-only table")
				end,
			__metatable = false
		}
	);

end

-- Recursively compare two tables
-- Optionally, pass in a compare function
-- Returns false if any of the values or values in nested tables
-- are not matching either in name or in value
-- t = O(n)
function compareTable(t1, t2, compFunc)

	if type(t1) ~= "table" or type(t2) ~= "table" then
		-- both are not tables

		print("compareTable : invalid parameter(s)")
		return false

	elseif t1 == t2 then

		compFunc = compFunc or function(t1,t2) return t1 == t2 end

		-- loop through one table
		for k,v in pairs(t1) do

			-- We're gonna compare t1[k] with t2[k]

			if k ~= "__index" then
				-- metatable ignore __index
			
				if type(v) == "table" then
					-- ok they're tables

					if	type(t2[k]) ~= "table" and		-- make sure both are tables
						v ~= t2[k] and					-- if they don't have the same address
						not compareTable() then			-- we'll recursively check through their contents

						return false

					end

				elseif not t2[k] or compFunc(v,t2[k]) then		-- they're not tables, check if they're the same

					return false						-- ok not the same, the table doesn't match

				end

			end

		end

	end

	return true

end

-- Finds a value inside a table
-- Optionally, pass in a compare function
-- Ignores nested tables, matches table adresses instead
-- Ignores metatables
-- If value is found,
--		return true, <index of value>
-- Else if value not found
--		return false, 0
function findInTable(table, value, compFunc)

	if table == nil and value == nil then
		error("findInTable : invalid parameter(s)")
	end

	compFunc = compFunc or function(v1,v2) return v1 == v2 end

	for i,v in ipairs(table) do
		if compFunc(v,value) then
			return true, i
		end
	end

	return false, 0

end

-- Check if value is in a range
-- If value is between min and max, returns true
-- Else returns false
function isInRange(value, min, max)

	if value == nil and min == nil and max == nil then
		error("isInRange : invalid parameter(s)")
	end

	-- check the type of value
	local vType = type(value)
	
	-- if we have a table
	if vType == "table" then

		-- go through all the values in the table
		for k,v in pairs(value) do
			-- if one value is not in range, no need to check the rest
			if not isInRange(v,min,max) then return false end
		end

		-- all values are in range, return true
		return true

	elseif vType == "number" and type(min) == "number" and type(max) == "number" then
		-- make sure all the stuff we are checking are numbers

		return value > min and value < max

	end

	print("isInRange : invalid parameter(s)")
	return false -- "NaN"

end

-- Makes sure that a value stays in range
-- If value is less than min, value will be set to min
-- Else if value is more than man, value will be set to max
function clamp(value, min, max)

	if value == nil and min == nil and max == nil then
		error("clamp : invalid parameter(s)")
	end

	-- check the type of value
	local vType = type(value)
	
	-- if we have a table
	if vType == "table" then

		local table = value

		-- go through all the values in the table
		for k,v in pairs(table) do
			table[k] = clamp(v,min,max)
		end

		return table

	elseif vType == "number" and type(min) == "number" and type(max) == "number" then
		-- make sure all the stuff we are checking are numbers

		if value < min then
			print("clamp min", value, min)
			value = min
		elseif value > max then
			print("clamp max", value, max)
			value = max
		end

	else

		print("clamp : invalid parameter(s)")

	end

	return value

end

function clampMin(value, min) return clamp(value,min,value) end
function clampMax(value, max) return clamp(value,value,max) end