

local grid = {}
grid.sprite 		= nil
grid.parent 		= nil
grid.child 			= nil
grid.costToSource 	= 0
grid.x 				= 0
grid.y 				= 0
grid.fVal 			= 0

local pathFind = {}
pathFind.startX 		= 0
pathFind.startY 		= 0
pathFind.endX			= 0
pathFind.endY 			= 0
pathFind.mapSize 		= nil
pathFind.tileSize       = nil

pathFind.openList		= {{}, {}}