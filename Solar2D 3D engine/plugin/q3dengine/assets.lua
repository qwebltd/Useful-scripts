-----------------------------------------------------------------------------------------
--
-- assets.lua
--
-- Assets handling functions.
--
--[[
<documentation type="head">
	<parent>Data</parent>
	<name>Assets</name>
	<description>
		Q3D needs to know where your assets are, such as 3D models and texture files. Place all of your assets in a particular folder within your project structure, and tell Q3D where to find it.
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
	<name>getAssetsFolder()</name>
	<description>
		Returns the address of the current assets folder.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")
	print("Assets folder: " .. q3d.getAssetsFolder())
	</example>
</documentation> --]]
module.getAssetsFolder = function()
	return vars.assetsFolder
end

--[[
<documentation type="function">
	<name>setAssetsFolder(string path)</name>
	<description>
		Sets the folder where all of your assets should reside, so that Q3D knows where to load them in from.
	</description>
	<example>
	local q3d = require "plugin.q3dengine"
	q3d.setAssetsFolder("assets")
	</example>
</documentation> --]]
module.setAssetsFolder = function(folder)
	vars.assetsFolder = folder

	return true
end

-- Puts all of the module functions in to the main library scope
module.init = function(main)
	main.getAssetsFolder = module.getAssetsFolder
	main.setAssetsFolder = module.setAssetsFolder
end

return module