-----------------------------------------------------------------------------------------
--
-- control.lua
--
-- Main control functions.
--
--[[
<documentation type="head">
	<parent>Main</parent>
	<name>Control</name>
	<description>
		Main controller functions, to activate/deactivate Q3D.
	</description>
</documentation>
--]]
-----------------------------------------------------------------------------------------

-- Various functions for convenience.
local convenience = require ((...):match("(.-)[^%.]+$") .. "convenience")

-- Global variables
local vars = require ((...):match("(.-)[^%.]+$") .. "globals")

-- Rendering
local rendering = require ((...):match("(.-)[^%.]+$") .. "rendering")

-- Local variables
local module = {}

--[[
<documentation type="function">
	<name>activate()</name>
	<description>
		Activates the main Q3D loop. This is basically the same as creating your own game loop and manually invoking clearGraphics() and render(). You should call this when ready for the world to render, and call deactivate() when you want to pause Q3D and render something else, like a menu screen.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Enable the main Qiso loop to render/update our world
	q3d.activate()
	</example>
</documentation> --]]
module.activate = function()
	vars.active = true
end

--[[
<documentation type="function">
	<name>deactivate()</name>
	<description>
		Deactivates the main Q3D loop. Call this any time after activate() when you want to pause Q3D and render something else, like a menu screen. Then call activate() again to resume Q3D rendering.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")

	-- Enable the main Q3D loop to render/update our world
	q3d.activate()

	local gamePaused = false

	-- Pause or resume on tap.
	function tapScreen(event)
		if(gamePaused) then
			q3d.activate()
			gamePaused = false
		else
			q3d.deactivate()
			gamePaused = true
		end
	end

	Runtime:addEventListener('tap', tapScreen)
	</example>
</documentation> --]]
module.deactivate = function()
	vars.active = false
end

-- Main Qiso loop
module.mainLoop = function()
	-- This way we can basically turn Q3D rendering on/off with the above function calls, allowing developers to render other screens outside of Q3D and then resume once those screens are done.
	if(vars.active) then
		-- Render the map
		rendering.clearGraphics()
		rendering.render()
	end
end

-- Puts all of the module functions in to the main library scope
module.init = function(main)
	main.activate = module.activate
	main.deactivate = module.deactivate
end

-- Run the main game loop
Runtime:addEventListener('enterFrame', module.mainLoop)

return module