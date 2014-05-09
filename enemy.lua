-------------------------------------------------
--
-- enemy.lua
--
-- Example "enemy" class for Corona SDK tutorial.
--
-------------------------------------------------
 
local enemy = {}
local enemy_mt = { __index = enemy }	-- metatable

local pos_x, pos_y
--local aggro
--local att_cd
--local last_att

--local chaseSpeed
--local chaseDist
--local chasePos_x

local allSprites = {}
local sprite
local attackSprite

local theMap
local mapX, mapY

local screenWidth = display.contentWidth
local screenHeight = display.contentHeight
local xMultiplier = display.contentWidth/480
local yMultiplier = display.contentHeight/320

local CURRENT_STATE = 1
local STATE_PATROL = 1
local STATE_CHASING = 2
local STATE_ATTACKING = 3
local STATE_EXPLODING = 4
--local STATE_RETURNING = 4

local DIRECTION_LEFT = -1
local DIRECTION_RIGHT = 1

local BULLET_DIRECTION = 0
--local BULLET_DIRECTION_LEFT = -1
--local BULLET_DIRECTION_RIGHT = 1
local BULLET_DIRECTION_UP = 2

local bullets = {}
local sprays = {}
local booms = {}

--local playerHealth = 5
local playerMaxHealth = 6--5


-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

local runtime = 0

local function getDeltaTime()
   local temp = system.getTimer()  --Get current game time in ms
   local dt = (temp-runtime) / (1000/30)  --60fps or 30fps as base
   runtime = temp  --Store game time
   return dt
end

local CannabisOptions = {
	width = 48,
	height = 48,
	numFrames = 35,
	sheetContentWidth = 1680,
	sheetContentHeight = 48
}
local CannabisSheet = graphics.newImageSheet( "Images/Characters/Cannabis/Cannabis_Sprite.png", CannabisOptions )
local CannabisSequenceData = {
		--{ name = "1", frames={ 1,2,3,4,5,6,7 }, time = 1000 },
		{ name = "1", frames={ 1,2,3,4 }, time = 1000 },
		{ name = "2", frames={ 5,6,7 }, time = 1000 },
		--{ name = "2", frames={ 8,9,10,11,12,13,14 }, time = 1000 },
		{ name = "3", frames={ 8,9,10,11 }, time = 1000 },
		{ name = "4", frames={ 12,13,14 }, time = 1000 },
		--{ name = "3", frames={ 15,16,17,18,19,20,21 }, time = 1000 },
		{ name = "5", frames={ 15,16,17,18 }, time = 1000 },
		{ name = "6", frames={ 19,20,21 }, time = 1000 },
		--{ name = "4", frames={ 22,23,24,25,26,27,28 }, time = 1000 },
		{ name = "7", frames={ 22,23,24,25 }, time = 1000 },
		{ name = "8", frames={ 26,27,28 }, time = 1000 },
		--{ name = "5", frames={ 29,30,31,32,33,34,35 }, time = 1000 }
		{ name = "9", frames={ 29,30,31,32 }, time = 1000 },
		{ name = "10", frames={ 33,34,35 }, time = 1000 }
}
function enemy.newCannabis( index, type, x, y, patrolDirection, patrolSpeed, patrolRadius, aggroRadius, chaseSpeed, chaseRad, map )

	theMap = map
	local layer = map.layer["Enemy"]
	
	local id = index
	local type = tonumber(type)
	local originalX = x
	local originalY = y
	local xpos = x
	local ypos = y
	local state = STATE_PATROL
	local direction = patrolDirection 
	local patrolSpeed = patrolSpeed
	local patrolRadius = patrolRadius
	local aggroRadius = aggroRadius
	local chaseSpeed = chaseSpeed
	local chaseRadius = chaseRad
	
	local isDead = false
	
	-- sprite
	
	--local 
	sprite = display.newSprite( layer, CannabisSheet, CannabisSequenceData )
	sprite.x = x
	sprite.y = y
	sprite.type = type
	--sprite:setSequence(currentFrame)
	sprite:play()
	sprite.id = index
	sprite.IsCannabis = true
	sprite.isDead = false
	sprite.isFixedRotation = true
	
	table.insert(allSprites, sprite)
	
	local newenemy = {
		
		originalX = originalX,
		originalY = originalY,
		xpos = xpos,
		ypos = ypos,
		id = id,
		type = type,
		state = state,
		direction = direction,
		patrolSpeed = patrolSpeed,
		patrolRadius = patrolRadius,
		aggroRadius = aggroRadius,
		chaseSpeed = chaseSpeed,
		chaseRadius = chaseRadius,
		
		isDead = isDead,
		
		movingUp = false,
		movingDown = false,
		
		sprite = sprite
		
	}
	
	return setmetatable( newenemy, enemy_mt )
end

local HeroinOptions = {
	width = 32,
	height = 96,
	numFrames = 35,
	sheetContentWidth =1120,
	sheetContentHeight = 96
}
local HeroinSheet = graphics.newImageSheet( "Images/Characters/Heroin/Heroin_Sprite.png", HeroinOptions )
local HeroinSequenceData = {
	{ name = "1", frames={ 1,2,3,4,5,6,7 }, time = 1050 },
	{ name = "2", frames={ 8,9,10,11,12,13,14 }, time = 1050 },
	{ name = "3", frames={ 15,16,17,18,19,20,21 }, time = 1050 },
	{ name = "4", frames={ 22,23,24,25,26,27,28 }, time = 1050 },
	{ name = "5", frames={ 29,30,31,32,33,34,35 }, time = 1050 }
}
function enemy.newHeroin(index, type, x, y, patrolDirection, patrolSpeed, patrolRadius, aggroRadius, attackSpeed, bulletSpeed, map)

	theMap = map
	local layer = map.layer["Enemy"]
	
	local id = index
	local type = type
	local originalX = x
	local originalY = y
	local xpos = x
	local ypos = y
	local state = STATE_PATROL
	local direction = patrolDirection
	local patrolSpeed = patrolSpeed
	local patrolRadius = patrolRadius
	local aggroRadius = aggroRadius
	local att_cd = attackSpeed
	local last_att = 0
	BULLET_DIRECTION_UP = bulletSpeed
	
	local isDead = false
	
	-- sprite
	
	--local 
	sprite = display.newSprite( layer, HeroinSheet, HeroinSequenceData )
	sprite.x = x
	sprite.y = y
	sprite.type = type
	--sprite:setSequence(currentFrame)
	sprite:play()
	sprite.id = index
	sprite.IsHeroin = true
	sprite.CanShoot = true -- new; later
	sprite.isDead = false
	sprite.isFixedRotation = true

	table.insert(allSprites, sprite)
	
	-- empty first
	for i=#bullets,1,-1 do
		table.remove(bullets, i)
	end
	
	local newenemy = {
		
		originalX = originalX,
		originalY = originalY,
		xpos = xpos,
		ypos = ypos,
		id = id,
		type = type,
		state = state,
		direction = direction,
		patrolSpeed = patrolSpeed,
		patrolRadius = patrolRadius,
		aggroRadius = aggroRadius,
		att_cd = attackSpeed,--2
		last_att = 0,
		
		isDead = isDead,
		
		movingUp = false,
		movingDown = false,

		sprite = sprite
		
		--sprite = display.newSprite( HeroinSheet, HeroinSequenceData )
		
	}
	
	return setmetatable( newenemy, enemy_mt )
end

local InhalantOptions = {
	width = 48,
	height = 48,
	numFrames = 55,
	sheetContentWidth = 2640,
	sheetContentHeight = 48
}
local InhalantSheet = graphics.newImageSheet( "Images/Characters/Inhalant/Inhalant_Sprite.png", InhalantOptions )
local InhalantSequenceData = {
	{ name = "1", frames={ 1,2,3,4,5 }, time = 500 },
	{ name = "2", frames={ 12,13,14,15,16 }, time = 500 },
	{ name = "3", frames={ 23,24,25,26,27 }, time = 500 },
	{ name = "4", frames={ 34,35,36,37,38 }, time = 500 },
	{ name = "5", frames={ 45,46,47,48,49 }, time = 500 },
	{ name = "6", frames={ 6,7,6,7,8,9,8,9,10,11 }, time = 750 },
	{ name = "7", frames={ 17,18,17,18,19,20,19,20,21,22 }, time = 750 },
	{ name = "8", frames={ 28,29,28,29,30,31,30,31,32,33 }, time = 750 },
	{ name = "9", frames={ 39,40,39,40,41,42,41,42,43,44 }, time = 750 },
	{ name = "10", frames={ 50,51,50,51,52,53,52,53,54,55 }, time = 750 },
}
function enemy.newInhalant( index, type, x, y, patrolDirection, patrolSpeed, patrolRadius, aggroRadius, attackSpeed, map )

	local layer = map.layer["Enemy"]

	local id = index
	local type = tonumber(type)
	local originalX = x
	local originalY = y
	local xpos = x
	local ypos = y
	local state = STATE_PATROL
	local direction = patrolDirection
	local patrolSpeed = patrolSpeed
	local patrolRadius = patrolRadius
	local aggroRadius = aggroRadius
	local last_att = 0
	local spray_dir = patrolDirection
	local b_sprayin = false
	local b_boomin = false
	
	local isDead = false
	
	-- sprite
	
	--local 
	sprite = display.newSprite( layer, InhalantSheet, InhalantSequenceData )
	sprite.x = x
	sprite.y = y
	sprite.type = type
	--sprite:setSequence(currentFrame)
	sprite:play()
	sprite.id = index
	sprite.IsInhalant = true
	sprite.isDead = false
	sprite.isFixedRotation = true
	
	table.insert(allSprites, sprite)
	
	local newenemy = {
		
		originalX = originalX,
		originalY = originalY,
		xpos = xpos,
		ypos = ypos,
		id = id,
		type = type,
		state = state,
		direction = direction,
		patrolSpeed = patrolSpeed,
		patrolRadius = patrolRadius,
		aggroRadius = aggroRadius,
		last_att = 0,
		spray_dir = patrolDirection,
		b_sprayin = false,
		b_boomin = false,
		
		isDead = isDead,
		
		movingUp = false,
		movingDown = false,

		sprite = sprite
		
		--sprite = display.newSprite( HeroinSheet, HeroinSequenceData )
		
	}
	
	return setmetatable( newenemy, enemy_mt )
end

local IceOptions =
{
	width = 48,
	height = 48,
	numFrames = 10,
	sheetContentWidth = 480,
	sheetContentHeight = 48
}
local IceSheet = graphics.newImageSheet("Images/Characters/Ice/Ice_Sprite.png",IceOptions )
local IceSequenceData =
{
	{ name = "1", frames={ 1,2 }, time = 500 },
	{ name = "2", frames={ 3,4 }, time = 500 },
	{ name = "3", frames={ 5,6 }, time = 500 },
	{ name = "4", frames={ 7,8 }, time = 500 },
	{ name = "5", frames={ 9,10 }, time = 500 }
}
function enemy.newIce(index, type, x, y, swingRadius, swingSpeed, map)

	--	local iceSprite = display.newSprite( IceSheet, sequenceData )
	--	iceSprite.anchorX, iceSprite.anchorY = 0.5, 0.5
	--	iceSprite.x, iceSprite.y = object.x, object.y
	--	iceSprite:setSequence(currentFrame)
	--	iceSprite:play()
	--	iceSprite.alpha = 1
	--	iceSprite.id = index

	--	iceSprite.isDead = false

	--	physics.addBody(iceSprite,{isSensor = true, radius = 18})

	--	sprite.isFixedRotation = true

	--	local temp = enemy.new( object.x, object.y, 
	--							tonumber(object.props.enemyType), 
	--							tonumber(object.props.patrolRadius), 
	--							tonumber(object.props.aggroRadius), index, 
	--							tonumber(object.props.patrolSpeed))	
	--	temp.id = index
	--	index = index + 1
	--	temp.isFixedRotation = true
	--	table.insert(enemyList, temp)

	theMap = map
	local layer = map.layer["Enemy"]

	sprite = display.newSprite( layer, IceSheet, IceSequenceData )
	sprite.x, sprite.y = x,y
	sprite.anchorX, sprite.anchorY = 0.5, 0.5
	sprite.type = type
	sprite.id = index
	sprite.IsIce = true
	sprite.isDead = false
	sprite.isFixedRotation = true
	sprite:play()

	table.insert(allSprites, sprite)

	local ice = 
	{
		id = index,
		type = tonumber(type),
		xpos = x,
		ypos = y,
		originalX = x,
		originalY = x,
		state = STATE_PATROL,
		swingRadius = swingRadius,
		swingSpeed = swingSpeed,

		sprite = sprite
	}

	return setmetatable( ice, enemy_mt )

end

function enemy:isChasing()
	if self.state == STATE_CHASING then
		return true
	else
		return false
	end
end

function enemy:getType()
	return self.type
end

function enemy:getId()
	return self.id
end

function enemy:setId( t )
	self.id = t
end

function enemy:setIsDead()

	self.isDead = true
	
end

function enemy:getIsDead()

	return self.isDead 
	
end

function enemy:getDirectionUp()
	return self.movingUp
end

function enemy:getDirectionDown()
	return self.movingDown
end

function enemy:getPositionX()
	return self.xpos
end

function enemy:getPositionY()
	return self.ypos
end

function enemy:UpdateCannabis( player, map, ii )
	if self.state == STATE_PATROL then
		-- left-right movement
		if self.xpos < self.originalX + self.patrolRadius and self.direction == DIRECTION_RIGHT then
			self.xpos = self.xpos + self.patrolSpeed-- * getDeltaTime()
			if self.xpos >= self.originalX + self.patrolRadius then
				self.direction = DIRECTION_LEFT
			end
		end
		
		if self.xpos > self.originalX - self.patrolRadius and self.direction == DIRECTION_LEFT then
			self.xpos = self.xpos - self.patrolSpeed-- * getDeltaTime()
			if self.xpos <= self.originalX - self.patrolRadius then
				self.direction = DIRECTION_RIGHT
			end
		end
		-- end of left-right movement
		
		if math.abs(self.ypos - player.y) <= 32 then -- hardcoded
			if math.abs(self.xpos - player.x) <= self.aggroRadius then
				if player.x >= math.abs(self.originalX - self.patrolRadius*2) and player.x <= math.abs(self.originalX + self.patrolRadius*2) then
					self.state = STATE_CHASING
					-- changin the animation
					for i = #allSprites, 1, -1 do
						if allSprites[i].id == ii then
							allSprites[i]:setSequence( (playerMaxHealth - player.playerHealth) * 2 )
							allSprites[i]:play()
							break
						end
					end
				end
			end
		end
		
	elseif self.state == STATE_CHASING then
		
		if (player.x - self.xpos) >= 0 then
			self.direction = DIRECTION_LEFT
		else
			self.direction = DIRECTION_RIGHT
		end
		
		self.xpos = self.xpos - ( self.chaseSpeed * self.direction )
		
		if math.abs(self.ypos - player.y) >= 32 or--then -- hardcoded
			--[[if]] math.abs(self.xpos - self.originalX) >= self.chaseRadius then
				self.state = STATE_PATROL
				-- changin the animation
				for i = #allSprites, 1, -1 do
					if allSprites[i].id == ii then
						allSprites[i]:setSequence( (playerMaxHealth - player.playerHealth) * 2 - 1 )
						allSprites[i]:play()
						break
					end
				end
			--end
		end
		
	else
		print("Error in UpdateCannabis()")
	end
end

local BulletOptions = {
	width = 16,
	height = 32,
	numFrames = 6,
	sheetContentWidth = 96,
	sheetContentHeight = 32
}
local BulletSheet = graphics.newImageSheet( "Images/Characters/Heroin/HeroinBullet_Sprite.png", BulletOptions )
local BulletSequenceData = {
	{ name = "1", frames={ 1,2,3,4,5,6 }, time = 250 }
}
function enemy:Shoot(inx, iny)
	--local bullet = display.newCircle(pos_x, pos_y, 5)
	local bullet = display.newSprite( theMap.layer["Enemy"], BulletSheet, BulletSequenceData )
	bullet.x = inx
	bullet.y = iny - 10
	bullet:setSequence(1)
	bullet:play()
	
	--bullet:setReferencePoint(display.CenterReferencePoint)
	
	-- new
	bullet.IsBullet = true
	bullet.dir = BULLET_DIRECTION_UP
	physics.addBody( bullet, "static", {isSensor = true} )
	
	table.insert(bullets, bullet)
	
	--return bullet
end

function enemy:UpdateHeroin( player, map, ii )
	if self.state == STATE_PATROL then
		-- left-right movement
		if self.xpos < self.originalX + self.patrolRadius and self.direction == DIRECTION_RIGHT then
			self.xpos = self.xpos + self.patrolSpeed-- * getDeltaTime()
			if self.xpos >= self.originalX + self.patrolRadius then
				self.direction = DIRECTION_LEFT
			end
		end
		
		if self.xpos > self.originalX - self.patrolRadius and self.direction == DIRECTION_LEFT then
			self.xpos = self.xpos - self.patrolSpeed-- * getDeltaTime()
			if self.xpos <= self.originalX - self.patrolRadius then
				self.direction = DIRECTION_RIGHT
			end
		end
		-- end of left-right movement
		
		-- shoot every x second
		local t = system.getTimer()/1000
		if  t - self.last_att >= 3--[[self.att_cd]] then
			self.last_att = t
			self.state = STATE_ATTACKING
		end
	elseif self.state == STATE_ATTACKING  and not self.isDead then
		enemy:Shoot(self.xpos, self.ypos)
		self.state = STATE_PATROL
	else
		print("Error in UpdateHeroin()")
	end
	
	-- bullet loop
	if bullets ~= nil then
		for i=#bullets,1,-1 do
			--bullets[i].x = bullets[i].x - bullets[i].dir*3
			bullets[i].y = bullets[i].y - bullets[i].dir*3
			
			-- hardcoded
			if bullets[i].y <= 0 then	-- out of screen
				display.remove(bullets[i])
				table.remove(bullets, i)
				--return
			end
		end
	end
	-- end of bullet loop
end

function enemy:UpdateIce( player, map, ii )

end

local SprayOptions = {
	width = 64,
	height = 32,
	numFrames = 7,
	sheetContentWidth =448,
	sheetContentHeight = 32
}
local SpraySheet = graphics.newImageSheet( "Images/Characters/Inhalant/InhalantAttack_Sprite.png", SprayOptions )
local SpraySequenceData = {
	{ name = "1", frames={ 1 }, time = 1000 },
	{ name = "2", frames={ 1,2,3,4,5,6,7 }, loopCount = 1, time = 1500 }
	--{ name = "2", start = 2, count = 6, loopCount = 1, time = 1000 },
}
function enemy:Spray(inx, iny, indir, ii, map)
	local spray
	spray = display.newSprite( map.layer["Enemy"], SpraySheet, SpraySequenceData )
	spray.x = inx + indir * 50
	spray.y = iny - 13
	spray.xScale = indir
	spray.by = ii		-- by who
	spray.IsSpray = true
	physics.addBody( spray, "static", {isSensor = true} )
	spray:setSequence(2)
	spray:play()
	
	table.insert(sprays, spray)
end

local BoomOptions = {
	width = 128,
	height = 128,
	numFrames = 8,
	sheetContentWidth =1024,
	sheetContentHeight = 128
}
local BoomSheet = graphics.newImageSheet( "Images/Characters/Inhalant/InhalantExplode_Sprite.png", BoomOptions )
local BoomSequenceData = {
	{ name = "1", frames={ 1,2,3,4,5,6,7 }, loopCount = 1, time = 2000 }
}
function enemy:Boom(inx, iny, ii)
	local boom
	boom = display.newSprite( theMap.layer["Enemy"], BoomSheet, BoomSequenceData )
	boom.x = inx
	boom.y = iny - 40
	boom.xScale = boom_dir
	boom.by = ii		-- by who
	boom.IsBoom = true
	physics.addBody( boom, "static", {isSensor = true} )
	boom:setSequence(1)
	boom:play()
	
	--boom:setReferencePoint(display.CenterReferencePoint)
	
	table.insert(booms, boom)
end

function enemy:UpdateInhalant( player, map, ii )
	if self.state == STATE_PATROL then
		-- left-right movement
		if self.xpos < self.originalX + self.patrolRadius and self.direction == DIRECTION_RIGHT then
			self.xpos = self.xpos + self.patrolSpeed-- * getDeltaTime()
			if self.xpos >= self.originalX + self.patrolRadius then
				self.direction = DIRECTION_LEFT
				self.spray_dir = DIRECTION_LEFT
			end
		end
		
		if self.xpos > self.originalX - self.patrolRadius and self.direction == DIRECTION_LEFT then
			self.xpos = self.xpos - self.patrolSpeed-- * getDeltaTime()
			if self.xpos <= self.originalX - self.patrolRadius then
				self.direction = DIRECTION_RIGHT
				self.spray_dir = DIRECTION_RIGHT
			end
		end
		-- end of left-right movement
		
		-- shoot every x second
		local t = system.getTimer()/1000
		if  t - self.last_att >= 3 then--att_cd thenB
			self.state = STATE_ATTACKING
			--b_sprayin = true
		end
	elseif self.state == STATE_ATTACKING then
		if self.b_sprayin == false then
			enemy:Spray(self.xpos, self.ypos, self.spray_dir, ii, map)
			self.b_sprayin = true
		end
		
		-- update
		--if #sprays >= 1 then
			for i = #sprays, 1, -1 do
				if sprays[i].by == ii then			-- this (temporarily)
					if sprays[i].frame == 7 then -- last frame
						display.remove(sprays[i])
						self.b_sprayin = false
						self.state = STATE_PATROL
						table.remove(sprays, i)
					end
				end
			end
		--end
		
		--if self.spray~=nil then
		--	if self.spray.frame == 7 then -- last frame
		--		--display.remove(self.spray)
		--		--spray = nil
		--		self.b_sprayin = false
		--		self.state = STATE_PATROL
		--	end
		--end
	elseif self.state == STATE_EXPLODING then
		if self.b_boomin == false then
			for i = #allSprites, 1, -1 do
				if allSprites[i].id == ii then
					allSprites[i]:setSequence(allSprites[i].sequence+5)
					allSprites[i]:play()
					self.b_boomin = true
				end
			end
		end
		
		for i = #allSprites, 1, -1 do
			if allSprites[i].id == ii then
				if allSprites[i].frame == 10 then			-- last frame
					-- remove the sprite
					local function listener(event)
						for i = #allSprites, 1, -1 do
							if allSprites[i].id == ii then
								display.remove(allSprites[i])
								table.remove(allSprites, i)
								break
							end
						end
					end
					timer.performWithDelay(500, listener)
					
					enemy:Boom(self.xpos, self.ypos, ii)
				end
			end
		end
		
		--if #booms >= 1 then
			for i = #booms, 1, -1 do
				if booms[i].frame == 7 then -- last frame
					display.remove(booms[i])
					self.b_sprayin = false
					table.remove(booms, i)
				end
			end
		--end
	else
		print("ERROR in Inhalant")
	end
	
	if self.b_boomin == false then
		-- hardcoded
		if math.abs(self.ypos - player.y) <= 32 then
			if math.abs(self.xpos - player.x) <= 64 then
				if self.b_sprayin == true then
					-- remove the remainin
					for i = #sprays, 1, -1 do
						if sprays[i].by == ii then
							display.remove(sprays[i])
						end
					end
				end
				
				self.state = STATE_EXPLODING
			end
		end
	end
end

function enemy:Update( player, map, ii, enemyType )
	
	if enemyType == 1 then
		self:UpdateCannabis( player, map, ii )
	elseif enemyType == 2 then
		self:UpdateHeroin( player, map, ii )
	elseif enemyType == 3 then
		self:UpdateInhalant( player, map, ii )
	elseif enemyType == 4 then
		self:UpdateIce( player, map, ii )
	else
		print("enemy:Update() : Inavlid Enemy Type")
	end

--	if not self.sprite then error( self.type ) end
	self.sprite.x = self.xpos
	self.sprite.y = self.ypos
end

function enemy:changeAnimation( s )
	for i = #allSprites, 1, -1 do
		--if allSprites[i].id == ii then
			if allSprites[i].type == 1 then
				allSprites[i]:setSequence( (playerMaxHealth - s) * 2 - 1 )
			else
				allSprites[i]:setSequence(  playerMaxHealth - s  )
			end
			allSprites[i]:play()
		--end
	end
end

function enemy:Destroy()
	if #bullets > 0 then
		for b = #bullets,1,-1 do
			display.remove(bullets[b])
			--bullets[b]:removeSelf()
			table.remove(bullets, b)
		end
	end
	
	--for sp = #sprays,1,-1 do
	--	display.remove(sprays[sp])
	--	table.remove(sprays, sp)
	--end
	
	--for bm = #booms,1,-1 do
	--	display.remove(booms[bm])
	--	table.remove(booms, bm)
	--end
	
	for s = #allSprites, 1, -1 do
		--display.remove(allSprites[s])
		table.remove(allSprites, s)
	end
end

function enemy:DestroyAll()
	for s = #allSprites, 1, -1 do
		--display.remove(allSprites[s])
		table.remove(allSprites, s)
	end
end

 function onCollision(event)
     if ( event.phase == "began" ) then


    elseif ( event.phase == "ended" ) then


    end
 end

 --Runtime:addEventListener("enterFrame", enemy )
 
 --enemy.collision = onCollision
 --Runtime:addEventListener("collision", onCollision)
 
return enemy