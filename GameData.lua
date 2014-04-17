
----------
M = {};
 
loadsave = require("loadsave");
local DATA_FILE = "mygamesettings.json";
 
M.saveData = function()
    loadsave.saveTable(M.myTable, DATA_FILE);
end
 
M.myTable = loadsave.loadTable(DATA_FILE)  -- this load myTable everytime I open the app
 
local numOfWorlds = 5
local numOfLevels = 8

function M.GetNumOfWorlds()
	return numOfWorlds
end

function M.GetNumOfLevels()
	return numOfLevels
end

if (M.myTable == nil) then

	M.myTable = {}
	M.myTable.levelData = {}

	for i=1,numOfWorlds do

		M.myTable.levelData[i] = {}

        for j=1,numOfLevels do
			 
			M.myTable.levelData[i][j] = {}
			M.myTable.levelData[i][j].locked = true
			M.myTable.levelData[i][j].stars = 0
		end
    end
	
	M.myTable.levelData[1][1].locked = false
	M.saveData() -- Saves the data	
end

for j=1,numOfLevels do
	M.myTable.levelData[1][j].locked = false
end

M.myTable.levelData[1][2].locked = false
M.myTable.levelData[1][3].locked = false
M.myTable.levelData[1][4].locked = false
M.myTable.levelData[1][5].locked = false
M.myTable.levelData[1][6].locked = false
M.myTable.levelData[1][7].locked = false
M.myTable.levelData[1][8].locked = false
 
M.myTable.levelData[5][1].locked = false

for i=1,7 do
	M.myTable.levelData[1][i].stars = 3 
end

M.myTable.levelData[1][2].stars = 2

M.myTable = loadsave.loadTable(DATA_FILE) -- This loads the saved table

return M;