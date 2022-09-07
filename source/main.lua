-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local pd <const> = playdate
local gfx <const> = playdate.graphics

local font = nil

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local diceTable = nil
local rollingDice = {}
local playerCount = 2
local whoseTurn = 1
local scores = {0, 0}

-- A function to set up our game environment.

local turnIndicators = {
}


function myGameSetUp()

	diceTable = gfx.imagetable.new("images/dice")
	assert( diceTable)

	math.randomseed(pd.getSecondsSinceEpoch())


	local randomDice = math.random(1, 6)
	rollingDice[1] = gfx.sprite.new ( diceTable:getImage(randomDice) )
	rollingDice[1]:moveTo(80, 80)
	rollingDice[1]:add()

	randomDice = math.random(1, 6)
	rollingDice[2] = gfx.sprite.new ( diceTable:getImage(randomDice) )
	rollingDice[2]:moveTo(240, 80)
	rollingDice[2]:add()

	font = gfx.font.new("font/namco-1x")
	assert(font)

turnIndicators[1] =  pd.geometry.polygon.new(10, 180, 10, 190, 16, 185)
turnIndicators[2] = 	pd.geometry.polygon.new(260, 180, 260, 190, 266, 185)

	for _, turnIndicator in ipairs(turnIndicators) do
		turnIndicator:close()
	end

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function pd.update()

	-- Poll the d-pad and move our player accordingly.
	-- (There are multiple ways to read the d-pad; this is the simplest.)
	-- Note that it is possible for more than one of these directions
	-- to be pressed at once, if the user is pressing diagonally.

	if playdate.buttonJustPressed( pd.kButtonA ) then
		for _, dice in ipairs(rollingDice) do
			local randomDice = math.random(1, 6)
			dice:setImage(diceTable:getImage(randomDice))

			scores[whoseTurn] += randomDice
		end
	end

	if pd.buttonJustPressed(pd.kButtonB) then
		whoseTurn += 1
		if whoseTurn > playerCount then
			whoseTurn = 1
		end
	end


	-- Call the functions below in playdate.update() to draw sprites and keep
	-- timers updated. (We aren't using timers in this example, but in most
	-- average-complexity games, you will.)

	gfx.sprite.update()
	pd.timer.updateTimers()

	gfx.setFont(font)
	gfx.setFontTracking(-1)
	gfx.drawText("Score: " .. scores[1], 20, 180)
	gfx.drawText("Score: " .. scores[2], 270, 180)

	local turnIndicator = turnIndicators[whoseTurn]
		gfx.drawPolygon(turnIndicator)

end
