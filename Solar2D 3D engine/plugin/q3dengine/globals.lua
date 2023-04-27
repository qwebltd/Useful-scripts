-----------------------------------------------------------------------------------------
--
-- globals.lua
--
-- Create global variables here, as locals. This way they remain private to the plugin.
--
-----------------------------------------------------------------------------------------

-- Local variables
local module = {}

module.active = false
module.assetsFolder = ''

-- Camera
module.camera = {
	x = 0,
	y = 0,
	z = 0,
	xr = 0,
	yr = 0,
	zr = 0
}

-- Objects
module.objects = {}

-- Rendering
module.drawDistance = 50

-- Lighting
module.ambientBrightness = 0.5
module.ambientPoint = {x = 1, y = -.75, z = 0}

return module