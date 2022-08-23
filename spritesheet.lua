--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:11293ec3938c4b6a36955064a6c2d71f:e5ea7036527c9140cdecd038114783d7:c46243f411ca86fe596665ab352bd775$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- bar
            x=98,
            y=567,
            width=320,
            height=40,

        },
        {
            -- bar2
            x=98,
            y=483,
            width=320,
            height=82,

        },
        {
            -- bkg_cor
            x=1,
            y=1,
            width=320,
            height=480,

        },
        {
            -- drink
            x=323,
            y=223,
            width=73,
            height=170,

            sourceX = 6,
            sourceY = 3,
            sourceWidth = 79,
            sourceHeight = 188
        },
        {
            -- hamburger
            x=323,
            y=152,
            width=98,
            height=69,

            sourceX = 3,
            sourceY = 3,
            sourceWidth = 102,
            sourceHeight = 73
        },
        {
            -- hotdog
            x=323,
            y=85,
            width=120,
            height=65,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 126,
            sourceHeight = 67
        },
        {
            -- icecream
            x=323,
            y=1,
            width=122,
            height=82,

            sourceX = 3,
            sourceY = 3,
            sourceWidth = 126,
            sourceHeight = 88
        },
        {
            -- icecream2
            x=51,
            y=483,
            width=45,
            height=95,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 47,
            sourceHeight = 101
        },
        {
            -- icecream3
            x=1,
            y=483,
            width=48,
            height=108,

            sourceX = 1,
            sourceY = 8,
            sourceWidth = 50,
            sourceHeight = 118
        },
        {
            -- orange
            x=323,
            y=395,
            width=58,
            height=57,

            sourceX = 0,
            sourceY = 1,
            sourceWidth = 58,
            sourceHeight = 59
        },
    },
    
    sheetContentWidth = 446,
    sheetContentHeight = 608
}

SheetInfo.frameIndex =
{

    ["bar"] = 1,
    ["bar2"] = 2,
    ["bkg_cor"] = 3,
    ["drink"] = 4,
    ["hamburger"] = 5,
    ["hotdog"] = 6,
    ["icecream"] = 7,
    ["icecream2"] = 8,
    ["icecream3"] = 9,
    ["orange"] = 10,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
