-- urTime
-- Created by: Georg Essl, 2012
-- Tests timing relevant flowboxes and mechanisms

dofile(SystemPath("urLineGraph.lua"))
--[[
pull = FlowBox(FBPull)
sin = FlowBox(FBSinOsc)

pump = FlowBox(FBPump)
drain = FlowBox(FBDrain)

drain.In:SetPull(sin.Out)
pump.In:SetPull(drain.Out)
pull.In:SetPull(pump.Out)

pulld = FlowBox(FBPull)
pulld.In:SetPull(drain.Time)

pushp = FlowBox(FBPush)
pushp.Out:SetPush(pump.Time)

pushs = FlowBox(FBPush)
pushs.Out:SetPush(sin.Time)

DPrint(pull:Pull())
DPrint(pull:Pull())
DPrint(pull:Pull())
DPrint(pull:Pull())
DPrint(pull:Pull())
DPrint(pull:Pull())
DPrint(pull:Pull())
DPrint(pull:Pull())
DPrint(pull:Pull())
DPrint("---")
pushs:Push(0) -- Reset phase
DPrint(pull:Pull())
pushp:Push(1.0)
DPrint(pull:Pull())
pushp:Push(1.0)
DPrint(pull:Pull())
pushp:Push(1.0)
DPrint(pull:Pull())
pushp:Push(1.0)
DPrint(pull:Pull())
pushp:Push(1.0)
DPrint(pull:Pull())
pushp:Push(1.0)
DPrint(pull:Pull())
pushp:Push(1.0)
DPrint(pull:Pull())
pushp:Push(1.0)
DPrint(pull:Pull())
DPrint("---")
pushs:Push(0) -- Reset phase
DPrint(pull:Pull())
pulld:Pull()
DPrint(pull:Pull())
pulld:Pull()
DPrint(pull:Pull())
pulld:Pull()
DPrint(pull:Pull())
pulld:Pull()
DPrint(pull:Pull())
pulld:Pull()
DPrint(pull:Pull())
pulld:Pull()
DPrint(pull:Pull())
pulld:Pull()
DPrint(pull:Pull())
pulld:Pull()
DPrint(pull:Pull())
--]]
--[[
pumptestpush = FlowBox(FBPush)
pumptestpull = FlowBox(FBPull)
pump = FlowBox(FBPump)
pumper = FlowBox(FBPush)

pumptestpush.Out:SetPush(pump.In)
pumptestpull.In:SetPull(pump.Out)
pumper.Out:SetPush(pump.Time)

function setpump(self)
    local data = 2*math.random()-1.0
--    DPrint("Pushing: "..data)
    pumptestpush:Push(data)
    self:Paint(data)
end

function dopump(self)
    pumper:Push(1.0)
    local data = pumptestpull:Pull()
--    DPrint("Pumped: "..data)
    self:Paint(data)
end

r = CreateLineGraph(255,255)
r.texture:SetSolidColor(255,0,0,255)
r:Handle("OnTouchDown",setpump)
r:EnableInput(true)

r2 = CreateLineGraph(255,255)
r.texture:SetSolidColor(0,255,0,255)
r2:SetAnchor("BOTTOMLEFT",r:Right(),0)
r2:Handle("OnTouchDown",dopump)
r2:EnableInput(true)
--]]

local enable_train = true

if enable_drain then
--draintestpush = FlowBox(FBPush)
draintestaccel = FlowBox(FBAccel)
draintestpull = FlowBox(FBPull)
drain = FlowBox(FBDrain)
drainer = FlowBox(FBPull)

--draintestpush.Out:SetPush(drain.In)
draintestaccel.X:SetPush(drain.In)
draintestpull.In:SetPull(drain.Out)
drainer.In:SetPull(drain.Time)
end

function setdrain(self)
    local data = 2*math.random()-1.0
--    DPrint("Pushing: "..data)
if enable_drain then
    draintestpush:Push(data)
    self:Paint(data)
end
end

function dodrain(self)
if enable_drain then
    drainer:Pull()
    return draintestpull:Pull()
--    DPrint("drained: "..draintestpull:Pull())
end
end

function dodrain2(self)
if enable_drain then
drainer:Pull()
self:Paint(draintestpull:Pull())
--    DPrint("drained: "..draintestpull:Pull())
end
end



r3 = CreateLineGraph(255,255,dodrain)
r3.texture:SetSolidColor(255,128,0,255)
r3:SetAnchor("BOTTOMLEFT",ScreenWidth()/2-256,0)
--r3:Handle("OnTouchDown",setdrain)
r3:Handle("OnUpdate",r3.Paint)
r3:EnableInput(true)

r4 = CreateLineGraph(255,255)
r4.texture:SetSolidColor(128,255,0,255)
r4:SetAnchor("BOTTOMLEFT",r3:Right(),r3:Bottom())
r4:Handle("OnTouchDown",dodrain2)
r4:EnableInput(true)

local interp = false
if interp then
    sniff = FlowBox(FBSniffL)
else
    sniff = FlowBox(FBSniff)
end

dac = FBDac
vis = FBVis
spush = FlowBox(FBPush)
sin = FlowBox(FBSinOsc)
sample = FlowBox(FBSample)
sample:AddFile("Red-Mono.wav")

local dacfirst = false
if dacfirst then
    dac.In:SetPull(sniff.Out)
    vis.In:SetPull(sniff.Sniff)
else
    dac.In:SetPull(sniff.Sniff)
    vis.In:SetPull(sniff.Out)
end

--spush.Out:SetPush(sin.Freq)
sniff.In:SetPull(sample.Out)
--sniff.In:SetPull(sin.Out)
spush:Push(0.0001)

--[[
accel = FBAccel
sin = FlowBox(FBSinOsc)

accel.X:SetPush(sin.Freq)
sin.Out:SetPush(sniff.In)
--]]

--[[
function visdraw(self,elapsed)
    local x,y = InputPosition()
    spush:Push((y/ScreenHeight())*2-1)
    DPrint("Vis: "..vis:Get())
end

r5 = Region()
r5:Handle("OnUpdate", visdraw)
--]]

local function visget()
    SetCameraFilterParameter((math.abs(vis:Get())*2)-1)
    return vis:Get()*3
end

function togglesources(self)

    if dacfirst then
        dac.In:RemovePull(sniff.Out)
        vis.In:RemovePull(sniff.Sniff)
        dac.In:SetPull(sniff.Sniff)
        vis.In:SetPull(sniff.Out)
    else
        dac.In:RemovePull(sniff.Sniff)
        vis.In:RemovePull(sniff.Out)
        dac.In:SetPull(sniff.Out)
        vis.In:SetPull(sniff.Sniff)
    end
    dacfirst  = not dacfirst
end

lg6 = CreateLineGraph(255,255,visget)
lg6:SetAnchor("BOTTOMLEFT",r4:Left(),r4:Top()+1)
lg6:Handle("OnUpdate", lg6.Paint)
lg6:Handle("OnDoubleTap", togglesources)
lg6:EnableInput(true)

c = Region()
c:SetWidth(255)
c:SetHeight(255)
c.t=c:Texture()
c.t:UseCamera()
c:Show()
c:SetAnchor("BOTTOMLEFT", lg6:Left(), lg6:Top()+1)
--SetCameraFilter("POLARPIXELLATE")
--SetCameraFilter("SWIRL")
SetCameraFilter("CROSSHATCH")

local dowavey = false
local curwait = 0.05
local curtime = 0
local curmult = 1.1
local chaser = false
local ignorechaser = true

function wavey(self, elapsed)
    curtime = curtime + elapsed
    if curtime > curwait then
        curtime = curtime - curwait
        curwait = curwait*curmult
        if curwait >0.5 then
            curmult = 0.95
        elseif curwait <0.05 then
            curmult = 1.05
        end
        cwpush:Push(1.0)
        self:Paint(1.0)
        orn.t:SetGradientColor("TOP",math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255))
        orn.t:SetGradientColor("BOTTOM",math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255),math.random(127,255))

        chaser = true
    elseif chaser or ignorechaser then
        orn.t:SetSolidColor(255,255,255,255)
        cwpush:Push(0.0)
        self:Paint(0.0)
        chaser = false
    end
end

cwpush = FlowBox(FBPush)
cwpush.Out:SetPush(dac.In)

function togglewavey(self)
    dowavey = not dowavey
    if dowavey then
        lg7:Handle("OnUpdate", wavey)
    else
        lg7:Handle("OnUpdate",nil)
    end
end

function togglechaser(self)
    ignorechaser = not ignorechaser
end

lg7 = CreateLineGraph(255,255)
lg7:SetAnchor("BOTTOMLEFT",r3:Left(),r3:Top()+1)
if dowavey then
    lg7:Handle("OnUpdate", wavey)
end
lg7:Handle("OnDoubleTap", togglewavey)
lg7:Handle("OnTouchDown", togglechaser)
lg7:EnableInput(true)

function turno(self,x,y,z)
    self.t:SetRotation(x)
end

orn = Region()
orn:SetWidth(255)
orn:SetHeight(255)
orn.t=orn:Texture("Ornament1.png")
orn:Show()
orn:SetAnchor("BOTTOMLEFT", lg7:Left(), lg7:Top()+1)
orn:Handle("OnAccelerate",turno)

local pagebutton=Region('region', 'pagebutton', UIParent)
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4)
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()