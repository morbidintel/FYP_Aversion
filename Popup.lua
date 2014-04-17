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
local bg

--local HUD = require("HUD")
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local image, text1, text2, text3, memTimer
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
	
	if btn.id == "retry_btn" then
	
		--local function retryScene ( event )
			--storyboard.purgeScene("GameScene")
			storyboard.isPaused = false
			--HUD.PauseTimer(false)
			--HUD.Destroy()
			storyboard.gotoScene( "dummyscene" )
		--end
		--timer.performWithDelay( 100, retryScene)
		
	elseif btn.id == "resume_btn" then

		--local function resumeScene ( event )
			storyboard.hideOverlay()
			storyboard.isPaused = false
			--HUD.PauseTimer(false)
		--end
				
		--timer.performWithDelay( 100, resumeScene)
			
	elseif btn.id == "exit_btn" then
							
		--local function nextScene ( event )
			--storyboard.hideOverlay()
			--storyboard.purgeScene(GameScene)
			storyboard.firstEntry = true
			storyboard.isPaused = false
			--HUD.PauseTimer(false)
			--HUD.Destroy()
			storyboard.gotoScene( "LevelSelect" )		
		--end			
		--timer.performWithDelay( 100, nextScene)	
			
		return true
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
	local params = event.params
	
	bg = display.newImageRect("Images/Popups/"..params.one..".png", screenWidth, screenHeight)
	bg.x = screenWidth/2
	bg.y = screenHeight/2
	bg.alpha = 0.9
	
	local pauseScreenOptions =
	{
		-- FRAME 1:
		width = 84,
		height = 36,
		numFrames = 2,
		sheetContentWidth = 168,
		sheetContentHeight = 36
	}
	
	local myPauseScreenSheet = graphics.newImageSheet("Images/ok_button.png",pauseScreenOptions )
	
	button = widget.newButton
	{
		sheet = myPauseScreenSheet,
		id = "resume_btn",
		defaultFrame = 1,
		overFrame = 2,
		onRelease = onButtonEvent,
		width = 32,
		height = 32
	}
	
	myPauseScreenSheet = nil
	
	button.x = screenWidth*0.50
	button.y = screenHeight*0.80
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	print( "1: enterScene event" )
	
	-- remove previous scene's view
	--storyboard.purgeScene( "scene4" )
	--prior_scene = storyboard.getPrevious()
	--storyboard.purgeScene( prior_scene )
	--storyboard.removeAll()
	--storyboard.purgeAll()
	--button1.x = 300 * xMultiplier; button1.y = 280 * yMultiplier
	--button2.x = 360 * xMultiplier; button2.y = 280 * yMultiplier
	--button3.x = 420 * xMultiplier; button3.y = 280 * yMultiplier
	-- Update Lua memory text display
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
local screenGroup = self.view

	for i=1,3 do
		display.remove( button[i] )
		button[i] = nil
	end
	display.remove(bg)
	bg = nil

	screenGroup:removeSelf()
	screenGroup = nil
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