--SpriteGrabber Version 1.2  December 12, 2010
--Written by Magenda 
 
--Get support / leave your feedback here: 
-- http://developer.anscamobile.com/forum/2010/10/29/spritegrabber-class-spritesheets-2-lines
 
 
--[[
 
SPRITEGRABBER
--------------------------------------------------------------------------- 
 
CONTENTS: 
Features
Documentation
Usage Examples
Module Code
 
 
FEATURES:
--------------------------------------------------------------------------- 
 
*Mix sprites of different characters, different movements and/or various stationary images in a single SpriteSheet and call them by common image-name prefix (e.g. "hero-", "background", "enemy3attack").
 
*Obtain access to a SpriteSheet's images by image-name, in 1 line. -e.g. sprites=SpriteGrabber.grabSheet("myspritesheet")
 
*Rapidly grab and display sprites, by name, in 1 line of code - e.g. hero=sprites.grabSprite("hero", true)
 
*Conveniently register a sprite's animation clips - e.g. enemy=sprites.grabSprite("enemy", true, {stand={1,6,1000,0}, attack={7,6,1000,1}})
 
*Play a named clip without preparing it - e.g. enemy:playClip("attack")
 
*Normally use all spriteInstance SDK-supported functions - e.g. enemy:pause()/play()
 
*Start/Stop rendering or transform a given sprite in 1 line of code - e.g. enemy:hide()  , enemy:show()  ,  enemy:show(100,100,0.5,"c")
 
 
 
DOCUMENTATION:
--------------------------------------------------------------------------- 
 
(* = optional argument)
 
function grabSheet(sheetName, *sheetExtension)
Example: 
local grabber = require("SpriteGrabber")
local umaSheet=grabber.grabSheet("uma")
--sheetName is the spritesheetname.png without the extension
--extension is optional string with default=".png"
 
function sprites:grabSprite(framesPreffix, *showBoolean, *clipsTable)
Example1:
local horse=umaSheet:grabSprite("",true,{run={1,8,1000,0}})
--This example loads "uma" sprite from the HorseAnimation GE sample project. Images here are numbers (01,02,03...) so placing a blank framesPreffix does the trick to collect all these frames as a single sprite.
--showBoolean determines if the sprite will be shown, centered, on screen or will initially wait hidden (not being rendered).
--clipsTable syntax: { clipName={startFrame, clipTotalFrames, durationMilliseconds, loopCount}  For loopCount details see:http://developer.anscamobile.com/reference/index/spriteadd
Example2:
local apple=myFruits:grabSprite("apple", true)
 
function sprite:playClip(clip)
Example: horse:playClip("run")
--clip is one of the records you have declared in grabSprite's clipsTable
 
function sprite:show(*x,*y,*scale,*referencePoint)
Example1: enemy:show()
Example2: enemy:show(100,100,0.7,"tl")
--x,y are the positions on screen (default=center of viewableContent)
--scale is the scaling factor -same for both x,y (default=1)
--referencePoint is a first-letters shortname of the SDK setReferencePoint() valid names  (default="c" which stands for CenterReferencePoint)  Note: currently there must be a SDK bug involving SpriteSheets+referencePoints ...stay tuned.
 
function sprite:hide()
Example: enemy:hide()
--places the sprite far away from viewable screen and sets isVisible=false
 
 
function sheet:remove()
Example: umaSheet:remove()
--removes all sprites from screen and memory -call this when you don't need the sprites any more.
 
 
 
USAGE EXAMPLES:
--------------------------------------------------------------------------- 
 
Let's say we have a folder in a project, with the following images inside:
 
****
building.png
hero-breath01, hero-breath02... hero-breath08   
hero-jump01, hero-jump02 ... hero-jump08
01.jpg, 02.jpg ... 16.jpg (this could be an intro lighting background, for example)
 
and a second folder with these images:
background1.png, background2.png
bird1.png, bird2.png ... bird16.png (in first 8 frames the bird flies, in 9-16 it falls down wounded)
****
 
So, we use TexturePacker (or Zwoptex) to produce 2 spritesheets: mainSprites.png + mainSprites.lua  ..and helperSprites.png + helperSprites.lua
 
Now, you would normally have a lot of work to manipulate all these stuff. 
With SpriteGrabber you can do (in your main.lua):
 
 
local grabber = require("SpriteGrabber")
 
--grab the two sprite collections
local mainSprites=grabber.grabSheet("mainSprites")
local helperSprites=grabber.grabSheet("helperSprites")
 
--place the background1 first, centered on screen, and show it instantly
local bg=mainSprites:grabSprite("background1",true)
 
--place the building now, at specific position and scale, with refpoint=bottom-right
local house=helperSprites:grabSprite("building", true)
house:show(300,320,1.5,"br")
 
--play the intro lighting once
local intro=mainSprites:grabSprite("",true,{lighting={1,16,3000,1}})
intro:playClip("lighting")
 
--show our hero standing at center of screen and breathing in loop
 
local hero=mainSprites:grabSprite("hero",true,{ breath={1,8,1000,0}, jump={9,8,700,1}})
hero:playClip("breath")
--Note: all image names are parsed in alphabetic order, so breath frames=1-8 and jump frames=9-16
 
--prepare the bird animation clips but don't show it yet
local bird=helperSprites:grabSprite("bird",false, { fly={1,8,1000,0}, die={9,8,1000,1} })
 
--later, according to some user interaction  
bird:show(200,300)
hero:playClip("jump")
 
--the user taps on game pause, so in our handler this is triggered:
hero:pause()
--and on resume:
hero:play()
 
--while resuming the jump animation the hero kills the bird 
bird:playClip("die")
 
--the user taps on menu (or changes scenery)
mainSprites:remove()
helperSprites:remove()
 
--]]
 
 
 
--MODULE CODE
--------------------------------------------------------------------------- 
 
module(..., package.seeall)
require("sprite")
 
--Images with odd number in width,height dimensions sometimes get blurry when visualized on screen
--Set this boolean to true if you want SpriteGrabber to correct image dimensions to even numbers, on the fly, and deliver CRISP SPRITES! 
--If you want this feature enabled, PAY ATTENTION to use a PADDING of 1-2 pixels in your spritesheet tool (TexturePacker, Zwoptex etc)
local increaseOddPixels=false
 
function grabSheet(sheetName, sheetExtension)           
        local sheetExtension=sheetExtension or ".png"
        local iSheet={}
        local sData=require(sheetName).getSpriteSheetData()
        local fTags={}
        local sTags={}
        local fullTag
        local shortTag
                local frameDimensions={}
        --iterate sheetName.lua data file and collect the image names (and dimensions)
                local w,h=0,0 --temp width, height for dimensions correction
        for i,v in ipairs(sData.frames) do
                fullTag=sData.frames[i].name
                fTags[i]=fullTag
                shortTag=string.sub(fullTag,1,-5)
                sTags[shortTag]=i  
                                if increaseOddPixels==true then
                                        w=sData.frames[i].spriteSourceSize.width
                                        h=sData.frames[i].spriteSourceSize.height
                                        if (w)%2 == 1 then
                                                sData.frames[i].textureRect.width=sData.frames[i].textureRect.width+1
                                                sData.frames[i].spriteColorRect.width=sData.frames[i].spriteColorRect.width+1
                                                sData.frames[i].spriteSourceSize.width=sData.frames[i].spriteSourceSize.width+1
                                        end 
                                        if (h)%2 == 1 then
                                                sData.frames[i].textureRect.height=sData.frames[i].textureRect.height+1
                                                sData.frames[i].spriteColorRect.height=sData.frames[i].spriteColorRect.height+1
                                                sData.frames[i].spriteSourceSize.height=sData.frames[i].spriteSourceSize.height+1
                                        end
                                end
                        frameDimensions[fullTag]={sData.frames[i].textureRect.width,sData.frames[i].textureRect.height}
        end
        local iSpriteSheet = sprite.newSpriteSheetFromData( sheetName..sheetExtension, sData )
 
        
        --ADD some administrative FUNCTIONS 
 
        --expose the spritesheet for manual manipulation
        function iSheet:getSheet()
                return iSpriteSheet or nil
        end
 
        --remove all sprites and the spritesheet from display and memory
        function iSheet:remove()
                self.getSheet():dispose()
   
                
        end
        
        --when the user asks for a sprite:
        --search the sheet images with the given string and...
        --return either a stationary-image or a sprite-animation (with the instructed clips)
        --also, add some administrative functions to the returning sprite (show, hide, play(clip))
        function iSheet:grabSprite(requestedSprite,showBool,clips)
                local returningSprite={}                        
                local sprLength=string.len(requestedSprite)
                local firstLetters=""
                local spriteFrames={}
                                local lastFrameFullName=""
                --gather spritename-whatever.png frames
                for i,v in ipairs(fTags) do
                        firstLetters=string.sub(fTags[i],1,sprLength)
                        if firstLetters==requestedSprite then 
                                table.insert(spriteFrames,i)
                                                                lastFrameFullName=v
                        end
                end
                --if there are some frames, lets build the animation clip(s)
                if #spriteFrames>0 then
                        local spriteSet = sprite.newSpriteSet(self:getSheet(),spriteFrames[1],#spriteFrames)
                        --if there are instructions for separating clips inside the animation, register the clips
                        if clips then
                                                        --if no clipping instructions, then all the frames are assigned to a default clip
                                                        if type(clips[1])=="number" then
                                                                sprite.add(spriteSet,"all",1,#spriteFrames,clips[1],clips[2])
                                                        else  --build the instructed clips
                                for k,v in pairs(clips) do
                                        sprite.add(spriteSet,k,clips[k][1],clips[k][2],clips[k][3],clips[k][4])
                                end
                                                        end                               
                        end                        
                        local spriteInstance = sprite.newSprite(spriteSet)
                                                --if sprite is single-framed make a function that returns a shape for 
                                                --appropriatelly turning the sprite to a physics object (as of 11/11/10 there is a bug in SDK:
                                                --physics use false dimensions for a sprite that has neighbor frames, so you can use this function
                                                --to overcome the bug. See example here: http://developer.anscamobile.com/forum/2010/10/29/spritegrabber-class-spritesheets-2-lines#comment-10778) 
                                                if #spriteFrames==1 then
                                                        function spriteInstance:getShape()
                                                                local x=(frameDimensions[lastFrameFullName][1])
                                                                local y=(frameDimensions[lastFrameFullName][2])
                                                                print(x)
                                                                print(y)
                                                                local shape={math.floor(-x/2),math.floor(-y/2), math.ceil(x/2),math.floor(-y/2), math.ceil(x/2),math.ceil(y/2), math.floor(-x/2),math.ceil(y/2)}
                                                                return shape
                                                        end
                                                end
                        returningSprite = spriteInstance
                else
                        returningSprite= nil
                end
 
                -- play a given clip (without firstly calling prepare())
                --user can still keep using pause() and play()     -->play=resume of last playing clip
                function returningSprite:playClip(clip)
                        if clip then
                                self:prepare(clip)
                                self:play()                             
                        else
                                self:play()
                        end
                end
                
                --show the sprite in given position/scaling
                --as of 2/Nov/2010 there is a bug (internal issue: 1772) in SDK, concerning spritesheets and referencepoints
                --see here:http://developer.anscamobile.com/forum/2010/10/27/spritesheet-setreferencepoint-shifted-sprites#comment-9185
                function returningSprite:show(x,y,scale,refPoint)
                    local referencePoints={
                    c=display.CenterReferencePoint,
                    tl=display.TopLeftReferencePoint,
                    tc=display.TopCenterReferencePoint,
                    tr=display.TopRightReferencePoint,
                    cr=display.CenterRightReferencePoint,
                    br=display.BottomRightReferencePoint,
                    bc=display.BottomCenterReferencePoint,
                    bl=display.BottomLeftReferencePoint,
                    cl=display.CenterLeftReferencePoint }                           
                        self:setReferencePoint(referencePoints[refPoint or "c"])
                                                --self:setReferencePoint(display.CenterLeftReferencePoint ) 
                        self:scale(scale or 1,scale or 1)
                        self.x=x or display.viewableContentWidth/2
                        self.y=y or display.viewableContentHeight/2                     
                        self.isVisible=true
                end     
                --hide the sprite and make it invisible (to not being rendered)
                function returningSprite:hide() 
                        self.x=-5000
                        self.y=-5000                    
                        self.isVisible=false
                end
                
                --sometimes we simply want to show an image to the center of screen (e.g. a background!)...
                --or just throw a sprite in screen for debbuging purposes without requiring special positioning
                if showBool==true then 
                        returningSprite:show()
                else
                        returningSprite:hide()
                end
                
                --we now have the appropriate sprite in hand
                return returningSprite
        end
        
        --ok, we now have parsed the sheet by image-name
        --and have added some helpful functions for sprites definition and manipulation
        return iSheet   
end