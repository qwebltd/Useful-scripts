-----------------------------------------------------------------------------------------
--
-- objects.lua
--
-- Object handling functions.
--
--[[
<documentation type="head">
	<parent>Graphics</parent>
	<name>Objects</name>
	<description>
		Controls the creation, modification, and removal of objects in the 3D world.
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
	<name>addCube(table parameters)</name>
	<description>
		Adds a new cube to the world. Cubes consist of 6 faces, with each face made of 32 triangles arranged in the form of 4x4 grids of squares. UV mapping is set up by default so that textures can be applied to each face independantly.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		name (required) = String value used to uniquely identify this object in the world.
		x = world x co-ordinate to position the cube at. Defaults to 0.
		y = world y co-ordinate to position the cube at. Defaults to 0.
		z = world z co-ordinate to position the cube at. Defaults to 0.
		xr = Rotation along the x axis, in degrees between 0 and 359. Defaults to 0.
		yr = Rotation along the y axis, in degrees between 0 and 359. Defaults to 0.
		zr = Rotation along the z axis, in degrees between 0 and 359. Defaults to 0.
		xs = Scale along the x axis. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size. Defaults to 1.
		ys = Scale along the y axis. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size. Defaults to 1.
		zs = Scale along the z axis. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size. Defaults to 1.

		Rotations passed in degrees outside of the range 0 - 359 are normalised and will work, but passing the angle 360015 and leaving the engine to refactor this to 15 degrees will be slower than just passing the angle 15.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.addCube = function(parameters)
	-- locals are faster
	local lnormalisedRotation = convenience.normalisedRotation

	local name = parameters.name or "object" .. (#vars.objects + 1)
	local x = parameters.x or 0
	local y = parameters.y or 0
	local z = parameters.z or 0
	local xr = parameters.xr or 0
	local yr = parameters.yr or 0
	local zr = parameters.zr or 0
	local xs = parameters.xs or 1
	local ys = parameters.ys or 1
	local zs = parameters.zs or 1

	vars.objects[name] = {
		x = x,
		y = y,
		z = z,
		xr = lnormalisedRotation(xr),
		yr = lnormalisedRotation(yr),
		zr = lnormalisedRotation(zr),
		xs = xs,
		ys = ys,
		zs = zs,
		vertices = { -- each vertice is an x,y,z relative to the object x,y,z
			{x = -1, y = 1, z = -1, u = 0, v = 0},
			{x = -1, y = .5, z = -1, u = 0, v = .25},
			{x = -1, y = 0, z = -1, u = 0, v = .5},
			{x = -1, y = -.5, z = -1, u = 0, v = .75},
			{x = -1, y = -1, z = -1, u = 0, v = 1},
			{x = -.5, y = 1, z = -1, u = .25, v = 0},
			{x = -.5, y = .5, z = -1, u = .25, v = .25},
			{x = -.5, y = 0, z = -1, u = .25, v = .5},
			{x = -.5, y = -.5, z = -1, u = .25, v = .75},
			{x = -.5, y = -1, z = -1, u = .25, v = 1},
			{x = 0, y = 1, z = -1, u = .5, v = 0},
			{x = 0, y = .5, z = -1, u = .5, v = .25},
			{x = 0, y = 0, z = -1, u = .5, v = .5},
			{x = 0, y = -.5, z = -1, u = .5, v = .75},
			{x = 0, y = -1, z = -1, u = .5, v = 1},
			{x = .5, y = 1, z = -1, u = .75, v = 0},
			{x = .5, y = .5, z = -1, u = .75, v = .25},
			{x = .5, y = 0, z = -1, u = .75, v = .5},
			{x = .5, y = -.5, z = -1, u = .75, v = .75},
			{x = .5, y = -1, z = -1, u = .75, v = 1},
			{x = 1, y = 1, z = -1, u = 1, v = 0},
			{x = 1, y = .5, z = -1, u = 1, v = .25},
			{x = 1, y = 0, z = -1, u = 1, v = .5},
			{x = 1, y = -.5, z = -1, u = 1, v = .75},
			{x = 1, y = -1, z = -1, u = 1, v = 1},

			{x = 1, y = 1, z = -1, u = 0, v = 0},
			{x = 1, y = .5, z = -1, u = 0, v = .25},
			{x = 1, y = 0, z = -1, u = 0, v = .5},
			{x = 1, y = -.5, z = -1, u = 0, v = .75},
			{x = 1, y = -1, z = -1, u = 0, v = 1},
			{x = 1, y = 1, z = -.5, u = .25, v = 0},
			{x = 1, y = .5, z = -.5, u = .25, v = .25},
			{x = 1, y = 0, z = -.5, u = .25, v = .5},
			{x = 1, y = -.5, z = -.5, u = .25, v = .75},
			{x = 1, y = -1, z = -.5, u = .25, v = 1},
			{x = 1, y = 1, z = 0, u = .5, v = 0},
			{x = 1, y = .5, z = 0, u = .5, v = .25},
			{x = 1, y = 0, z = 0, u = .5, v = .5},
			{x = 1, y = -.5, z = 0, u = .5, v = .75},
			{x = 1, y = -1, z = 0, u = .5, v = 1},
			{x = 1, y = 1, z = .5, u = .75, v = 0},
			{x = 1, y = .5, z = .5, u = .75, v = .25},
			{x = 1, y = 0, z = .5, u = .75, v = .5},
			{x = 1, y = -.5, z = .5, u = .75, v = .75},
			{x = 1, y = -1, z = .5, u = .75, v = 1},
			{x = 1, y = 1, z = 1, u = 1, v = 0},
			{x = 1, y = .5, z = 1, u = 1, v = .25},
			{x = 1, y = 0, z = 1, u = 1, v = .5},
			{x = 1, y = -.5, z = 1, u = 1, v = .75},
			{x = 1, y = -1, z = 1, u = 1, v = 1},

			{x = 1, y = 1, z = 1, u = 0, v = 0},
			{x = 1, y = .5, z = 1, u = 0, v = .25},
			{x = 1, y = 0, z = 1, u = 0, v = .5},
			{x = 1, y = -.5, z = 1, u = 0, v = .75},
			{x = 1, y = -1, z = 1, u = 0, v = 1},
			{x = .5, y = 1, z = 1, u = .25, v = 0},
			{x = .5, y = .5, z = 1, u = .25, v = .25},
			{x = .5, y = 0, z = 1, u = .25, v = .5},
			{x = .5, y = -.5, z = 1, u = .25, v = .75},
			{x = .5, y = -1, z = 1, u = .25, v = 1},
			{x = 0, y = 1, z = 1, u = .5, v = 0},
			{x = 0, y = .5, z = 1, u = .5, v = .25},
			{x = 0, y = 0, z = 1, u = .5, v = .5},
			{x = 0, y = -.5, z = 1, u = .5, v = .75},
			{x = 0, y = -1, z = 1, u = .5, v = 1},
			{x = -.5, y = 1, z = 1, u = .75, v = 0},
			{x = -.5, y = .5, z = 1, u = .75, v = .25},
			{x = -.5, y = 0, z = 1, u = .75, v = .5},
			{x = -.5, y = -.5, z = 1, u = .75, v = .75},
			{x = -.5, y = -1, z = 1, u = .75, v = 1},
			{x = -1, y = 1, z = 1, u = 1, v = 0},
			{x = -1, y = .5, z = 1, u = 1, v = .25},
			{x = -1, y = 0, z = 1, u = 1, v = .5},
			{x = -1, y = -.5, z = 1, u = 1, v = .75},
			{x = -1, y = -1, z = 1, u = 1, v = 1},

			{x = -1, y = 1, z = 1, u = 0, v = 0},
			{x = -1, y = .5, z = 1, u = 0, v = .25},
			{x = -1, y = 0, z = 1, u = 0, v = .5},
			{x = -1, y = -.5, z = 1, u = 0, v = .75},
			{x = -1, y = -1, z = 1, u = 0, v = 1},
			{x = -1, y = 1, z = .5, u = .25, v = 0},
			{x = -1, y = .5, z = .5, u = .25, v = .25},
			{x = -1, y = 0, z = .5, u = .25, v = .5},
			{x = -1, y = -.5, z = .5, u = .25, v = .75},
			{x = -1, y = -1, z = .5, u = .25, v = 1},
			{x = -1, y = 1, z = 0, u = .5, v = 0},
			{x = -1, y = .5, z = 0, u = .5, v = .25},
			{x = -1, y = 0, z = 0, u = .5, v = .5},
			{x = -1, y = -.5, z = 0, u = .5, v = .75},
			{x = -1, y = -1, z = 0, u = .5, v = 1},
			{x = -1, y = 1, z = -.5, u = .75, v = 0},
			{x = -1, y = .5, z = -.5, u = .75, v = .25},
			{x = -1, y = 0, z = -.5, u = .75, v = .5},
			{x = -1, y = -.5, z = -.5, u = .75, v = .75},
			{x = -1, y = -1, z = -.5, u = .75, v = 1},
			{x = -1, y = 1, z = -1, u = 1, v = 0},
			{x = -1, y = .5, z = -1, u = 1, v = .25},
			{x = -1, y = 0, z = -1, u = 1, v = .5},
			{x = -1, y = -.5, z = -1, u = 1, v = .75},
			{x = -1, y = -1, z = -1, u = 1, v = 1},

			{x = -1, y = 1, z = 1, u = 0, v = 0},
			{x = -1, y = 1, z = .5, u = 0, v = .25},
			{x = -1, y = 1, z = 0, u = 0, v = .5},
			{x = -1, y = 1, z = -.5, u = 0, v = .75},
			{x = -1, y = 1, z = -1, u = 0, v = 1},
			{x = -.5, y = 1, z = 1, u = .25, v = 0},
			{x = -.5, y = 1, z = .5, u = .25, v = .25},
			{x = -.5, y = 1, z = 0, u = .25, v = .5},
			{x = -.5, y = 1, z = -.5, u = .25, v = .75},
			{x = -.5, y = 1, z = -1, u = .25, v = 1},
			{x = 0, y = 1, z = 1, u = .5, v = 0},
			{x = 0, y = 1, z = .5, u = .5, v = .25},
			{x = 0, y = 1, z = 0, u = .5, v = .5},
			{x = 0, y = 1, z = -.5, u = .5, v = .75},
			{x = 0, y = 1, z = -1, u = .5, v = 1},
			{x = .5, y = 1, z = 1, u = .75, v = 0},
			{x = .5, y = 1, z = .5, u = .75, v = .25},
			{x = .5, y = 1, z = 0, u = .75, v = .5},
			{x = .5, y = 1, z = -.5, u = .75, v = .75},
			{x = .5, y = 1, z = -1, u = .75, v = 1},
			{x = 1, y = 1, z = 1, u = 1, v = 0},
			{x = 1, y = 1, z = .5, u = 1, v = .25},
			{x = 1, y = 1, z = 0, u = 1, v = .5},
			{x = 1, y = 1, z = -.5, u = 1, v = .75},
			{x = 1, y = 1, z = -1, u = 1, v = 1},

			{x = -1, y = -1, z = -1, u = 0, v = 0},
			{x = -1, y = -1, z = -.5, u = 0, v = .25},
			{x = -1, y = -1, z = 0, u = 0, v = .5},
			{x = -1, y = -1, z = .5, u = 0, v = .75},
			{x = -1, y = -1, z = 1, u = 0, v = 1},
			{x = -.5, y = -1, z = -1, u = .25, v = 0},
			{x = -.5, y = -1, z = -.5, u = .25, v = .25},
			{x = -.5, y = -1, z = 0, u = .25, v = .5},
			{x = -.5, y = -1, z = .5, u = .25, v = .75},
			{x = -.5, y = -1, z = 1, u = .25, v = 1},
			{x = 0, y = -1, z = -1, u = .5, v = 0},
			{x = 0, y = -1, z = -.5, u = .5, v = .25},
			{x = 0, y = -1, z = 0, u = .5, v = .5},
			{x = 0, y = -1, z = .5, u = .5, v = .75},
			{x = 0, y = -1, z = 1, u = .5, v = 1},
			{x = .5, y = -1, z = -1, u = .75, v = 0},
			{x = .5, y = -1, z = -.5, u = .75, v = .25},
			{x = .5, y = -1, z = 0, u = .75, v = .5},
			{x = .5, y = -1, z = .5, u = .75, v = .75},
			{x = .5, y = -1, z = 1, u = .75, v = 1},
			{x = 1, y = -1, z = -1, u = 1, v = 0},
			{x = 1, y = -1, z = -.5, u = 1, v = .25},
			{x = 1, y = -1, z = 0, u = 1, v = .5},
			{x = 1, y = -1, z = .5, u = 1, v = .75},
			{x = 1, y = -1, z = 1, u = 1, v = 1},
		},
		faces = { -- each face links 3 or more vertices. Fan mode needs an extra vertice at the beginning to fan from
			{1,2,6,2,6,7,2,3,7,3,7,8,3,4,8,4,8,9,4,5,9,5,9,10,6,7,11,7,11,12,7,8,12,8,12,13,8,9,13,9,13,14,9,10,14,10,14,15,11,12,16,12,16,17,12,13,17,13,17,18,13,14,18,14,18,19,14,15,19,15,19,20,16,17,21,17,21,22,17,18,22,18,22,23,18,19,23,19,23,24,19,20,24,20,24,25},
			{26,27,31,27,31,32,27,28,32,28,32,33,28,29,33,29,33,34,29,30,34,30,34,35,31,32,36,32,36,37,32,33,37,33,37,38,33,34,38,34,38,39,34,35,39,35,39,40,36,37,41,37,41,42,37,38,42,38,42,43,38,39,43,39,43,44,39,40,44,40,44,45,41,42,46,42,46,47,42,43,47,43,47,48,43,44,48,44,48,49,44,45,49,45,49,50},
			{51,52,56,52,56,57,52,53,57,53,57,58,53,54,58,54,58,59,54,55,59,55,59,60,56,57,61,57,61,62,57,58,62,58,62,63,58,59,63,59,63,64,59,60,64,60,64,65,61,62,66,62,66,67,62,63,67,63,67,68,63,64,68,64,68,69,64,65,69,65,69,70,66,67,71,67,71,72,67,68,72,68,72,73,68,69,73,69,73,74,69,70,74,70,74,75},
			{76,77,81,77,81,82,77,78,82,78,82,83,78,79,83,79,83,84,79,80,84,80,84,85,81,82,86,82,86,87,82,83,87,83,87,88,83,84,88,84,88,89,84,85,89,85,89,90,86,87,91,87,91,92,87,88,92,88,92,93,88,89,93,89,93,94,89,90,94,90,94,95,91,92,96,92,96,97,92,93,97,93,97,98,93,94,98,94,98,99,94,95,99,95,99,100},
			{101,102,106,102,106,107,102,103,107,103,107,108,103,104,108,104,108,109,104,105,109,105,109,110,106,107,111,107,111,112,107,108,112,108,112,113,108,109,113,109,113,114,109,110,114,110,114,115,111,112,116,112,116,117,112,113,117,113,117,118,113,114,118,114,118,119,114,115,119,115,119,120,116,117,121,117,121,122,117,118,122,118,122,123,118,119,123,119,123,124,119,120,124,120,124,125},
			{126,127,131,127,131,132,127,128,132,128,132,133,128,129,133,129,133,134,129,130,134,130,134,135,131,132,136,132,136,137,132,133,137,133,137,138,133,134,138,134,138,139,134,135,139,135,139,140,136,137,141,137,141,142,137,138,142,138,142,143,138,139,143,139,143,144,139,140,144,140,144,145,141,142,146,142,146,147,142,143,147,143,147,148,143,144,148,144,148,149,144,145,149,145,149,150},
		},
		mode = "triangles", -- tells the renderer how to iterate the defined face vertices and uvs
		fnormals = { -- each face has an x,y,z direction indicating the axis it's pointing towards
			{x = 0, y = 0, z = -1},
			{x = 1, y = 0, z = 0},
			{x = 0, y = 0, z = 1},
			{x = -1, y = 0, z = 0},
			{x = 0, y = 1, z = 0},
			{x = 0, y = -1, z = 0},
		}
	}

	return true
end

--[[
<documentation type="function">
	<name>rotate(table parameters)</name>
	<description>
		Increments the rotation x,y,z of a given object. This differs from rotation() in that the angles passed are used as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		name (required) = Name of the object to rotate.
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

	-- Rotates the cube by 10 degrees along the x axis
	q3d.rotate({ name = "myCube", x = 10 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.rotate = function(parameters)
	-- locals are faster
	local lnormalisedRotation = convenience.normalisedRotation

	local name = parameters.name
	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.objects[name].xr = lnormalisedRotation(vars.objects[name].xr + x)
	end

	if(y ~= nil) then
		vars.objects[name].yr = lnormalisedRotation(vars.objects[name].yr + y)
	end

	if(z ~= nil) then
		vars.objects[name].zr = lnormalisedRotation(vars.objects[name].zr + z)
	end

	return true
end

--[[
<documentation type="function">
	<name>rotation(table parameters)</name>
	<description>
		Sets the rotation x,y,z of a given object. This differs from rotate() in that the angles passed are used as absolute values rather than as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		name (required) = Name of the object to rotate.
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

	-- Rotates the cube to 10 degrees along the x axis
	q3d.rotation({ name = "myCube", x = 10 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.rotation = function(parameters)
	-- locals are faster
	local lnormalisedRotation = convenience.normalisedRotation

	local name = parameters.name
	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.objects[name].xr = lnormalisedRotation(x)
	end

	if(y ~= nil) then
		vars.objects[name].yr = lnormalisedRotation(y)
	end

	if(z ~= nil) then
		vars.objects[name].zr = lnormalisedRotation(z)
	end

	return true
end

--[[
<documentation type="function">
	<name>move(table parameters)</name>
	<description>
		Adjusts the position x,y,z of a given object. This differs from position() in that the co-ordinates passed are used as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		name (required) = Name of the object to move.
		x = Amount along the x axis to move by.
		y = Amount along the y axis to move by.
		z = Amount along the z axis to move by.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Moves the cube even further from the camera along the z axis
	q3d.move({ name = "myCube", z = 4 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.move = function(parameters)
	local name = parameters.name
	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.objects[name].x = vars.objects[name].x + x
	end

	if(y ~= nil) then
		vars.objects[name].y = vars.objects[name].y + y
	end

	if(z ~= nil) then
		vars.objects[name].z = vars.objects[name].z + z
	end

	return true
end

--[[
<documentation type="function">
	<name>position(table parameters)</name>
	<description>
		Sets the position x,y,z of a given object. This differs from move() in that the co-ordinates passed are used as absolute values rather than as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		name (required) = Name of the object to move.
		x = Position along the x axis to move to.
		y = Position along the y axis to move to.
		z = Position along the z axis to move to.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Positions the cube a little closer to the camera along the z axis
	q3d.position({ name = "myCube", z = 4 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.position = function(parameters)
	local name = parameters.name
	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.objects[name].x = x
	end

	if(y ~= nil) then
		vars.objects[name].y = y
	end

	if(z ~= nil) then
		vars.objects[name].z = z
	end

	return true
end

--[[
<documentation type="function">
	<name>size(table parameters)</name>
	<description>
		Sets the size x,y,z of a given object. This differs from scale() in that the values passed are used as absolute values rather than as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		name (required) = Name of the object to scale.
		x = Scale along the x axis. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size.
		y = Scale along the y axis. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size.
		z = Scale along the z axis. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Shrink the cube to half the default size.
	q3d.size({ name = "myCube", x = 0.5, y = 0.5, z = 0.5 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.size = function(parameters)
	local name = parameters.name
	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.objects[name].xs = x
	end

	if(y ~= nil) then
		vars.objects[name].ys = y
	end

	if(z ~= nil) then
		vars.objects[name].zs = z
	end

	return true
end

--[[
<documentation type="function">
	<name>scale(table parameters)</name>
	<description>
		Adjusts the size x,y,z of a given object. This differs from size() in that the values passed are used as relative adjustments.

		Parameters are passed as a table of key = value pairs. Supported parameters are:

		name (required) = Name of the object to scale.
		x = Amount along the x axis to adjust the current scale by. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size.
		y = Amount along the y axis to adjust the current scale by. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size.
		z = Amount along the z axis to adjust the current scale by. A scale of 2 would be twice the default size, and a scale of 0.5 would be half the default size.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Creates a cube and positions it slightly in front of the camera, which defaults to pointing straight down the z axis at position 0,0,0
	q3d.addCube({ name = "myCube", z = 5 })

	-- Enlarge the cube to a scale of 1.5.
	q3d.scale({ name = "myCube", x = 0.5, y = 0.5, z = 0.5 })

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.scale = function(parameters)
	local name = parameters.name
	local x = parameters.x or nil
	local y = parameters.y or nil
	local z = parameters.z or nil

	if(x ~= nil) then
		vars.objects[name].xs = vars.objects[name].xs + x
	end

	if(y ~= nil) then
		vars.objects[name].ys = vars.objects[name].ys + y
	end

	if(z ~= nil) then
		vars.objects[name].zs = vars.objects[name].zs + z
	end

	return true
end

-- Puts all of the module functions in to the main library scope
module.init = function(main)
	main.addCube = module.addCube
	main.rotate = module.rotate
	main.rotation = module.rotation
	main.move = module.move
	main.position = module.position
	main.size = module.size
	main.scale = module.scale
end

return module