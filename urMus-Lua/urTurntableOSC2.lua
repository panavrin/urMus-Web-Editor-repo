-- urTurntableOSC.lua (Turntable Version 2, for use with Max/MSP patch
-- for spinning piece). The app functions the same as version 1, except
-- there is no native audio, all audio is synthesized by the computer.
-- Note: The variable "host" needs to be assigned the IP Address of the
-- target host computer.

-- Turntable interface designed by Anton Pugh
-- OSC code written by Robert Alexander

FreeAllRegions()
DPrint(" ")

local host = "192.168.1.190"
local port = "7408"

bg = Region()
bg.t = bg:Texture()
bg:Show()
bg:SetWidth(ScreenWidth())
bg:SetHeight(ScreenHeight())
bg.t:SetTexture("metal.png")

bg2 = Region()
bg2.t = bg2:Texture(0,0,0,120)
bg2:Show()
bg2:SetWidth(ScreenWidth())
bg2:SetHeight(ScreenHeight())
bg2.t:SetBlendMode("BLEND")

-- Make Pad Bank
locx = {}
locy = {}
for i = 1,10 do
locx[i] = bg:Width()*(3*((i-1)%5)-6)/16
end
for i = 1,5 do
locy[i] = 0.44*bg:Height()
locy[i+5] = 0.32*bg:Height()
end

pics = {"pad.png", "padLoop.png"}
txt = {"Pad\n1","Pad\n2","Pad\n3","Pad\n4","Mute","Pad\n6",
"Pad\n7","Pad\n8","Pad\n9","Loop"}

function tap(self)
if(self.loop == "norm" and self.mute == "norm") then
SendOSCMessage(host,port,"/urMus/trigger",self.type)
end
if(self.loop == "on") then
self.t:SetTexture(pics[1])
self.loop = "off"
else if(self.loop == "off") then
self.t:SetTexture(pics[2])
self.loop = "on"
end
end
if(self.mute == true) then
SendOSCMessage(host,port,"/urMus/mute",0.0)
end
end

function release(self)
if(self.mute == true) then
SendOSCMessage(host,port,"/urMus/mute",1.0)
end
end

pads = {}
for i = 1,10 do
pad = Region()
pad.t = pad:Texture()
pad.loop = "norm"
pad.mute = "norm"
pad.type = i
pad.tl = pad:TextLabel()
pad.tl:SetLabel(txt[i])
pad.tl:SetFontHeight(12)
pad.tl:SetColor(0,0,0,255)
pad.tl:SetHorizontalAlign("JUSTIFY")
pad.tl:SetShadowColor(255,255,255,255)
pad.tl:SetShadowOffset(1,1)
pad.tl:SetShadowBlur(1)
pad.t:SetBlendMode("BLEND")
pad:Show()
pad:SetWidth(bg:Width()*5/32)
pad:SetHeight(bg:Width()*5/32)
pad.t:SetTexture(pics[1])
pad:SetAnchor("CENTER",UIParent,"CENTER",locx[i],locy[i])
pads[i] = pad
pads[i]:EnableInput(true)
pads[i]:Handle("OnTouchDown",tap)
pads[i]:Handle("OnTouchUp",release)
pads[i]:Handle("OnLeave",release)
end
pads[5].mute = true
pads[10].loop = "off"

disc = Region()
disc.t = disc:Texture()
disc:Show()
disc:SetWidth(bg:Width())
disc:SetHeight(bg:Width())
disc:SetAnchor("CENTER",bg,"BOTTOMLEFT",bg:Width()/2,bg:Height()/3)
disc.t:SetTexture("vinyl.png")
disc.t:SetTiling(false)
disc.t:SetBlendMode("BLEND")
disc:EnableInput(true)
disc:EnableHorizontalScroll(true)
disc:EnableVerticalScroll(true)
disc.arg = 0
disc.prevArg = 0
disc.v = 0
disc.vSigned = 0
disc.dir = "ccw"

function rotX(self,v)
x,y = InputPosition()
x = disc:Width()/2 - x
y = disc:Width()/2 - y
self.arg = math.atan2(y,x)+math.pi
if((v < 0 and self.arg < math.pi) or
(v > 0 and self.arg > math.pi)) then
self.dir = "ccw"
else if((v > 0 and self.arg < math.pi) or
(v < 0 and self.arg > math.pi)) then
self.dir = "cw"
end
end
self.v = math.abs(v)
self.t:SetRotation(self.arg)
end

function rotY(self,v)
x,y = InputPosition()
x = disc:Width()/2 - x
y = disc:Width()/2 - y
self.arg = math.atan2(y,x)+math.pi
if((v > 0 and (self.arg < math.pi/2 or self.arg > 3*math.pi/2)) or
(v < 0 and (self.arg > math.pi/2 and self.arg < 3*math.pi/2))) then
self.dir = "ccw"
else if((v < 0 and (self.arg < math.pi/2 or self.arg > 3*math.pi/2)) or
(v > 0 and (self.arg > math.pi/2 and self.arg < 3*math.pi/2))) then
self.dir = "cw"
end
end
self.v = math.abs(v)
self.t:SetRotation(self.arg)
end

function stop(self)
self.prevArg = self.arg
self.v = 0
end

function spin(self, elapsed)
bg2.t:SetTexture(self.v/2,0,self.v,160)

if(self.dir == "cw") then
self.arg = self.arg - self.v/200
self.vSigned = 15*math.log(self.v)
else
self.arg = self.arg + self.v/200
self.vSigned = -15*math.log(self.v)
end
SendOSCMessage(host,port,"/urMus/spinV",self.vSigned)
if(pads[10].loop == "off" and self.v >= 0) then
self.v = self.v - (elapsed*25)^2
end
if(pads[10].loop == "off" and self.v < 0) then
self.v = 0
end
self.t:SetRotation(self.arg)
if(1.5*self.v > ScreenWidth()/9 and 1.5*self.v < 8*ScreenWidth()/9) then
fader:SetAnchor("BOTTOMLEFT",1.5*self.v-ScreenWidth()/16,ScreenWidth()/3.85+ScreenHeight()/2)
end
end

disc:Handle("OnHorizontalScroll",rotX)
disc:Handle("OnVerticalScroll",rotY)
disc:Handle("OnTouchDown",stop)
disc:Handle("OnUpdate",spin)

arm = Region()
arm:SetWidth(ScreenWidth()/3)
arm:SetHeight(ScreenWidth()/1.2)
arm:SetAnchor("BOTTOMLEFT",-20,-35)
arm.t = arm:Texture()
arm.t:SetTexture("arm.png")
arm.t:SetBlendMode("BLEND")
arm:Show()

function slide(self,v)
x,y = InputPosition()
if(x >= ScreenWidth()/10 and x <= 9*ScreenWidth()/10) then
fader:SetAnchor("BOTTOMLEFT",x-ScreenWidth()/16,ScreenWidth()/3.85+ScreenHeight()/2)
if(pads[10].loop == "on") then
disc.v = x/1.5
end
end
end

bar = Region()
bar:SetWidth(ScreenWidth()/1.1)
bar:SetHeight(ScreenWidth()/8)
bar:SetAnchor("CENTER",UIParent,"CENTER",0,ScreenWidth()/3.15)
bar.t = bar:Texture(12,15,30,128)
bar.t:SetBlendMode("BLEND")
bar.tl = bar:TextLabel()
bar.tl:SetLabel("Loop Speed")
bar.tl:SetFontHeight(14)
bar.tl:SetHorizontalAlign("JUSTIFY")
bar.tl:SetShadowColor(0,0,0,255)
bar.tl:SetShadowOffset(2,2)
bar.tl:SetShadowBlur(3)
bar:EnableHorizontalScroll(true)
bar:EnableInput(true)
bar:Show()

fader = Region()
fader:SetWidth(ScreenWidth()/8)
fader:SetHeight(ScreenWidth()/8)
fader:SetAnchor("BOTTOMLEFT",ScreenWidth()/20,ScreenWidth()/3.8+ScreenHeight()/2)
fader.t = fader:Texture()
fader.t:SetTexture("star.png")
fader.t:SetBlendMode("BLEND")
fader:Show()
bar:Handle("OnHorizontalScroll",slide)
bar:Handle("OnEnter",slide)
bar:Handle("OnTouchDown",slide)

function reee(self)
SendOSCMessage(host,port,"/urMus/reset",1.0)
end

reset = Region()
reset:SetWidth(ScreenWidth()/7)
reset:SetHeight(ScreenWidth()/7)
reset:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
reset.t = reset:Texture(255,255,255,0)
reset.t:SetBlendMode("BLEND")
reset:EnableInput(true)
reset:Show()
reset:Handle("OnTouchDown",reee) 

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
pagebutton:Show()
