-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local banner = require( "banner" )
local scene = storyboard.newScene()

storyboard.removeAll( )
-- include Corona's "physics" library

--------------------------------------------

-- forward declarations and other locals

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	---------------------
	-- LOAD HIGH SCORE --
	---------------------

	local ptext = display.newText("Game Paused", W/2, H/3, system.native, 60)

	ptext.alpha = 0; 
	
	local paused = 0

	local path = system.pathForFile( "hs.txt", system.ResourceDirectory )

	local hsFile = io.open( path, "r" )
	
	local lastHS = hsFile:read( "*n" )

	io.close( hsFile )

	path = system.pathForFile( "oldHS.txt", system.ResourceDirectory )

	hsFile = io.open(path, "w")
	hsFile:write( lastHS )
	io.close( hsFile )

	print( "old hs: " .. lastHS )

	hsFile = nil

	path = system.pathForFile( "oldScore.txt", system.ResourceDirectory )

	local file = io.open( path, "w" )
	
	file:write( 0 )

	io.close( file )

	file = nil

	path = nil


	local function saveScore( a )
		
		local path = system.pathForFile( "oldScore.txt", system.ResourceDirectory )

		local file = io.open( path, "w" )
		
		file:write( a )

		io.close( file )

		print( "score is: " .. a )
	
	end

	local function newHS( a )
		if (a > lastHS) then
			local path = system.pathForFile( "hs.txt", system.ResourceDirectory )
			local file = io.open( path, "w" )
			file:write((a))
			io.close(file)
		end
	end
	---------------------

	local levelTime = 60

	local group = self.view

	local gameOver = false

	local selWord = {}

	local wrongPenalty = 10

	local skipPenalty = 120

	W = display.viewableContentWidth;
	H = display.viewableContentHeight;
	midx = W/2;
	midy = H/2;

	local wasWrong = false

	local lettersPushed = 0; 

	local spots = {}

	local function loadWords ()
		
		local words = {}	
		
		local path = system.pathForFile( "words.txt", system.ResourceDirectory )
		
		for line in io.lines(path) do 

			words[#words + 1] = line

		end

		return words

	end

	local wordBank = loadWords()

	local timeLeft

	--------------------
	-- BUTTON CLASSES --
	--------------------

	local function printArray (a)

		local contents = "[" 

		for i = 1, #a do 
			contents = contents .. a[i] .. ", "
		end

		contents = contents .. "]"

		print( contents )

	end

	local Letter = {}

	local lastPushed = {}


	local function nextAvailable()
		for i=1, 4 do
			if (spotsTaken[i] == 0) then
				return i
			end
		end
	end

	local resetButton = display.newRect( W/2, H/10*9, 100, 60 )
		
		resetButton:setFillColor( 1, 1, 1 )


	local gameOverText = display.newText("", W/2, H/4, system.native, 60)


	Letter.new = function ( c, n, x, y )
		
		local img = display.newGroup( )

		local bg = display.newRect( 0, 0, 100, 100 )

		local txt = display.newText(string.upper(c), 0, 0, system.native, 45)
			
			txt:setFillColor( 0, 0, 0 )

		img:insert( bg )
		img:insert( txt )



		img.x = x
		img.y = y

		local letter = {
			image = img,
			number = n,
			val = txt,

		}

		local selected = false

		local lastX = 0

		function img:touch (e)
				if (e.phase == "began") then
					if (paused == 0) then
						display.getCurrentStage( ):setFocus( self )
						self.hasFocus = true
					end
				elseif (self.hasFocus) then
					
					if (e.phase == "ended") then

						if (paused == 0) then
							-- keyboard click
							local sound = audio.loadSound("Sounds/keyboard.mp3")
							audio.play( sound )
						
							if (wasWrong and self.y == H/20*15) then
								selected = false
							end

							if (selected == false) then
								lastX = self.x
								self.x = W/5 + W/5*lettersPushed
								self.y = H/20*15 - 120
								lettersPushed = lettersPushed + 1
								selected = true
								lastPushed[#lastPushed + 1] = n
								selWord[#selWord + 1] = c
							elseif (n == lastPushed[#lastPushed]) then 
								self.x = lastX
								self.y = H/20*15
								lettersPushed = lettersPushed - 1
								table.remove( lastPushed, #lastPushed )
								table.remove( selWord, #selWord )
								selected = false
							end

							display.getCurrentStage( ):setFocus( nil )
							self.hasFocus = false

						end
					end

					if (#selWord == 4) then

						wasWrong = false

						local function listener ()
							resetButton:dispatchEvent( {name = "correct"} )
						end

					--	if (timeLeft > 1) then
							timer.performWithDelay( 500, listener, 1 )
					--	end
						
					
					end
					
				end
		end

		img:addEventListener( "touch", img )

		function img:remove( e )
			self:removeSelf( )
		end

		img:addEventListener( "remove", img )

		function txt:paused( e )
			print( "test" )
			if (paused == 0) then
				self.text = string.upper( c )
			else
				self.text = ""
			end
		end

		txt:addEventListener( "paused", txt )

		return letter; 

	end



	local function randomOrder ()

		local numbers = {1, 2, 3, 4}

		local randOrder = {}
		while (#randOrder < 4) do
			
			local flagged = false
			
			local rand = math.random(1,#numbers)
			
			for j = 1, #randOrder do
				if (randOrder[j] == rand) then
					flagged = true
				end
			end

			if (flagged == false) then
				randOrder[#randOrder+1] = rand
			end
		end

		if (randOrder[1] == 1 and
			randOrder[2] == 2 and 
			randOrder[3] == 3 and 
			randOrder[4] == 4) then
			randOrder = randomOrder ()
		end
		
		return randOrder
	end

	local function nextLevel ()

		local rand = math.random(1,#wordBank)

		local answer = table.remove( wordBank, rand )

		local orderArray = randomOrder()

		local question = ""

		local letters = {}

		for i = 1, 4 do 

			question = question .. string.sub(answer,orderArray[i],orderArray[i])
			letters[i] = string.sub(answer,orderArray[i],orderArray[i])

		end

		local levelTable = {

			word = answer,
			question = question,
			order = orderArray,
			letters = letters

		}

		return levelTable; 

	end

	local function printLevel( a )
		print( "word: " .. a.word )
		print( "mixed up word: " .. a.question )
		printArray ( a.order )
		printArray ( a.letters )
	end

	local function checkWord (input)
		
		local words = {}
		
		local path = system.pathForFile( "dictionary.txt", system.ResourceDirectory )
		
		for line in io.lines(path) do

			words[#words + 1] = line

		end

		for i=1,#words do
			if (input == words[i]) then
				return true
			end
		end
		return false

	end

	local function toWord( input )
		
		local output = ""	

		for i=1, #input do
		 	output = output .. input[i]
		end 

		return output

	end

	----------
	-- MAIN --
	----------

	local score = 0; 

	local bg = display.newImage( "Images/bg.jpg"); 

		bg.x = midx; 
		bg.y = midy;
		bg.width = W
		bg.height = H
		print( W .. " x " .. H)
		bg.alpha = .25


	local scoreTxt = display.newText( {

		text = "answer",
		x = 198,
		y = 150,
		width = 300,
		font = system.native,
		fontSize = 40, 
		align = "left"

	} )



	local timerTxt = display.newText( {

		text = "1:00",
		x = W-200,
		y = 150,
		width = 300,
		font = system.native,
		fontSize = 40, 
		align = "right"

	})


	-----------
	-- TIMER -- 
	-----------


	local function subTime( e )
		
		if (paused == 0) then
			
			if (timeLeft > 1) then
				timeLeft = timeLeft - 1
			elseif (timeLeft == 1) then 
				resetButton:dispatchEvent( {name = "timesUp"} )
			end

			if(timeLeft >= 10) then
				timerTxt.text = "0:"..timeLeft
			else
				timerTxt.text = "0:0"..timeLeft
			end
		else
		end
			
	end

	-- 

	timeLeft = levelTime

	local gameTime = timer.performWithDelay( 1000, subTime, -1 )

	local level = nextLevel()

	local resetTxt = display.newText( "SKIP", W/2, H/10*9, system.native, 30 )

		resetTxt:setFillColor(1, 0, 0)


	-------------
	-- BUTTONS --
	-------------

	-- Reset Button -- 

	local counter = 0

	local letter1 = Letter.new(level.letters[1], 1, W/5, H/20*15)
	local letter2 = Letter.new(level.letters[2], 2, W/5*2, H/20*15)
	local letter3 = Letter.new(level.letters[3], 3, W/5*3, H/20*15)
	local letter4 = Letter.new(level.letters[4], 4, W/5*4, H/20*15)

	local pauseGroup = display.newGroup(); 

	local pauseButton = display.newRect( 0, 0, 60, 60 )


	local pauseText = display.newText("P", 0,0,system.native, 30)

	pauseText:setFillColor(0, 0, 0)

	
	pauseGroup:insert( pauseButton )
	pauseGroup:insert( pauseText )

	pauseGroup.x = W-80
	pauseGroup.y = 50

	function pauseButton:touch( e )
		if (e.phase == "began") then
			paused = (paused + 1)%2
			ptext.alpha = paused; 
			letter1.val:dispatchEvent( {name = "paused"} )
			letter2.val:dispatchEvent( {name = "paused"} )
			letter3.val:dispatchEvent( {name = "paused"} )
			letter4.val:dispatchEvent( {name = "paused"} )

			print( paused )
	
		end



	end

	pauseButton:addEventListener( "touch", pauseButton )

	
	print( level.word )


	scoreTxt.text = score

	function resetButton:touch (e)
		
		if (e.phase == "began" and paused == 0) then
			if (gameOver == false) then 
				local banner = banner.new("-".. skipPenalty , W/2,H/2,1)
				local function newBan(  )
					local banner = banner.new("Skip!", W/2,H/2 - 50,1)
				end

				local timer = timer.performWithDelay( 500, newBan , 1 )
				local sound = audio.loadSound("Sounds/skip.mp3")
				audio.play( sound )
				
				if ((score - skipPenalty) >= 0) then
					score = score - skipPenalty
					scoreTxt.text = score
				else
					score = 0
					scoreTxt.text = score
				end

				level = nextLevel()

				while (checkWord(level.question)) do 
					printLevel(level)
					level = nextLevel()
				end

				scoreTxt.text = score

				letter1.image:dispatchEvent( {name = "remove"} )
				letter2.image:dispatchEvent( {name = "remove"} )
				letter3.image:dispatchEvent( {name = "remove"} )
				letter4.image:dispatchEvent( {name = "remove"} )

				lettersPushed = 0; 

				letter1 = Letter.new(level.letters[1], 1, W/5, H/20*15)
				letter2 = Letter.new(level.letters[2], 2, W/5*2, H/20*15)
				letter3 = Letter.new(level.letters[3], 3, W/5*3, H/20*15)
				letter4 = Letter.new(level.letters[4], 4, W/5*4, H/20*15)
				
				lastPushed = {}
				selWord = {}
			else
				---------------------
				-- NEW GAME BUTTON -- 
				---------------------

				print( "new game" )
				
			end
		end
	end

	resetButton:addEventListener( "touch", resetButton )

	function resetButton:correct( e )

		if (checkWord(toWord(selWord))) then
			local banner = banner.new("+100", W/2,H/2)
			local sound = audio.loadSound("Sounds/correct.mp3")
			audio.play( sound )
			level = nextLevel()
			local function newBan(  )
				local banner = banner.new("good", W/2,H/2 - 50)
			end

			local timer = timer.performWithDelay( 500, newBan , 1 )

			while (checkWord(level.question)) do 
				printLevel(level)
				level = nextLevel()
			end

			score = score + 100

			scoreTxt.text = score

			newHS(score)
			saveScore(score)

			print( level.word )

			letter1.image:dispatchEvent( {name = "remove"} )
			letter2.image:dispatchEvent( {name = "remove"} )
			letter3.image:dispatchEvent( {name = "remove"} )
			letter4.image:dispatchEvent( {name = "remove"} )

			lettersPushed = 0; 

			letter1 = Letter.new(level.letters[1], 1, W/5, H/20*15)
			letter2 = Letter.new(level.letters[2], 2, W/5*2, H/20*15)
			letter3 = Letter.new(level.letters[3], 3, W/5*3, H/20*15)
			letter4 = Letter.new(level.letters[4], 4, W/5*4, H/20*15)
			
			lastPushed = {}
			selWord = {}
		
		else
			local banner = banner.new("-10", W/2,H/2,1)
			local function newBan(  )
				local banner = banner.new("Nope!", W/2,H/2 - 50,1)
			end

			local timer = timer.performWithDelay( 500, newBan , 1 )
			local sound = audio.loadSound("Sounds/wrong.mp3")
			audio.play( sound )

			if ((score - wrongPenalty ) >= 0) then
				score = score - wrongPenalty
				scoreTxt.text = score
			else
				score = 0
				scoreTxt.text = score
			end
			
			wasWrong = true

			letter1.image.x = W/5
			letter2.image.x = W/5*2
			letter3.image.x = W/5*3
			letter4.image.x = W/5*4

			letter1.image.y = H/20*15
			letter2.image.y = H/20*15
			letter3.image.y = H/20*15
			letter4.image.y = H/20*15

			lettersPushed = 0;
			lastPushed = {}
			selWord = {}

		end
	end

	resetButton:addEventListener( "correct", resetButton )

	local exitGroup = display.newGroup();

	exitButton = display.newRect( 0, 0, 60, 60 )

	

	local exitText = display.newText("M", 0,0,system.native, 30)

	exitText:setFillColor(0, 0, 0)

	
	exitGroup:insert( exitButton )
	exitGroup:insert( exitText )

	exitGroup.x = 80
	exitGroup.y = 50

	local function leaving(  )
		group:insert(letter1.image)
		group:insert(letter2.image)
		group:insert(letter3.image)
		group:insert(letter4.image)
		group:insert(bg)
		group:insert(resetButton)
		group:insert(resetTxt)
		group:insert(scoreTxt)
		group:insert(gameOverText)
		group:insert(timerTxt)
		group:insert( ptext )
		group:insert(pauseButton)
		group:insert(pauseText)
		group:insert(exitText)
	--	group:insert(exitButton)
		letter1.image:dispatchEvent( {name = "remove"} )
		letter2.image:dispatchEvent( {name = "remove"} )
		letter3.image:dispatchEvent( {name = "remove"} )
		letter4.image:dispatchEvent( {name = "remove"} )
		timer.pause( gameTime )	end
	
	function exitButton:touch( e )
		if (e.phase == "began" and paused == 0) then

			leaving()

			storyboard.gotoScene( "menu", "fromLeft", 300)
			exitButton:removeSelf()
		end



	end

	exitButton:addEventListener( "touch", exitButton )
	
	function resetButton:timesUp (e)
		local sound = audio.loadSound("Sounds/lose.mp3")
		audio.play( sound )
		exitButton:removeSelf()

		leaving()

		storyboard.gotoScene( "gameover", "fromBottom", 300)

	end

	resetButton:addEventListener( "timesUp", resetButton )

	 
	--	
		-- all display objects must be inserted into group
	--	group:insert( background )
	--	group:insert( grass)
	--	group:insert( crate )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	local group = self.view
		
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

		print( "exit scene" )
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	

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