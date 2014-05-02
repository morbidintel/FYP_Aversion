---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )
local gameData = require("GameData")

local xMultiplier = display.contentWidth/480  
local yMultiplier = display.contentHeight/320

--local GameScene = display.newGroup()
local screenWidth = display.contentWidth
local screenHeight = display.contentHeight

local bgs = {bg1, bg2}
--local bg, bg2
local dots, dot_yellow
local pageDots1,pageDots2,pageDots3
local button1,button2,button3

local bgoverlay_animate = false
local titleDisplay
local textDisplay = {}

local button = {}
local buttonText = {}
local buttonLock = {}
local backBtn
local xStart
local groupBg
local prevGroup
local groupStars = display.newGroup()

local group = display.newGroup()
local groupStatic = display.newGroup()

local currentPage = 1
local maxPage = gameData.GetNumOfWorlds()

local dot_gap = 21
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local image, text1, text2, text3, memTimer

local function onButtonEvent(event)

	local btn = event.target
	
	if btn.id ~= "close_btn" and btn.id ~= "unlock_btn" then
	
		storyboard.currentLevel = btn.id
		storyboard.currentWorld = btn.world_id
		--print("id : ",btn.id)
		print("world :",btn.world_id)
		
		local function nextScene ( event )
			storyboard.gotoScene( "GameScene")--,"slideLeft",600)
		end
		timer.performWithDelay( 100, nextScene)
		Runtime:removeEventListener("touch", onTouch)
	end
	
	if btn.id == "close_btn" then
			
		local function nextScene ( event )
			storyboard.gotoScene( "MainMenu","fade",300)
		end
				
		timer.performWithDelay( 100, nextScene)	
		
	elseif btn.id == "unlock_btn" then
	
		for i = 1,1 do 
			for j = 1,8 do

				gameData.myTable.levelData[i][j].locked = false 
				if gameData.myTable.levelData[i][j].locked == false then
					if buttonLock[i][j] ~= nil then
						buttonLock[i][j].alpha = 0
						display.remove(buttonLock[i][j])
						buttonLock[i][j] = nil
						button[i][j]:setEnabled(true)
					end
				end

			end
		end
		for i = 2,2 do 
			for j = 1,8 do

				gameData.myTable.levelData[i][j].locked = false 
				if gameData.myTable.levelData[i][j].locked == false then
					if buttonLock[i][j] ~= nil then
						buttonLock[i][j].alpha = 0
						display.remove(buttonLock[i][j])
						buttonLock[i][j] = nil
						button[i][j]:setEnabled(true)
					end
				end

			end
		end
	end
	

	
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	collectgarbage( "collect" )
	print("GARBAGE : "..collectgarbage("count")/1000)
	groupBg = display.newGroup()
	prevGroup = display.newGroup()
	xStart = 0
	
	dots = display.newImageRect("Images/Level_Select_Screen/dots(5).png", 128, 64)
	dots.x = math.floor(screenWidth/2)
	dots.y = math.floor(screenHeight*0.95)
	--groupStatic:insert(dots)
	
	dot_yellow = display.newImageRect("Images/Level_Select_Screen/dot_yellow.png", 32, 64)
	dot_yellow.x = math.floor(screenWidth/2 - (dot_gap * 2))
	dot_yellow.y = math.floor(screenHeight*0.95)
	--groupStatic:insert(dot_yellow)

	for i = 1, gameData.GetNumOfWorlds() do

		local bg_filename = "Images/Level_Select_Screen/bg_Stage_" .. i .. ".png"
		print(bg_filename)

		bgs[i] = display.newImageRect(bg_filename,screenWidth ,screenHeight )
		bgs[i].x = math.floor(screenWidth * (0.5 + i-1))
		bgs[i].y = math.floor(screenHeight/2)
		groupBg:insert(bgs[i])
		--prevGroup:insert( bgs[i])
 
	end
	
	local buttonOptions =
	{
		-- FRAME 1:
		width = 64,
		height = 80,
		numFrames = 17,
		sheetContentWidth = 64*17,
		sheetContentHeight = 80
	}
	
	local myButtonSheet = graphics.newImageSheet("Images/Level_Select_Screen/Aversion-level-select-button-sprite.png",buttonOptions )

	local index = 1
	
	-- creates buttons
	for i=1,maxPage do

		button[i] = {}
		buttonLock[i] = {}
		index = 1
		for j = 1,8 do
		
			button[i][j] = widget.newButton
			{
				sheet = myButtonSheet,
				id = j,
				--label = i,
				--font = "Comic Sans MS",
				--fontSize = 35,
				defaultFrame = index,
				overFrame = index+1,
				--defaultFile = "Images/Level Select Screen/blank_btn.png",
				--overFrame = i + 4,
				isEnabled = false,
				onRelease = onButtonEvent,
				width = 64,
				height = 80
			}
			
			button[i][j].alpha = 1
			button[i][j].world_id = i
			buttonLock[i][j] = display.newImageRect(myButtonSheet, 17, 64, 80)
			groupBg:insert(button[i][j])
			groupBg:insert(buttonLock[i][j])


			index = index + 2

		end
		
	end
	
	-- set buttons' pos
	for i = 1,maxPage do
		for j = 1,8 do
		
			if j < 5 then
				button[i][j].x = screenWidth * (0.2 * j) + ( screenWidth * (i - 1) ); button[i][j].y = screenHeight * 0.45
				buttonLock[i][j].x = screenWidth * (0.2 * j) + ( screenWidth * (i - 1) ); buttonLock[i][j].y = screenHeight * 0.45

			else
				button[i][j].x = screenWidth * (0.2 * (j-4)) + ( screenWidth * (i - 1) ); button[i][j].y = screenHeight * 0.75
				buttonLock[i][j].x = screenWidth * (0.2 * (j-4)) + ( screenWidth * (i - 1) ); buttonLock[i][j].y = screenHeight * 0.75

			end
		
			for k=1,gameData.myTable.levelData[i][j].stars do
				local temp = display.newImageRect("Images/Level_Select_Screen/Star.png",28,28)
				temp.x = button[i][j].x - screenWidth * 0.034 + (screenWidth * 0.036 * (k-1))
				temp.y = button[i][j].y + (screenHeight * 0.085)
				groupBg:insert(temp)
				--groupStars:insert(temp)
			end
		end
	end
	
	if storyboard.currentWorld >= 2 then
		--groupBg.x = groupBg.x - screenWidth
		--groupStars.x = groupStars.x - screenWidth
		transition.to(groupBg, {x = groupBg.x - screenWidth * (storyboard.currentWorld - 1), time=100})
		dot_yellow.x = dot_yellow.x + 21
		currentPage = currentPage + 1
	end
	
	-- get the data
	for i = 1,maxPage do
		for j = 1,8 do
			if gameData.myTable.levelData[i][j].locked == false then
				buttonLock[i][j].alpha = 0
				display.remove(buttonLock[i][j])
				buttonLock[i][j] = nil
				button[i][j]:setEnabled(true)
			end
		end
	end 
	
	local backBtnOptions =
	{
		-- FRAME 1:
		width = 48,
		height = 48,
		numFrames = 2,
		sheetContentWidth = 96,
		sheetContentHeight = 48
	}
	
	local myBackButtonSheet = graphics.newImageSheet("Images/Buttons/Aversion_back_button_sprite.png",backBtnOptions )

	--for i = 1,4 do
	
		backBtn = widget.newButton
		{
			sheet = myBackButtonSheet,
			id = "close_btn",
			defaultFrame = 1,
			overFrame = 2,
			onRelease = onButtonEvent,
			width = 64,
			height = 64
		}
		unlockBtn = widget.newButton
		{
			sheet = myBackButtonSheet,
			id = "unlock_btn",
			defaultFrame = 1,
			overFrame = 2,
			onRelease = onButtonEvent,
			width = 64,
			height = 64
		}
		--button[i].alpha = 0
		
	--end

	
	backBtn.x = math.floor(screenWidth * 0.92); backBtn.y = math.floor(screenHeight * 0.12)
	unlockBtn.x = math.floor(screenWidth * 0.08); unlockBtn.y = math.floor(screenHeight * 0.12)
	unlockBtn.alpha = 0.01

	local object = display.newRect(screenWidth/2,screenHeight/2,screenWidth,screenHeight)
 
	object:setFillColor(0, 0, 0)
	--object:toBack()
	transition.to(object,{alpha = 0, time = 2000, transition = easing.linear})

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	print( "1: enterScene event" )
	
	storyboard.isPaused = false
	storyboard.playerHealth = 5
	prior_scene = storyboard.getPrevious()
	storyboard.removeScene( prior_scene )
	
    storyboard.purgeScene("GameScene")
    storyboard.removeScene("GameScene")

    storyboard.purgeScene("MainMenu")
    storyboard.removeScene("MainMenu")

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local screenGroup = self.view

	prior_scene = storyboard.getPrevious()
	storyboard.removeScene( prior_scene )
	
	Runtime:removeEventListener("touch", onTouch)

	-- remove them before moving to next scene
	display.remove(bgs[1])
	bgs[1] = nil
	display.remove(bgs[2])
	bgs[2] = nil
	display.remove(backBtn)
	backBtn = nil
	display.remove(unlockBtn)
	unlockBtn = nil
	for i=1,maxPage do
		for j=1,8 do
			if button[i][j] ~= nil then
				display.remove(button[i][j])
				button[i][j] = nil
			end
			if buttonLock[i][j] ~= nil then
				display.remove(buttonLock[i][j])
				buttonLock[i][j] = nil
			end
		end
	end
	
	display.remove(dots)
	dots = nil
	display.remove(dot_yellow)
	dot_yellow = nil
	
	screenGroup:removeSelf()
	screenGroup = nil
	groupStars:removeSelf()
	groupStars = nil
	groupBg:removeSelf()
	groupBg = nil

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	storyboard.purgeScene( "GameScene" )
	storyboard.removeScene( "GameScene" )
	print( "((destroying scene 1's view))" )
	Runtime:removeEventListener("touch", onTouch)
end


function onTouch(event)
	if event.phase == "began" then 
		xStart = event.x

	else if event.phase == "moved" then 
	

	elseif event.phase == "ended" or event.phase == "cancelled" then
		-- previous page
		if xStart < event.x and event.x - xStart >= 10 then
			if currentPage >= 2 then -- min + 1
				transition.to(groupBg, { x = groupBg.x + screenWidth , time= 300 })
				dot_yellow.x = dot_yellow.x - 21 
				currentPage = currentPage - 1
			end
		-- next page
		elseif xStart > event.x and xStart - event.x >= 100 then
			if currentPage <= maxPage-1 then -- max - 1
				transition.to(groupBg, { x = groupBg.x - screenWidth, time=300 })
				dot_yellow.x = dot_yellow.x + 21
				currentPage = currentPage + 1
			end
		end
	end
end
end

Runtime:addEventListener("touch", onTouch)

function onKeyEvent( event )

	local phase = event.phase
	local keyName = event.keyName

	if phase == "down" then

		if "left" == keyName then

			if currentPage >= 2 then -- min + 1
				--transition.to(groupStars,{x=groupStars.x + screenWidth,time = 300})
				transition.to(groupBg, {x = groupBg.x + screenWidth , time=300})
				dot_yellow.x = dot_yellow.x - 21
				currentPage = currentPage - 1
			end

		elseif "right" == keyName then

			if currentPage <= maxPage-1 then -- max - 1
				--transition.to(groupStars,{x=groupStars.x - screenWidth, time = 300})
				transition.to(groupBg, {x = groupBg.x - screenWidth, time=300})
				dot_yellow.x = dot_yellow.x + 21
				--dots.x = dots.x - screenWidth--math.floor(screenWidth/2)
				currentPage = currentPage + 1
			end

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

