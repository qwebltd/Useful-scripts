-----------------------------------------------------------------------------------------
--
-- camera.lua
--
-- Camera control functions.
--
--[[
<documentation type="head">
	<parent>Main</parent>
	<name>Camera</name>
	<description>
		Camera functions, to move and rotate the camera.
	</description>
</documentation>
--]]
-----------------------------------------------------------------------------------------

-- Various functions for convenience.
local convenience = require ((...):match("(.-)[^%.]+$") .. "convenience")

-- Global variables
local vars = require ((...):match("(.-)[^%.]+$") .. "globals")

-- Local variables
local module = {}

--[[
<documentation type="function">
	<name>moveCamera(decimal x, decimal y, decimal z)</name>
	<description>
		Adjusts the position x,y,z of the camera. This differs from positionCamera() in that the co-ordinates passed are used as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		x = Amount along the x axis to move by.
		y = Amount along the y axis to move by.
		z = Amount along the z axis to move by.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Moves the camera slightly along the x axis
	q3d.moveCamera({ x = 5 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.moveCamera = function(parameters)
	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.camera.x = vars.camera.x + x
	end

	if(y ~= nil) then
		vars.camera.y = vars.camera.y + y
	end

	if(z ~= nil) then
		vars.camera.z = vars.camera.z + z
	end

	return true
end

--[[
<documentation type="function">
	<name>positionCamera(decimal x, decimal y, decimal z)</name>
	<description>
		Sets the position x,y,z of the camera. This differs from moveCamera() in that the co-ordinates passed are used as absolute values rather than as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		x = Amount along the x axis to move by.
		y = Amount along the y axis to move by.
		z = Amount along the z axis to move by.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Moves the camera to a position slightly along the x axis
	q3d.positionCamera({ x = 5 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.positionCamera = function(parameters)
	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.camera.x = x
	end

	if(y ~= nil) then
		vars.camera.y = y
	end

	if(z ~= nil) then
		vars.camera.z = z
	end

	return true
end

--[[
<documentation type="function">
	<name>rotateCamera(table parameters)</name>
	<description>
		Increments the rotation x,y,z of the camera. This differs from rotationCamera() in that the angles passed are used as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		x = Rotation along the x axis, in degrees between 0 and 359. Defaults to 0.
		y = Rotation along the y axis, in degrees between 0 and 359. Defaults to 0.
		z = Rotation along the z axis, in degrees between 0 and 359. Defaults to 0.

		Rotations passed in degrees outside of the range 0 - 359 are normalised and will work, but passing the angle 360015 and leaving the engine to refactor this to 15 degrees will be slower than just passing the angle 15.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Rotates the camera by 10 degrees along the y axis
	q3d.rotateCamera({ y = 10 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.rotateCamera = function(parameters)
	-- locals are faster
	local lnormalisedRotation = convenience.normalisedRotation

	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.camera.xr = lnormalisedRotation(vars.camera.xr + x)
	end

	if(y ~= nil) then
		vars.camera.yr = lnormalisedRotation(vars.camera.yr + y)
	end

	if(z ~= nil) then
		vars.camera.zr = lnormalisedRotation(vars.camera.zr + z)
	end

	return true
end

--[[
<documentation type="function">
	<name>rotationCamera(table parameters)</name>
	<description>
		Sets the rotation x,y,z ofthe camera. This differs from rotateCamera() in that the angles passed are used as absolute values rather than as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		x = Rotation along the x axis, in degrees between 0 and 359. Defaults to 0.
		y = Rotation along the y axis, in degrees between 0 and 359. Defaults to 0.
		z = Rotation along the z axis, in degrees between 0 and 359. Defaults to 0.

		Rotations passed in degrees outside of the range 0 - 359 are normalised and will work, but passing the angle 360015 and leaving the engine to refactor this to 15 degrees will be slower than just passing the angle 15.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Rotates the camera to 10 degrees along the y axis
	q3d.rotationCamera({ y = 10 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.rotationCamera = function(parameters)
	-- locals are faster
	local lnormalisedRotation = convenience.normalisedRotation

	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.camera.xr = lnormalisedRotation(x)
	end

	if(y ~= nil) then
		vars.camera.yr = lnormalisedRotation(y)
	end

	if(z ~= nil) then
		vars.camera.zr = lnormalisedRotation(z)
	end

	return true
end

--[[
<documentation type="function">
	<name>getCameraRotation()</name>
	<description>
		Returns the current rotation x,y,z of the camera.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Rotates the camera to 10 degrees along the y axis
	q3d.rotationCamera({ y = 10 })

	-- Outputs the current y rotation of the camera
	print("Camera y rotaion = " .. q3d.getCameraRotation().y)

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.getCameraRotation = function()
	return {
		x = vars.camera.xr,
		y = vars.camera.yr,
		z = vars.camera.zr
	}
end


--[[
<documentation type="function">
	<name>getCameraPosition()</name>
	<description>
		Returns the current x,y,z position of the camera.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Moves the camera to a position slightly along the x axis
	q3d.positionCamera({ x = 5 })

	-- Outputs the current y rotation of the camera
	print("Camera x position = " .. q3d.getCameraPosition().x)

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.getCameraPosition = function()
	return {
		x = vars.camera.x,
		y = vars.camera.y,
		z = vars.camera.z
	}
end

-- Puts all of the module functions in to the main library scope
module.init = function(main)
	main.moveCamera = module.moveCamera
	main.positionCamera = module.positionCamera
	main.rotateCamera = module.rotateCamera
	main.rotationCamera = module.rotationCamera
	main.getCameraRotation = module.getCameraRotation
	main.getCameraPosition = module.getCameraPosition
end

return module