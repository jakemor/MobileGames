------------
-- Locals -- 
------------

local banner = {}
local banner_mt = { __index = banner }

-----------------
-- Constructor --
-----------------

function banner.new( input, inX, inY, red )
	local banner = {
		group = display.newGroup(),
	}

	local text = display.newText( input, inX, inY, system.native, 100 );

	local good = {"Nice!", "Great!", "Super!", "Awesome!", "Amazing!", "Good Job!", "Sweet!"}
	local bad = {"Nope!", "Try Again!", "Incorrect!", "Not a Word!", "Wrong!"}

	if (input == "good") then
		text.text = good[math.random(1,#good)];
	end

	if (input == "Nope!") then
		text.text = bad[math.random(1,#bad)];
	end

	if (red) then
		text:setFillColor( 1, 0, 0 );
		transition.to( text, { time=500, alpha=0, x=inX, y=inY-100, onComplete=banner.group:remove( ) } )
	else
		transition.to( text, { time=500, alpha=0, x=inX, y=inY-100, onComplete=banner.group:remove( ) } )
		text:setFillColor( 0, 1, 0 );
	end



	return setmetatable( banner, banner_mt )
end

-------------
-- Methods -- 
-------------



return banner