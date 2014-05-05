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
			--	storyboard.hideOverlay()
			--	storyboard.purgeScene("GameScene")
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
	
	bg = display.newRect(0,0,screenWidth,screenHeight)
	bg.x, bg.y = screenWidth / 2, screenHeight / 2
	bg:setFillColor(255, 255, 255)
	bg.alpha = 0.4

	local pauseScreenOptions =
	{
		-- FRAME 1:
		width = 64,
		height = 64,
		numFrames = 6,
		sheetContentWidth = 384,
		sheetContentHeight = 64
	}

	local myPauseScreenSheet = graphics.newImageSheet("Images/Help_Menu/Pause_screen.png",pauseScreenOptions )

	for i = 1,3 do
	
		button[i] = widget.newButton
		{
			sheet = myPauseScreenSheet,
			id = "retry_btn",
			defaultFrame = i,
			overFrame = i+3,
			onRelease = onButtonEvent,
			width = 64,
			height = 64
		}
		
	end
	
	myPauseScreenSheet = nil
	
	button[2].id = "resume_btn"
	button[3].id = "exit_btn"
	
	button[1].x = screenWidth*0.25 ; button[1].y = screenHeight*0.55
	button[2].x = screenWidth*0.5 ; button[2].y = screenHeight*0.55 
	button[3].x = screenWidth * 0.75 ; button[3].y = screenHeight*0.55
	
	bg2 = display.newImageRect("Images/Help_Menu/Paused_word.png",192,96)
	
	bg2.x, bg2.y = screenWidth / 2, screenHeight / 3
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	
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

	for i=1,3 do
		display.remove( button[i] )
		button[i] = nil
	end
	display.remove(bg)
	bg = nil

	display.remove(bg2)
	bg2 = nil
	--display.remove(bg)
	screenGroup:removeSelf()
	screenGroup = nil
	
	-- remove touch listener for image
	--image:removeEventListener( "touch", image )
	
	-- cancel timer
	--timer.cancel( memTimer ); memTimer = nil;
	
	-- reset label text
	--text2.text = "MemUsage: "
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
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