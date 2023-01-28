-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local machine = import('statemachine')

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local pd <const> = playdate
local gfx <const> = playdate.graphics

local font = nil

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local diceTable
local bustDice = {}
local bustDiceSum
local bustDiceSprites = {}
local rollingDiceSprites = {}
local playerCount = 2
local whoseTurn = 1
local scores = { 0, 0 }
local turnScore = 0


local fsm = machine.create({
	initial = 'rollBust',
	
	events = {
		{ name = 'establishBust', from = 'rollBust', to = 'rollPress' },
		{ name = 'stopPressing', from = 'rollPress', to = 'awardPoints' },
		{ name = 'pointsAwarded', from = 'awardPoints', to = 'nextPlayer' },
		{ name = 'goBust', from = 'rollPress', to = 'showBust'},
		{ name = 'acceptBust', from = 'showBust', to = 'nextPlayer'},
		{ name = 'startNextTurn', from = 'nextPlayer', to = 'rollBust' },
	},
	
	callbacks = {
		onrollBust = function(self, event, from, to)
			bustDice = {}
			bustDiceSum = 0
			bustDiceSprites[1]:setVisible(true)
			bustDiceSprites[2]:setVisible(true)
		end,
		onestablishBust = function(self, event, from, to)
			
		end,
		onrollPress = function(self, event, from, to)
			rollingDiceSprites[1]:setVisible(true)
			rollingDiceSprites[2]:setVisible(true)
		end,
		onawardPoints = function(self, event, from, to)
			scores[whoseTurn] += turnScore
		end,
		onnextPlayer = function(self, event, from, to)
			turnScore = 0
			advanceTurn()
		end,
	}
})

-- A function to set up our game environment.

local turnIndicators = table.create(2, 0)

function rollDice()
	return math.random(1,6)
end

function myGameSetUp()

	diceTable = gfx.imagetable.new("images/dice")
	assert(diceTable)

	math.randomseed(pd.getSecondsSinceEpoch())

	bustDiceSprites[1] = gfx.sprite.new(diceTable:getImage(rollDice()))
	bustDiceSprites[1]:moveTo(40, 40)
	bustDiceSprites[1]:add()
	bustDiceSprites[1]:setVisible(false)

	bustDiceSprites[2] = gfx.sprite.new(diceTable:getImage(rollDice()))
	bustDiceSprites[2]:moveTo(110, 40)
	bustDiceSprites[2]:add()
	bustDiceSprites[2]:setVisible(false)
	
	rollingDiceSprites[1] = gfx.sprite.new(diceTable:getImage(rollDice()))
	rollingDiceSprites[1]:moveTo(260, 40)
	rollingDiceSprites[1]:add()
	rollingDiceSprites[1]:setVisible(false)
	

	rollingDiceSprites[2] = gfx.sprite.new(diceTable:getImage(rollDice()))
	rollingDiceSprites[2]:moveTo(330, 40)
	rollingDiceSprites[2]:add()
	rollingDiceSprites[2]:setVisible(false)

	font = gfx.font.new("font/namco-1x")
	assert(font)

	turnIndicators[1] = pd.geometry.polygon.new(10, 180, 10, 190, 16, 185)
	turnIndicators[2] = pd.geometry.polygon.new(260, 180, 260, 190, 266, 185)

	for _, turnIndicator in ipairs(turnIndicators) do
		turnIndicator:close()
	end

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

function advanceTurn()
	whoseTurn += 1
	if whoseTurn > playerCount then
		whoseTurn = 1
	end
end


-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function pd.update()

	-- Poll the d-pad and move our player accordingly.
	-- (There are multiple ways to read the d-pad; this is the simplest.)
	-- Note that it is possible for more than one of these directions
	-- to be pressed at once, if the user is pressing diagonally.

	if fsm:is('rollBust') then
		if pd.buttonJustPressed(pd.kButtonA) then
			bustDiceSum = 0
			for i, dice in ipairs(bustDiceSprites) do
				local randomDice = rollDice()
				dice:setImage(diceTable:getImage(randomDice))
			
				bustDice[i] = randomDice
				bustDiceSum += randomDice
			end
			
			turnScore = bustDiceSum
			
			fsm:establishBust()
		end
	elseif fsm:is('rollPress') then
		if pd.buttonJustPressed(pd.kButtonA) then
			local thisTurnDice = {}
			local thisTurnDiceSum = 0
		
			for i, dice in ipairs(rollingDiceSprites) do
				local randomDice = rollDice()
				dice:setImage(diceTable:getImage(randomDice))
	
				thisTurnDice[i] = randomDice
				thisTurnDiceSum += randomDice
			end
			
			if thisTurnDiceSum == bustDiceSum then
				fsm:goBust()
			else
				turnScore += thisTurnDiceSum
			end
		elseif pd.buttonJustPressed(pd.kButtonB) then
			fsm:stopPressing()
		end
	elseif fsm:is('awardPoints') then
		if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then
			fsm:pointsAwarded()
		end
	elseif fsm:is('showBust') then
		if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then
			fsm:acceptBust()
		end
	elseif fsm:is('nextPlayer') then
		if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then
			fsm:startNextTurn()
		end
	end


	-- Call the functions below in playdate.update() to draw sprites and keep
	-- timers updated. (We aren't using timers in this example, but in most
	-- average-complexity games, you will.)

	gfx.sprite.update()
	pd.timer.updateTimers()

	gfx.setFont(font)
	gfx.setFontTracking(-1)
	
	local scoreTexts = {	
	 "Score: " .. scores[1],
	 "Score: " .. scores[2]
 }
 scoreTexts[whoseTurn] = scoreTexts[whoseTurn] .. " +" .. turnScore
	
	
	gfx.drawText(scoreTexts[1], 20, 180)
	gfx.drawText(scoreTexts[2], 270, 180)

	if fsm:is('awardPoints') then
		gfx.setFont(font)
		gfx.setFontTracking(-1)
		gfx.drawText("SUCCESS!  +" .. turnScore, 240, 120)
	elseif fsm:is('nextPlayer') then
		gfx.setFont(font)
		gfx.setFontTracking(-1)
		gfx.drawText("Player " .. whoseTurn .. ", ready?", 120, 120)
	elseif fsm:is('showBust') then
		gfx.setFont(font)
		gfx.setFontTracking(-1)
		gfx.drawText("BUST!", 300, 120)
	end

	local turnIndicator = turnIndicators[whoseTurn]
	gfx.drawPolygon(turnIndicator)

end
