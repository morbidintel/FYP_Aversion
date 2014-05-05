---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )

local xMultiplier = display.contentWidth/480  
local yMultiplier = display.contentHeight/320

--local GameScene = display.newGroup()
local screenWidth = display.contentWidth
local screenHeight = display.contentHeight

local button1,button2,button3
local bg1sprite,bg2sprite --= {}
local bg4sprite,bg3sprite
local myBgSheet1,myBgSheet2,myBgSheet3
local bg1_animate = true
local bg1_delay = 0

local bg2_animate = true
local bg2_delay = 0
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local button = {}
local backBtn,nextBtn
local image, text1, text2, text3, memTimer
local xStart
local pageDots
local pageDotsSprite

local function onButtonEvent(event)
	
	local btn = event.target
			
		if btn.id == "close_btn" then
		
			local function nextScene ( event )
				storyboard.gotoScene( "MainMenu")--,"fade",300)
			end
				
			timer.performWithDelay( 100, nextScene)

			
		return true
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	collectgarbage( "collect" )

	local bgOptions =
	{
		width=screenWidth,
		height=screenHeight,
		numFrames=6, 
		sheetContentWidth=screenWidth * 3,
		sheetContentHeight=screenHeight * 2
	}
	--[[
	local bg2Options =
	{
		width=screenWidth,
		height=screenHeight,
		numFrames=5, 
		sheetContentWidth=screenWidth * 5,
		sheetContentHeight=screenHeight
	}
	]]
	local pagedotsOptions =
	{
		-- FRAME 1:
		width = 64,
		height = 64,
		numFrames = 4,
		sheetContentWidth = 256,
		sheetContentHeight = 64
	}
	
	local sequenceData = {
		{ name = "first", 		frames={ 1,1,2,2,3,4,5,5,6,6,6,6 }, time=6000 },
		{ name = "second", 	frames={ 1,1,2,2,3,4,5,5,6,6,6,6 }, time=6000 },
		{ name = "third", 		frames={ 1,1,2,2,3,4,5,5,6,6,6,6}, time=6000 },
		{ name = "default", 	frames={ 1,2,3,4}, time=5000 }
	}
	
	myBgSheet1 = graphics.newImageSheet( "Images/Help_Menu/Help1Sprite.png",bgOptions )
	myBgSheet2 = graphics.newImageSheet( "Images/Help_Menu/Help2Sprite.png",bgOptions )
	myBgSheet3 = graphics.newImageSheet( "Images/Help_Menu/Help4Sprite.png",bgOptions )
	
	
	--First help tutorial bg
	bg1sprite = display.newSprite( myBgSheet1, sequenceData )
	bg1sprite:setSequence("first")	
	bg1sprite.x = math.floor(screenWidth/2)
	bg1sprite.y = math.floor(screenHeight/2)	
	bg1sprite:play()
	screenGroup:insert(bg1sprite)
	
	--Second help tutorial bg	
	bg2sprite = display.newSprite( myBgSheet2, sequenceData )
	bg2sprite:setSequence("second")	
	bg2sprite.x = math.floor(screenWidth/2)
	bg2sprite.y = math.floor(screenHeight/2)	
	bg2sprite:pause()	
	bg2sprite.alpha = 0
	screenGroup:insert(bg2sprite)
	
	--Second help tutorial bg	
	bg3sprite = display.newSprite( myBgSheet3, sequenceData )
	bg3sprite:setSequence("third")	
	bg3sprite.x = math.floor(screenWidth/2)
	bg3sprite.y = math.floor(screenHeight/2)	
	bg3sprite:pause()	
	bg3sprite.alpha = 0
	screenGroup:insert(bg3sprite)
	
	myBgSheet1 = nil
	myBgSheet2 = nil
	myBgSheet3 = nil

	
	--Third help tutorial bg	
	bg4sprite = display.newImageRect( "Images/Help_Menu/Help3enemies.png",screenWidth,screenHeight )
	bg4sprite.x = math.floor(screenWidth/2)
	bg4sprite.y = math.floor(screenHeight/2)	
	bg4sprite.alpha = 0
	screenGroup:insert(bg4sprite)
	
	
	local myDotsSheet = graphics.newImageSheet("Images/Gallery/Page_Dots.png",pagedotsOptions )
	pageDotsSprite = display.newSprite( myDotsSheet, sequenceData )
	pageDotsSprite:setSequence("default")	
	pageDotsSprite.x = math.floor(screenWidth/2)
	pageDotsSprite.y = math.floor(screenHeight * 0.97)	
	pageDotsSprite:pause()	
	pageDotsSprite.alpha = 1
	screenGroup:insert(pageDotsSprite )
	
	myDotsSheet = nil 
	
	
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

	backBtn.x = math.floor(screenWidth * 0.92)
	backBtn.y = math.floor(screenHeight * 0.12)
	screenGroup:insert(backBtn)
	
	myBackButtonSheet = nil

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	
	-- remove previous scene's view
	--storyboard.purgeScene( "scene4" )
	prior_scene = storyboard.getPrevious()
	storyboard.purgeScene( prior_scene )
	storyboard.removeScene( "MainMenu" )
	storyboard.purgeAll()

	

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local screenGroup = self.view

	Runtime:removeEventListener("enterFrame", Update)
	Runtime:removeEventListener("touch", onTouch)
	display.remove( button1 )
	display.remove( button2 )
	display.remove( button3 )
	button1 = nil
	button2 = nil
	button3 = nil

	display.remove(bg1sprite)
	bg1sprite = nil

	display.remove(bg2sprite)
	bg2sprite = nil
	
	display.remove(bg4sprite)
	bg4sprite = nil
	
	display.remove(backBtn)
	backBtn = nil
	
	--display.remove(bg)
	screenGroup:removeSelf()
	screenGroup = nil
	
	for i=1,4 do
	
		display.remove( button[i] )
		button[i] = nil
	
	end

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	Runtime:removeEventListener("enterFrame", Update)
	Runtime:removeEventListener("touch", onTouch)
end



local function onTouch(event)

	if event.phase == "began" then 
		xStart = event.x
		
	elseif event.phase == "moved" then 

			
	elseif event.phase == "ended" then 
		
		
		if xStart < event.x and event.x - xStart >= 100 then
			if bg2sprite ~=nil and bg2sprite.isPlaying == true then
			
				bg2sprite:setFrame(1)
				bg2sprite:pause()
				bg2sprite.alpha = 0
				
				bg1sprite:setFrame(1)
				bg1sprite:play()
				bg1sprite.alpha = 1
				
				pageDotsSprite:setFrame(1)
				--nextBtn.xScale = 1
			
			elseif bg4sprite ~=nil and bg4sprite.alpha == 1 then
				
				bg4sprite.alpha = 0
				
				bg3sprite:setFrame(1)
				bg3sprite:play()
				bg3sprite.alpha = 1
				pageDotsSprite:setFrame(3)
				--nextBtn.xScale = -1
				
			elseif bg3sprite ~= nil and bg3sprite.isPlaying == true then
			
				bg3sprite:setFrame(1)
				bg3sprite:pause()
				bg3sprite.alpha = 0
				
				bg2sprite:setFrame(1)
				bg2sprite:play()
				bg2sprite.alpha = 1
				
				pageDotsSprite:setFrame(2)
				--nextBtn.xScale = 1
			end
			
		elseif xStart > event.x and xStart - event.x >= 100 then
		
			if bg1sprite ~=nil and bg1sprite.isPlaying == true then
			
				bg1sprite:setFrame(1)
				bg1sprite:pause()
				bg1sprite.alpha = 0
				
				bg2sprite:setFrame(1)
				bg2sprite:play()
				bg2sprite.alpha = 1
				pageDotsSprite:setFrame(2)
				--nextBtn.xScale = -1
			
			elseif bg2sprite ~=nil and bg2sprite.isPlaying == true then
			
				bg2sprite:setFrame(1)
				bg2sprite:pause()
				bg2sprite.alpha = 0
				
				bg3sprite:setFrame(1)
				bg3sprite:play()
				bg3sprite.alpha = 1
				pageDotsSprite:setFrame(3)
				--nextBtn.xScale = -1
				
			elseif bg3sprite ~=nil and bg3sprite.isPlaying == true then
			
				bg3sprite:setFrame(1)
				bg3sprite:pause()
				bg3sprite.alpha = 0
				
				bg4sprite.alpha = 4
				pageDotsSprite:setFrame(4)
			end
		
		end
	end


end

Runtime:addEventListener("touch", onTouch)


function onKeyEvent( event )

	local phase = event.phase
	local keyName = event.keyName

	print( event.phase, event.keyName )

	if "back" == keyName then
		onButtonEvent{ target = { id = "close_btn" } }
	end

end

Runtime:addEventListener("onKey", onKeyEvent)
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