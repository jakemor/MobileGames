-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require "storyboard"
local bg = display.newRect( 300, 512, 600, 1024 )
bg:setFillColor( 1,1,1 )
-- load scenetemplate.lua
storyboard.gotoScene( "game" )

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc.):