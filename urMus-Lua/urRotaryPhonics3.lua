-- RotaryPhonics3.lua
-- Kaleidoscopic Animated Graphic for Spinning Piece
-- Anton Pugh: Animation code
-- Robert Alexander: Accelerometer-Controlled Alpha
-- Channel Modification code and Concept

FreeAllRegions()
DPrint("")

local host = "192.168.1.190"
local port = "7403"

function spin(self,elapsed)
    self.angle = self.angle + self.v*elapsed
    self.t:SetRotation(self.angle)
end

function PrintAccelerations(self,x,y,z) --Alpha based on accelerometer *****
    d = ((-y)*255) -- Data Scaling from Accelerometer
    d = math.max(d,30)
    d = math.min(d,255)
    r,g,b,a = self.t:SolidColor()
    self.t:SetTexture(r,g,b,255-d)
    SendOSCMessage(host,port,"/urMus/accelROT",d)
end

r1 = Region()
r1:SetWidth(ScreenWidth())
r1:SetHeight(ScreenHeight())
r1:SetAnchor("BOTTOMLEFT",0,0)
r1.t = r1:Texture(128,0,128,200)
r1.t:SetBlendMode("BLEND")
r1.t:SetTexture("shape.png")
r1.t:SetTiling(false)
r1:Show()
r1.v = 8;
r1.angle = 0
r1:Handle("OnUpdate",spin)

r2 = Region()
r2:SetWidth(ScreenWidth()/1.5)
r2:SetHeight(ScreenHeight()/1.5)
r2:SetAnchor("BOTTOMLEFT",ScreenWidth()/6,ScreenHeight()/6)
r2.t = r2:Texture(0,255,128,128)
r2.t:SetBlendMode("BLEND")
r2.t:SetTexture("shape.png")
r2.t:SetTiling(false)
r2:Show()
r2.v = -12
r2.angle = math.pi/6
r2:Handle("OnUpdate",spin)

r3 = Region()
r3:SetWidth(ScreenWidth()/2)
r3:SetHeight(ScreenHeight()/2)
r3:SetAnchor("BOTTOMLEFT",ScreenWidth()/4,ScreenHeight()/4)
r3.t = r3:Texture(255,0,128,128)
r3.t:SetBlendMode("BLEND")
r3.t:SetTexture("shape.png")
r3.t:SetTiling(false)
r3:Show()
r3.v = 16
r3.angle = math.pi/3
r3:Handle("OnUpdate",spin)

r4 = Region()
r4:SetWidth(ScreenWidth()/3)
r4:SetHeight(ScreenHeight()/3)
r4:SetAnchor("BOTTOMLEFT",ScreenWidth()/3,ScreenHeight()/3)
r4.t = r4:Texture(0,128,255,128)
r4.t:SetBlendMode("BLEND")
r4.t:SetTexture("shape.png")
r4.t:SetTiling(false)
r4:Show()
r4.v = -24
r4.angle = math.pi/2
r4:Handle("OnUpdate",spin) 

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
