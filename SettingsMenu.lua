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
local slider = {}
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local button = {}
local backBtn 
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

--Handles the slide event for the volume slider
local function sliderListener( event )
    local slider = event.target
    local value = event.value / 100
    audio.setVolume(value)

    print( "Slider at " .. value .. "%" )

end

--Handles the press event for the checkbox
local function onSwitchPress( event )
	-- body
	local switch = event.target
	print("Switch with ID '"..switch.id.."' is on:" ..tostring(switch.isOn))
	print( switch.isOn )

	storyboard.isVibrateOn = switch.isOn

	--Enable vibration when the check box for Vibrates is checked.
	if (switch.isOn) then -- If the checkbox is checked, then run this code.
		print( "Switch is on, Vibrate the device" )
		system.vibrate() -- Vibrate the device
	end
end

local function onButtonEvent(event)
	
	local btn = event.target
	
	if btn.id == "start_btn" then
		
		local function nextScene ( event )
			storyboard.gotoScene( "LevelSelect","slideLeft",600)
		end
			
		timer.performWithDelay( 100, nextScene)

	
		elseif btn.id == "gallery_btn" then
		
			local function nextScene ( event )
				storyboard.gotoScene( "Gallery","slideLeft",600)
			end
				
			timer.performWithDelay( 100, nextScene)
			
		elseif btn.id == "close_btn" then
		
			local function nextScene ( event )
				storyboard.gotoScene( "MainMenu","fade",200)
			end
				
			timer.performWithDelay( 100, nextScene)
				
		elseif btn.id == "button3" then
			print( "Green" )
			print (collectgarbage("count")/1000)
			collectgarbage( "collect" )
			
		return true
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	collectgarbage( "collect" )
	--local bg = display.newImageRect("mainmenu_bg_test3.png",screenWidth ,screenHeight);
	--screenGroup:insert(bg)
	--bg:setReferencePoint(display.TopLeftReferencePoint);
	-- bg.x = 240*yMultiplier ; bg.y = 160*xMultiplier
--[[
	button1 = widget.newButton
	{
		id = "button1",
		defaultFile = "Images/PlayButton.png",
		overFile = "Images/PlayButton_Emb.png",
		--label = "Button 1 Label",
		--emboss = true,
		--onPress = button1Press,
		--onRelease = button1Release,
		onRelease = onButtonEvent,
		width = 127,
		height = 72
	}
]]--
	local bg = display.newImageRect("Images/UI_Screen/Settings_Screen/settings.png",screenWidth ,screenHeight);
	bg.x = screenWidth / 2
	bg.y = screenHeight / 2
	screenGroup:insert(bg)

	
	
	slider[1] = widget.newSlider
	{
		id = "bgm",
		top = screenHeight * 0.81,
		left = screenWidth * 0.260,
		width = screenWidth * 0.49,
		listener = sliderListener,
		value = audio.getVolume() * 100
	}

	slider[2] = widget.newSlider
	{
		id = "sfx",
		top = screenHeight * 0.61,
		left = screenWidth * 0.283,
		width = screenWidth * 0.49,
		listener = sliderListener,
		value = audio.getVolume() * 100
	}
	
	--Checkbox for vibration
	checkboxButton = widget.newSwitch
	{
		top = screenHeight * 0.505,--0.74,
		left = screenWidth * 0.48,
		initialSwitchState = storyboard.isVibrateOn, -- Set the vibration mode to "On" at the start.
		style = "checkbox",
		id = "Checkbox button",
		onPress = onSwitchPress,
	}
	
	
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
		--button[i].alpha = 0
	--end

	
	backBtn.x = math.floor(screenWidth * 0.92)
	backBtn.y = math.floor(screenHeight * 0.15)
	myBackButtonSheet = nil
	slider[2].alpha = 0
	screenGroup:insert(slider[1])
	screenGroup:insert(slider[2])
	screenGroup:insert(checkboxButton)
	screenGroup:insert(backBtn)
	--end
	
	--[[
	sprite[1]:setSequence("fire")
	sprite[2]:setSequence("water")
	sprite[3]:setSequence("nature")
	sprite[4]:setSequence("brown")
	sprite[5]:setSequence("darkgreen")
	sprite[6]:setSequence("purple")
	sprite[7]:setSequence("yellow")
	sprite[8]:setSequence("horn")
	sprite[9]:setSequence("angel")
	sprite[10]:setSequence("ball")
	]]--
	--[[
	local listener2 = function()
		for i=1,10 do
			if sprite[i] ~= nil then
				sprite[i].x = ( 400 + ( 60 * i ) * xMultiplier ); sprite[i].y = 290 * yMultiplier
				transition.to(sprite[i], {x = (-700 + ( 60 * i ) * xMultiplier ),time=20000, onComplete = listener1})
			end
		end
	end
	local listener1 = function()
		for i=1,10 do
			if sprite[i] ~= nil then
				sprite[i].x = ( 400 + ( 60 * i ) * xMultiplier ); sprite[i].y = 290 * yMultiplier
				transition.to(sprite[i], {x = (-700 + ( 60 * i ) * xMultiplier ),time=20000, onComplete = listener2})
			end
		end
	end
	
	for i=1,10 do
		if sprite[i] ~= nil then
			sprite[i]:play()
			sprite[i].x = ( 400 + ( 60 * i ) * xMultiplier ); sprite[i].y = 290 * yMultiplier
			transition.to(sprite[i], {x = (-700 + ( 60 * i ) * xMultiplier ),time=20000, onComplete = listener1})
		end
	end
	]]--
	
	
	--button1.x = screenWidth * 0.5; button1.y = screenHeight * 0.75
	--button1.isVisible = false
	--button2.x = 360 * xMultiplier; button2.y = 280 * yMultiplier
	--button3.x = 420 * xMultiplier; button3.y = 280 * yMultiplier
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	print( "1: enterScene event" )
	
	-- remove previous scene's view
	--storyboard.purgeScene( "scene4" )
	prior_scene = storyboard.getPrevious()
	storyboard.removeScene( prior_scene )
	storyboard.removeScene( "MainMenu" )
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

	button1 = nil
	button2 = nil
	button3 = nil

	display.remove(bg)
	bg = nil

	display.remove(backBtn)
	backBtn = nil
	
	for i=1,2 do
		display.remove(slider[i])
		slider[i] = nil
	end
	display.remove(checkboxButton)
	checkboxButton = nil
	--display.remove(bg)
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

function onKeyEvent( event )

   local phase = event.phase
   local keyName = event.keyName
   --print( event.phase, event.keyName )
   -- Print which key was pressed down/up to the log.
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
   	print( message )

   if ( "back" == keyName and phase == "up" ) then
		storyboard.showOverlay( "ExitScreen" ) 
   end

   --Volume Control in Settings Menu
   if ( keyName == "volumeUp" and phase == "down" ) then --Key that is used/pressed to increase volume.
      local masterVolume = audio.getVolume()
      print( "Volume:", masterVolume )
      if ( masterVolume < 1.0 ) then
         masterVolume = masterVolume + 0.1 -- Increase the volume by 0.1 whenever up key is pressed.
         audio.setVolume( masterVolume ) -- Set the new mastervolume affter increasing the volume.
      end

   elseif ( keyName == "volumeDown" and phase == "down" ) then -- Key that is used/pressed to decrease the volume.
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