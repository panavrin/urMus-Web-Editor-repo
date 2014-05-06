-- turntable.lua
FreeAllRegions()
DPrint(" ")

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

pics = {"pad.png", "padPress.png",
"padRel.png", "padLoop.png"}
txt = {"Kick","Clap","Hat","Crash","Loop :","Sine",
"Squ","Saw","Skrach","Write :"}

function tap(self)
if(self.write == "norm" and self.loop == "norm"
and self.sel == "norm") then
self.t:SetTexture(pics[2])
if(self.type == "Kick") then
drumSampPush:Push(0.0)
else if(self.type == "Clap") then
drumSampPush:Push(0.3)
else if(self.type == "Hat") then
drumSampPush:Push(0.6)
else
drumSampPush:Push(1.0)
end
end
end
drumPosPush:Push(0.0)
end
if(self.write == "off") then
self.t:SetTexture(pics[3])
self.write = "on"
writePush:Push(1.0)
end
if(self.loop == "on") then
self.t:SetTexture(pics[1])
self.loop = "off"
else if(self.loop == "off") then
self.loop = "on"
end
end
if(self.sel == "on") then
self.t:SetTexture(pics[1])
self.sel = "off"
sampAmpPush:Push(0.0)
disc.mode = "sample"
else if(self.sel == "off") then
for i = 6,9 do
if(pads[i].sel == "on") then
pads[i].t:SetTexture(pics[1])
pads[i].sel = "off"
end
end
self.sel = "on"
if(disc.mode == "sample") then
sampAmpPush:Push(0.35)
end
disc.mode = "play"
if(self.type == "Sine") then
sampSampPush:Push(0.0)
else if(self.type == "Squ") then
sampSampPush:Push(0.3)
else if(self.type == "Saw") then
sampSampPush:Push(0.6)
else if(self.type == "Skrach") then
sampSampPush:Push(1.0)
end
end
end
end
end
end
end

function release(self)
if(self.write == "norm" and self.loop == "norm") then
self.t:SetTexture(pics[1])
drumPosPush:Push(1.0)
end
if(self.write == "on") then
self.t:SetTexture(pics[1])
self.write = "off"
writePush:Push(0.0)
end
if((self.loop == "on") or (self.sel == "on")) then
self.t:SetTexture(pics[4])
end
end

dac = dac or _G["FBDac"]
mic = mic or FlowBox("object", "mic", _G["FBMic"])

looper = looper or FlowBox("object", "looper", _G["FBLooper"])
loopAmpPush = FlowBox("object", "loopAmpPush", _G["FBPush"])
loopRatePush = FlowBox("object", "loopRatePush", _G["FBPush"])
writePush = FlowBox("object", "writePush", _G["FBPush"])
loopPlayPush = FlowBox("object", "loopPlayPush", _G["FBPush"])
loopPosPush = FlowBox("object", "loopPosPush", _G["FBPush"])

sample = sample or FlowBox("object", "sample", _G["FBSample"])
sampAmpPush = sampAmpPush or FlowBox("object", "sampAmpPush", _G["FBPush"])
sampRatePush = sampRatePush or FlowBox("object", "sampRatePush", _G["FBPush"])
sampPosPush = sampPosPush or FlowBox("object", "sampPosPush", _G["FBPush"])
sampSampPush = sampSampPush or FlowBox("object", "sampSampPush", _G["FBPush"])
sampLoopPush = sampLoopPush or FlowBox("object", "sampLoopPush", _G["FBPush"])
sample:AddFile("sine.wav")
sample:AddFile("square.wav")
sample:AddFile("saw.wav")
sample:AddFile("Scratch.wav")

drum = drum or FlowBox("object", "drum", _G["FBSample"])
drumAmpPush = drumAmpPush or FlowBox("object", "drumAmpPush", _G["FBPush"])
drumRatePush = drumRatePush or FlowBox("object", "drumRatePush", _G["FBPush"])
drumPosPush = drumPosPush or FlowBox("object", "drumPosPush", _G["FBPush"])
drumSampPush = drumSampPush or FlowBox("object", "drumSampPush", _G["FBPush"])
drumLoopPush = drumLoopPush or FlowBox("object", "drumLoopPush", _G["FBPush"])
drum:AddFile("Bass.wav")
drum:AddFile("Clap.wav")
drum:AddFile("ClosedHat.wav")
drum:AddFile("OpenHat.wav")

dac:SetPullLink(0,looper,0)
dac:SetPullLink(0,sample,0)
dac:SetPullLink(0,drum,0)
mic:SetPushLink(0,looper,0)

loopAmpPush:SetPushLink(0,looper,1)
loopRatePush:SetPushLink(0,looper,2)
writePush:SetPushLink(0,looper,3)
loopPlayPush:SetPushLink(0,looper,4)
loopPosPush:SetPushLink(0,looper,5)

sampAmpPush:SetPushLink(0,sample,0)
sampRatePush:SetPushLink(0,sample,1)
sampPosPush:SetPushLink(0,sample,2)
sampSampPush:SetPushLink(0,sample,3)
sampLoopPush:SetPushLink(0,sample,4)

drumAmpPush:SetPushLink(0,drum,0)
drumRatePush:SetPushLink(0,drum,1)
drumPosPush:SetPushLink(0,drum,2)
drumSampPush:SetPushLink(0,drum,3)
drumLoopPush:SetPushLink(0,drum,4)

loopAmpPush:Push(0.65)
loopRatePush:Push(0.0)
writePush:Push(0.0)
loopPlayPush:Push(1.0)
loopPosPush:Push(0.0)

sampAmpPush:Push(0.0)
sampRatePush:Push(0.0)
sampPosPush:Push(0.0)
sampSampPush:Push(0.0)
sampLoopPush:Push(1.0)

drumAmpPush:Push(0.8)
drumRatePush:Push(0.5)
drumPosPush:Push(1.0)
drumSampPush:Push(0.0)
drumLoopPush:Push(0.0)

pads = {}
for i = 1,10 do
pad = Region()
pad.t = pad:Texture()
pad.write = "norm"
pad.loop = "norm"
if((i > 5) and (i < 10)) then
pad.sel = "off"
else
pad.sel = "norm"
end
pad.type = txt[i]
pad.tl = pad:TextLabel()
pad.tl:SetLabel(txt[i])
pad.tl:SetFontHeight(12)
pad.tl:SetColor(0,0,0,255)
pad.tl:SetHorizontalAlign("JUSTIFY")
pad.tl:SetShadowColor(255,255,255,255)
pad.tl:SetShadowOffset(1,1)
pad.tl:SetShadowBlur(1)
pad:Show()
pad:SetWidth(bg:Width()*5/32)
pad:SetHeight(bg:Width()*5/32)
pad.t:SetTexture(pics[1])
pad.t:SetBlendMode("BLEND")
pad:SetAnchor("CENTER",bg,"CENTER", locx[i],locy[i])
pads[i] = pad
pads[i]:EnableInput(true)
pads[i]:Handle("OnTouchDown",tap)
pads[i]:Handle("OnLeave",release)
pads[i]:Handle("OnTouchUp",release)
end
pads[10].write = "off"
pads[5].loop = "off"

disc = Region()
disc.t = disc:Texture()
disc:Show()
disc:SetWidth(bg:Width())
disc:SetHeight(bg:Width())
disc:SetAnchor("CENTER",bg,"BOTTOMLEFT",bg:Width()/2,bg:Height()/3)
disc.t:SetTexture("vinyl.png")
disc.t:SetBlendMode("BLEND")
disc.t:SetTiling(false)
disc:EnableInput(true)
disc:EnableHorizontalScroll(true)
disc:EnableVerticalScroll(true)
disc.arg = 0
disc.prevArg = 0
disc.v = 0
disc.dir = "ccw"
disc.mode = "sample"

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
self.prevArg = disc.arg
self.v = 0
end

function spin(self, elapsed)
bg2.t:SetTexture(self.v/2,0,self.v,160)
local offset = 0

if(self.dir == "cw") then
self.arg = self.arg - self.v/200
offset = 30
else
self.arg = self.arg + self.v/200
offset = 30
end
if(pads[5].loop == "off" and self.v >= 0) then
self.v = self.v - (elapsed*25)^2
end
if(pads[5].loop == "off" and self.v < 0) then
self.v = 0
offset = 0
end
self.t:SetRotation(self.arg)
if(1.5*self.v > ScreenWidth()/9 and 1.5*self.v < 8*ScreenWidth()/9) then
fader:SetAnchor("BOTTOMLEFT",1.5*self.v-ScreenWidth()/16,ScreenWidth()/3.85+ScreenHeight()/2)
end
if(self.dir == "cw") then
loopRatePush:Push(math.min(0.5,(self.v+offset)/200))
sampRatePush:Push(math.min(0.8,(self.v+offset)/200))
else
loopRatePush:Push(math.max(-0.5,(self.v+offset)/-200))
sampRatePush:Push(math.max(-0.8,(self.v+offset)/-200))
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
if(pads[5].loop == "on") then
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

local button = Region('region', 'button', UIParent)
button:SetWidth(pagersize/1.5)
button:SetHeight(pagersize/1.5)
button:SetLayer("TOOLTIP")
button:SetAnchor("CENTER",disc,"CENTER",0,0)
button:EnableClamping(true)
button.t = button:Texture("Button-128-blurred.png")
button.t:SetBlendMode("BLEND")
button:EnableInput(true)
button:Show()
button:Handle("OnDoubleTap", FlipPage) -- Double tap for easy exit

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
