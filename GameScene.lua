----------------------------------------------------------------------------------
--
-- GameScene.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local loadsave = require("loadsave")

system.activate("multitouch")

require("physics"); physics.start()

local gameData = require("GameData")

require("functions")

local touchHandler = require("TouchHandler")

local screen = const_table
{
	width  = display.contentWidth,
	height = display.contentHeight,
	originalWidth = 480,
	originalHeight = 360,

	debugText = display.newText
	{ 
		text = "",
		x = display.contentWidth / 2,
		y = 20,
		fontSize = 20
	},

	debugText2 = display.newText
	{ 
		text = "",
		x = display.contentWidth / 2,
		y = 40,
		fontSize = 20
	},

	debugText3 = display.newText
	{ 
		text = "",
		x = display.contentWidth / 2,
		y = 60,
		fontSize = 20,
		width = display.contentWidth,
		align = "left"
	},

	debugText4 = display.newText
	{ 
		text = "",
		x = display.contentWidth / 2,
		y = 80,
		fontSize = 20,
		width = display.contentWidth,
		align = "left"
	}
}

local States = const_table
{
	idle = "idle",
	walking = "walking",
	jumping = "jumping",
	moving = "moving",
}

local player = 
{
}

local Directions = const_table
{
	up		= 2,
	down	= -2,
	left	= -1,
	right	= 1
}

local Enable = 
{
	playerBlur = true,
	blur = false,
	distortion = false,
	reverse = false
}

local map
local btnDown = false
local btnDownTimer = 0
local holdingBtn = false

local mapPos =
{
	curr = { x = 0, y = 0 },
	prev = { x = 0, y = 0 },
	diff = { x = 0, y = 0 },
	before_touch = { x = 0, y = 0 },
	delta = { x = 0, y = 0 },
}

local groupmb = display.newGroup()
local inAir = false
local onIce = false
local groupcs 
local touchJumpX, touchJumpY
local enemy = require( "enemy" )
local enemyList = {}
local obstacleLayer

local touchDistFromPlayer = { x = 0, y = 0 }
local playerPrevPos = { x = 0, y = 0 }

local distortion_Timer = 0
local sfx_Timer = 0
local reverse_Timer = 0

local pendulum = {}
local pendulumSupport = {}
local spinBlade = {}
local platform = {}

local bg,bg2,bg3

local bg1Alpha = 1
local bg2Alpha = 0

local collectableLayer

local playerHealth = 5
local playerMaxHealth = 5

--local testBtn
local pauseBtn
--local storyboard.isPaused = false
local sfx_delay = 0

local bgBase
local bgFront = {}

local questionMark
local myCharSheet
local currentFrame
local myHearts = {}
local blackbox
local myHealthbar
local differencePX = 0
local differencePY = 0
local prevPX = 0
local prevPY = 0
local banner_bg
local banner_text
local banner_trans = {}
local trans_blackbox

local traject
local traject_width
local traject_rotation
local traject_created = false
local prevAngle 

local screenSizeHalf = { x = screen.width / 2, y = screen.height / 2 }
local lineOrigin = { x = 0, y = 0 }

local tap_effect

local popup

local isTutorial
local redArrow
local taphereText
local canMove = true
local tutorial = 
{
	step1,
	step2,
	step3
}

local redArrowUp 
local redArrowDown 
local pushingCrate = false
local handicon

local tutorial_Bg1
local tutorial_Bg2
local tutorial_Bg3

--local times = 0

local IdleTime = 0
local IdleStartTime = 0
local b_Idle = true

local b_pop = false

---------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------



local function onButtonEvent(event)
	
	local btn = event.target
	
	if btn.id == "pause_btn" then
		
		if holdingBtn == true then
			print("stupid onButtonEvent shit")
			traject.width = 5
			traject.alpha = 0
			traject.x = player:localToContent( 0, 0 ).x
			traject_created = false
		end
		
		if storyboard.isPaused == false then
			physics:pause()
			storyboard.isPaused = true
			storyboard.showOverlay( "PauseScreen" )
			pauseBtn:setEnabled(false)
			--storyboard.playerHealth = playerMaxHealth
		else
			physics:start()
			storyboard.isPaused = false
		end
		
	end
	
	return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )

	local group = self.view
	collectgarbage( "collect" )
	--Enable.distortion = true
	Enable.playerBlur = true
	pushingCrate = false
	
	traject = display.newRect(0,0,5,2)
	traject.alpha = 0
	traject:setFillColor(255, 255, 255) 
	traject.anchorX, traject.anchorY = 0.0, 0.0
	prevAngle = 0
	bgFront = {}
	onPlatform = false
	
	Runtime:addEventListener("enterFrame", Update)
	
	mapfilename = "Levels/Level_"..storyboard.currentWorld.."_"..storyboard.currentLevel..".json"
--	mapfilename = "Levels/Level_"..storyboard.currentWorld.."_"..storyboard.currentLevel..".tmx" -- Lime
	print("current world : "..storyboard.currentWorld.." current level : "..storyboard.currentLevel)
	print("Map filename : " .. mapfilename)


--	map = lime.loadMap(mapfilename)
	map = dusk.buildMap(mapfilename)
	if not map then error("Map not loaded") end

	local imgOptions =
	{
		-- FRAME 1:
		width = screen.width,
		height = screen.height,
		numFrames = 5,
		sheetContentWidth = screen.width * 5,
		sheetContentHeight = screen.height
		
	}
	local imgOptions2 =
	{
		-- FRAME 1:
		width = screen.width,
		height = screen.height,
		numFrames = 6,
		sheetContentWidth = screen.width * 2,
		sheetContentHeight = screen.height * 3
		
	}
	local imgOptions3 =
	{
		-- FRAME 1:
		width = screen.width*5,
		height = screen.height,
		numFrames = 5,
		sheetContentWidth = screen.width * 5,
		sheetContentHeight = screen.height * 5
		
	}
	local sequenceData =
	{
	
		{ name = "1", frames={ 1,2,3,4,5 }, time = 750 },
		
	}
	
	--1 reset player's health to the max (at the start)
	if storyboard.playerHealth == 0 then
		storyboard.playerHealth = playerMaxHealth
	end
	
	--1 this change the background according to the player's health
	currentFrame = playerMaxHealth - storyboard.playerHealth + 1
	
	if storyboard.currentWorld == 1 then
		--local myImgSheet = graphics.newImageSheet("Images/UI Screen/scrollable bg layers/Combined-BG-Sprite.png",imgOptions )
		local myImgSheet = graphics.newImageSheet("Images/UI_Screen/scrollable_bg_layers/Aversion-bg-base-final-sprite.png",imgOptions )
		local myImgSheet2 = graphics.newImageSheet("Images/UI_Screen/scrollable_bg_layers/Aversion-bg-front-final-sprite2.png",imgOptions2 )
		
		bgBase = display.newSprite(group,myImgSheet,sequenceData )
		bgBase.x = screen.width/2
		bgBase.y = screen.height/2
		bgBase:setFrame(currentFrame)
		
		for i = 1,2 do
			bgFront[i] = display.newSprite(group,myImgSheet2,sequenceData)
			bgFront[i].x = screen.width/2
			bgFront[i].y = screen.height/2
			bgFront[i].parallaxFactor = 1.0
			bgFront[i]:setFrame(currentFrame)
		end

		myImgSheet = nil
		myImgSheet2 = nil

		bgFront[2].x = screen.width + screen.width * 0.5
	end
	
	if storyboard.currentWorld >= 2 then

		local myImgSheet6_filename

		if storyboard.currentWorld == 5 then
			myImgSheet6_filename = "Images/UI_Screen/scrollable_bg_layers/BG_Sprite_5.png"
		else
			myImgSheet6_filename = "Images/UI_Screen/scrollable_bg_layers/Level2/BG_Sprite.png"
		end

		local myImgSheet6 = graphics.newImageSheet(myImgSheet6_filename, imgOptions3 )

		bg2 = display.newSprite(group,myImgSheet6,sequenceData )
		bg2.x = screen.width*0.5
		bg2.y = screen.height*0.5
		bg2:setFrame(currentFrame)
		bg2.parallaxFactor = 0.5
	end

	-- Table of functions to run
	local InitFunctions = {}

	-- Function to add a init func to our table defined above
	-- This is to replace map:addObjectListener()
	local function AddInitFunction (objectType, func)

		-- make sure params are valid
		if(objectType and func) then

			-- if the objectType is not defined
			if(not InitFunctions[objectType]) then
				-- create an array of funcs for this objectType
				InitFunctions[objectType] = {}
			end

			-- add the func to the array held by objectType
			InitFunctions[objectType][#InitFunctions[objectType] + 1] = func

		end

	end

	-- Function to run all the added init funcs in the table defined above
	-- This is to replace map:addObjectListener()
	local function RunAllInitFunctions ()

		-- Loop through all the objectTypes
		for k,v in pairs(InitFunctions) do

			-- Get all the functions in func array of this objectType
			local listeners = v or {}

			-- get the objects of objectType k
			local objects = {}

			for i=1, #map.layer, 1 do

				local currLayer = map.layer[i]

				if currLayer.object then

					for j=1, #currLayer.object, 1 do

						local currObj = currLayer.object[j]

						if k == currObj._type then
							objects[#objects + 1] = currObj
						end

					end

				end

			end

			if objects then
			
				-- Loop through all the objects
				for i=1, #objects, 1 do

					local currObj = objects[i]

					-- Loop through all the functions and run
					for j=1, #listeners, 1 do			
						listeners[j](currObj)
					end

				end

			end

		end
		
	end
	
	-- player
	local onPlayerSpawnObject = function(object)

		local layer = map.layer["Player"]
	
		local charOptions =
		{
			width = 36,
			height = 36,
			numFrames = 50,
			sheetContentWidth = 1800,
			sheetContentHeight = 36
		}

		local sequenceData =
		{
			-- 1
			{ name = "1", frames={ 1,1,2,3,3,3,4,5,6,7,7,7 }, time = 750 },
			{ name = "2", frames={ 8,9,10 }, time = 750 },
			-- 2
			{ name = "3", frames={ 11,11,12,13,13,13,14,15,16,17,17,17 }, time = 750 },
			{ name = "4", frames={ 18,19,20 }, time = 750 },
			-- 3
			{ name = "5", frames={ 21,21,22,23,23,23,24,25,26,27,27,27 }, time = 750 },
			{ name = "6", frames={ 28,29,30 }, time = 750 },
			-- 4
			{ name = "7", frames={ 31,31,32,33,33,33,34,35,36,37,37,37 }, time = 750 },
			{ name = "8", frames={ 38,39,40 }, time = 750 },
			-- 5
			{ name = "9", frames={ 41,41,42,43,43,43,44,45,46,47,47,47 }, time = 750 },
			{ name = "10", frames={ 48,49,50 }, time = 750 }
			
		}

		myCharSheet = graphics.newImageSheet("Images/Characters/Main_Char/PlayerSprite.png", charOptions )

		player = display.newSprite(layer,myCharSheet,sequenceData)
		player:setSequence(currentFrame * 2 - 1)

		player.id = "Player"
		player.x, player.y = object.x, object.y
		player.originalX, player.originalY = player.x, player.y
		player.invul = false
		player.playerHealth = storyboard.playerHealth
		player.direction = 0
		player.state = States.idle
		player.canJump = true

		physics.addBody(player, { density = 2.0, friction = 0.9, bounce = 0.2, radius = 14 })
		player:addEventListener("collision", onCollision)

		-- physics variables
		player.isFixedRotation = true
		player.isSleepingAllowed = false
		player.isBullet = true
		player.gravityScale = 2.0

	end
	AddInitFunction("PlayerSpawn", onPlayerSpawnObject)

	-- get the ground objects from the map, add to physics
	local onGroundSpawnObject = function(object)

		object.alpha = 0
		physics.addBody( object, "static" )

		if object.props.IsPit == true then
			object.IsPit = true
		end

	end
	AddInitFunction("Body", onGroundSpawnObject)
	
	local QuestionMarkOptions =
	{
		-- FRAME 1:
		width = 64,
		height = 64,
		numFrames = 2,
		sheetContentWidth = 128,
		sheetContentHeight = 64
	}
	local sequenceData = 
	{
		{ name = "1", frames={ 1,2 }, time = 750 },
	}

	local myQuestionMarkSheet = graphics.newImageSheet( "Images/Others/Qmarks.png",QuestionMarkOptions )
	questionMark = display.newSprite( myQuestionMarkSheet, sequenceData )
	questionMark.x, questionMark.y = 100, 150
	questionMark:setSequence("1")
	questionMark.alpha = 0
	
	local eindex = 1

	local onSpinBladeSpawnObject = function(object)

		local spinBladeOptions =
		{
			-- FRAME 1:
			width = 64,
			height = 32,
			numFrames = 3,
			sheetContentWidth = 192,
			sheetContentHeight = 32
		}

		local mySpinBladeSheet

		if storyboard.currentWorld == 1 then
			mySpinBladeSheet = graphics.newImageSheet( "Images/Aversion-spinning-blade-animation-sprite.png",spinBladeOptions )
		else
			mySpinBladeSheet = graphics.newImageSheet( "Images/Spinning-blade-animation-sprite2.png",spinBladeOptions )
		end

		local sequenceData = 
		{
			{ name = "default", frames = { 1,2,3 }, time = 250 }
		}

		local sprite = display.newSprite( mySpinBladeSheet, sequenceData )

		sprite.x, sprite.y = object.x, object.y
		sprite:setSequence("default")
		sprite:play()
		sprite.id = eindex

		physics.addBody(sprite,{isSensor = true})
		sprite.bodyType = "static"

		local newEnemy = enemy.new( object.x, object.y, tonumber(object.props.enemyType), tonumber(object.props.patrolRadius), eindex, 2)
		eindex = eindex + 1
		newEnemy.isFixedRotation = true
		newEnemy.sprite = sprite

		table.insert(enemyList, newEnemy)

	end
	AddInitFunction("SpinBladeSpawn", onSpinBladeSpawnObject)
	
	local onPendulumSpawnObject = function(object)
	
		local PendulumOptions = 
		{
			width = 100,
			height = 50,
			numFrames = 5,
			sheetContentWidth = 500,
			sheetContentHeight = 50
		}
		
		local myPendulumSheet = graphics.newImageSheet("Images/IceSprite.png", PendulumOptions)
		local SequenceData =
		{
			{ name = "1", frames={ 1,2,3,4,5 }, time = 500 },
			--{ name = "2", frames={ 6,7,8,9,10 }, time = 500 },
			--{ name = "3", frames={ 11,12,13,14,5 }, time = 500 },
			--{ name = "4", frames={ 16,17,18,19,20 }, time = 500 },
			--{ name = "5", frames={ 21,22,23,24,25 }, time = 500 }
			-- was meant for Images/IceSprite_.png - George
		}

		-- the sprite for the pendulum
		local pSprite = display.newSprite( myPendulumSheet, SequenceData )

		pSprite:setSequence(1)
		pSprite:play()
		pSprite.wheelX, pSprite.wheelY = object.x, object.y
		pSprite.radius = ( tonumber(object.props.radius) * 2.8 )	
	
		if object.direction == 2 then
			pSprite.direction = Directions.right
			pSprite.switchingSide = false
			pSprite.swingingLeft = false
			pSprite.swingingRight = true
			pSprite.degStart = 160
		else
			pSprite.direction = Directions.left
			pSprite.switchingSide = false
			pSprite.swingingLeft = true
			pSprite.swingingRight = false
			pSprite.degStart = 20
		end

		local rads = (pSprite.degStart) * (math.pi / 180.0)

		pSprite.x = pSprite.radius * math.cos(rads) + pSprite.wheelX
		pSprite.y = pSprite.radius * math.sin(rads) + pSprite.wheelY
		pSprite.pendulum = 1
		physics.addBody(pSprite, {isSensor = true,radius = 20})
		
		pSprite.last_shit = 0

		pSprite.bodyType = "static"
		table.insert(pendulum, pSprite)
		
		local ropeImage = display.newImageRect("Images/Aversion-pendulum-rope.png", 35 * 1.2, pSprite.radius * 0.9 )

		ropeImage.yScale = -1
		ropeImage.anchorX, ropeImage.anchorY = 0.5, 0.0
		ropeImage.x, ropeImage.y = object.x, object.y

		if object.direction == 2 then
			ropeImage.rotation = 250
			ropeImage.direction = Directions.right
		else
			ropeImage.rotation = 110
			ropeImage.direction = Directions.left
		end

		ropeImage:toBack()
		ropeImage.switchingSide = true
		ropeImage.pendulumSupport = 1
				
		table.insert(pendulumSupport, ropeImage)

	end
	AddInitFunction("PendulumSpawn", onPendulumSpawnObject)
	
	
	local onCrateSpawnObject = function(object)
		
		obstacleLayer = map.layer["Obstacle"]

		-- sprite for the crate
		local cSprite = display.newImageRect( obstacleLayer.group,"Images/Crate.png",64,64)

		cSprite.width = 62
		cSprite.height = 62
		cSprite.x, cSprite.y = object.x, object.y
		cSprite.IsCrate = true
		cSprite.IsGround = true

		physics.addBody(cSprite, { density = 2, friction = 0.4, isSensor = false })
		cSprite.gravityScale = 2
		cSprite.bodyType = "dynamic"

	end
	AddInitFunction("CrateSpawn", onCrateSpawnObject)
	
	local onCannabisSpawnObject = function(object)
		
		local cannabis = enemy.newCannabis( eindex, 
										tonumber(object.props.enemyType), 
										object.x, object.y, 
										tonumber(object.props.patrolDirection), 
										tonumber(object.props.patrolSpeed), 
										tonumber(object.props.patrolRadius), 
										tonumber(object.props.aggroRadius), 
										tonumber(object.props.chaseSpeed), 
										tonumber(object.props.chaseRadius), map )
		cannabis.id = eindex
		eindex = eindex + 1
		table.insert(enemyList, cannabis)
		physics.addBody( cannabis.sprite, "dynamic", { density = 2.0, friction = 0.9, bounce = 0.2, radius = 14 } )

	end
	AddInitFunction("CannabisSpawn", onCannabisSpawnObject)
	
	
	local onInhalantSpawnObject = function(object)

		local inhalant = enemy.newInhalant( eindex, 
										tonumber(object.props.enemyType), 
										object.x, object.y, 
										tonumber(object.props.patrolDirection), 
										tonumber(object.props.patrolSpeed), 
										tonumber(object.props.patrolRadius), 
										tonumber(object.props.aggroRadius), 
										tonumber(object.props.attackSpeed), map )
		inhalant.id = eindex
		eindex = eindex + 1
		table.insert(enemyList, inhalant)
		physics.addBody( inhalant.sprite, "dynamic", { density = 2.0, friction = 0.9, bounce = 0.2, radius = 14 } )

	end
	AddInitFunction("InhalantSpawn", onInhalantSpawnObject)
	
	
	local onHeroinSpawnObject = function(object)

		local heroin = enemy.newHeroin(	eindex, 
										tonumber(object.props.enemyType), 
										object.x, object.y, 
										tonumber(object.props.patrolDirection), 
										tonumber(object.props.patrolSpeed), 
										tonumber(object.props.patrolRadius), 
										tonumber(object.props.aggroRadius), 
										tonumber(object.props.attackSpeed), 
										tonumber(object.props.bulletSpeed), map)
		heroin.id = eindex
		eindex = eindex + 1
		table.insert(enemyList, heroin)
		physics.addBody( heroin.sprite, "dynamic", { density = 2.0, friction = 0.9, bounce = 0.2, radius = 14 } )

	end
	AddInitFunction("HeroinSpawn", onHeroinSpawnObject)
	
	
	local onIceSpawnObject = function(object)

		local IceOptions =
		{
			width = 48,
			height = 48,
			numFrames = 10,
			sheetContentWidth = 480,
			sheetContentHeight = 48
		}

		local myIceSheet = graphics.newImageSheet("Images/Characters/Ice/Ice_Sprite.png",IceOptions )

		local sequenceData =
		{
			{ name = "1", frames={ 1,2 }, time = 500 },Aversion-level-select-button-sprite
			{ name = "2", frames={ 3,4 }, time = 500 },
			{ name = "3", frames={ 5,6 }, time = 500 },
			{ name = "4", frames={ 7,8 }, time = 500 },
			{ name = "5", frames={ 9,10 }, time = 500 }
		}

		local iceSprite = display.newSprite( myIceSheet, sequenceData )
		iceSprite.anchorX, iceSprite.anchorY = 0.5, 0.5
		iceSprite.x, iceSprite.y = object.x, object.y
		iceSprite:setSequence(currentFrame)
		iceSprite:play()
		iceSprite.alpha = 1
		iceSprite.id = eindex
	
		iceSprite.isDead = false

		physics.addBody(iceSprite,{isSensor = true, radius = 18})

		sprite.isFixedRotation = true

		local temp = enemy.new( object.x, object.y, 
								tonumber(object.props.enemyType), 
								tonumber(object.props.patrolRadius), 
								tonumber(object.props.aggroRadius), eindex, 
								tonumber(object.props.patrolSpeed))	
		temp.id = eindex
		eindex = eindex + 1
		temp.isFixedRotation = true
		table.insert(enemyList, temp)

	end
	AddInitFunction("IceSpawn", onIceSpawnObject)
	
	
	local onHealthSpawnObject = function(object)

		local HealthOptions =
		{
			-- FRAME 1:
			width = 64,
			height = 64,
			numFrames = 5,
			sheetContentWidth = 320,
			sheetContentHeight = 64
		}
		
		local myHealthSheet = graphics.newImageSheet( object.sprite,HealthOptions )

		local sequenceData =
		{
			{ name = "default", frames={ 1,2,3,4,5 }, time = 1200 },
			{ name = "second", frames={ 6,7,8,9,10 }, time = 1200 },
			{ name = "third", frames={ 11,12,13,14,15 }, time = 1200 },
			{ name = "fourth", frames={ 16,17,18,19,20 }, time = 1200 }
		}

		local sprite = display.newSprite( myHealthSheet, sequenceData )

		sprite.anchorX, sprite.anchorY = 0.5, 0.5
		sprite.x, sprite.y = object.x, object.y
		sprite:setSequence("default")
		sprite:play()
		sprite.id = eindex
		sprite.IsHealth = true

		physics.addBody(sprite, { isSensor = true })
		sprite.isFixedRotation = true
		sprite.bodyType = "static"

	end
	AddInitFunction("HealthSpawn", onHealthSpawnObject)

	local onEndPointSpawnObject = function(object)
		
		local layer = map.layer["Object Layer 1"]
		
		local EndPointOptions =
		{
			-- FRAME 1:
			width = 64,
			height = 64,
			numFrames = 4,
			sheetContentWidth = 256,
			sheetContentHeight = 64
		}
		
		local myEndPointSheet = graphics.newImageSheet( "Images/End_Portal_Sprite.png",EndPointOptions )

		local sequenceData =
		{ { name = "default", frames={ 1,2,3,4 }, time = 500 } }

		local sprite

		if storyboard.currentWorld == 1 and storyboard.currentLevel == 8 
		or storyboard.currentWorld == 2 and storyboard.currentLevel == 8 then
			sprite = display.newSprite( myEndPointSheet, sequenceData )
		else
			sprite = display.newSprite( layer, myEndPointSheet, sequenceData )
		end

		sprite.anchorX, sprite.anchorY = 0.5, 0.5
		sprite.x, sprite.y = object.x, object.y
		sprite:setSequence("default")
		sprite:play()
		sprite.id = eindex
		sprite.IsExit = true

		physics.addBody(sprite, { isSensor = true,radius = 28 })
		sprite.isFixedRotation = true
		sprite.bodyType = "static"

	end
--	map:addObjectListener("EndPointSpawn", onEndPointSpawnObject)
	AddInitFunction("EndPointSpawn", onEndPointSpawnObject)
	
	local onPopupSpawnObject = function(object)
		popup = display.newImageRect("Images/Visual_Feedback/Arrow.png",32,96)
		popup.isVisible = false
		popup.x = object.x
		popup.y = object.y - 32
		popup.IsPopup = true
		if storyboard.currentWorld == 1 then
			if storyboard.currentLevel == 2 then
				popup.text = "cannabis"
			elseif storyboard.currentLevel == 3 then
				popup.text = "heroin"
			elseif storyboard.currentLevel == 6 then
				popup.text = "ice"
			elseif storyboard.currentLevel == 8 then
				popup.text = "inhalant"
			end
		end
		
		physics.addBody(popup, "static", {isSensor = true})
	end
--	map:addObjectListener("PopupSpawn", onPopupSpawnObject)
	AddInitFunction("PopupSpawn", onPopupSpawnObject)
	
	--Code for custom tutorial for first level
	if storyboard.currentLevel == 1 and  storyboard.currentWorld == 1 then
		isTutorial = true
		tutorial.step1 = true
		tutorial.step2 = false

		local onArrowSpawnObject = function(object)
			
			local layer = map.layer["Object Layer 1"]
			
			if tutorial.step1 == true then
				
				tutorial_Bg1 = display.newImageRect("Images/Visual_Feedback/Tutorial/Move.png",192,64)
				tutorial_Bg1.x = screen.width*0.75
				tutorial_Bg1.y = screen.height*0.65
				tutorial_Bg1.alpha = 0.9
				
			end

			redArrow = display.newImageRect(layer,"Images/Visual_Feedback/Arrow.png",48,48)
			redArrow.x = object.x
			redArrow.y = object.y
			redArrowOriginalY = object.y
			redArrow.IsArrow = true
			
			taphereText = display.newImageRect(layer,"Images/Visual_Feedback/Tap_Here.png",100,45)
			taphereText.x = object.x
			taphereText.y = object.y - 60
			
			handicon = display.newImageRect(layer,"Images/Visual_Feedback/Hand_Icon.png",64,64)
			handicon.x = object.x + 25
			handicon.y = object.y + 32
			handicon.originalX = object.x + 25
			handicon.originalY = object.y + 32
			handicon.rotation = -90
			handicon.activated = false
			handicon.alpha = 0
			handicon.isPlaying = false

			physics.addBody(redArrow,{isSensor = true,radius = 24})
			redArrow.isFixedRotation = true
			redArrow.bodyType = "static"

		end
		AddInitFunction("ArrowSpawn", onArrowSpawnObject)
	end
	
	--Creates the map
	
--	local physical = lime.buildPhysical(map)

	RunAllInitFunctions()

--	Setting focus on player, for Dusk
	map.enableFocusTracking(true)
	map.setCameraFocus(player)
	map.setCameraBounds( 
		{	xMin = screen.width / 2, xMax = map.data.width - (screen.width / 2), 
			yMin = screen.height / 2, yMax = map.data.height - (screen.height / 2) } )
--

	player:addEventListener("touch", onTouchPlayer)
	
	-----------------------------------------------------------------------------
	
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved player.state.
	
	-----------------------------------------------------------------------------
	
	local pauseBtnOptions =
		{
		-- FRAME 1:
		width = 48,
		height = 48,
		numFrames = 2,
		sheetContentWidth = 96,
		sheetContentHeight = 48
	}
	local myPauseButtonSheet = graphics.newImageSheet("Images/Buttons/Aversion_pause_button_sprite.png",pauseBtnOptions )
	
	pauseBtn = widget.newButton
	{
		sheet = myPauseButtonSheet,
		id = "pause_btn",
		defaultFrame = 1,
		overFrame = 2,
		onRelease = onButtonEvent,
		width = 64,
		height = 64
	}
	pauseBtn.x = screen.width * 0.92
	pauseBtn.y = screen.height * 0.12
	
	
	blackbox = display.newRect(0,0,screen.width,screen.height)
	blackbox:setFillColor(0, 0, 0)
	blackbox.anchorX, blackbox.anchorY = 0, 0
	--object:toBack()
	trans_blackbox = transition.to(blackbox,{alpha = 0, time = 1000, transition = easing.linear})
	
	local HeartOption =
	{
		width = 64,
		height = 64,
		numFrames = 2,
		sheetContentWidth = 128,
		sheetContentHeight= 64
	}

	local HeartSheet = graphics.newImageSheet( "Images/Others/HeartIconSpriteSheet.png", HeartOption )

	local sequenceData =
	{
		{ name = "1", frames = { 1, 2 }, time = 750 },
	}
	
	HeartSprite1 = display.newSprite( HeartSheet, sequenceData )
	HeartSprite1.x = 160+15
	HeartSprite1.y = 32+5
	HeartSprite1.xScale = 0.5
	HeartSprite1.yScale = 0.5
	HeartSprite1:play()
	
	HeartSprite2 = display.newSprite( HeartSheet, sequenceData )
	HeartSprite2.x = 128+15
	HeartSprite2.y = 32+5
	HeartSprite2.xScale = 0.5
	HeartSprite2.yScale = 0.5
	HeartSprite2:play()
	
	HeartSprite3 = display.newSprite( HeartSheet, sequenceData )
	HeartSprite3.x = 96+15
	HeartSprite3.y = 32+5
	HeartSprite3.xScale = 0.5
	HeartSprite3.yScale = 0.5
	HeartSprite3:play()
	
	HeartSprite4 = display.newSprite( HeartSheet, sequenceData )
	HeartSprite4.x = 64+15
	HeartSprite4.y = 32+5
	HeartSprite4.xScale = 0.5
	HeartSprite4.yScale = 0.5
	HeartSprite4:play()

	HeartSprite5 = display.newSprite( HeartSheet, sequenceData )
	HeartSprite5.x = 32+10
	HeartSprite5.y = 32+5
	HeartSprite5:play()
	
	
	local DeathBgOptions =
	{
		-- FRAME 1:
		width = screen.width,
		height = screen.height,
		numFrames = 9,
		sheetContentWidth = screen.width * 3,
		sheetContentHeight = screen.height * 3
	}
	local myDeathBgSheet = graphics.newImageSheet("Images/UI_Screen/char_die_screen_only/Aversion-character-die-screen-sprite.png",DeathBgOptions )
	local sequenceDataDBG =
	{
		{ name = "1", frames={ 1,1,1,1,1,1,1,1,1,1
							  ,2,3,4,5,6,6,6,6,7,7,7,7,8,8,8,8
							  ,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9 }, time = 3600, loopCount=1}
	}
	DeathBg = display.newSprite( myDeathBgSheet, sequenceDataDBG )
	DeathBg.x = screen.width * 0.5
	DeathBg.y = screen.height * 0.5
	DeathBg:setSequence("1")
	DeathBg.alpha = 0
	
	
	groupcs = display.newGroup()
	
	
	local listener4 = function()
		
		banner_trans[1] = transition.to(banner_bg,{x=screen.width*1.5,time=500})
	
	end
	local listener3 = function()
		
		banner_trans[2] = transition.to(banner_text,{x=screen.width*1.5,time=500,onComplete = listener4})
	
	end
	local listener2 = function()
		
		banner_trans[3] = transition.to(banner_text,{time=1800,onComplete = listener3})
	
	end
	local listener1 = function()
		
		banner_trans[4] = transition.to(banner_text,{x=screen.width*0.5,time=500,onComplete = listener2})
	
	end
	
	banner_bg = display.newImageRect("Images/Level_Banner/Banner.png",screen.width,screen.height)
	banner_bg.x = screen.width * -0.5
	banner_bg.y = screen.height * 0.5
	
	transition.to(banner_bg,{x=screen.width*0.5,time=500,onComplete = listener1})
	
	
	local imgOptions2 =
	{
		width = 128 ,
		height = 64 ,
		numFrames = 8,
		sheetContentWidth = 512 ,
		sheetContentHeight = 128 	
	}
	
	local myImgSheet2 = graphics.newImageSheet("Images/Level_Banner/Levels.png",imgOptions2)
	local sequenceData2 = 
	{
		{ name = "1", frames={ 1,2,3,4,5,6,7,8 }, time = 750 },	
	}
	
	banner_text = display.newSprite( myImgSheet2, sequenceData2 )
	banner_text.x = screen.width * -0.5
	banner_text.y = screen.height * 0.3
	banner_text:setFrame(storyboard.currentLevel)
	
	myImgSheet2 = nil
	if storyboard.firstEntry == false then
		banner_text.alpha = 0
		banner_bg.alpha = 0
	end
	storyboard.firstEntry = false
	
	local tapOptions =
	{
		width = 48 ,
		height = 48 ,
		numFrames = 2,
		sheetContentWidth = 96 ,
		sheetContentHeight = 48 	
	}
	
	local myImgSheetTap = graphics.newImageSheet("Images/Visual_Feedback/Tap_Area.png",tapOptions)
	local sequenceDataTap = 
	{
		{ name = "1", frames={ 1,2 }, time = 150, loopCount = 1},	
	}
	tap_effect = display.newSprite( myImgSheetTap, sequenceDataTap )
	tap_effect:pause()
	tap_effect.alpha = 0

	IdleStartTime = system.getTimer()/1000

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	-- Save the data everytime when entering a new scene
	M.saveData()

	prior_scene = storyboard.getPrevious()
	--storyboard.purgeScene( prior_scene )
	storyboard.removeScene( prior_scene )
	
	--storyboard.purgeScene( "LevelSelect" )
	storyboard.removeScene( "LevelSelect" )
	--storyboard.purgeScene( "dummyscene" )
	storyboard.removeScene( "dummyscene" )
	--storyboard.purgeScene( "GameScene" )
	--storyboard.removeScene( "GameScene" )
	storyboard.removeAll()
	--storyboard.purgeAll()
	
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	
	--Runtime:removeEventListener("enterFrame", Update)
	--Runtime:removeEventListener("touch", onTouch)
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save player.state, etc.)
	
	-----------------------------------------------------------------------------

	
	local group = self.view
	
	if map ~= nil then
	--	map:destroy()
		map.destroy()
		map = nil
	end
	Runtime:removeEventListener( "key", onKeyEvent )
	
	display.remove(tap_effect)
	tap_effect = nil
	
	display.remove(traject)
	traject = nil
	
	Runtime:removeEventListener("enterFrame", Update)
	Runtime:removeEventListener("touch", onTouch)
	for i=1,4 do
		if banner_trans[i] ~= nil then
			transition.cancel(banner_trans[i])
		end
	end
	
	--Remove tutorial text boxes
	display.remove(tutorial_Bg1)
	tutorial_Bg1 = nil
	display.remove(tutorial_Bg2)
	tutorial_Bg2 = nil
	display.remove(tutorial_Bg3)
	tutorial_Bg3 = nil
	
	if trans_blackbox ~= nil then
		transition.cancel(trans_blackbox)
	end
	
	-- remove them
	display.remove(HeartSprite1)
	display.remove(HeartSprite2)
	display.remove(HeartSprite3)
	display.remove(HeartSprite4)
	display.remove(HeartSprite5)
	
	for i=1,2 do
		display.remove(bgBase)
		bgBase = nil
		display.remove(bgFront[i])
		bgFront[i] = nil
	end
	for i=1,playerMaxHealth do
	
		if myHearts[i] ~= nil then
			display.remove(myHearts[i])
			myHearts[i] = nil
		end
		
	end
	
	display.remove(blackbox)
	blackbox = nil
	
	if redArrow ~= nil then
		--display.remove(redArrow)
		--redArrow = nil
		
	end
	if handicon~= nil then
		--display.remove(handicon)
		--handicon = nil
	end
	if taphereText~= nil then
		--display.remove(taphereText)
		--taphereText = nil
	end
	
	display.remove(bg)
	bg = nil
	display.remove(bg2)
	bg2 = nil
	reverse_Timer = 0
	Enable.reverse = false
	--questionMark.alpha = 0
	display.remove(questionMark)
	questionMark = nil
	display.remove(pauseBtn)
	pauseBtn = nil

	display.remove(banner_bg)
	banner_bg = nil
	
	display.remove(banner_text)
	banner_text = nil

	player:removeSelf()

	if player ~= nil then
		--player:removeEventListener("touch", onTouchPlayer)
		display.remove(player)
		player = nil
	end
	
	for i=#pendulum,1,-1 do
		pendulum[i] = nil
	end
	for i=#pendulumSupport,1,-1 do
		pendulumSupport[i] = nil
	end
	for i=#platform,1,-1 do
		platform[i] = nil
	end
	
	-- new
	if #enemyList > 0 then
		enemyList[1].DestroyAll()
	end
	for e = #enemyList,1,-1 do
		table.remove(enemyList, e)
	end
	
	if popup ~= nil then
		physics.removeBody(popup)
		popup = nil
	end
	
	display.remove(obstacleLayer)
	obstacleLayer = nil
	display.remove(collectableLayer)
	collectableLayer = nil
	display.remove(DeathBg)
	DeathBg = nil
	Enable.distortion = false
	Enable.blur = false
	Enable.playerBlur = false
	
	--End of Screenshake function
	if groupcs ~= nil then
		for i=groupcs.numChildren,1, -1 do
		
			local child = groupcs[i]

				child.alpha = 0 -- blur 0.6		
			
				--if child.alpha == 0 then
					 child.parent:remove( child )
					 child = nil
				--end
			
		end

	end
	--groupcs:removeSelf()
	groupcs = nil
	--playermb:removeSelf()
	playermb = nil

end


local ShavedIceOptions = 
 {
	width = 32,
	height = 32,
	numFrames = 3,
	sheetContentWidth = 96,
	sheetContentHeight = 32
}
local myShavedIceSheet = graphics.newImageSheet("Images/ShavedIceSprite.png", ShavedIceOptions )
local sequenceData = 
{
	{ name = "1", frames={ 1,2,3,1,2,3 }, time = 1000 }
}
--local sprite
local shits = {}
--local last_shit = 0

local function UpdatePendulum(object, degrees, minAngle, maxAngle)

	if object.direction == Directions.left and object.degStart + degrees <= maxAngle then
		local rads = (object.degStart + degrees) * (math.pi / 180.0)
		object.degStart = object.degStart + degrees
		
		object.x = object.radius * math.cos(rads) + object.wheelX
		object.y = object.radius * math.sin(rads) + object.wheelY
		if object.degStart + degrees >= maxAngle then
			local rads2 = (object.degStart - 1  ) * (math.pi / 180.0)
			object.degStart = object.degStart - 1
			object.x = object.radius * math.cos(rads2) + object.wheelX
			object.y = object.radius * math.sin(rads2) + object.wheelY
			object.direction = -object.direction
		end
		object.xScale = 1

	elseif object.direction == Directions.right and object.degStart - degrees >= minAngle then
		local rads = (object.degStart - degrees) * (math.pi / 180.0)
		object.degStart = object.degStart - degrees
		
		object.x = object.radius * math.cos(rads) + object.wheelX
		object.y = object.radius * math.sin(rads) + object.wheelY
		if object.degStart - degrees <= minAngle then
			local rads2 = (object.degStart + 1  ) * (math.pi / 180.0)
			object.degStart = object.degStart + 1
			object.x = object.radius * math.cos(rads2) + object.wheelX
			object.y = object.radius * math.sin(rads2) + object.wheelY
			object.direction = -object.direction
		end
		object.xScale = -1
	end
	
	local t = system.getTimer()/1000
	if  t - object.last_shit >= 0.40 then	-- shit rate here
		object.last_shit = t
		local sprite = display.newSprite( obstacleLayer.group, myShavedIceSheet, sequenceData )
		sprite.x = object.x
		sprite.y = object.y + 40
		if object.direction == Directions.left then
			sprite.rotation = -45
		else
			sprite.rotation = 45
		end
		sprite.IsShavedIce = true
		physics.addBody(sprite, {isSensor = true})
		--physics.addBody(sprite, "static", {isSensor = true})
		
		sprite:play()
		table.insert(shits, sprite)
	end
	if shits ~= nil then
		for t = 1, #shits, 1 do
			if shits[t].frame == 6 then
				display.remove(shits[t])
				table.remove(shits, t)
				return
			end
		end
	end
end


function UpdateObstacles()

	if storyboard.isPaused then return end

	if obstacleLayer ~= nil and obstacleLayer.group ~= nil then

		for i=#pendulumSupport,1, -1 do
			local child = pendulumSupport[i]
			local child2 = pendulum[i]
			if child ~= nil then
				local listener1 = function()
					child.switchingSide = true

					child.direction = -child.direction
	
				end
				if child2.direction == Directions.left then--and child.switchingSide == true then
					--child.direction = Directions.right
					if child2.swingingLeft == true then
						child.rotation = child.rotation + 1.5	-- pendulum support's speed
					end
					child2.swingingLeft = true
					child2.swingingRight = false
					
					
					--transition.to(child,{rotation = 250, time = 1800,transition = easing.inOutExpo,onComplete = listener1})
					--transition.to(child,{rotation = 250, time = 2000,transition = easing.linear,onComplete = listener1})
				elseif child2.direction == Directions.right then--and child.switchingSide == true then
					--child.direction = Directions.left
					if child2.swingingRight == true then
						child.rotation = child.rotation - 1.5	-- pendulum support's speed
					end
					child2.swingingRight = true
					child2.swingingLeft = false
					--transition.to(child,{rotation = 110, time = 2000,transition = easing.linear,onComplete = listener1})
				end	

			end
			
		end
		
		for i=#platform,1, -1 do
			local child = platform[i]
			
			if child ~= nil and platform ~= nil then
				local listener1 = function()
					child.switchingSide = true
					child.direction = -child.direction
					
				end
				if child.direction == Directions.left then--and child.switchingSide == true then

					--child.direction = Directions.right
					child:setLinearVelocity( -child.speed, 0 )
					--child.switchingSide = false
					--child.rotation = child.rotation + 2
					--transition.to(child,{rotation = 250, time = 1800,transition = easing.inOutExpo,onComplete = listener1})
					if child.startingDir == Directions.left and child.x < child.startingX - child.distance then
						listener1()
					elseif child.startingDir == Directions.right and child.x <= child.startingX  then
						--child.x = child.startingX
						listener1()
					end
				end
				if child.direction == Directions.right then--and child.switchingSide == true then

					--child.direction = Directions.left
					--child.rotation = child.rotation - 2
					child:setLinearVelocity( child.speed, 0 )
					--child:translate(2,0)
					--child.switchingSide = false
					if child.startingDir == Directions.right and child.x > child.startingX + child.distance then
						listener1()
					elseif child.startingDir == Directions.left and child.x >= child.startingX  then
						--child.x = child.startingX
						listener1()
					end
				end	
				
				if child.direction == Directions.up then--and child.switchingSide == true then
				
					--child.direction = Directions.right
					child:setLinearVelocity( 0, -child.speed )
					--child.switchingSide = false
					--child.rotation = child.rotation + 2
					--transition.to(child,{rotation = 250, time = 1800,transition = easing.inOutExpo,onComplete = listener1})
					if child.startingDir == Directions.up and child.y < child.startingY - child.distance then
						listener1()
					elseif child.startingDir == Directions.down and child.y <= child.startingY  then
						--child.x = child.startingX
						listener1()
					end
				end
				if child.direction == Directions.down then--and child.switchingSide == true then
				
					--child.direction = Directions.left
					--child.rotation = child.rotation - 2
					child:setLinearVelocity( 0, child.speed )
					--child:translate(2,0)
					--child.switchingSide = false
					if child.startingDir == Directions.down and child.y > child.startingY + child.distance then
						listener1()
					elseif child.startingDir == Directions.up and child.y >= child.startingY  then
						--child.x = child.startingX
						listener1()
					end
				end	
				
			end
			
		end
		
	end
	
end

function UpdateEnemy()

	if storyboard.isPaused then return end

	if player.canJump == false and inAir == true or btnDown == true then
		pauseBtn:setEnabled(false)
	elseif player.canJump == true and inAir == false then
		pauseBtn:setEnabled(true)
	end

	if enemyList ~= nil then
		for i=#enemyList,1,-1 do
			enemyList[i]:Update( player, map, i, enemyList[i]:getType() )
		end
	end
end

local rlistener
local rlistener2

function Update(event)
	
	IdleTime = (system.getTimer()/1000) - IdleStartTime
	if IdleTime >= 3 and b_Idle == true and player.isPlaying == false then	-- hardcoded
		--local life = playerMaxHealth - storyboard.playerHealth + 1
		--player:setSequence(currentFrame * 2 - 1)
		player:play()
	elseif IdleTime <= 3 then
		player:pause()
	end
	
	if holdingBtn == true then
		pauseBtn.alpha = 0
	elseif holdingBtn == false then
		pauseBtn.alpha = 1
	end

	rlistener2 = function()
		if handicon	~= nil and handicon.isPlaying == true then
			handicon.x = handicon.originalX
			handicon.y = handicon.originalY
			handicon.isPlaying = true
			handicon.alpha = 1
			transition.to(handicon,{x=screen.width * 0.58,y=handicon.y-150,time=1600,onComplete=rlistener})
		end
	end
	
	rlistener = function()
		if handicon	~= nil and handicon.isPlaying == true then
			timer.performWithDelay( 500, rlistener2)
		end
	end
	
	if handicon	~= nil and handicon.activated == true and handicon.isPlaying == false then
		handicon.isPlaying = true
		timer.performWithDelay( 500, rlistener2)
		--transition.to(handicon,{x=screen.width * 0.58,y=handicon.y-150,time=1300,onComplete=rlistener})
	end
	
	if redArrow ~= nil then

		redArrow.alpha = 0.8

		if redArrow.y == redArrowOriginalY then
			redArrowUp = true
			redArrowDown = false
		end

		if redArrowUp == true and redArrow ~= nil and redArrow.y ~= nil then
			redArrow.y = redArrow.y - 1.5
			if redArrow.y < redArrowOriginalY - 20 then
				redArrowUp = false
				redArrowDown = true
			end	
		elseif redArrowDown == true and redArrow ~= nil then
			redArrow.y = redArrow.y + 1.5
			if redArrow.y >= redArrowOriginalY then
				redArrowUp = true
				redArrowDown = false
			end
		end

	end
	
	if Enable.reverse == true then
		
		questionMark.x, questionMark.y = player:localToContent( 0, -50 )
		questionMark.alpha = 1

	end
	
	--collectgarbage( "collect" )
	if storyboard.isPaused == false then
		physics:start()
		--if pauseBtn.isEnabled == false then
			pauseBtn:setEnabled(true)
		--end
	
		--Timer for Reverse player effect
		if Enable.reverse == true then
		
			reverse_Timer = reverse_Timer + 1
			
			if reverse_Timer > 500 then		
				reverse_Timer = 0
				Enable.reverse = false
				questionMark.alpha = 0
			end
		
		end

	end
		
	-- heart icon
	-- temp
	if storyboard.playerHealth == 4 then
		display.remove(HeartSprite1)
	elseif storyboard.playerHealth == 3 then
		display.remove(HeartSprite2)
	elseif storyboard.playerHealth == 2 then
		display.remove(HeartSprite3)
	elseif storyboard.playerHealth == 1 then
		display.remove(HeartSprite4)
	elseif storyboard.playerHealth == 0 then
		display.remove(HeartSprite5)
	end
	
	UpdateEnemy()
	--[[
	-- for bullet collision
	if enemyList ~= nil then
		for i=#enemyList,1,-1 do
			local temp_B = enemyList[i].BulletHit()
			if temp_B == true then
				enemyList[i].BulletReset()
				decreaseHealth(1)
			end
		end
	end
	]]

	local child = nil

	if obstacleLayer ~= nil then
		--for i=#pendulum,1, -1 do
		for i=1, #pendulum, 1 do
			child = pendulum[i]
			--if i == 1 then
				UpdatePendulum(child,1.5,30,150)	-- 2nd parameter = pendulum's speed
			--end
		end
	end
	child = nil

	UpdateObstacles()
	
	if player ~= nil then
		
		player.xScale = (player.direction and 1 or player.direction)

		mapPos.diff.x = mapPos.curr.x - mapPos.prev.x
		mapPos.diff.y = mapPos.curr.y - mapPos.prev.y
		mapPos.prev.x, mapPos.prev.y = mapPos.curr.x, mapPos.curr.y
		
		tap_effect.x = tap_effect.x - mapPos.diff.x
		tap_effect.y = tap_effect.y - mapPos.diff.y
		
		differencePX = prevPX - player.x
		differencePY = prevPY - player.y
		
		if differencePX == 0 and differencePY == 0 then
			inAir = false
			player.canJump = true
		end	
	end
	prevPX = player.x
	prevPY = player.y

	if bg2 ~= nil then
		bg2.x = bg2.x - mapPos.diff.x * bg2.parallaxFactor
		--bg2.y = bg2.y - mapPos.diff.y * bg2.parallaxFactorY
	end
	--Scrolling bg layers updates
	if storyboard.currentWorld == 1 then
		for i=1,2 do
			if bgFront ~= nil then

				if bgFront[i].x <= -screen.width * 0.5 then	
					--bgFront[i].x = screen.width * 1.5 
					if i == 1 then
						--bgFront[2].x = screen.width * 0.5
						bgFront[1].x = bgFront[2].x + screen.width
					else
						--bgFront[1].x = screen.width * 0.5
						bgFront[2].x = bgFront[1].x + screen.width
					end
				end

				if bgFront[i].x > screen.width * 1.5 then	
					--bgFront[i].x = -screen.width * 0.5 
					if i == 1 then
						bgFront[1].x = bgFront[2].x - screen.width
						--bgFront[2].x = bgFront[1].x  + screen.width--screen.width * 0.5
					else
						bgFront[2].x = bgFront[1].x - screen.width
						--bgFront[1].x = bgFront[2].x  + screen.width--screen.width * 0.5
					end
				end

				bgFront[i].x = bgFront[i].x - mapPos.diff.x

			end
		end
	end

	
	if mapPos.diff.x == 0 and mapPos.diff.y == 0 and player.state ~= States.walking then
		player.state = States.idle
	elseif player.state ~= States.walking and (mapPos.diff.x ~= 0 or mapPos.diff.y ~=0) then
		player.state = States.moving
	end
	

	--Screenshake function
	if groupcs ~= nil and (Enable.distortion == true or Enable.blur == true) then
			
		local function captureWithDelay2()
			--if groupcs ~= nil then
			if Enable.distortion == true or Enable.blur == true then
			
				local img = display.captureScreen()
				img.id = "cs"
				
				local scaleX = screen.width/screen.height
				local r = {}
				r.r1 = math.random(-scaleX,scaleX)
				
				
				--Blur
				if Enable.blur == true then
					
					img.alpha = 0.71
					img.y = screen.height / 2 
					sfx_Timer = sfx_Timer + 1
					if sfx_Timer > 70 then
						
						sfx_Timer = 0
						Enable.blur = false
					end
				
				--Shake
				elseif Enable.distortion == true then

					r.r2r = {}
					r.r2r.r2 = math.random( 0,1 )
					local scaleY = screen.width/screen.height * 5
					r.r3 = math.random(-scaleY,scaleY)
					
					img.alpha = 0.9
					img.x = (screen.width / 2) + r.r1
					-- if r.r2r.r2 == 0 then
					-- 	img.y = (screen.height / 2) + r.r1
					-- elseif r.r2 == 1 then
					-- 	img.y = (screen.height / 2) - r.r1
					-- end
					img.y = screen.height / 2
					img:rotate(r.r3)
					
					sfx_Timer = sfx_Timer + 5
					if sfx_Timer > 70 then
						
						sfx_Timer = 0
						Enable.distortion = false
						
						for i=1,storyboard.playerHealth do

							--myHearts[i].alpha = 1
							pauseBtn.alpha = 1

						end

					end

				end

				if groupcs ~= nil then
					groupcs:insert(img)
				end

				if(Enable.distortion == false and Enable.blur == false) then
					img.alpha = 0
					display.remove(img)
					img = nil
					collectgarbage( "collect" )
				end

			end

		end
		sfx_delay = sfx_delay + 3
			
		if Enable.distortion == true and sfx_delay > 39 then
			sfx_delay = 0
			timer.performWithDelay( 100, captureWithDelay2 )
		elseif Enable.blur == true and sfx_delay > 3 then
			sfx_delay = 0
			timer.performWithDelay( 100, captureWithDelay2 )
		end
	end
	--End of Screenshake function
	
	if groupcs ~= nil then
		for i=groupcs.numChildren,1, -1 do
		
			child = groupcs[i]
			if child ~= nil and child.id == "cs" then
				if Enable.distortion == true then
					child.alpha = child.alpha * 0.9 -- blur 0.6
				elseif Enable.blur == true then
					child.alpha = child.alpha * 0.9
				end
				
				if child.alpha <= 0.3 then
					 child.parent:remove( child )
					 child = nil
					 collectgarbage( "collect" )
				end
			end
		end
	end
	child = nil

	if Enable.distortion == false and Enable.blur == false then
		if groupcs ~= nil then
			for i=groupcs.numChildren,1, -1 do
			
				child = groupcs[i]
				if child ~= nil and child.id == "cs" then
					--if Enable.distortion == true then
						child.alpha = 0.0 -- blur 0.6		
					--elseif Enable.blur == true then
						--child.alpha = child.alpha * 0.7
					--end
					
					if child.alpha == 0 then
						 child.parent:remove( child )
						 child = nil
						 collectgarbage( "collect" )
					end
				end
					
			end
		end
	end
	child = nil

	local vx, vy = player:getLinearVelocity()
	--Code for player left right movement
	if player ~= nil and btnDown == false and player.state == States.walking and onIce == false and holdingBtn == false then
		
		-- if player has reached the tap destination
		if math.abs(player.x - playerPrevPos.x) >= math.abs(touchDistFromPlayer.x) then

			vx = math.floor(vx - vx / 5)
		--	vy = math.floor(vy / 2) 
			player:setLinearVelocity( vx, vy ) -- decelerate
			
			transition.pause(tap_effect) -- remove tap_effect

			-- if player has stopped moving, no velocity
			if isInRange( {vx,vy} , -.5, .5 ) then
				clamp( {vx,vy}, -.5, .5 )
				player.state = States.idle
			end

		-- else continue walking
		elseif pushingCrate == true or onPlatform == false then
			player:setLinearVelocity(200 * player.direction,vy)
		end
		
	end

	if player.state == States.moving then

			-- if player has stopped moving, no velocity
			if isInRange( {vx,vy} , -1, 1 ) then
				vx, vy = 0, 0
				player.state = States.idle
			end

	end

	-- Code for holding down of the finger for jump
	if btnDown == true then		
		btnDownTimer = btnDownTimer + 1
		if btnDownTimer > 2 then
			holdingBtn = true
			btnDown = false
			btnDownTimer = 0
		end
	end
	
	if map ~= nil then
		map.updateView()
		mapPos.curr.x, mapPos.curr.y = map.getViewpoint()
	end

	if holdingBtn == true then	
		btnDownTimer = btnDownTimer + 1
	end
	
	-- collided with popup
	if storyboard.isPaused == false and b_pop == true then
		b_pop = false
		physics:pause()
		storyboard.isPaused = true
		pauseBtn:setEnabled(false)
		
		storyboard.showOverlay( "Popup", { params = { one = popup.text } } )
	end

	if touchHandler.numTouches > 0 then
		screen.debugText.text = "numTouches : " .. tostring(touchHandler.numTouches)
	else
		screen.debugText.text = ""
	end

	screen.debugText.text = "numTouches : " .. tostring(touchHandler.numTouches)

	screen.debugText3.text = "mapPos.curr.x : " .. tostring(mapPos.curr.x)
	screen.debugText4.text = "mapPos.curr.y : " .. tostring(mapPos.curr.y)

end 

-- listener for touch event on Player
function onTouchPlayer ( event )

	if storyboard.isPaused == false and player.invul == false and
		touchHandler.numTouches < 2 then
	
		local target = event.target

		touchHandler:updateTouch(event)
		
		if event.phase == "began" then

			if touchHandler.beganOn ~= "screen" then
				touchHandler.beganOn = "player"
			end

			lineOrigin.x, lineOrigin.y = player:localToContent( 0, 0 )

			traject.width = 5
			traject.alpha = 1
			traject.x = lineOrigin.x - mapPos.curr.x
			traject.y = lineOrigin.y - mapPos.curr.y - 5
			traject_created = true
				
			holdingBtn = true
			touchJumpX = event.x - mapPos.curr.x
			touchJumpY = event.y - mapPos.curr.y
					
		elseif	event.phase == "moved" and
				touchHandler.beganOn == "player" and
				touchHandler.numTouches < 2 then

				btnDown = true
				if btnDown == true and traject_created == false and tutorial.step1 ~= true then
					traject.alpha = 1
					traject.x = lineOrigin.x + mapPos.curr.x
					traject.y = lineOrigin.y + mapPos.curr.y - 5
					traject_created = true
				end

			
		elseif event.phase == "ended" then 

			btnDown = false
			btnDownTimer = 0

		end
		
		return true
	
	end

end

--Function for both click to move, and drag to and release to jump
local function onTouch(event)

	if storyboard.isPaused == false then

		touchHandler:updateTouch(event)

		if player ~= nil  and player.invul == false then

			if event.phase == "began" then 

				if touchHandler.beganOn ~= "player" then touchHandler.beganOn = "screen" end

				b_Idle = false
				player:setFrame(1)

				lineOrigin.x, lineOrigin.y = player:localToContent( 0, 0 )

				mapPos.before_touch.x, mapPos.before_touch.y = map.getViewpoint()
				
			elseif event.phase == "moved" then 
				b_Idle = false
				
				pauseBtn:setEnabled(false)

				if holdingBtn == true then
					
					local widthcheck = CalculateDistance(event.x, event.y, lineOrigin.x, lineOrigin.y)
					
					local life = playerMaxHealth - storyboard.playerHealth + 1
					player:setSequence(life * 2)
					player:pause()
					if traject.width < 30 then
						player:setFrame(1)
					elseif traject.width < 90 and traject.width > 30 then
						player:setFrame(2)
					elseif traject.width > 90 then
						player:setFrame(3)
					end
					
					if traject.width < 200 and widthcheck < 200 then
						traject.width = widthcheck
					end
					
				--	traject:setReferencePoint( display.CenterLeftReferencePoint )
					traject.alpha = 1
					traject.x = lineOrigin.x
					traject.y = lineOrigin.y
					local dir = math.atan2(( event.y - lineOrigin.y ), ( event.x - lineOrigin.x )) * 180 / math.pi
					traject:rotate(dir - prevAngle )
					prevAngle = dir

				elseif player.state == States.idle and touchHandler.beganOn == "screen" then

					if touchHandler.numTouches == 1 then -- one touch, look around map

						-- manipulate the screen to look around the map
						local diff_pos = { x = event.x - event.xStart, y = event.y - event.yStart }
						local newMapPos = { x = mapPos.before_touch.x - diff_pos.x, y = mapPos.before_touch.y - diff_pos.y }

						-- make sure moving of the camera doesn't go out of bound
						newMapPos.x = clamp( newMapPos.x, screen.width / 2, map.data.width - (screen.width / 2) )
						newMapPos.y = clamp( newMapPos.y, screen.height / 2, map.data.height - (screen.height / 2) )

						map.enableFocusTracking(false)
						map.positionCamera( newMapPos.x, newMapPos.y )

						touchHandler.isMovingMap = true

						--	screen.debugText.text = "isMovingMap"

					elseif touchHandler.numTouches > 1 then -- two or more touches, zoom in/out

						map.enableFocusTracking(true)

						-- get this touch and the last active touch
						local touch1, touch2 = touchHandler.activeTouch, touchHandler.lastActiveTouch

						local currZoomDist = touchHandler.distBetween(touch1,touch2)
						local zoomAmt = 0
						local zoomFactor = 50
						local newMapScale = { x = map.xScale, y = map.yScale }

						if touchHandler.prevZoomDist == 0 then
							touchHandler.prevZoomDist = currZoomDist
						end

						zoomAmt = (currZoomDist - touchHandler.prevZoomDist) / zoomFactor

						touchHandler.prevZoomDist = currZoomDist

						newMapScale.x = newMapScale.x + (newMapScale.x * zoomAmt)
						newMapScale.y = newMapScale.y + (newMapScale.y * zoomAmt)

						screen.debugText2.text = "newMapScale.y : " .. tostring( newMapScale.y )

						clamp( newMapScale, 0.6, 1.5 )

						map.xScale = newMapScale.x ~= 0 and newMapScale.x or map.xScale
						map.yScale = newMapScale.y ~= 0 and newMapScale.y or map.yScale

						touchHandler.isZoomingMap = true

					end

				end
				
			elseif event.phase == "ended" then 

				b_Idle = true
				IdleStartTime = system.getTimer()/1000
				
				--local 
				life = playerMaxHealth - storyboard.playerHealth + 1
				player:setSequence(life * 2 - 1)

				--	print(	"\ncanMove == true				", canMove,
				--			"\nbtnDown == false				", not btnDown,
				--			"\nholdingBtn == false			", not holdingBtn,
				--			"\nplayer.canJump == true		", player.canJump,
				--			"\ninAir == false				", not inAir,
				--			"\nplayer.state == \"idle\"		", player.state == "idle",
				--			"\ntouchHandler.isMovingMap == false	", not touchHandler.isMovingMap
				--			)
				
				if holdingBtn == true and tutorial.step1 ~= true then

					local maxX = 15; 
					local minX = 0.0;
					local maxY = 20;
					local minY = 0.0;
					
					player.state = States.moving
					local maxLimit = 1
						
					local dir = math.atan2(( event.y - lineOrigin.y ), ( event.x - lineOrigin.x ))
					--local forceX = 10 * math.cos(dir)-- * (1 - btnDownTimer/25)
					--local forceY = 10 * math.sin(dir)-- * (1 - btnDownTimer/25)
					local forceX = maxX * ( event.x - lineOrigin.x ) / 90--(event.x - lineOrigin.x) * 0.05 --* math.cos(dir)
					local forceY = maxY * ( event.y - lineOrigin.y ) / 90--(event.y - player.y) * 0.2--* math.sin(dir)
					
					if forceX > maxX and event.x > lineOrigin.x then
						forceX = maxX
					end
					if forceX < -maxX and event.x < lineOrigin.x then
						forceX = -maxX
					end
					if forceY > maxY and event.y > lineOrigin.y then
						forceY = maxY
					end
					if forceY < -maxY and event.y < lineOrigin.y then
						forceY = -maxY
					end
					if forceX <= minX and event.x >= lineOrigin.x then
						forceX = minX
					end
					if forceX >= -minX and event.x <= lineOrigin.x then
						forceX = -minX
					end
					if forceY <= minY and event.y >= lineOrigin.y then
					--	forceY = minY
					end

						if inAir == false or player.canJump == true then

							player:setLinearVelocity( 0, 0 )

							if Enable.reverse == false then 
								player:applyLinearImpulse( forceX, forceY, player.x, player.y) 
							elseif Enable.reverse == true then
								player:applyLinearImpulse( -forceX, forceY, player.x, player.y) 
							end
							
						elseif inAir == true or player.canJump == false then
							
							if event.y > lineOrigin.y then

								player:setLinearVelocity( 0, 0 )

								--forceY = forceY * 0.5
								if Enable.reverse == false then
									player:applyLinearImpulse( forceX, forceY, player.x, player.y) 
								elseif Enable.reverse == true then						
									player:applyLinearImpulse( -forceX, forceY, player.x, player.y) 
								end

							end		
							
						end

					if tutorial.step2 == true then

						display.remove(tutorial_Bg2)
						tutorial_Bg2 = nil
						tutorial_Bg3 = display.newImageRect("Images/Visual_Feedback/Tutorial/land.png",192,64)
						tutorial_Bg3.x = screen.width*0.5
						tutorial_Bg3.y = screen.height*0.7
						transition.to(tutorial_Bg3,{alpha = 0,time = 4500})
						
						--handicon:removeSelf()
						if handicon~= nil then
							display.remove(handicon)
							handicon = nil
						end
						canMove = true
						tutorial.step1 = false
						tutorial.step2 = false
					end
					
					if forceX > 0 then
						player.direction = Directions.right
					else 
						player.direction = Directions.left
					end

					transition.pause(tap_effect)
				
				elseif	canMove == true and
						btnDown == false and
						holdingBtn == false and
						player.canJump == true and
						inAir == false and
						(player.state == States.idle or pushingCrate == true or onPlatform == true) and
						touchHandler.isMovingMap == false and
						touchHandler.isZoomingMap == false then

					playerPrevPos.x, playerPrevPos.y = player.x, player.y
					touchDistFromPlayer.x = math.abs(event.x - lineOrigin.x)
					touchDistFromPlayer.y = math.abs(event.y - lineOrigin.y)

					player:setLinearVelocity( 0, 0 )
					player.state = States.walking
					
					if event.x > lineOrigin.x then
						player.direction = Directions.right
					elseif event.x < lineOrigin.x then
						player.direction = Directions.left
					end 

					if Enable.reverse then
						player.direction = player.direction * -1
						tap_effect.x = lineOrigin.x + touchDistFromPlayer.x * player.direction
					else
					
					tap_effect.x = event.x end					
					tap_effect.y = event.y
					tap_effect.alpha = 1
					tap_effect:play()
					transition.to(tap_effect,
						{
							alpha = 0.0,
							iterations = 20,
							onRepeat =	function ( obj )
										--	obj:play()
										end,
							onPause =	function ( obj )
										 	obj.alpha = 0
										end,
							onCancel = onPause
						})

				end
				
				traject.width = 5
				traject.alpha = 0
				traject.x = lineOrigin.x
				traject_created = false
				btnDown = false
				btnDownTimer = 0
				holdingBtn = false

				-- transition back to original position
				-- if map is not in the original position before the player looked around
				if not compareTable(mapPos.curr, mapPos.before_touch) then

					-- initialise the step
					if touchHandler.isMovingMap then
						local step = 50
						mapPos.delta.x = (mapPos.curr.x - mapPos.before_touch.x) / step
						mapPos.delta.y = (mapPos.curr.y - mapPos.before_touch.y) / step
					end

					mapPos.curr.x = mapPos.curr.x - mapPos.delta.x
					mapPos.curr.y = mapPos.curr.y - mapPos.delta.y
					map.setViewpoint(mapPos.curr.x, mapPos.curr.y)

					print("\tmapPos.curr			: x = " .. mapPos.curr.x .. " y = " .. mapPos.curr.y)

				else -- transitioning ended

					print("transition end")

					mapPos.delta.x, mapPos.delta.y = 0, 0
					tmapPos.before_touch.x, tmapPos.before_touch.y = 0, 0

					map.enableFocusTracking(true)
					map.setCameraFocus(player)

				end

				touchHandler:reset()

				if touchHandler.numTouches < 2 then`
					map.xScale, map.yScale = 1,1
					screen.debugText2.text = ""
				end

			end -- event.phase check

		end

	end
	
end

Runtime:addEventListener("touch", onTouch)

local function setHealth( value )
	
	if value == -1 then
		bg1Alpha = bg1Alpha - 0.25
		bg2Alpha = bg2Alpha + 0.25
	elseif value == 1 then
		bg1Alpha = bg1Alpha + 0.25
		bg2Alpha = bg2Alpha - 0.25
	end

	bg.alpha = bg1Alpha
	bg2.alpha = bg2Alpha

end

--Function to detect collision of player and different objects
function onCollision( event )

    if ( event.phase == "began" ) then

    	if event.other.props then
			for k,v in pairs(event.other.props) do
				event.other[k] = v
			end
		end

        if event.other.IsGround then
            player.canJump = true

			local vx, vy = player:getLinearVelocity()

			if inAir then vx = 0 end

           	player:setLinearVelocity( vx, 0 )

			inAir = false
				
		elseif event.other.IsIce then
		
            onIce = true
			player.state = States.moving
			
		elseif event.other.IsPlatform then
			
			local vxx,vyy
			vxx,vyy = player:getLinearVelocity()
			if player.y < event.other.y then
				event.other.isSensor = true	
			end
            if vyy <= 0 then
				--if event.other.isSensor == false then
					event.other.isSensor = true	
				--end
			elseif vyy > 0 or player.y < event.other.y then
				event.other.isSensor = false
				player.state = States.idle
				player.canJump = true
				onPlatform = true
				inAir = false
				btnDown = false 
				holdingBtn = false
			end
			
		elseif event.other.IsExit and storyboard.isPaused == false then
			
			local function nextScene ( event )
				
				local numStars = gameData.myTable.levelData[storyboard.currentWorld][storyboard.currentLevel].stars
				if storyboard.playerHealth > 4 then
					gameData.myTable.levelData[storyboard.currentWorld][storyboard.currentLevel].stars = 3
				elseif storyboard.playerHealth >= 3 and numStars ~= 3 then
					gameData.myTable.levelData[storyboard.currentWorld][storyboard.currentLevel].stars = 2
				elseif storyboard.playerHealth >= 1 and numStars < 2 then
					gameData.myTable.levelData[storyboard.currentWorld][storyboard.currentLevel].stars = 1
				end
				
				if storyboard.currentLevel ~= 8 and gameData.myTable.levelData[storyboard.currentWorld][storyboard.currentLevel+1].locked == true then
					gameData.myTable.levelData[storyboard.currentWorld][storyboard.currentLevel+1].locked = false
				end

				storyboard.firstEntry = true
				storyboard.isPaused = true


				if storyboard.currentLevel == 8 then
					storyboard.showOverlay("SocialNetworkSharing")
				else
					storyboard.showOverlay("LevelClear")
				end
	
			end
			
			local listener2 = function()
				timer.performWithDelay( 50, nextScene)
				--transition.to(player,{y = - 500,time=500,onComplete = listener2})				
			end
			
			local listener1 = function()
				--timer.performWithDelay( 300, nextScene)
				if player ~= nil then
					transition.to(player,{y = event.other.y - 60,alpha = 0,time=600,onComplete = nextScene})	
				end
			end
			
			if playermb ~= nil then
				playermb.alpha = 0
			end

			player.state = States.idle
			Enable.playerBlur = false
			transition.to(player,{x=event.other.x,time=300,onComplete = listener1})

		elseif event.other.IsPit then
			print("Hit Pit")
			
			if player.invul == false then
				local disableInvul = function()
					player.invul = false
					pauseBtn.alpha = 1
				end

				Enable.reverse = false
				questionMark.alpha = 0

				decreaseHealth(1)
				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
				--decreaseHealth(1)
				player.state = States.idle
				player:setLinearVelocity(0,0)
				player.invul = true
				transition.to(player,{x =  player.originalX, y = player.originalY, time = 300,onComplete = disableInvul})
			end
						
		elseif event.other.IsSpike then
			print("Hit Spike")
			
			if player.invul == false then
				local disableInvul = function()
					player.invul = false
					pauseBtn.alpha = 1
				end

				Enable.reverse = false
				questionMark.alpha = 0

				decreaseHealth(1)
				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
				--decreaseHealth(1)
				player.state = States.idle 
				player:setLinearVelocity(0,0)
				player.invul = true
				transition.to(player,{x =  player.originalX, y = player.originalY, time = 200,onComplete = disableInvul})
				--decreaseHealthObj(2)
			end	

		elseif event.other.IsBlade then
			print("Hit bBlade")
			
			if player.invul == false then
				local disableInvul = function()
					player.invul = false
					pauseBtn.alpha = 1
				end
				decreaseHealth(1)
				--decreaseHealth(1)
				player.state = States.idle
				player:setLinearVelocity(0,0)
				player.invul = true
				transition.to(player,{x =  player.originalX, y = player.originalY, time = 200,onComplete = disableInvul})
				--storyboard.gotoScene("dummyscene")			
			end	
			
		elseif event.other.pendulum then
			print("Hit Pendulum")
			
			if player.invul == false then
				local disableInvul = function()
					player.invul = false
					pauseBtn.alpha = 1
				end
				decreaseHealth(1)
				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
				--decreaseHealth(1)
				player.state = States.idle
				player:setLinearVelocity(0,0)
				player.invul = true
				transition.to(player,{x =  player.originalX, y = player.originalY, time = 200,onComplete = disableInvul})
			end
			
		elseif event.other.IsShavedIce == true then
			print("Hit by Shaved Ice")

			if player.invul == false then
				local item = event.other
				if item ~= nil then
					decreaseHealthEnemy(1)
					
				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
					
					Enable.reverse = true
					
					questionMark.alpha = 1
					questionMark:play()
					
					player.invul = true
					
					local function listener( event )
						player.invul = false
					end

					timer.performWithDelay( 1000, listener )
				end
			end
			
		elseif event.other.IsInhalant == true then
			print("Hit by Inhalant")

			if player.invul == false then
				local item = event.other
				if item ~= nil and item.isDead == false then
					item.isDead = true
					
					decreaseHealthEnemy(1)

				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
					
					Enable.distortion = true
					
					local listener1 = function()
						if item ~= nil then
							display.remove(item)
							item = nil
						end
					end
					transition.to( item,{alpha=0,timer=300,onComplete = listener1} )
				end
			end
			
		elseif event.other.IsSpray == true then
			print("Hit by Spray")

			if player.invul == false then
				local item = event.other
				if item ~= nil then
					decreaseHealthEnemy(1)
					
				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
					Enable.distortion = true
					
					player.invul = true
					
					local function listener( event )
						player.invul = false					-- player nil when 0 lives
					end

					timer.performWithDelay( 500, listener )	-- based on how long distortion lasts X
				end
			end
			
		elseif event.other.IsBoom == true then
			print("Hit by Boom")
			
			if player.invul == false then
				local item = event.other
				if item ~= nil then
					player.invul = true
					
					local function listener( event )
						player.invul = false
						
						decreaseHealth(1)

					if (storyboard.isVibrateOn) then -- Check if the checkbox is on
						print( "Vibrate the device" )
						system.vibrate() -- Vibrate the device
					end
						
						player.state = States.idle
						player:setLinearVelocity(0,0)
						transition.to(player,{x =  player.originalX, y = player.originalY, time = 200})
					end

					timer.performWithDelay( 2000, listener )
				end
			end
			
		elseif event.other.IsHeroin == true then
		print("Hit by Heroin")
			if player.invul == false then
				local item = event.other
				if item ~= nil and item.isDead == false then
					item.isDead = true
					decreaseHealthEnemy(1)

				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
					Enable.distortion = true
					
					for i=1,storyboard.playerHealth do
						pauseBtn.alpha = 0
					end
					
					
					local listener1 = function()
						if item ~= nil then--and item.isDead == false then
							item.isDead = true
							--item:removeSelf()
							display.remove(item)
							print("item id "..item.id)
							enemyList[item.id].Destroy()
							table.remove(enemyList, item.id)
							item = nil
						end
					end
					transition.to(item,{alpha=0,timer=500,onComplete = listener1})
				end
			end
			
		elseif event.other.IsBullet == true then
		print("Hit by Bullet")
			if player.invul == false then
				local item = event.other
				if item ~= nil then
					decreaseHealthEnemy(1)
					
				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
					
					Enable.distortion = true
					
					for i=1,storyboard.playerHealth do
						pauseBtn.alpha = 0
					end
				end
			end
			
		elseif event.other.IsCannabis == true then
		print("Hit by Cannabis")
			if player.invul == false then
				local item = event.other
				if item ~= nil and item.isDead == false then
					item.isDead = true
					decreaseHealthEnemy(1)

				if (storyboard.isVibrateOn) then -- Check if the checkbox is on
					print( "Vibrate the device" )
					system.vibrate() -- Vibrate the device
				end
					
					Enable.reverse = true
					
					questionMark.alpha = 1
					questionMark:play()
					
					
					local listener1 = function()
						if item ~= nil then
							item.isDead = true
							item:removeSelf( )
							display.remove(item)
							enemyList[item.id].Destroy()
							table.remove(enemyList, item.id)
							item = nil
						end				
					end
					transition.to(item,{alpha=0,timer=300,onComplete = listener1})
				end
			end
		
		elseif event.other.IsPickup then
            local item = event.other
			
			local onTransitionEnd = function(event)
			   --event:removeSelf()
			   display.remove(event)
			   event = nil
			end
			
			-- fade out the item
			transition.to(item, { time = 300, alpha = 0, onComplete=onTransitionEnd })
			
		elseif event.other.IsArrow then
		
            local item = event.other
			
			local onTransitionEnd = function(event)
			   --event:removeSelf()
			   display.remove(event)
			   event = nil
		
			end
			
			local onTransitionEnd2 = function(event)
			  -- taphereText:removeSelf()
			   display.remove(taphereText)
			   taphereText = nil
			end
			
			if handicon ~= nil then
				handicon.activated = true
			end
			
			-- fade out the item
			redArrowUp = false
			redArrowDown = false
			canMove = false
			tutorial.step1 = false
			tutorial.step2 = true
			
			display.remove(tutorial_Bg1)
			tutorial_Bg1 = nil
			
			tutorial_Bg2 = display.newImageRect("Images/Visual_Feedback/Tutorial/Jump.png",192,64)
			tutorial_Bg2.x = screen.width*0.75
			tutorial_Bg2.y = screen.height*0.65
			tutorial_Bg2.alpha = 0.9
			
			player.state = States.idle
			transition.to(player, { x = item.x, time = 300 })
			transition.to(item, { time = 200, alpha = 0, onComplete = onTransitionEnd })
			transition.to(taphereText, { time = 200, alpha = 0, onComplete = onTransitionEnd2 })
			transition.pause(tap_effect)
			
		elseif event.other.IsPopup then
			
			local function listener( event )
				physics.removeBody(popup)
			end

			timer.performWithDelay( 100, listener )
			
			b_pop = true
			
		elseif event.other.IsHealth then
		
            local item = event.other
			setHealth( 1 )
			--local onTransitionEnd = function(event)
			if item ~= nil then
			   --item:removeSelf()
			   	display.remove(item)
				item = nil
			end

        end
		
    elseif ( event.phase == "ended" ) then
	
		if event.other.IsCrate then	
			pushingCrate = false
		end
        if event.other.IsGround then
            player.canJump = false
			inAir = true
			
		elseif event.other.IsIce then
            onIce = false
			
		elseif event.other.IsPlatform then
			event.other.isSensor = true
			inAir = true
			onPlatform = false

			player.gravityScale = 1.0

        end
    end
end

--Function that deals with the loss of player life when enemy touches
function decreaseHealthObj(h)

	if storyboard.playerHealth > 1 then
		storyboard.playerHealth = storyboard.playerHealth - h
		player.playerHealth = storyboard.playerHealth
		storyboard.purgeScene("GameScene")
		storyboard.reloadScene()
		
			-- Here
			--if storyboard.playerHealth > 3 then
			--	player:setFrame(1)
			--elseif storyboard.playerHealth > 1 then
			--	player:setFrame(4)
			--else
			--	player:setFrame(7)
			--end
				
	else
		Enable.distortion = false

		if groupcs ~= nil then
		for i=groupcs.numChildren,1, -1 do
		
			local child = groupcs[i]
			if child ~= nil and child.id == "cs" then

				child.alpha = 0 -- blur 0.6		
				
				if child.alpha == 0 then
					 child.parent:remove( child )
					 child = nil
					 collectgarbage( "collect" )
				end
			end
				
		end
	end
		physics:pause()
		blackbox.alpha = 1
		banner_bg.alpha = 0
		banner_text.alpha = 0
		DeathBg.alpha = 1
	    DeathBg:play()
		pauseBtn.alpha = 1
		local listener1 = function()
		local options =
		{
			effect = "fade",
			time = 500,
		}
		storyboard.gotoScene("LevelSelect",options)	
		storyboard.firstEntry = true
		end
		if storyboard.isPaused == false then
			timer.performWithDelay(4500,listener1)
		end
		storyboard.isPaused = true

	end
end

function decreaseHealthEnemy(h)

	if player.invul == false then
		if storyboard.playerHealth > h then
			if Enable.distortion == false then
				storyboard.playerHealth  = storyboard.playerHealth - h
				player.playerHealth = storyboard.playerHealth
				Enable.distortion = false
			end
		else
			Enable.distortion = false
			
			if groupcs ~= nil then
				for i=groupcs.numChildren,1, -1 do
				
					local child = groupcs[i]
					if child ~= nil and child.id == "cs" then

						child.alpha = 0 -- blur 0.6		
				
						if child.alpha == 0 then
							 child.parent:remove( child )
							 child = nil
							 collectgarbage( "collect" )
						end
					end
				end
			end

			physics:pause()
			blackbox.alpha = 1
			banner_bg.alpha = 0
			banner_text.alpha = 0
			DeathBg.alpha = 1
			DeathBg:play()
			pauseBtn.alpha = 1

			local listener1 = function()

				local options =
				{
					effect = "fade",
					time = 500,
				}

				storyboard.gotoScene("LevelSelect",options)	
				storyboard.firstEntry = true

			end

			if storyboard.isPaused == false then
				timer.performWithDelay(4500,listener1)
			end

			storyboard.isPaused = true
		end
	
		life = playerMaxHealth - storyboard.playerHealth + 1
		
		if storyboard.currentWorld == 1 then
			for i = 1,2 do
				bgBase:setFrame( life )
				bgFront[i]:setFrame( life )
			end
		end
		
		if storyboard.currentWorld == 2 then
			bg2:setFrame(life)
		end
		
		--if enemyList ~= nil then
		--	for i=#enemyList,1,-1 do
		--		enemyList[i]:changeAnimation(storyboard.playerHealth)
		--	end
		--end
	end
end

--Function that deals with the loss of player life 
function decreaseHealth(h)

	if player.invul == false then
		if storyboard.playerHealth > h then
			--if Enable.distortion == false then
				storyboard.playerHealth  = storyboard.playerHealth - h
				player.playerHealth = storyboard.playerHealth
				blackbox.alpha = 1.0 -- later
				local listener1 = function()
					if storyboard.playerHealth > 0 then	
						transition.to(blackbox,{alpha = 0,time=500})
						-- Here this only
						life = playerMaxHealth - storyboard.playerHealth + 1
						player:setSequence(life*2 - 1)
					end
				end
				timer.performWithDelay(300,listener1)
				Enable.distortion = false
				
			--end
			
		else
			Enable.distortion = false
			
			if groupcs ~= nil then
				for i=groupcs.numChildren,1, -1 do
				
					local child = groupcs[i]
					if child ~= nil and child.id == "cs" then

						child.alpha = 0 -- blur 0.6		
				
						if child.alpha == 0 then
							 child.parent:remove( child )
							 child = nil
							 collectgarbage( "collect" )
						end
					end
						
				end
			end
			physics:pause()
			blackbox.alpha = 1
			banner_bg.alpha = 0
			banner_text.alpha = 0
			DeathBg.alpha = 1
			DeathBg:play()		
			pauseBtn.alpha = 1
			local listener1 = function()
			local options =
			{
				effect = "fade",
				time = 500,
			}
			storyboard.gotoScene("LevelSelect",options)	
			storyboard.firstEntry = true
			end
			if storyboard.isPaused == false then
				timer.performWithDelay(4500,listener1)
			end
			storyboard.isPaused = true

		end
		
		life = playerMaxHealth - storyboard.playerHealth + 1
		--myHealthbar:setFrame( life )
		-- Here
		--player:setFrame(life)
		if storyboard.currentWorld == 1 then
			for i = 1,2 do
				bgBase:setFrame( life )
				bgFront[i]:setFrame( life )
			end
		end
		if storyboard.currentWorld == 2 then
			bg2:setFrame(life)
		end
		
		if enemyList ~= nil then
			for i=#enemyList,1,-1 do
				enemyList[i]:changeAnimation(storyboard.playerHealth)
			end
		end
	end

end

function CalculateDistance(x1,y1,x2,y2)
	
	--return math.sqrt( math.pow ( ( x2 - x1 ), 2 ), math.pow ( ( y2 - y1 ), 2 ) )
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)

end

function onKeyEvent( event )

	local phase = event.phase
	local keyName = event.keyName
 
	print(keyName .. " " .. phase)

	if "f" == keyName then

		local fakeTouchEvent = 
		{
			id = "fakeTouch",
			name = "touch",
			phase = "began",
			x = 0,
			y = 0,
			xStart = 0, 
			yStart = 0
		}

		if phase == "down" then
			touchHandler:addTouch(fakeTouchEvent)
		else
			fakeTouchEvent.phase = "ended"
			touchHandler:removeTouch(fakeTouchEvent)
		end

	end

	if phase ~= "down" then return true end
	if "escape" == keyName then
		storyboard.showOverlay( "ExitScreen" )
	elseif "tab" == keyName then
		onCollision( { other = { IsExit = true, x = 0.0, y = 0.0 }, phase = "began" } )
	end

	--Volume Control(Working with keypad for now)
	if keyName == "volumeUp" then --Key that is used/pressed to increase volume.
		local masterVolume = audio.getVolume()
		print( "Volume:", masterVolume )
		if ( masterVolume < 1.0 ) then 
			masterVolume = masterVolume + 0.1 -- Increase the volume by 0.1 whenever up key is pressed.
			audio.setVolume(masterVolume ) -- Set the new mastervolume affter increasing the volume.
		end

	elseif keyName == "volumeDown" then -- Key that is used/pressed to decrease the volume.

		local masterVolume = audio.getVolume()
		print( "Volume:", masterVolume )
		if ( masterVolume > 0.0 ) then
			masterVolume = masterVolume - 0.1 -- Decrease the volume by 0.1 whenever down key is pressed.
			audio.setVolume( masterVolume ) -- Set the new mastervolume affter decreasing the volume.
		end

	end

	return true  --SEE NOTE BELOW
end

--add the key callback
Runtime:addEventListener( "key", onKeyEvent )

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene