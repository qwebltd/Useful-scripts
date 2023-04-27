-----------------------------------------------------------------------------------------
--
-- rendering.lua
--
-- Rendering functions.
--
--[[
<documentation type="head">
	<parent>Graphics</parent>
	<name>Rendering</name>
	<description>
		Controls the actual rendering of the 3D world.
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

-- Q3D display group for rendering onto.
local q3dcanvas = display.newGroup()

local renderlock = false

-- rotates a point relative to another point. For example if rotating around the z axis, rp1 and rp2 should be the x,y to rotate around, and p1,p2 should be the x,y of the point being rotated
module.rotatePoint = function(rp1, rp2, p1, p2, rotation)
	local lsin = math.sin
	local lcos = math.cos
	local lrad = math.rad

	local s = lsin(lrad(rotation))
	local c = lcos(lrad(rotation))

	return { p1 = rp1 + (p1 * c - p2 * s), p2 = rp2 + (p2 * c + p1 * s) }
end

module.renderFace = function(vertices, mode, x, y, z, xr, yr, zr, xs, ys, zs, brightness)
	-- locals are faster
	local ldistanceBetweenPoints = convenience.distanceBetweenPoints
	local lcamera = vars.camera
	local lcontentCenterX = display.contentCenterX
	local lcontentCenterY = display.contentCenterY
	local lassetsFolder = vars.assetsFolder
	local lScreenWidth = convenience.screen.width

	local lxEdgeLeft = convenience.screen.xEdgeLeft
	local lxEdgeRight = convenience.screen.xEdgeRight
	local lyEdgeTop = convenience.screen.yEdgeTop
	local lyEdgeBottom = convenience.screen.yEdgeBottom

	local point = nil
	local face = {}
	local uvs = {}
	local screenX = nil
	local screenY = nil
	local realx = nil
	local realy = nil
	local realz = nil

	-- We only want to waste resources rendering a polygon if at least part of it will be on screen, so use these to determine likelihood of shape being visible...
	local vertexIsBeyondScreenLeft = false
	local vertexIsBeyondScreenRight = false
	local vertexIsBeyondScreenTop = false
	local vertexIsBeyondScreenBottom = false

	-- Convert each vertex to a screen co-ord and then to triangles
	for vertexKey,vertex in pairs(vertices) do
		-- Adjust vertex position based on object x,y,z rotation
		realx = vertex.x * xs
		realy = vertex.y * ys
		realz = vertex.z * zs

		-- y
		point = module.rotatePoint(0, 0, realx, realz, yr)
		realx = point.p1
		realz = point.p2

		-- x
		point = module.rotatePoint(0, 0, realz, realy, xr)
		realz = point.p1
		realy = point.p2

		-- z
		point = module.rotatePoint(0, 0, realx, realy, zr * -1) -- multiplied by -1 because we want to reverse z rotations
		realx = point.p1
		realy = point.p2

		-- and then offset by the camera rotation

		-- y
		point = module.rotatePoint(0, 0, realx, realz, lcamera.yr)
		realx = point.p1
		realz = point.p2

		-- x
		point = module.rotatePoint(0, 0, realz, realy, lcamera.xr * -1)
		realz = point.p1
		realy = point.p2

		-- z
		point = module.rotatePoint(0, 0, realx, realy, lcamera.zr)
		realx = point.p1
		realy = point.p2

		-- now convert to screen co-ords, factoring in the camera position
		screenX = lcontentCenterX + ((x + realx) / (z + realz) * lScreenWidth)
		screenY = lcontentCenterY - ((y + realy) / (z + realz) * lScreenWidth)
		-- screenY uses minus because we want y+ to move upwards, not downwards

		if(screenX > lxEdgeLeft) then
			vertexIsBeyondScreenLeft = true
		end

		if(screenX < lxEdgeRight) then
			vertexIsBeyondScreenRight = true
		end

		if(screenY > lyEdgeTop) then
			vertexIsBeyondScreenTop = true
		end

		if(screenY < lyEdgeBottom) then
			vertexIsBeyondScreenBottom = true
		end

		table.insert(face, screenX)
		table.insert(face, screenY)

		table.insert(uvs, vertex.u)
		table.insert(uvs, vertex.v)
	end

	-- Create a polygon, but only if it's likely to be visible
	if(vertexIsBeyondScreenLeft and vertexIsBeyondScreenRight and vertexIsBeyondScreenTop and vertexIsBeyondScreenBottom) then
		local polygon = display.newMesh( { parent = q3dcanvas, mode = mode, vertices = face, uvs = uvs, x = 0, y = 0 } )

		-- Move the resulting mesh to compensate for origin offset
		polygon:translate( polygon.path:getVertexOffset() )

		polygon.fill = { type = "image", filename = lassetsFolder .. "/" .. "checker2.png" }

		polygon.fill.effect = "filter.brightness"
		polygon.fill.effect.intensity = brightness

		return true
	else
		return false
	end
end

--[[
<documentation type="function">
	<name>render()</name>
	<description>
		Renders the world as per the current camera position and orientation. Used internally by the rendering engine and not really intended for direct use but is available for convenience. If used, you'd usually want to call clearGraphics() first.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Rather than calling q3d.activate(), you could do this...
	function mainLoop()
		-- Render the map
		q3d.clearGraphics()
		q3d.render()
	end

	-- Run the main game loop
	Runtime:addEventListener('enterFrame', mainLoop)
	</example>
</documentation> --]]
module.render = function()
	-- locals are faster
	local ldrawDistance = vars.drawDistance
	local ldistanceBetweenPoints = convenience.distanceBetweenPoints
	local lobjects = vars.objects
	local lcamera = vars.camera
	local lambientBrightness = vars.ambientBrightness
	local lambientPoint = vars.ambientPoint
	local lmax = math.max

	if renderlock == false  then
		renderlock = true

		local x = nil
		local y = nil
		local z = nil
		local point = nil
		local normalx = nil
		local normaly = nil
		local normalz = nil
		local faces = {}
		local distances = {}
		local vertices = {}
		local brightness = nil
		local distanceToNormal = nil
		local distanceToObject = nil
		local renderDistance = nil

		-- Adjust the ambient light direction to compensate camera rotation. It's faster to do this here rather than within every single call to renderFace()
		local ambientx = lambientPoint.x
		local ambienty = lambientPoint.y
		local ambientz = lambientPoint.z

		-- y
		point = module.rotatePoint(0, 0, ambientx, ambientz, lcamera.yr)
		ambientx = point.p1
		ambientz = point.p2

		-- x
		point = module.rotatePoint(0, 0, ambientz, ambienty, lcamera.xr * -1)
		ambientz = point.p1
		ambienty = point.p2

		-- z
		point = module.rotatePoint(0, 0, ambientx, ambienty, lcamera.zr)
		ambientx = point.p1
		ambienty = point.p2

		-- Loop through all of the objects in the world
		for objectName,objectData in pairs(lobjects) do
			-- Offset the object x,y,z position by the camera x,y,z position
			x = objectData.x - lcamera.x
			y = objectData.y - lcamera.y
			z = objectData.z - lcamera.z

			-- Then offset by the camera x,y,z rotation...

			-- y
			point = module.rotatePoint(0, 0, x, z, lcamera.yr)
			x = point.p1
			z = point.p2

			-- x
			point = module.rotatePoint(0, 0, z, y, lcamera.xr * -1) -- we want to reverse this rotation
			z = point.p1
			y = point.p2

			-- z
			point = module.rotatePoint(0, 0, x, y, lcamera.zr)
			x = point.p1
			y = point.p2

			-- Ignore objects that are too far away as iterating absolutely everything would be too resource intensive
			distanceToObject = ldistanceBetweenPoints(0, 0, 0, x, y, z)

			if(distanceToObject <= ldrawDistance) then
				-- Loop through each face of the object
				for faceKey,faceData in pairs(objectData.faces) do
					-- Use the face normal to figure out if this particular face is pointing towards the camera before wasting any resources rendering it...
					-- Rotate the normal first, by the objects x,y,z rotation
					normalx = objectData.fnormals[faceKey].x
					normaly = objectData.fnormals[faceKey].y
					normalz = objectData.fnormals[faceKey].z

					-- y
					point = module.rotatePoint(0, 0, normalx, normalz, objectData.yr)
					normalx = point.p1
					normalz = point.p2

					-- x
					point = module.rotatePoint(0, 0, normalz, normaly, objectData.xr)
					normalz = point.p1
					normaly = point.p2

					-- z
					point = module.rotatePoint(0, 0, normalx, normaly, objectData.zr * -1)
					normalx = point.p1
					normaly = point.p2

					-- and then by the camera rotation

					-- y
					point = module.rotatePoint(0, 0, normalx, normalz, lcamera.yr)
					normalx = point.p1
					normalz = point.p2

					-- x
					point = module.rotatePoint(0, 0, normalz, normaly, lcamera.xr * -1)
					normalz = point.p1
					normaly = point.p2

					-- z
					point = module.rotatePoint(0, 0, normalx, normaly, lcamera.zr)
					normalx = point.p1
					normaly = point.p2

					-- Is this face in front of the camera?
					if(z * objectData.zs > 2) then
						-- Determine whether the face is pointing towards the camera by measuring the distance to the object and to the face normal and then comparing
						distanceToNormal = ldistanceBetweenPoints(0, 0, 0, x + (normalx * 2), y + (normaly * 2), z + (normalz * 2)) -- multiplied by 2 for better trig accuracy

						if(distanceToObject > distanceToNormal) then
							-- Collate the vertices that belong to this face
							vertices = {}

							for vertexKey,vertex in pairs(faceData) do
								table.insert(vertices, objectData.vertices[vertex])
							end

							-- The further away from each other the face normal and ambient light normal are, the more the two must be pointing towards each other, where 0 means the face and light are directly facing.
							-- Thus the amount of light reaching the face from this source would be maximum at 2 and none at 0 (because normals and light positions are set in 0-1 values
							brightness = -1 + lambientBrightness + lmax(0, (-1 - lambientBrightness) + ldistanceBetweenPoints(ambientx, ambienty, ambientz, normalx, normaly, normalz))

							-- Add everything to a faces list, ordered by distance from camera ready for back-to-front rendering
							renderDistance = math.floor(distanceToNormal * 1000000000000) * -1

							if(faces[renderDistance] == nil) then
								faces[renderDistance] = {}
								table.insert(distances, renderDistance)
							end

							table.insert(faces[renderDistance], {
								vertices = vertices,
								mode = objectData.mode,
								x = x,
								y = y,
								z = z,
								xr = objectData.xr,
								yr = objectData.yr,
								zr = objectData.zr,
								xs = objectData.xs,
								ys = objectData.ys,
								zs = objectData.zs,
								brightness = brightness
							})
							-- TODO: Colour needs replacing with proper colour/texture/lighting
						end
					end
				end
			end
		end

		-- Finally, loop through the faces list to render
		table.sort(distances)

		for distanceKey,distance in pairs(distances) do
			for faceKey,faceData in pairs(faces[distance]) do
				module.renderFace(faceData.vertices, faceData.mode, faceData.x, faceData.y, faceData.z, faceData.xr, faceData.yr, faceData.zr, faceData.xs, faceData.ys, faceData.zs, faceData.brightness)
			end
		end

		renderlock = false
	end

	return true
end

--[[
<documentation type="function">
	<name>clearGraphics()</name>
	<description>
		Clears the current render ready to redraw, or just because you no longer need the output. You'd usually want to call q3d.deactivate() and then this to clear the screen for something else, and then q3d.activate() to resume.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()

	local gamePaused = false

	-- Pause and clear, or resume on tap.
	function tapScreen(event)
		if(gamePaused) then
			q3d.activate()
			gamePaused = false
		else
			q3d.deactivate()
			q3d.clearGraphics()
			gamePaused = true
		end
	end

	Runtime:addEventListener('tap', tapScreen)
	</example>
</documentation> --]]
module.clearGraphics = function()
	if renderlock == false then
		for i = q3dcanvas.numChildren, 1, -1 do
			if q3dcanvas[i] ~= nil then
				display.remove(q3dcanvas[i])
			end
		end
	end

	return true
end

--[[
<documentation type="function">
	<name>getDrawDistance()</name>
	<description>
		Returns the current draw distance. I.e. the maximum distance away from the camera an object can be before it's excluded from rendering. Increase for better graphics, decrease for performance. The default is 50.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Output the current draw distance
	print("Current draw distance: " .. q3d.getDrawDistance())

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.getDrawDistance = function()
	return vars.drawDistance
end

--[[
<documentation type="function">
	<name>setDrawDistance(decimal distance)</name>
	<description>
		Sets the draw distance. I.e. the maximum distance away from the camera an object can be before it's excluded from rendering. Increase for better graphics, decrease for performance. The default is 50.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Increase the draw distance
	q3d.setDrawDistance(80)
	print("Current draw distance: " .. q3d.getDrawDistance())

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.setDrawDistance = function(distance)
	vars.drawDistance = distance

	return true
end

-- Puts all of the module functions in to the main library scope
module.init = function(main)
	main.clearGraphics = module.clearGraphics
	main.render = module.render
	main.getDrawDistance = module.getDrawDistance
	main.setDrawDistance = module.setDrawDistance
end

return module