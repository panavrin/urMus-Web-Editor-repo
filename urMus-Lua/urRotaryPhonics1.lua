FreeAllRegions()
DPrint("")

local host = "192.168.1.190"
local port = "7401"

function move(self,elapsed)
    local pos = self.pos
    if((self.dir == "up") and (pos + 150*elapsed > 2*ScreenHeight()/3)) then
        self.dir = "down"
    else if((self.dir == "down") and (pos - 150*elapsed < ScreenHeight()/3)) then
        self.dir = "up"
        end
    end
    if(self.dir == "up") then
        self.pos = pos + 150*elapsed
    else
        self.pos = pos - 150*elapsed
    end
    self:SetAnchor("CENTER",ScreenWidth()/2,self.pos)
end

function spin(self,elapsed)
    local angle = math.atan2(self.ypos,self.xpos) + self.v*elapsed
    self.xpos = self.r*math.cos(angle)
    self.ypos = self.r*math.sin(angle)
    self:SetAnchor("CENTER",self:Parent(),"CENTER",self.xpos,self.ypos)
end

function PrintAccelerations(self,x,y,z) --Alpha based on accelerometer *****
    d = ((-y)*255) -- Data Scaling from Accelerometer
    d = math.max(d,0)
    d = math.min(d,255)
    r,g,b,a = self.t:SolidColor()
    self.t:SetTexture(r,g,b,255-d)
    SendOSCMessage(host,port,"/urMus/accelROT",d)
end

c1 = Region()
c1:SetWidth(ScreenWidth()/3)
c1:SetHeight(ScreenWidth()/3)
c1.t = c1:Texture(128,0,255,255)
c1.t:SetTexture("circle512.png")
c1.t:SetBlendMode("BLEND")

c2 = Region()
c2:SetWidth(4*ScreenWidth()/27)
c2:SetHeight(4*ScreenWidth()/27)
c2.xpos = 2*ScreenWidth()/9
c2.ypos = 2*ScreenWidth()/9
c2.v = math.random(2.0,8.0)
c2.r = 2*ScreenWidth()/9
c2.t = c2:Texture(255,128,0,180)
c2.t:SetTexture("circle512.png")
c2.t:SetBlendMode("BLEND")

c3 = Region()
c3:SetWidth(4*ScreenWidth()/27)
c3:SetHeight(4*ScreenWidth()/27)
c3.xpos = ScreenWidth()/3
c3.ypos = ScreenWidth()/3
c3.v = -math.random(2.0,8.0)
c3.r = ScreenWidth()/3
c3.t = c3:Texture(255,128,0,180)
c3.t:SetTexture("circle512.png")
c3.t:SetBlendMode("BLEND")

c4 = Region()
c4:SetWidth(ScreenWidth()/9)
c4:SetHeight(ScreenWidth()/9)
c4.xpos = 4*ScreenWidth()/9
c4.ypos = 4*ScreenWidth()/9
c4.v = math.random(2.0,8.0)
c4.r = 4*ScreenWidth()/9
c4.t = c4:Texture(255,128,0,180)
c4.t:SetTexture("circle512.png")
c4.t:SetBlendMode("BLEND")

c5 = Region()
c5:SetWidth(4*ScreenWidth()/27)
c5:SetHeight(4*ScreenWidth()/27)
c5.xpos = 2*ScreenWidth()/9
c5.ypos = 2*ScreenWidth()/9
c5.v = -math.random(2.0,8.0)
c5.r = 2*ScreenWidth()/9
c5.t = c5:Texture(255,128,0,180)
c5.t:SetTexture("circle512.png")
c5.t:SetBlendMode("BLEND")

c6 = Region()
c6:SetWidth(4*ScreenWidth()/27)
c6:SetHeight(4*ScreenWidth()/27)
c6.xpos = ScreenWidth()/3
c6.ypos = ScreenWidth()/3
c6.v = math.random(2.0,8.0)
c6.r = ScreenWidth()/3
c6.t = c6:Texture(255,128,0,180)
c6.t:SetTexture("circle512.png")
c6.t:SetBlendMode("BLEND")

c7 = Region()
c7:SetWidth(ScreenWidth()/9)
c7:SetHeight(ScreenWidth()/9)
c7.xpos = 4*ScreenWidth()/9
c7.ypos = 4*ScreenWidth()/9
c7.v = -math.random(2.0,8.0)
c7.r = 4*ScreenWidth()/9
c7.t = c7:Texture(255,128,0,180)
c7.t:SetTexture("circle512.png")
c7.t:SetBlendMode("BLEND")

local r = Region('region', 'r', UIParent)
r:SetWidth(ScreenWidth())
r:SetHeight(ScreenWidth())
r:SetLayer("TOOLTIP")
r:EnableClamping(true)
r.pos = ScreenHeight()/2
r.dir = "up"
r.t = r:Texture(0,0,0,255)
r.t:SetBlendMode("BLEND")
r:EnableInput(true)
r:SetAnchor("CENTER",ScreenWidth()/2,r.pos)
r:Show()
c1:Show()
c1:SetAnchor("CENTER",r,"CENTER",0,0)
c2:Show()
c2:SetAnchor("CENTER",r,"CENTER",c2.xpos,c2.ypos)
c3:Show()
c3:SetAnchor("CENTER",r,"CENTER",c3.xpos,c3.ypos)
c4:Show()
c4:SetAnchor("CENTER",r,"CENTER",c4.xpos,c4.ypos)
c5:Show()
c5:SetAnchor("CENTER",r,"CENTER",c5.xpos,c5.ypos)
c6:Show()
c6:SetAnchor("CENTER",r,"CENTER",c6.xpos,c6.ypos)
c7:Show()
c7:SetAnchor("CENTER",r,"CENTER",c7.xpos,c7.ypos)
r:Handle("OnAccelerate",PrintAccelerations)
r:Handle("OnUpdate", move)
c2:Handle("OnUpdate",spin)
c3:Handle("OnUpdate",spin)
c4:Handle("OnUpdate",spin)
c5:Handle("OnUpdate",spin)
c6:Handle("OnUpdate",spin)
c7:Handle("OnUpdate",spin) 

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
