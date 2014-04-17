-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require "storyboard"
storyboard.currentWorld = 1
storyboard.currentLevel = 1
storyboard.isPaused = false
storyboard.playerHealth = 5
storyboard.firstRun = true
storyboard.firstEntry = true
storyboard.isVibrateOn = true

dusk = require("Dusk.Dusk")
--lime = require("lime.lime")
display.setStatusBar( display.HiddenStatusBar )
--local lime = require("lime.lime")
-- load GameScene.lua
storyboard.gotoScene( "MainMenu" )
	print(display.contentWidth)
	print(display.contentHeight)
-- Add any objects that should appear on all scenes below (e.g. tab bar, HUD, etc.):

local bgm = audio.loadStream( "Audios/bgm.mp3" )
local bgmChn = audio.play( bgm, { channel=1, loops=-1, fadein=5000 } )