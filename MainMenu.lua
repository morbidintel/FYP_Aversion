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

local deviceWidth = display.pixelWidth
local deviceHeight = display.pixelHeight

local button1,button2,button3
local bgsprite --= {}
local bgsprite2
local bgoverlay

local bg_animate = true
local bg_delay = 0
local bgoverlay_animate = false
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local button = {}
local image, text1, text2, text3, memTimer
local slider = {}
local bg
--local bgm
--local bgmChn
--[[
-- Touch event listener for background image
local function onSceneTouch( self, event )
	if event.phase == "began" then
		
		storyboard.gotoScene( "scene1", "slideLeft", 800  )
		
		return true
	end
end
]]--

local function onButtonEvent(event)
	
	local btn = event.target
	
	if btn.id == "start_btn" then
		
		
		local function nextScene ( event )
			storyboard.gotoScene( "LevelSelect")--,"slideLeft",600)
		end
			
		timer.performWithDelay( 100, nextScene)

	
		elseif btn.id == "gallery_btn" then
		
			local function nextScene ( event )
				storyboard.gotoScene( "Gallery")--,"slideLeft",600)
			end
				
			timer.performWithDelay( 100, nextScene)
			
		elseif btn.id == "help_btn" then
		
			local function nextScene ( event )
				storyboard.gotoScene( "HelpMenu")--,"slideLeft",600)
			end
				
			timer.performWithDelay( 100, nextScene)
			
		elseif btn.id == "settings_btn" then
		
			local function nextScene ( event )
				storyboard.gotoScene( "SettingsMenu")--,"slideLeft",600)
			end
				
			timer.performWithDelay( 100, nextScene)
			
		return true
	end
end

local t = 1
local p = 0.005
local up = false

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	bgoverlay_animate = false
	
	bg_animate = true
	bg_delay = 0
	collectgarbage( "collect" )
	
	local scaleFactor = display.pixelWidth / display.actualContentWidth 
	--local bg = display.newImageRect("mainmenu_bg_test3.png",screenWidth ,screenHeight);
	--screenGroup:insert(bg)
	--bg:setReferencePoint(display.TopLeftReferencePoint);
	-- bg.x = 240*yMultiplier ; bg.y = 160*xMultiplier


--print("End")

	bgsprite = display.newImageRect( "Images/UI_Screen/BG_blue.png", screenWidth, screenHeight)
	bgsprite2 = display.newImageRect( "Images/UI_Screen/BG_orange.png", screenWidth, screenHeight)
	
	bgsprite.x = display.contentCenterX
	bgsprite.y = display.contentCenterY
	
	bgsprite2.x = display.contentCenterX
	bgsprite2.y = display.contentCenterY
	
	screenGroup:insert(bgsprite)
	screenGroup:insert(bgsprite2)
	
	if storyboard.firstRun == true then
		bgoverlay = display.newImageRect("Images/UI_Screen/Aversion-tap-to-start-bar-final.png",screenWidth ,29 * yMultiplier)
		bgoverlay.x = math.floor(screenWidth/2)
		bgoverlay.y = math.floor(screenHeight * 0.9)
		bgoverlay.alpha = 0.9
	end
	myBgSheet = nil
	
	local button1Options =
	{
		-- FRAME 1:
		width = 200,
		height = 100,
		numFrames = 8,
		sheetContentWidth = 1600,
		sheetContentHeight = 100
	}
	
	local myButton1Sheet = graphics.newImageSheet("Images/UI_Screen/Aversion-menu-screen-button-sprite.png",button1Options )
	
	local button234Options =
	{
		-- FRAME 1:
		width = 137.25,
		height = 64,
		numFrames = 8,
		sheetContentWidth = 1098,
		sheetContentHeight = 64
	}
	
	local myButtonSheet = graphics.newImageSheet("Images/UI_Screen/Aversion-menu-screen-button-sprite.png",button234Options )

	--screenGroup:insert(bgsprite)
	if storyboard.firstRun == true then
		screenGroup:insert(bgoverlay)
	end
	
	button[1] = widget.newButton
	{
		sheet = myButton1Sheet,
		id = "start_btn",
		defaultFrame = 1,
		overFrame = 1 + 4,
		onRelease = onButtonEvent,
		width = 200,
		height = 100
	}
	button[1].alpha = 0
	screenGroup:insert(button[1])
	button[1].id = "start_btn"
	
	for i = 2,4 do
	
		button[i] = widget.newButton
		{
			sheet = myButtonSheet,
			id = "settings_btn",
			defaultFrame = i,
			overFrame = i + 4,
			onRelease = onButtonEvent,
			width = 137.25,
			height = 64
		}
		button[i].alpha = 0
		screenGroup:insert(button[i])
	end
	--button[2].id = "settings_btn"
	button[3].id = "gallery_btn"
	button[4].id = "help_btn"
	
	if storyboard.firstRun == false then
		for i = 1,4 do
			button[i].alpha = 1
		end
		--bgoverlay.alpha = 0
	end
	
	
	button[1].x = screenWidth * 0.22; button[1].y = screenHeight * 0.80
	button[2].x = screenWidth * 0.45; button[2].y = screenHeight * 0.82
	button[3].x = screenWidth * 0.70; button[3].y = screenHeight * 0.82
	button[4].x = screenWidth * 0.92; button[4].y = screenHeight * 0.82
	
	myButtonSheet = nil
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	print( "1: enterScene event" )
	
	-- remove previous scene's view
	storyboard.removeScene( "GameScene" )
	storyboard.removeScene( "HelpMenu" )
	storyboard.removeScene( "Gallery" )
	storyboard.purgeScene( "Gallery" )
	storyboard.removeScene( "SettingsMenu" )
	storyboard.removeScene( "LevelSelect" )
	
	prior_scene = storyboard.getPrevious()
	storyboard.purgeScene( prior_scene )
	
	storyboard.removeAll()
	storyboard.purgeAll()
	
	--button1.isVisible = true
	--button1.x = 300 * xMultiplier; button1.y = 280 * yMultiplier
	--button2.x = 360 * xMultiplier; button2.y = 280 * yMultiplier
	--button3.x = 420 * xMultiplier; button3.y = 280 * yMultiplier
	-- Update Lua memory text display
	--[[local showMem = function()
		image:addEventListener( "touch", image )
		text3.isVisible = true
		text2.text = text2.text .. collectgarbage("count")/1000 .. "MB"
		text2.x = display.contentWidth * 0.5
	end
	memTimer = timer.performWithDelay( 1000, showMem, 1 )--]]
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local screenGroup = self.view

	Runtime:removeEventListener("enterFrame", Update)
	Runtime:removeEventListener("touch", onTouch)
	Runtime:removeEventListener( "key", onKeyEvent )
	display.remove( button1 )
	display.remove( button2 )
	display.remove( button3 )
	button1 = nil
	button2 = nil
	button3 = nil

	display.remove(bgsprite)
	bgsprite = nil
	
	display.remove(bgoverlay)
	bgoverlay = nil

	--display.remove(bg)
	screenGroup:removeSelf()
	screenGroup = nil
	
	for i=1,4 do
	
		display.remove( button[i] )
		button[i] = nil
	
	end
	--print( "1: exitScene event" )
	
	-- remove touch listener for image
	--image:removeEventListener( "touch", image )
	
	-- cancel timer
	--timer.cancel( memTimer ); memTimer = nil;
	
	-- reset label text
	--text2.text = "MemUsage: "
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	print( "((destroying scene 1's view))" )
end



function onTouch(event)

	if bgoverlay ~= nil then
	
		if event.phase == "began" then 
		
			if bgoverlay ~= nil then
				display.remove(bgoverlay)
				bgoverlay = nil
				
				--storyboard.gotoScene( "GameScene" )
			end
			
			for i=1,4 do
				button[i].alpha = 1
			end
			
			if storyboard.firstRun == true then
				storyboard.firstRun = false 
			end
		elseif event.phase == "moved" then 

				
		elseif event.phase == "ended" then 
		

			
		end
		
	end


end

function Update( event )
	if up == true then
		t = t + p
		bgsprite2.alpha = t
	elseif up == false then
		t = t - p
		bgsprite2.alpha = t
	end
	
	if t < 0.01 then
		p = 0
		local function listener( event )
			up = true
			p = 0.005
		end

		timer.performWithDelay( 3000, listener )
	elseif t > 0.99 then
		p = 0
		local function listener( event )
			up = false
			p = 0.005
		end

		timer.performWithDelay( 3000, listener )
	end

	if bgoverlay ~= nil then
	
		local listener2 = function()
		
			--bgoverlay.alpha = 0.8
			bgoverlay_animate = false
		
		end
		local listener1 = function()
		
			--bgoverlay.alpha = 0.8
			--bgoverlay_animate = false
			
			transition.to(bgoverlay,{alpha = 0.9, time = 50, onComplete = listener2})
		
		end
		if bgoverlay_animate == false then

			bgoverlay_animate = true
			transition.to(bgoverlay,{alpha = 0.2, time = 1200, onComplete = listener1})
		
		end
	
	end
end

function onKeyEvent( event )

   local phase = event.phase
   local keyName = event.keyName
   print( event.phase, event.keyName )

   if ( "back" == keyName and phase == "up" ) then
		storyboard.showOverlay( "ExitScreen" )
   end
--[[
   if ( keyName == "volumeUp" and phase == "down" ) then
      local masterVolume = audio.getVolume()
      print( "volume:", masterVolume )
      if ( masterVolume < 1.0 ) then
         masterVolume = masterVolume + 0.1
         audio.setVolume( masterVolume )
      end
   elseif ( keyName == "volumeDown" and phase == "down" ) then
      local masterVolume = audio.getVolume()
      print( "volume:", masterVolume )
      if ( masterVolume > 0.0 ) then
         masterVolume = masterVolume - 0.1
         audio.setVolume( masterVolume )
      end
   end
   ]]--
   return true  --SEE NOTE BELOW
end

--add the key callback
Runtime:addEventListener( "key", onKeyEvent )
Runtime:addEventListener("enterFrame", Update)
Runtime:addEventListener("touch", onTouch)
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