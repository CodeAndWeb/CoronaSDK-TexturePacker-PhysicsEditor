-- 
-- Abstract: Physicsdemo
-- Demonstrates complex body construction by generating 100 random physics objects
--
-- This demo loads physics bodies created with http://www.physicseditor.de


local physics = require("physics")
physics.start()
display.setStatusBar( display.HiddenStatusBar )

-- Load the TexturePacker generated image sheet.
local sheetInfo = require("spritesheet")
local myImageSheet = graphics.newImageSheet(
    "spritesheet.png", sheetInfo:getSheet()
)

-- add background to the center of the screen
local bkg = display.newImage( myImageSheet , sheetInfo:getFrameIndex("bkg_cor") )
bkg.x = display.contentCenterX
bkg.y = display.contentCenterY

-- create physical floor shape to the bottom of the screen
local bar = display.newImage( myImageSheet , sheetInfo:getFrameIndex("bar") )
bar.x = display.contentCenterX
bar.y = display.contentHeight - display.screenOriginY - 56
physics.addBody( bar, "static", { friction=0.5, bounce=0.3 } )

-- create floor shape only for the looks
local bar2 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("bar2") )
bar2.x = display.contentCenterX
bar2.y = display.contentHeight - display.screenOriginY
bar2.anchorY = 1

-- load the physics data, scale factor is set to 1.0
local physicsData = require("shapedefs").physicsData(1.0)

-- physics.setDrawMode( "hybrid" )

local function newItem()
	names = {"orange", "drink", "hamburger", "hotdog", "icecream", "icecream2", "icecream3"}

	name = names[math.random(#names)]

	-- set the graphics
	obj = display.newImage( myImageSheet , sheetInfo:getFrameIndex(name) )

	-- set the shape
	physics.addBody( obj, physicsData:get(name))

	-- random start location
	obj.x = math.random( 60, display.contentWidth-60 )
	obj.y = display.screenOriginY-100
end

timer.performWithDelay( 500, newItem, 100 )