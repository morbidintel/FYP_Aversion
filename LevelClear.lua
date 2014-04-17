local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require( "widget" )

local xMultiplier = display.contentWidth/480  
local yMultiplier = display.contentHeight/320

--local GameScene = display.newGroup()
local screenWidth = display.contentWidth
local screenHeight = display.contentHeight
local gameData = require("GameData")
local button,button2
local bg,bg2
local star = {}
local button = {}

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
			storyboard.isPaused = false
			--HUD.PauseTimer(false)
			storyboard.gotoScene( "dummyscene" )
		--end
		--timer.performWithDelay( 100, retryScene)
		
	elseif btn.id == "exit_btn" then
	
		--local function nextScene ( event )
			storyboard.firstEntry = true
			storyboard.isPaused = false
			--HUD.PauseTimer(false)
			storyboard.gotoScene( "LevelSelect" )		
		--end			
		--timer.performWithDelay( 100, nextScene)	
		
	elseif btn.id == "next_btn" then
	
		--local function resumeScene ( event )
			storyboard.hideOverlay("LevelClear")
			if storyboard.currentWorld == 1 and storyboard.currentLevel == 8 then
				storyboard.currentWorld = 2
				storyboard.currentLevel = 1
				gameData.myTable.levelData[2][1].locked = false
				storyboard.gotoScene("LevelSelect")
			elseif storyboard.currentWorld == 2 and storyboard.currentLevel == 8 then
				storyboard.gotoScene("Credits")
			else
				storyboard.currentLevel = storyboard.currentLevel + 1
				storyboard.gotoScene( "dummyscene" )
			end
		--end
				
		--timer.performWithDelay( 100, resumeScene)
		--return true
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	--local params = event.params
		
	platformName = system.platformName
	
	bg = display.newRect(0,0,screenWidth,screenHeight)
	bg:setFillColor(255,255,255)
	bg.alpha = 0.4 
	bg.x, bg.y = screenWidth / 2, screenHeight / 2
	
	bg2 = display.newImageRect("Images/Screen/ClearedScreen.png",screenWidth,screenHeight)
	bg2.x = screenWidth / 2
	bg2.y = screenHeight / 2.5

	-- score here
	for k=1,gameData.myTable.levelData[storyboard.currentWorld][storyboard.currentLevel].stars do
	
		star[k] = display.newImageRect("Images/Screen/Star.png",80,80)
		star[k].x =  screenWidth * 0.365 + (screenWidth * 0.135 * (k-1))
		star[k].y =  (screenHeight * 0.47)

	end

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
		--button[i].alpha = 0
		
	end
	myPauseScreenSheet = nil
	
	button[2].id = "next_btn"
	button[3].id = "exit_btn"
	
	button[1].x = screenWidth * 0.25;	button[1].y = screenHeight * 0.70
	button[2].x = screenWidth * 0.75;	button[2].y = screenHeight * 0.70 
	button[3].x = screenWidth * 0.5;	button[3].y = screenHeight * 0.70

	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	print( "1: enterScene event" )

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
	
	for i=1,3 do
		display.remove(star[i])
		star[i] = nil
	end

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