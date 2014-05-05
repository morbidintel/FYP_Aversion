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

local galleryScene = {}

local screenWidth = display.contentWidth
local screenHeight = display.contentHeight

--local button1,button2,button3
local drugIcons = {}
local dotsIcons = {}
local bgoverlay_animate = false
local titleDisplay
local textDisplay = {}
local bg,bg2
local backBtn
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local image, text1, text2, text3, memTimer
local scrollView = {}
local lotsOfTextObject

-- Our ScrollView listener
local function scrollListener( event )
	local phase = event.phase
	local direction = event.direction
	
	if "began" == phase then
		--print( "Began" )
		xStart = event.x
	elseif "moved" == phase then
		--print( "Moved" )
	elseif "ended" == phase then
		--print( "Ended" )
		if xStart < event.x and event.x - xStart >= 100 and galleryScene[1].x < 0 then
			for i=1,4 do
				transition.to(galleryScene[i],{ x = galleryScene[i].x + screenWidth,time = 300})
			end
		elseif xStart > event.x and xStart - event.x >= 100 and galleryScene[4].x > -screenWidth*3 then
			for i=1,4 do		
				print(galleryScene[4].x)
				transition.to(galleryScene[i],{ x = galleryScene[i].x - screenWidth,time = 300})-- = galleryScene[i].x - 480
				--scrollView[i].x = scrollView[i].x - 100	
				
			end
		
		
		end
	end
	
	-- If the scrollView has reached it's scroll limit
	if event.limitReached then
		if "up" == direction then
			--	print( "Reached Top Limit" )
		elseif "down" == direction then
			--	print( "Reached Bottom Limit" )
		elseif "left" == direction then
			--	print( "Reached Left Limit" )
		elseif "right" == direction then
			--	print( "Reached Right Limit" )
		end
	end
			
	return true
end

local function onButtonEvent(event)
	
	local btn = event.target
	
	if btn.id == "button1" then
	
		for i=1,4 do
			textDisplay[i].alpha = 0
			drugIcons[i].alpha = 0
		end
		textDisplay[1].alpha = 1
		drugIcons[1].alpha = 1
	
	elseif btn.id == "button2" then	
		for i=1,4 do

			textDisplay[i].alpha = 0
			drugIcons[i].alpha = 0

		end
		textDisplay[2].alpha = 1
		drugIcons[2].alpha = 1
			
	elseif btn.id == "button3" then
		for i=1,4 do
	
			textDisplay[i].alpha = 0
			drugIcons[i].alpha = 0
		end
		textDisplay[3].alpha = 1
		drugIcons[3].alpha = 1
			
	elseif btn.id == "button4" then	
		for i=1,4 do
	
			textDisplay[i].alpha = 0
			drugIcons[i].alpha = 0
		end
		textDisplay[4].alpha = 1
		drugIcons[4].alpha = 1
			
	elseif btn.id == "close_btn" then
		
		local function nextScene ( event )
			storyboard.gotoScene( "MainMenu")--,"fade",200)
		end
				
		timer.performWithDelay( 100, nextScene)	
		return true
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	bgoverlay_animate = false
	
	for i=1,4 do
		galleryScene[i] = display.newGroup()
	end
	
	collectgarbage( "collect" )
	bg = display.newImageRect("Images/Gallery/Aversion_Gallery_Screen.png",screenWidth ,screenHeight )
	bg.x = math.floor(screenWidth/2)
	bg.y = math.floor(screenHeight/2)
	
	
	-- Create a ScrollView
	for i=1,4 do
		scrollView[i] = widget.newScrollView
		{
			left = screenWidth * 0.37 + (screenWidth * (i-1)),
			top = 50,
			width = screenWidth * 0.6,
			scrollWidth = screenWidth * 0.6,
			height = screenHeight,
			bottomPadding = 125,
			id = "onBottom",
			horizontalScrollDisabled = true,
			verticalScrollDisabled = false,
			listener = scrollListener,
			hideBackground = true,
			hideScrollBar = true
		}
	end

	--Create a text object for the scrollViews title
	for i=1,4 do
		local titleText2 
		local titleText
		if i == 1 then
			titleText = display.newText("Heroin", 0, 0, native.systemFontBold, 24)
			titleText2 = display.newText("Heroin", 0, 0, native.systemFontBold, 20)
			--titleText2:setReferencePoint( display.TopCenterReferencePoint )
		elseif i == 2 then	
			titleText = display.newText("Cannabis", 0, 0, native.systemFontBold, 24)
			titleText2 = display.newText("Cannabis", 0, 0, native.systemFontBold, 20)
			--titleText2:setReferencePoint( display.TopCenterReferencePoint )
		elseif i == 3 then	
			titleText = display.newText("Meth", 0, 0, native.systemFontBold, 24)
			titleText2 = display.newText("METHAMPHETAMINE", 0, 0, native.systemFontBold, 20)
			--titleText2:setReferencePoint( display.TopCenterReferencePoint )
		elseif i == 4 then	
			titleText = display.newText("Inhalant", 0, 0, native.systemFontBold, 24)
			titleText2 = display.newText("Inhalant", 0, 0, native.systemFontBold, 20)
			--titleText2:setReferencePoint( display.TopLeftReferencePoint )
		end
		titleText:setTextColor(0, 0, 0)
		titleText.x = screenWidth * 0.2 + (screenWidth * (i-1))
		titleText.y = screenHeight * 0.8
		galleryScene[i]:insert( titleText )
		
	--	titleText2:setReferencePoint( display.TopRightReferencePoint ) -- deprecated
		titleText2.anchorX = 1.0	-- Graphics 2.0
		titleText2.anchorY = 0.0 	-- Graphics 2.0
		titleText2:setTextColor(0, 0, 0)
		titleText2.x = screenWidth * 0.127
		if i == 2 then
			titleText2.x = screenWidth * 0.177
		elseif i == 3 then
			titleText2.x = screenWidth * 0.41
		elseif i == 4 then
			titleText2.x = screenWidth * 0.155
		end
		titleText2.y = screenHeight * 0.17
		scrollView[i]:insert( titleText2 )
		
	end
	
		local filePath1 = system.pathForFile( "Images/Gallery/Heroin_Text.txt", "system.ResourceDirectory" )
		local filePath2 = system.pathForFile( "Images/Gallery/Cannabis_Text.txt", "system.ResourceDirectory" )
		local filePath3 = system.pathForFile( "Images/Gallery/Ice_Text.txt", "system.ResourceDirectory" )
		local filePath4 = system.pathForFile( "Images/Gallery/Inhalants_Text.txt", "system.ResourceDirectory" )
	
	-- io.open opens a file at filePath. returns nil if no file found
	--
	for i=1,4 do
		local file
		if i == 1 then
			file = io.open( filePath1, "r" )
		elseif i == 2 then
			file = io.open( filePath2, "r" )
		elseif i == 3 then
			file = io.open( filePath3, "r" )
		else
			file = io.open( filePath4, "r" )
		end
		
		if file then
			-- read all contents of file into a string
			local contents = file:read( "*a" )

			--Create a large text string
			local lotsOfText = contents--"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur imperdiet consectetur euismod. Phasellus non ipsum vel eros vestibulum consequat. Integer convallis quam id urna tristique eu viverra risus eleifend.\n\nAenean suscipit placerat venenatis. Pellentesque faucibus venenatis eleifend. Nam lorem felis, rhoncus vel rutrum quis, tincidunt in sapien. Proin eu elit tortor. Nam ut mauris pellentesque justo vulputate convallis eu vitae metus. Praesent mauris eros, hendrerit ac convallis vel, cursus quis sem. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque fermentum, dui in vehicula dapibus, lorem nisi placerat turpis, quis gravida elit lectus eget nibh. Mauris molestie auctor facilisis.\n\nCurabitur lorem mi, molestie eget tincidunt quis, blandit a libero. Cras a lorem sed purus gravida rhoncus. Cras vel risus dolor, at accumsan nisi. Morbi sit amet sem purus, ut tempor mauris.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur imperdiet consectetur euismod. Phasellus non ipsum vel eros vestibulum consequat. Integer convallis quam id urna tristique eu viverra risus eleifend.\n\nAenean suscipit placerat venenatis. Pellentesque faucibus venenatis eleifend. Nam lorem felis, rhoncus vel rutrum quis, tincidunt in sapien. Proin eu elit tortor. Nam ut mauris pellentesque justo vulputate convallis eu vitae metus. Praesent mauris eros, hendrerit ac convallis vel, cursus quis sem. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque fermentum, dui in vehicula dapibus, lorem nisi placerat turpis, quis gravida elit lectus eget nibh. Mauris molestie auctor facilisis.\n\nCurabitur lorem mi, molestie eget tincidunt quis, blandit a libero. Cras a lorem sed purus gravida rhoncus. Cras vel risus dolor, at accumsan nisi. Morbi sit amet sem purus, ut tempor mauris. "

			--Create a text object containing the large text string and insert it into the scrollView
			lotsOfTextObject = display.newText( lotsOfText, 0, 0, 300, 0, "Helvetica", 14)
			lotsOfTextObject:setTextColor( 0 ) 
		--	lotsOfTextObject:setReferencePoint( display.TopCenterReferencePoint )	-- deprecated
			lotsOfTextObject.anchorX = 0.5	-- Graphics 2.0
			lotsOfTextObject.anchorY = 0.0	-- Graphics 2.0
			lotsOfTextObject.x = screenWidth * 0.31 --+ (screenWidth * (i-1))
			lotsOfTextObject.y = screenHeight * 0.18
			scrollView[i]:insert( lotsOfTextObject )
		end
	end
	
	local imgOptions =
	{
		-- FRAME 1:
		width = 128,
		height = 128,
		numFrames = 4,
		sheetContentWidth = 512,
		sheetContentHeight = 128
	}
	
	local myImgSheet = graphics.newImageSheet("Images/Gallery/DrugIcons2.png",imgOptions )

	screenGroup:insert(bg)

	for i = 1,4 do
		drugIcons[i] = display.newImageRect(screenGroup,myImgSheet,i,128,128)
		
		drugIcons[i].alpha = 1
		drugIcons[i].x = screenWidth * 0.2 + (screenWidth * (i-1))
		drugIcons[i].y = screenHeight * 0.55
		galleryScene[i]:insert(drugIcons[i])
		galleryScene[i]:insert(scrollView[i])
	end
	
	bg2 = display.newImageRect("Images/Gallery/Aversion_Gallery_Screen_Overlay.png",screenWidth ,screenHeight )
	bg2.x = screenWidth/2
	bg2.y = screenHeight/2
	--screenGroup:insert(bg2)
	
	local DotsOptions =
	{
		-- FRAME 1:
		width = 48,
		height = 48,
		numFrames = 4,
		sheetContentWidth = 192,
		sheetContentHeight = 48
	}
	
	local myDotsSheet = graphics.newImageSheet("Images/Gallery/Page_Dots.png",DotsOptions )

	screenGroup:insert(bg)

	for i = 1,4 do
		dotsIcons[i] = display.newImageRect(screenGroup,myDotsSheet,i,48,48)
		
		--dotsIcons[i].alpha = 1
		dotsIcons[i].x = screenWidth * 0.2 + (screenWidth * (i-1))
		dotsIcons[i].y = screenHeight * 0.86
		galleryScene[i]:insert(dotsIcons[i])
		galleryScene[i]:insert(scrollView[i])
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

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local screenGroup = self.view
	
	storyboard.removeScene( "GameScene" )
	storyboard.removeScene( "HelpMenu" )
	storyboard.removeScene( "SettingsMenu" )
	storyboard.removeScene( "LevelSelect" )
	
	storyboard.removeAll()
	storyboard.purgeAll()

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
local screenGroup = self.view

	for i=1,4 do	
		display.remove(textDisplay[i])
		textDisplay[i] = nil
		display.remove(drugIcons[i])
		drugIcons[i] = nil
		display.remove(dotsIcons[i])
		dotsIcons[i] = nil
		display.remove(scrollView[i])
		scrollView[i] = nil
		display.remove(galleryScene[i])
		galleryScene[i] = nil
	end

	display.remove(lotsOfTextObject)
	lotsOfTextObject = nil
	
	display.remove(titleDisplay)
	titleDisplay = nil
	
	display.remove(backBtn)
	backBtn = nil
	
	display.remove(bg)
	bg = nil
	display.remove(bg2)
	bg2 = nil
	
	screenGroup:removeSelf()
	screenGroup = nil
	
	Runtime:removeEventListener("touch", onTouch)

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
end



local function onTouch(event)

	if event.phase == "began" then 
		xStart = event.x
		
	elseif event.phase == "moved" then 
		
	elseif event.phase == "ended" then 

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