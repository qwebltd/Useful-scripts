-- 
-- Abstract: q3dengine Library Plugin Test Project
--
------------------------------------------------------------

-- Load plugin library
local q3d = require "plugin.q3dengine"

-------------------------------------------------------------------------------
-- BEGIN (Insert your sample test starting here)
-------------------------------------------------------------------------------

-- This isn't really needed, but Android's navigation bar looks ugly so...
native.setProperty("androidSystemUiVisibility", "immersiveSticky")

-- First, tell q3dengine where 3D models and texture files are.
q3d.setAssetsFolder("assets")

-- Generate some cubes.

math.randomseed( os.time() )

for i=1, 30, 1 do
	q3d.addCube({ name = "myCube" .. i, x = math.random(-20, 20), y = math.random(-1, 1), z = math.random(-20, 20) })
end

-- Initial camera placement.
q3d.moveCamera({ x = 0, y = 6, z = -10 })
q3d.rotateCamera({ x = -30, y = 0, z = 0 })

-- Enable the main Q3D loop to render/update our world.
q3d.activate()

-- Keep the camera rotating to show these cubes. Alternatively, comment this section out and uncomment the following section to use the arrow keys to move around.
local function doCameraRotation()
	q3d.rotateCamera({ y = .5 })
end
Runtime:addEventListener('enterFrame', doCameraRotation)

--[[
-- Player (camera) movement.
local moveForward = false
local moveBackward = false
local turnLeft = false
local turnRight = false

local function capturePlayerActions(event)
	if(event.keyName == "up") then
		moveForward = (event.phase == "down")
	end

	if(event.keyName == "down") then
		moveBackward = (event.phase == "down")
	end

	if(event.keyName == "left") then
		turnLeft = (event.phase == "down")
	end

	if(event.keyName == "right") then
		turnRight = (event.phase == "down")
	end
end

Runtime:addEventListener( "key", capturePlayerActions )

local function doPlayerMovement()
	if(moveForward) then
	end

	if(moveBackward) then
	end

	if(turnLeft) then
		q3d.rotateCamera({ y = -.5 })
	end

	if(turnRight) then
		q3d.rotateCamera({ y = .5 })
	end
end

-- Using timers ensures a consistent movement speed.
timer.performWithDelay(10, doPlayerMovement, -1)
]]--
-------------------------------------------------------------------------------
-- END
-------------------------------------------------------------------------------