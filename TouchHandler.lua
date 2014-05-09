require("functions")

nilTouch = const_table{ id, name, phase, target, time, x, xStart, y, yStart }

local touchHandler =
{
	beganOn = "",			-- to check where the touch began on
	isMovingMap = false,	-- to check whether the player is looking around the map
	isZoomingMap = false,	-- to check whether the player is zooming in/out the map

	numTouches = 0,			-- to check for multitouches

	touches = {},			-- table of the touch events
--	activeTouch = {},		-- METATABLE VALUE, current touch that is moving
--	lastActiveTouch = {},	-- METATABLE VALUE, last touch that has moved, must be different from activeTouch
--	lastEndedTouch = {},	-- METATABLE VALUE, last touch that has ended

	prevZoomDist = 0,		-- the previous zoom distance

	bMoveMapFast = false,	-- for looking around the map super fast, for debug only
}

----    Table functions    ----

-- Reset some variables
function touchHandler:reset()
	self.beganOn = ""
	self.isMovingMap = false

	if self.numTouches < 2 then
		self.prevZoomDist = 0
		self.isZoomingMap = false
	end
end

function touchHandler.compareTouch(t1, t2)
	return t1 and t2 and t1.id == t2.id
end

-- metatable for touch
local touch_mt =
{
	--	__eq = function(self, other)
	--		return self.id == other.id
	--	end,

	__tostring = function(self)
		return tostring(self.id)
	end
}

-- Add a new touch the the touches array
-- returns t
function touchHandler:addTouch(t)

	if t == nil then error("touchHandler:addTouch : t is nil") end

	table.insert( self.touches, t )

	self.numTouches = #self.touches

	touchHandler.activeTouch = t

	return setmetatable(t, touch_mt)
end

-- Remove a touch from the touches array
-- Also removes its metatable
-- found is an optional parameter
-- returns t
function touchHandler:removeTouch(t, found)

	if t == nil then error("touchHandler:removeTouch : t is nil") end

	local hasFound = not not found

	if found == nil then
		hasFound, found = findInTable(self.touches, t, self.compareTouch)
	end

	if found > 0 then

		table.remove(self.touches, found)
		self.numTouches = #self.touches

		if self.compareTouch(self.activeTouch,t) then self.activeTouch = nilTouch end
		if self.compareTouch(self.lastActiveTouch,t) then self.lastActiveTouch = nilTouch end

		self.lastEndedTouch = t

	end

	setmetatable(t, nil)

end

function touchHandler:updateTouch(t)

	if t == nil then error("touchHander:updateTouch : t is nil") end

	local isFound, found = findInTable(self.touches, t, self.compareTouch)

	if not isFound then -- notFound, add to touches

		return self:addTouch(t)

	elseif t.phase == "moved" then -- update touch

		setmetatable(self.touches[found], nil)

		self.touches[found] = t
		setmetatable(t, touch_mt)
		self.activeTouch = t

		return t

	elseif t.phase == "ended" or t.phase == "cancelled" then -- remove touch

		return self:removeTouch(t, found)

	end

end

-- Calculate distance between two touches
function touchHandler.distBetween(t1,t2)
	if t1 == nil or t2 == nil then
		return 0
	end

	local xSquared = (t1.x - t2.x) ^ 2
	local ySquared = (t1.y - t2.y) ^ 2

	return math.sqrt( xSquared + ySquared )
end

----    Metatable    ----

local mt = { activeTouch = nilTouch, lastActiveTouch = nilTouch, lastEndedTouch = nilTouch }

function mt:__index(key)

	if key == "activeTouch" or key == "lastActiveTouch" or key == "lastEndedTouch" then
		return mt[key]
	end

	return table[key]

end

function mt:__newindex(key, value)

	if key == "activeTouch" then

		if value == nil then
			-- removing activeTouch, push lastActive to active
			mt.activeTouch = mt.lastActiveTouch
			mt.lastActiveTouch = nilTouch
			return
		elseif not touchHandler.compareTouch(value, mt.activeTouch) then
			-- incoming touch is from different finger
			-- push current active touch to lastActive			
			mt.lastActiveTouch = mt.activeTouch
		--	else
		end

		-- set incoming touch as active
		mt.activeTouch = value

	elseif key == "lastActiveTouch" then

		mt.lastActiveTouch = value

	elseif key == "lastEndedTouch" then

		mt.lastEndedTouch = value

	else

		table[key] = value

	end

end

return setmetatable( touchHandler, mt )