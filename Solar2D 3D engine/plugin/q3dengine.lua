-----------------------------------------------------------------------------------------
--
-- q3dengine.lua
--
-- Q3D Engine (pronounced ked). A 3D game engine by QWeb Ltd.
--
-- This library is intended to be a lightweight and easy to use engine for 3D game
-- development.
--
-----------------------------------------------------------------------------------------

local Library = require "CoronaLibrary"

-- Create library
local lib = Library:new{ name='plugin.q3dengine', publisherId='uk.co.qweb' }

-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------

-- Assets handling.
local assets = require ((...):match("(.-)[^%.]+$") .. "q3dengine.assets")
assets.init(lib)

-- Objects.
local objects = require ((...):match("(.-)[^%.]+$") .. "q3dengine.objects")
objects.init(lib)

-- Camera.
local camera = require ((...):match("(.-)[^%.]+$") .. "q3dengine.camera")
camera.init(lib)

-- Rendering.
local rendering = require ((...):match("(.-)[^%.]+$") .. "q3dengine.rendering")
rendering.init(lib)

-- Control.
local control = require ((...):match("(.-)[^%.]+$") .. "q3dengine.control")
control.init(lib)

-------------------------------------------------------------------------------
-- END
-------------------------------------------------------------------------------

-- Return library instance
return lib
