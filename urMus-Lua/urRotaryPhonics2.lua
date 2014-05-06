-- RotaryPhonics2.lua
-- Random Brick Animated Graphic for Spinning Piece
-- Anton Pugh: Animation code
-- Robert Alexander: Accelerometer-Controlled Alpha
-- Channel Modification code and Concept

FreeAllRegions()
DPrint("")

local host = "192.168.1.190"
local port = "7402"

-- Function for moving individual bricks up and down on the screen
function move(self,elapsed)
    local ypos = self.ypos

    -- Keep the brick within the screen
    if((self.dir == "up") and (ypos + elapsed > ScreenHeight()-self.h)) then
        self.dir = "down"
    else if((self.dir == "down") and (ypos - elapsed < 0)) then
        self.dir = "up"
        end
    end

    -- Change the location of the brick
    if(self.dir == "up") then
        self.ypos = ypos + self.v*elapsed
    else
        self.ypos = ypos - self.v*elapsed
    end
    self:SetAnchor("BOTTOMLEFT",self.xpos,self.ypos)
end

function PrintAccelerations(self,x,y,z) --Alpha based on accelerometer *****
    d = ((-y)*255) -- Data Scaling from Accelerometer
    d = math.max(d,30)
    d = math.min(d,255)
    r,g,b,a = self.t:SolidColor()
    self.t:SetTexture(r,g,b,255-d)
    SendOSCMessage(host,port,"/urMus/accelROT",d)
end

xcoord = {}
for i = 1,10 do
    xcoord[i] = (2*i-2)*ScreenWidth()/20 + 2
end
ycoord = {0, 1}

-- Generate 20 randomly sized bricks of random shades of blue
r = {}
for i = 1,20 do
    block = Region()
    block.h = math.random(ScreenWidth()/11,ScreenWidth()/5)
    block:SetWidth(block.h)
    block:SetHeight(block.h)
    block.xpos = xcoord[i%10 + 1]
    block.ypos = ycoord[i%2 + 1]*(ScreenHeight()-block.h)
    block.dir = "up"
    block.v = math.random(50,100)
    block.t = block:Texture(0,math.random(0,255),255,180)
    block.t:SetTexture("circle512.png")
    block.t:SetBlendMode("BLEND")
    block:SetAnchor("BOTTOMLEFT",block.xpos,block.ypos)
    block:Show()
    r[i] = block
    r[i]:Handle("OnUpdate",move)
end

-- Create a black region over the entire screen whose alpha channel
-- changes based on accelerometer data. This allows for hiding and
-- showing of the blue bricks depending on how fast the device spins
local over = Region('region', 'over', UIParent)
over:SetWidth(ScreenWidth())
over:SetHeight(ScreenHeight())
over:SetLayer("TOOLTIP")
over:EnableClamping(true)
over.t = over:Texture(0,0,0,255)
over.t:SetBlendMode("BLEND")
over:EnableInput(true)
over:Show()
over:Handle("OnAccelerate",PrintAccelerations)

local pagebutton=Region()
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
pagebutton:Handle("OnDoubleTap", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetBlendMode("BLEND")
pagebutton:EnableInput(true)
--pagebutton:Show()
