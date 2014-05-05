
----------
M = {};
 
loadsave = require("loadsave");
local DATA_FILE = "mygamesettings.json";
 
M.saveData = function()
    loadsave.saveTable(M.myTable, DATA_FILE);
end
 
M.levelData = loadsave.loadTable(DATA_FILE)  -- this load myTable everytime I open the app
 
local numOfStages = 5
local numOfLevels = 8

function M.GetNumOfStages()
	return numOfStages
end

function M.GetNumOfLevels()
	return numOfLevels
end

function M.GetStarsForStage(stage)

	if not stage or stage < 1 or stage > numOfStages then
		error("M.GetStarsForStage : invalid stage number")
	end

	local totalStars = 0

	for i = 1, numOfLevels do
		totalStars = totalStars + M.levelData[stage][i].stars
	end

	return totalStars

end


if (M.levelData == nil) then

	M.levelData = {}

	for i=1,numOfStages do

		M.levelData[i] = {}

        for j=1,numOfLevels do
			 
			M.levelData[i][j] = {}
			M.levelData[i][j].locked = false
			M.levelData[i][j].stars = 0
		end

    end
	
	M.levelData[1][1].locked = false
	M.saveData() -- Saves the data	
end

for stageIndex = 3, numOfStages do
	for levelIndex = 1, numOfLevels do
		M.levelData[stageIndex][levelIndex].locked = true
	end
end

M.saveData()

M.myTable = loadsave.loadTable(DATA_FILE) -- This loads the saved table

return M;