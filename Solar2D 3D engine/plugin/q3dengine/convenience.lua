-----------------------------------------------------------------------------------------
--
-- convenience.lua
--
-- Various variables and functions for convenience, basically to extend the Lua language.
--
-----------------------------------------------------------------------------------------

-- Local variables
local module = {}

-- Various letterbox-friendly screen properties, useful for positioning.
module.screen = {
	width = math.ceil(display.contentWidth + ((display.screenOriginX / -1) * 2)),
	height = math.ceil(display.contentHeight + ((display.screenOriginY / 1) * 2)),
	x = math.ceil(display.screenOriginX),
	y = math.ceil(display.screenOriginY),
	midX = display.contentWidth / 2,
	midY = display.contentHeight / 2,
	xEdgeLeft = display.screenOriginX,
	yEdgeTop = display.screenOriginY,
	xEdgeRight = display.contentWidth + (display.screenOriginX / -1),
	yEdgeBottom = display.contentHeight + (display.screenOriginY / -1)
}

-- Returns the length of an associative table, because Lua's # operator isn't able to.
module.tableLength = function(t)
	local iteration = 0

	for k,v in pairs(t) do
		iteration = iteration + 1
	end

	return iteration
end

-- Rounds a number, because Lua doesn't have a native function for it.
module.round = function(n, d)
	if(d) then
		return math.floor((n * (10 ^ d)) + 0.5) / (10 ^ d)
	else
		return math.floor(n + 0.5)
	end
end

-- Determines if a file exists.
module.isFile = function(filename, baseDir)
	local fileHandle = io.open(system.pathForFile(filename, baseDir), "r")

	if(fileHandle) then
		fileHandle:close()
		return true
	else
		return false
	end
end

-- Calculates the distance between two points. I.e. the hypotenuse, but in 3D space
module.distanceBetweenPoints = function(x1, y1, z1, x2, y2, z2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end


-- Keeps rotations between 0 and 359 degrees
module.normalisedRotation = function(rotation)
	while(rotation > 359) do
		rotation = rotation - 360
	end

	while(rotation < 0) do
		rotation = rotation + 360
	end

	return rotation
end

return module