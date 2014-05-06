FreeAllRegions()
DPrint("")

local host = "192.168.1.190"
local port = "7404"

r2 = {}
local maxr = 4

function MoveIt(self,elapsed)
    local pos = self.pos
    if ScreenWidth() > 320 then
        self.t:SetTexCoord(0.0-pos,16*128/1024.0-pos,0.0+pos,16*128/1024.0-pos)
    else
        self.t:SetTexCoord(0.0+pos,16*128/512.0+pos,0.0-pos,16*128/512.0+pos)
    end
    if(pos + self.i*0.01 > 2) then
        self.dir = "out"
    else if(pos - self.i*0.01 < 0) then
        self.dir = "in"
    end
end
        if(self.dir == "out") then
            self.pos = pos -self.i*0.01
        else
            self.pos = pos +self.i*0.01
        end
end 

function PrintAccelerations(self,x,y,z) --Alpha based on accelerometer *****
    d = ((-y)*255) -- Data Scaling from Accelerometer
    d = math.max(d,20)
    d = math.min(d,255)
    r,g,b,a = self.t:SolidColor()
    self.t:SetTexture(r,g,b,255-d)
    SendOSCMessage(host,port,"/urMus/accelROT",d)
end

for i=1,maxr do
r2[i] = Region()
r2[i]:SetWidth(ScreenWidth())
r2[i]:SetHeight(ScreenHeight())
r2[i]:SetLayer("BACKGROUND")
r2[i]:SetAnchor("BOTTOMLEFT",0,0)
r2[i].t = r2[i]:Texture(255,255,255,128)
r2[i].t:SetTexture("shape.png")
r2[i].i = i
r2[i].pos = 0
-- Texture internally have to be powers of 2. So we need to rescale our texture to fit the internals.
if ScreenWidth() > 320 then
r2[i].t:SetTexCoord(0,64/1024.0,64/1024.0,0.0)
else
r2[i].t:SetTexCoord(0,64/512.0,64/512.0,0.0)
end
r2[i]:Handle("OnUpdate",MoveIt)
r2[i].t:SetBlendMode("BLEND")
r2[i]:Show()
r2[i].t:SetGradientColor("TOP", 0, 128, 255, 128, 255, 128, 0, 128)
r2[i].t:SetGradientColor("BOTTOM", 128,0,128, 128, 128, 255, 0, 128)
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
