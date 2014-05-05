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

local myCannabisOptions = {
	width = 48,
	height = 48,
	numFrames = 35,
	sheetContentWidth = 1680,
	sheetContentHeight = 48
}
local myCannabisSheet = graphics.newImageSheet( "Images/Characters/Cannabis/Cannabis_Sprite.png", myCannabisOptions )
local myCannabisSequenceData = {
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
function enemy.newCannabis( eindex, etype, x, y, patroldirection, patrolspeed, patrolrad, aggrorad, chasespeed, chaserad, inMap )

	theMap = inMap
	local layer = inMap.layer["Enemy"]
	
	local id = eindex
	local etype = tonumber(etype)
	local originalX = x
	local originalY = y
	local xpos = x
	local ypos = y
	local state = STATE_PATROL
	local direction = patroldirection 
	local patrolSpeed = patrolspeed
	local patrolRadius = patrolrad
	local aggroRadius = aggrorad
	local chaseSpeed = chasespeed
	local chaseRadius = chaserad
	
	local isDead = false
	
	-- sprite
	
	--local 
	sprite = display.newSprite( layer, myCannabisSheet, myCannabisSequenceData )
	sprite.x = x
	sprite.y = y
	sprite.etype = etype
	--sprite:setSequence(currentFrame)
	sprite:play()
	sprite.id = eindex
	sprite.IsCannabis = true
	sprite.isDead = false
--	physics.addBody(sprite,{isSensor = true})
	sprite.isFixedRotation = true
	sprite.bodyType = "dynamic"
	
	table.insert(allSprites, sprite)
	
	local newenemy = {
		
		originalX = originalX,
		originalY = originalY,
		xpos = xpos,
		ypos = ypos,
		id = id,
		etype = etype,
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

local myHeroinOptions = {
	width = 32,
	height = 96,
	numFrames = 35,
	sheetContentWidth =1120,
	sheetContentHeight = 96
}
local myHeroinSheet = graphics.newImageSheet( "Images/Characters/Heroin/Heroin_Sprite.png", myHeroinOptions )
local myHeroinSequenceData = {
	{ name = "1", frames={ 1,2,3,4,5,6,7 }, time = 1050 },
	{ name = "2", frames={ 8,9,10,11,12,13,14 }, time = 1050 },
	{ name = "3", frames={ 15,16,17,18,19,20,21 }, time = 1050 },
	{ name = "4", frames={ 22,23,24,25,26,27,28 }, time = 1050 },
	{ name = "5", frames={ 29,30,31,32,33,34,35 }, time = 1050 }
}
function enemy.newHeroin( eindex, etype, x, y, patroldirection, patrolspeed, patrolrad, aggrorad, attackspeed, bulletspeed, inMap )

	theMap = inMap
	local layer = inMap.layer["Enemy"]
	
	local id = eindex
	local etype = etype
	local originalX = x
	local originalY = y
	local xpos = x
	local ypos = y
	local state = STATE_PATROL
	local direction = patroldirection
	local patrolSpeed = patrolspeed
	local patrolRadius = patrolrad
	local aggroRadius = aggrorad
	local attSpeed = attackspeed
	local att_cd = attackspeed
	local last_att = 0
	BULLET_DIRECTION_UP = bulletspeed
	
	local isDead = false
	
	-- sprite
	
	--local 
	sprite = display.newSprite( layer, myHeroinSheet, myHeroinSequenceData )
	sprite.x = x
	sprite.y = y
	sprite.etype = etype
	--sprite:setSequence(currentFrame)
	sprite:play()
	sprite.id = eindex
	sprite.IsHeroin = true
	sprite.CanShoot = true -- new; later
	sprite.isDead = false
	physics.addBody(sprite,{isSensor = true})
	sprite.isFixedRotation = true
	sprite.bodyType = "dynamic"

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
		etype = etype,
		state = state,
		direction = direction,
		patrolSpeed = patrolSpeed,
		patrolRadius = patrolRadius,
		aggroRadius = aggroRadius,
		attSpeed = attackspeed,
		att_cd = attackspeed,--2
		last_att = 0,
		
		isDead = isDead,
		
		movingUp = false,
		movingDown = false,

		sprite = sprite
		
		--sprite = display.newSprite( myHeroinSheet, myHeroinSequenceData )
		
	}
	
	return setmetatable( newenemy, enemy_mt )
end

local myInhalantOptions = {
	width = 48,
	height = 48,
	numFrames = 55,
	sheetContentWidth = 2640,
	sheetContentHeight = 48
}
local myInhalantSheet = graphics.newImageSheet( "Images/Characters/Inhalant/Inhalant_Sprite.png", myInhalantOptions )
local myInhalantSequenceData = {
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
function enemy.newInhalant( eindex, etype, x, y, patroldirection, patrolspeed, patrolrad, aggrorad, attackspeed, inMap )

	theMap = inMap
	local layer = inMap.layer["Enemy"]

	local id = eindex
	local etype = tonumber(etype)
	local originalX = x
	local originalY = y
	local xpos = x
	local ypos = y
	local state = STATE_PATROL
	local direction = patroldirection
	local patrolSpeed = patrolspeed
	local patrolRadius = patrolrad
	local aggroRadius = aggrorad
	local attSpeed = attackspeed
	local last_att = 0
	local spray_dir = patroldirection
	local b_sprayin = false
	local b_boomin = false
	
	local isDead = false
	
	-- sprite
	
	--local 
	sprite = display.newSprite( layer, myInhalantSheet, myInhalantSequenceData )
	sprite.x = x
	sprite.y = y
	sprite.etype = etype
	--sprite:setSequence(currentFrame)
	sprite:play()
	sprite.id = eindex
	sprite.IsInhalant = true
	sprite.isDead = false
	physics.addBody(sprite,{isSensor = true})
	sprite.isFixedRotation = true
	sprite.bodyType = "dynamic"
	
	table.insert(allSprites, sprite)
	
	local newenemy = {
		
		originalX = originalX,
		originalY = originalY,
		xpos = xpos,
		ypos = ypos,
		id = id,
		etype = etype,
		state = state,
		direction = direction,
		patrolSpeed = patrolSpeed,
		patrolRadius = patrolRadius,
		aggroRadius = aggroRadius,
		attSpeed = attackspeed,
		last_att = 0,
		spray_dir = patroldirection,
		b_sprayin = false,
		b_boomin = false,
		
		isDead = isDead,
		
		movingUp = false,
		movingDown = false,

		sprite = sprite
		
		--sprite = display.newSprite( myHeroinSheet, myHeroinSequenceData )
		
	}
	
	return setmetatable( newenemy, enemy_mt )
end

function enemy:isChasing()
	if self.state == STATE_CHASING then
		return true
	else
		return false
	end
end

function enemy:getType()
	return self.etype
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
local myBulletSheet = graphics.newImageSheet( "Images/Characters/Heroin/HeroinBullet_Sprite.png", BulletOptions )
local BulletSequenceData = {
	{ name = "1", frames={ 1,2,3,4,5,6 }, time = 250 }
}
function enemy:Shoot(inx, iny)
	--local bullet = display.newCircle(pos_x, pos_y, 5)
	local bullet = display.newSprite( theMap.layer["Enemy"], myBulletSheet, BulletSequenceData )
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
		if  t - self.last_att >= self.att_cd then
			self.last_att = t
			self.state = STATE_ATTACKING
		end
	elseif self.state == STATE_ATTACKING then
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

local SprayOptions = {
	width = 64,
	height = 32,
	numFrames = 7,
	sheetContentWidth =448,
	sheetContentHeight = 32
}
local mySpraySheet = graphics.newImageSheet( "Images/Characters/Inhalant/InhalantAttack_Sprite.png", SprayOptions )
local SpraySequenceData = {
	{ name = "1", frames={ 1 }, time = 1000 },
	{ name = "2", frames={ 1,2,3,4,5,6,7 }, loopCount = 1, time = 1500 }
	--{ name = "2", start = 2, count = 6, loopCount = 1, time = 1000 },
}
function enemy:Spray(inx, iny, indir, ii)
	local spray
	spray = display.newSprite( theMap.layer["Enemy"], mySpraySheet, SpraySequenceData )
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
local myBoomSheet = graphics.newImageSheet( "Images/Characters/Inhalant/InhalantExplode_Sprite.png", BoomOptions )
local BoomSequenceData = {
	{ name = "1", frames={ 1,2,3,4,5,6,7 }, loopCount = 1, time = 2000 }
}
function enemy:Boom(inx, iny, ii)
	local boom
	boom = display.newSprite( theMap.layer["Enemy"], myBoomSheet, BoomSequenceData )
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
		if  t - self.last_att >= 3 then--att_cd then
			self.last_att = t
			self.state = STATE_ATTACKING
			--b_sprayin = true
		end
	elseif self.state == STATE_ATTACKING then
		if self.b_sprayin == false then
			enemy:Spray(self.xpos, self.ypos, self.spray_dir, ii)
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
	else
		print("enemy:Update() : Inavlid Enemy Type")
	end

--	if not self.sprite then error( self.etype ) end
	self.sprite.x = self.xpos
	self.sprite.y = self.ypos
end

function enemy:changeAnimation( s )
	for i = #allSprites, 1, -1 do
		--if allSprites[i].id == ii then
			if allSprites[i].etype == 1 then
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