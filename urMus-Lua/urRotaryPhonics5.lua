-- RotaryPhonics5.lua
-- Parentheses-Shaped Animated Graphic for Spinning Piece
-- Anton Pugh: Animation code
-- Robert Alexander: Accelerometer-Controlled Alpha
-- Channel Modification code and Concept

FreeAllRegions()
DPrint("")

local host = "192.168.1.190"
local port = "7405"

function spin(self,elapsed)
    self.angle = self.angle + self.v*elapsed
    self.t:SetRotation(self.angle)
    width = self.width
    height = self.height
    if(width + 30*self.v*elapsed >= ScreenWidth()) then
        self.dir = "IN"
    else if(width - 30*self.v*elapsed <= ScreenWidth()/8) then
        self.dir = "OUT"
    end
    end
    if(self.dir == "IN") then
        self.width = width - 30*self.v*elapsed
        self.height = height - 30*self.v*elapsed
    else
        self.width = width + 30*self.v*elapsed
        self.height = height + 30*self.v*elapsed
    end
    self:SetWidth(self.width)
    self:SetHeight(self.height)
end

function PrintAccelerations(self,x,y,z) --Alpha based on accelerometer *****
    d = ((-y)*255) -- Data Scaling from Accelerometer
    d = math.max(d,30)
    d = math.min(d,255)
    r,g,b,a = self.t:SolidColor()
    self.t:SetTexture(r,g,b,255-d)
    SendOSCMessage(host,port,"/urMus/accelROT",d)
end

r = {}
for i = 1,9 do
    shape = Region()
    shape.width = ScreenWidth()/(i/4 + 0.75)
    shape.height = ScreenHeight()/(i/4 + 0.75)
    shape:SetWidth(shape.width)
    shape:SetHeight(shape.height)
    shape:SetAnchor("CENTER",UIParent,"CENTER",0,0)
    shape.t = shape:Texture(255-(25*(i-1)),128-(12.5*(i-1)),25*(i-1),200)
    shape.t:SetBlendMode("BLEND")
    shape.t:SetTexture("parenth.png")
    shape.t:SetTiling(false)
    shape:Show()
    shape.v = 4/(i % 4 + 1);
    shape.dir = "OUT"
    shape.angle = math.pi/(i % 4 + 1)
    r[i] = shape
    r[i]:Handle("OnUpdate",spin)
end

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
