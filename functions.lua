function printTable(s, l, i) -- recursive Print (structure, limit, indent)

	l = (l) or 50
	i = i or ""	-- default item limit, indent string

	if (l<1) then
		print "Item limit reached."
		return l-1
	end

	local ts = type(s)

	if ts ~= "table" then
		print(i, ts, s)
		return l - 1
	end

	print (i .. ts)		   -- print "table"

	for k,v in pairs(s) do  -- print "[KEY] VALUE"

		if tostring(k) == "__index" then

			print(i.."["..tostring(k).."]\t", ts, s)

		else

			l = printTable(v, l, i.."["..tostring(k).."]\t")

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

-- merges two tables and returns the result
function mergeTable(t1, t2)

	local tempTable = {}

	tempTable = clone(t1, tempTable)
	tempTable = clone(t2, tempTable)

	return tempTable

end

-- create a table with unmodifiable values
-- values in a table inside of a const_table are modifiable
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

-- check if value is in a range
function isInRange(value, min, max)

	-- check the type of value
	local vType = type(value)

	if vType == "table" then
		-- if we have a table

		-- go through all the values in the table
		for k,v in pairs(value) do
			-- if one value is not in range, no need to check the rest
			if not isInRange(v,min,max) return false
		end

		-- all values are in range, return true
		return true

	elseif vType == "number" and type(min) == "number" and type(max) == "number" then
		-- make sure all the stuff we are checking are numbers

		return value > min and value < max

	else
		return false -- "NaN"
	end

end