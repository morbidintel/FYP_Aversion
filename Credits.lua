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
local button,button2
local bg,bg2

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local image, text1, text2, text3, memTimer

local function onButtonEvent(event)
	
	local btn = event.target
	
	if btn.id == "resume_btn" then
	
	elseif btn.id == "next_btn" then
	
		button.alpha = 1
		button2.alpha = 0
		
	elseif btn.id == "exit_btn" then
	
		local function resumeScene ( event )
			storyboard.gotoScene( "MainMenu" )
		end
				
		timer.performWithDelay( 100, resumeScene)
		--return true
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	--local params = event.params

	storyboard.removeAll( )
		
	platformName = system.platformName

	button = widget.newButton
	{
		defaultFile = "Images/Screen/Credits.png",
		id = "exit_btn",
		onRelease = onButtonEvent,
		width = screenWidth,
		height = screenHeight
	}
		--button[i].alpha = 0
		
	button.x = screenWidth / 2
	button.y = screenHeight / 2

	screenGroup:insert(button)
	
	--	button2 = widget.newButton
	--	{
	--		defaultFile = "Images/Screen/Win-screen-vector.png",
	--		id = "next_btn",
	--		onRelease = onButtonEvent,
	--		width = screenWidth,
	--		height = screenHeight
	--	}
	--		--button[i].alpha = 0
		
	--	button2.x = screenWidth / 2
	--	button2.y = screenHeight / 2

--	screenGroup:insert(button2)

	media.playVideo("Images/Screen/cannibis.mp4", false, function()end)
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local screenGroup = self.view

	display.remove( button )
	button = nil
	display.remove( button2 )
	button2 = nil

	screenGroup:removeSelf()
	screenGroup = nil

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