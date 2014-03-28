------------
-- Locals -- 
------------
local events = require( "events" )
local nextSquare = {}
local nextSquare_mt = { __index = nextSquare }
local W = display.contentWidth
local H = display.contentHeight

local function toColor( box, id )
	if (id == 1) then
		box:setFillColor( 1, .2, .2 )
	elseif (id == 2) then 
		box:setFillColor( .2, .2, 1 )
	elseif (id == 3) then 
		box:setFillColor( .2, 1, .2 )
	elseif (id == 4) then 
		box:setFillColor( .7, .2, .5 )
	elseif (id == 5) then 
		box:setFillColor( 1, .7, .2 )
	elseif (id == 0) then 
		box:setFillColor( .915, .915, .915 )
	end
end

-----------------
-- Constructor --
-----------------

function nextSquare.new( c,x,y,w,h )
	local nextSquare = {
		image = display.newRect( x, y, w, h ),
		col = c, 
	}

	toColor(nextSquare.image, 0)

	return setmetatable( nextSquare, nextSquare_mt )
end

-------------
-- Methods -- 
-------------
function nextSquare:toColor( input )
	toColor(self.image, input or _colors[self.col])
end


return nextSquare