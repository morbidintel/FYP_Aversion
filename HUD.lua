local HUD = {}	-- table?

local StartTime = 0
local PauseTime = 0
local TimePaused = 0
local TimeResumed = 0
local RunTime = 0

local b_paused = false
local b_stopped= false

local TimerSprite
local TenthTimerSprite

function HUD.Create()

	local TimerOption = {
		width = 24,--32,
		height = 24,--32,
		numFrames = 10,
		sheetContentWidth = 240,--320,
		sheetContentHeight= 24--32
	}

	local TimerSheet = graphics.newImageSheet( "Images/Others/digits.png", TimerOption )

	local sequenceData = {
		{ name = "1", frames = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, time = 750 },
	}

	TimerSprite = display.newSprite( TimerSheet, sequenceData )
	TimerSprite.x = 320--64
	TimerSprite.y = 36

	TenthTimerSprite = display.newSprite( TimerSheet, sequenceData )
	TenthTimerSprite.x = 288--32
	TenthTimerSprite.y = 36
	
	print("Timer Created")
end

function HUD.GetRunTime()
	return RunTime
end

function HUD.StartTimer()
	b_stopped = false
	StartTime = system.getTimer()
	PauseTime = 0
	RunTime = 0
end

function HUD.PauseTimer(p)
	b_paused = p
	
	if p == true then	-- pause
		TimePaused = (system.getTimer() - StartTime) / 1000
		--print("Time Paused - "..TimePaused)
	else						-- resume
		TimeResumed = (system.getTimer() - StartTime) / 1000
		--print("Time Resumed - "..TimeResumed)
		PauseTime = PauseTime + (TimeResumed - TimePaused)
		--print("Time Difference "..PauseTime)
	end
end

function HUD.StopTimer()
	b_stopped = true
end

function HUD.UpdateTimer()
	RunTime = (system.getTimer() - StartTime) / 1000
	RunTime = RunTime - PauseTime
	
	if b_stopped ~= true and b_paused ~= true then
		local t = math.floor(RunTime%10)
		if t >= 0 then
			TimerSprite:setFrame(t+1)
			if t == 0 then
				TenthTimerSprite:setFrame(math.floor(RunTime/10) + 1)
			end
		end
	end
	
	if RunTime >= 99 then
		b_stopped = true
	end
end

function HUD.Destroy()
	--if TimerSprite ~= nil then
	--	TimerSprite:removeSelf()
	--end
	--if TenthTimerSprite ~= nil then
	--	TenthTimerSprite:removeSelf()
	--end
	display.remove(TimerSprite)
	display.remove(TenthTimerSprite)
	print("Timer Destroyed")
end

return HUD