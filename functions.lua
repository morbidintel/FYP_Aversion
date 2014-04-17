functions = {}

function functions.printTable(s, l, i) -- recursive Print (structure, limit, indent)

	l = (l) or 50
	i = i or ""	-- default item limit, indent string

	if (l<1) then
		print "ERROR: Item limit reached."
		return l-1
	end

	local ts = type(s)

	if (ts ~= "table") then
		print(i, ts, s)
		return l - 1
	end

	print (i .. ts)           -- print "table"

	for k,v in pairs(s) do  -- print "[KEY] VALUE"

		if tostring(k) == "__index" then

			print(i .. ts, s)

		else

			l = print_table(v, l, i.."["..tostring(k).."]\t")

			if (l < 0) then break end

		end

	end

	return l

end

function functions.mergeTable(t1, t2)

    for k,v in pairs(t2) do

    	if type(v) == "table" then

    		if type(t1[k] or false) == "table" then
    			tableMerge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end

    	else

    		t1[k] = v
    		
    	end

    end

    return t1

end

return functions