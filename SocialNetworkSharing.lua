----------------------------------------------------------------------------------
--
-- SocialNetworkSharing.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require( "widget" )
local gameData = require("GameData")

local screenWidth = display.contentWidth
local screenHeight = display.contentHeight

local gameData = require("GameData")

-- Facebook implementation
local facebook = require("Social Network.lib_facebook")
facebook.isDebug = true
facebook.FB_App_ID = "266081593562753"
facebook.FB_Access_Token = "CAADxZCZCLdloEBAJ2XY8C39tmrU2ZBHtBN10x13sC5UTqXAZCiJoQoYQLHCitMvMjbUKWLFggFrhiFRpm2BWbO1EZA3x1brF4k4qgSAMLuZBAFZC6ojGZBzZCsmv1iHF9x5zLXPrBV2DKGplGoVKu3QCtvsuUw5xcEWKQqTlZB9Vz4kctCT1kncGnkkBkYww2X9zcZD"

-- Twitter implementation
local twitter = require("Social Network.Twitter")
twitter.consumer_key = "MRHJT6ocah8j5O8xs5NlRDm2I"
twitter.consumer_secret = "iMU0xwdWLsOAOg89kWV87hg48LGCVBIr5bI6ZpLTYgwxzmlJBY"

local CurrentStage = storyboard.currentStage
local StarsForThisStage = gameData.GetStarsForStage(CurrentStage)

local Message = "I've earned " .. StarsForThisStage .. " stars for Stage " .. CurrentStage .. " in Aversion!"

local bg =
{
	black = {},
	pic = {},
	words = {}
}

local buttons =
{
	fb_btn = {},
	twt_btn = {},
	skip = {}
}

local hasShared = { facebook = false, twitter = false }

local isSimulator = false
if system.getInfo("platformName") == "Win" or system.getInfo("platformName") == "Mac OS X" then
	isSimulator = true
end

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function facebook_press(event)

	if hasShared.facebook then
		bg.words.text = "Already shared to Facebook"
		return
	end

	bg.words.text = "Sharing to Facebook..."
	bg.words.size = 20

	local function onRequestComplete(event)
		if not event.isError --[[or isSimulator]] then -- if you want the sharing to 'work' on the simulator
			bg.words.text = "Shared to Facebook!"
			hasShared.facebook = true
		else
	--		bg.words.text = event.response.error.message	-- debug error message
	--		bg.words.size = 10								-- error message too long, scale it down
			bg.words.text = "Sharing to Facebook Failed!"
		end
	end

	local function onLoginComplete(event)
		if event.phase == "login" then
			facebook.request( "me/feed", "POST", { message = Message }, onRequestComplete )
		else
			bg.words.text = "Facebook login failed!"
		end
	end

	facebook.login({"publish_stream"}, onLoginComplete)
end

local function twitter_press(event)

	if hasShared.twitter then
		bg.words.text = "Already shared to Twitter"
		return
	end

	bg.words.text = "Sharing to Twitter..."
	bg.words.size = 20

	local callback = {}

	function callback.twitterCancel()
		bg.words.text = "Sharing to Twitter cancelled"
	end

	function callback.twitterSuccess(requestType, name, response)
		bg.words.text = "Shared to Twitter!"
		hasShared.twitter = true
	end

	function callback.twitterFailed()
--	if isSimulator then -- if you want the sharing to 'work' on the simulator
--			callback.twitterSuccess()
--		else
			bg.words.text = "Sharing to Twitter failed"
--		end
	end

	local time = os.date ("*t")

	local params = 
	{
		"tweet",
		"statuses/update.json",
		"POST",
		{ "status", Message }
	}

	twitter.tweet(callback, params)
end

local function skip_press(event)
	storyboard.hideOverlay("SocialNetworkSharing")
	storyboard.showOverlay("LevelClear")
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------

	-- black transparent background
	bg.black = display.newRect( 0, 0, screenWidth, screenHeight )
	bg.black:setFillColor( 255, 255, 255 )
	bg.black.alpha = 0.75
	bg.black.x, bg.black.y = screenWidth / 2, screenHeight / 2

	-- words, asking player to share to FB and Twitter
--	bg.pic = display.newImageRect( "Images/Social_Network/Social_Network.png", screenWidth, screenHeight )
--	bg.pic.x, bg.pic.y = screenWidth / 2, screenHeight / 2

	bg.words = display.newText
	{ 
		text = "Share to Facebook and Twitter!",
		x = screenWidth * 0.5,
		y = screenHeight * 0.25,
		height = 0,
		width = screenWidth * 0.8,
		font = "MAGNUM__",
		fontSize = 50,
		align = "center"
	}
	bg.words:setFillColor( 0, 0, 0 )

	-- create Facebook button
	buttons.fb_btn = widget.newButton
	{
		defaultFile = "Images/Social_Network/facebook.png",
		overFile = "Images/Social_Network/facebook_down.png",
		id = "facebook_btn",
		width = 128,
		height = 128,
		x = screenWidth * 0.25,
		y = screenHeight * 0.7,
		onRelease = facebook_press
	}

	-- create Twitter button
	buttons.twt_btn = widget.newButton
	{
		defaultFile = "Images/Social_Network/twitter.png",
		overFile = "Images/Social_Network/twitter_down.png",
		id = "twitter_btn",
		width = 128,
		height = 128,
		x = screenWidth * 0.5,
		y = screenHeight * 0.7,
		onRelease = twitter_press
	}

	-- create Skip button
	buttons.skip_btn = widget.newButton
	{
		defaultFile = "Images/Social_Network/skip.png",
		overFile = "Images/Social_Network/skip_down.png",
		id = "skip_btn",
		width = 128,
		height = 128,
		x = screenWidth * 0.75,
		y = screenHeight * 0.7,
		onRelease = skip_press
	}
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
	for k,v in pairs(bg) do
		display.remove(bg[k])
		bg[k] = nil
	end
	bg = nil

	for k,v in pairs(buttons) do
		display.remove(buttons[k])
		buttons[k] = nil
	end
	buttons = nil

	group:removeSelf()
	group = nil

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
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