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
local gameData = require("GameData")
local button = {}
local bg,bg2
local platformName 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local image, text1, text2, text3, memTimer

local function onButtonEvent(event)
	
	local btn = event.target
	
	if btn.id == "resume_btn" then

		--local function resumeScene ( event )
			storyboard.hideOverlay()
			storyboard.isPaused = false
		--end
				
		--timer.performWithDelay( 100, resumeScene)
			
	elseif btn.id == "exit_btn" then
		--[[					
		local function nextScene ( event )
			--storyboard.hideOverlay()
			storyboard.isPaused = false
			storyboard.gotoScene( "LevelSelect" )		
		end			
		timer.performWithDelay( 100, nextScene)	
		]]--
		if platformName == "Android" then
			native.requestExit()
		end
		os.exit()
		return true
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	--local params = event.params
		
	platformName = system.platformName
	
	bg = display.newImageRect("Images/Others/Exit_game_bg.png",screenWidth,screenHeight)
--	bg = display.newImageRect("Images/test_hires.png",screenWidth,screenHeight)
	
	--bg:setReferencePoint(display.TopLeftReferencePoint);
	bg.x = screenWidth * 0.5 ; bg.y = screenHeight * 0.5
	

	local exitScreenOptions =
	{
		-- FRAME 1:
		width = 64,
		height = 66,
		numFrames = 4,
		sheetContentWidth = 256,
		sheetContentHeight = 66
	}

	local myExitScreenSheet = graphics.newImageSheet("Images/Others/Exit_game_buttons.png",exitScreenOptions )

	--for i = 1,3,2 do
	
		button[1] = widget.newButton
		{
			sheet = myExitScreenSheet,
			id = "exit_btn",
			defaultFrame = 1,
			overFrame = 2,
			onRelease = onButtonEvent,
			width = 64 * xMultiplier,
			height = 64 * yMultiplier
		}
		button[2] = widget.newButton
		{
			sheet = myExitScreenSheet,
			id = "resume_btn",
			defaultFrame = 3,
			overFrame = 4,
			onRelease = onButtonEvent,
			width = 64 * xMultiplier,
			height = 64 * yMultiplier
		}
		--button[i].alpha = 0
		
	--end
	myPauseScreenSheet = nil
	
	button[2].id = "resume_btn"

	
	button[1].x = screenWidth*0.35 ; button[1].y = screenHeight*0.55 --230
	button[2].x = screenWidth*0.65 ; button[2].y = screenHeight*0.55 

	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	print( "1: enterScene event" )
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
local screenGroup = self.view

	for i=1,2 do
		display.remove( button[i] )
		button[i] = nil
	end
	display.remove(bg)
	bg = nil

	screenGroup:removeSelf()
	screenGroup = nil

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
	print( "((destroying scene 1's view))" )
end

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