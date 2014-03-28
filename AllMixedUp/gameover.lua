-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

W = display.viewableContentWidth;
H = display.viewableContentHeight;

storyboard.removeAll()

-- include Corona's "widget" library

--------------------------------------------

-- forward declarations and other locals
-- 'onRelease' event listener for playBtn

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )

	-- put high score and last score into a table
	local score = {}

	local path1 = system.pathForFile( "hs.txt", system.ResourceDirectory )
	local path2 = system.pathForFile( "oldScore.txt", system.ResourceDirectory )
	local path3 = system.pathForFile( "oldHS.txt", system.ResourceDirectory )


	local hsFile = io.open( path1, "r" )
	local osFile = io.open( path2, "r")
	local ohsFile = io.open( path3, "r" )

	score.hs = hsFile:read("*n")
	score.os = osFile:read("*n")
	score.ohs = ohsFile:read("*n")

	print( "you just scored: " .. score.os )
	print( "your hs is: " .. score.hs )

	io.close( hsFile )
	io.close( osFile )
	io.close( ohsFile )

	hsFile = nil
	osFile = nil
	ohsFile = nil

	path1 = nil
	path2 = nil
	path3 = nil

	local newHS = false

	if (score.hs > score.ohs) then
		newHS = true
	end

	--

	local group = self.view

	-- display a background image
	local background = display.newImageRect( "Images/bg.jpg", display.contentWidth, display.contentHeight )
		background.anchorX = 0
		background.anchorY = 0
		background.x, background.y = 0, 0
		background.alpha = .25
	
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newText( "Time's Up!", W/2, H/20*2,system.native, 42 )

	-- display Score and HS
	local scoreText = display.newText( "Score: " .. score.os, W/2, H/20*5,system.native, 42 )

	local hsText = display.newText( "Best: " .. score.hs, W/2, H/20*7,system.native, 42 )

	if (newHS) then
		titleLogo.text = "New High Score!"
		scoreText.text = "Old Best: " .. score.ohs
		hsText.text = "New Best: " .. score.hs
	end


	-- create a widget button (which will loads level1.lua on release)
	local playBtn = display.newRect( W/2, H/20*18, 200, 70 )

	local playBtnText = display.newText( "PLAY AGAIN" ,W/2, H/20*18,system.native,30 )
		playBtnText:setFillColor( 1, 0, 0 )

	function playBtn:touch(e)
		if (e.phase == "began") then
			storyboard.gotoScene( "gameplay", "fromTop", 500 )
		end
	end

	playBtn:addEventListener( "touch", playBtn )


	
	-- all display objects must be inserted into group
	group:insert( scoreText )
	group:insert( hsText )
	group:insert( background )
	group:insert( titleLogo )
	group:insert( playBtn )
	group:insert(playBtnText)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene