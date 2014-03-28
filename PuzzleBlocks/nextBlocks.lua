------------
-- Locals -- 
------------
local nextSquare = require( "nextSquare" )
local nextBlocks = {}
local nextBlocks_mt = { __index = nextBlocks }
local W = display.contentWidth
local H = display.contentHeight
-----------------
-- Constructor --
-----------------

function nextBlocks.new(  )
	local nextBlocks = {}

	local nextBlocks = {}
	
	local x = W/2
	local y = H-130
	local spacing = 48
	local size = 44
	for j=1, 5 do
		nextBlocks[j] = nextSquare.new(j, x - (2*spacing) + spacing*(j-1), y, size, size)
	end
	return setmetatable( nextBlocks, nextBlocks_mt )
end

-------------
-- Methods -- 
-------------

function nextBlocks:toColor( )
	for i=1,_waveNumber do
		self[i]:toColor()
	end
	for i=_waveNumber+1,5 do
		self[i]:toColor(0)
	end
end

function nextBlocks:remove(  )
	for i=1,5 do
		self[i]:remove()
	end
end

return nextBlocks