--Color/synesthesia instrument
--Code adapted from urCameraDemo
--Adapted and debugged by Lizzie Paris, Tony Pugh, Scott Wagner, Mike Main, Robert
--All members worked to experiment with code and debug.  This was a team effort.  The code below was created by those indicated by each chunk, but worked on by the whole group.
 
FreeAllRegions()
DPrint("")
 
--Worked on by Tony and Mike
one = {}
two = {}
three = {}
four = {}
five ={}
six = {}
seven = {}
eight = {}
nine = {}
 
two[1] = 12.0/96.0*math.log(196.0/55)/math.log(2) -- 2,3,4
three[1] = two[1]
four[1] = two[1]
 
nine[1] = 12.0/96.0*math.log(207.7/55)/math.log(2) -- 9
five[1] = 12.0/96.0*math.log(233.1/55)/math.log(2) -- 5
one[1] = 12.0/96.0*math.log(261.6/55)/math.log(2) -- 1,2,3,4,6
two[2] = one[1]
three[2] = one[1]
four[2] = one[1]
six[1] = one[1]
 
one[2] = 12.0/96.0*math.log(293.7/55)/math.log(2) -- 1,5,7,7
five[2] = one[2]
seven[1] = one[2]
seven[2] = one[2]
 
nine[2] = 12.0/96.0*math.log(311.1/55)/math.log(2) -- 9,9
nine[3] = nine[2]
 
two[3] = 12.0/96.0*math.log(329.6/55)/math.log(2) -- 2,3,4,7,7
three[3] = two[3]
four[3] = two[3]
seven[3] = two[3]
seven[4] = two[3]
 
one[3] = 12.0/96.0*math.log(349.2/55)/math.log(2) -- 1,5,5
five[3] = one[3]
five[4] = one[3]
 
one[4] = 12.0/96.0*math.log(392.0/55)/math.log(2) -- 1,2,3,4,6
two[4] = one[4]
three[4] = one[4]
four[4] = one[4]
six[2] = one[4]
 
nine[4] = 12.0/96.0*math.log(415.3/55)/math.log(2) -- 9,9
nine[5] = nine[4]
 
five[5] = 12.0/96.0*math.log(466.2/55)/math.log(2) -- 5,6
six[3] = five[5]
 
seven[5] = 12.0/96.0*math.log(493.9/55)/math.log(2) -- 7,7
seven[6] = seven[5]
 
one[5] = 12.0/96.0*math.log(523.3/55)/math.log(2) -- 1,3,6,6,8
three[5] = one[5]
six[4] = one[5]
six[5] = one[5]
eight[1] = one[5]
 
one[6] = 12.0/96.0*math.log(587.3/55)/math.log(2) -- 1,3,8
three[6] = one[6]
eight[2] = one[6]
 
nine[6] = 12.0/96.0*math.log(622.3/55)/math.log(2) -- 9
eight[3] = 12.0/96.0*math.log(630.6/55)/math.log(2) -- 8
two[5] = 12.0/96.0*math.log(659.3/55)/math.log(2) -- 2,4,6,8
four[5] = two[5]
six[6] = two[5]
eight[4] = two[5]
 
five[6] = 12.0/96.0*math.log(698.5/55)/math.log(2) -- 5
eight[5] = 12.0/96.0*math.log(740.0/55)/math.log(2) -- 8
two[6] = 12.0/96.0*math.log(784.0/55)/math.log(2) -- 2
four[6] = 12.0/96.0*math.log(830.6/55)/math.log(2) -- 4
eight[6] = 12.0/96.0*math.log(932.3/55)/math.log(2) -- 8
 
--by tony Pugh
cam = _G["FBCam"]
dac = _G["FBDac"]
 
sinOsc1 = FlowBox("object","sinOsc1",_G["FBSinOsc"])
sinOsc2 = FlowBox("object","sinOsc2",_G["FBSinOsc"])
sinOsc3 = FlowBox("object","sinOsc3",_G["FBSinOsc"])
sinOsc4 = FlowBox("object","sinOsc4",_G["FBSinOsc"])
sinOsc5 = FlowBox("object","sinOsc5",_G["FBSinOsc"])
sinOsc6 = FlowBox("object","sinOsc6",_G["FBSinOsc"])
lowPush1 = FlowBox("object","lowPush1",_G["FBPush"])
medPush1 = FlowBox("object","medPush1",_G["FBPush"])
highPush1 = FlowBox("object","highPush1",_G["FBPush"])
lowPush2 = FlowBox("object","lowPush2",_G["FBPush"])
medPush2 = FlowBox("object","medPush2",_G["FBPush"])
highPush2 = FlowBox("object","highPush2",_G["FBPush"])
gain1 = FlowBox("object","gain1",_G["FBGain"])
gain2 = FlowBox("object","gain2",_G["FBGain"])
gain3 = FlowBox("object","gain3",_G["FBGain"])
gain4 = FlowBox("object","gain1",_G["FBGain"])
gain5 = FlowBox("object","gain2",_G["FBGain"])
gain6 = FlowBox("object","gain3",_G["FBGain"])
gainPush = FlowBox("object","gainPush",_G["FBPush"])
 
cam:SetPushLink(3,gain1,0)
cam:SetPushLink(2,gain2,0)
cam:SetPushLink(1,gain3,0)
cam:SetPushLink(3,gain4,0)
cam:SetPushLink(2,gain5,0)
cam:SetPushLink(1,gain6,0)
gain1:SetPushLink(0,sinOsc1,1)
gain2:SetPushLink(0,sinOsc2,1)
gain3:SetPushLink(0,sinOsc3,1)
gain4:SetPushLink(0,sinOsc4,1)
gain5:SetPushLink(0,sinOsc5,1)
gain6:SetPushLink(0,sinOsc6,1)
gainPush:SetPushLink(0,gain1,1)
gainPush:SetPushLink(0,gain2,1)
gainPush:SetPushLink(0,gain3,1)
gainPush:SetPushLink(0,gain4,1)
gainPush:SetPushLink(0,gain5,1)
gainPush:SetPushLink(0,gain6,1)
lowPush1:SetPushLink(0,sinOsc1,0)
medPush1:SetPushLink(0,sinOsc2,0)
highPush1:SetPushLink(0,sinOsc3,0)
lowPush2:SetPushLink(0,sinOsc4,0)
medPush2:SetPushLink(0,sinOsc5,0)
highPush2:SetPushLink(0,sinOsc6,0)
 
gainPush:Push(1.0/6.0)
lowPush1:Push(one[1])
medPush1:Push(one[3])
highPush1:Push(one[5])
lowPush2:Push(one[6])
medPush2:Push(one[2])
highPush2:Push(one[4])
 
on = false
 
function start(self)
    if(not on) then
        on = true
        dac:SetPullLink(0,sinOsc1,0)
        dac:SetPullLink(0,sinOsc2,0)
        dac:SetPullLink(0,sinOsc3,0)
        dac:SetPullLink(0,sinOsc4,0)
        dac:SetPullLink(0,sinOsc5,0)
        dac:SetPullLink(0,sinOsc6,0)
    end
end
 
function stop(self)
    if(on) then
        on = false
        dac:RemovePullLink(0,sinOsc1,0)
        dac:RemovePullLink(0,sinOsc2,0)
        dac:RemovePullLink(0,sinOsc3,0)
        dac:RemovePullLink(0,sinOsc4,0)
        dac:RemovePullLink(0,sinOsc5,0)
        dac:RemovePullLink(0,sinOsc6,0)
    end
end
 
--by Lizzie Paris
local camera = 1
function SwitchCamera(self)
--    DPrint(camera)
    if camera == 1 then camera = 2 else camera = 1 end
    SetActiveCamera(camera)
end
 
r1=Region()
r1:SetHeight(ScreenHeight())
r1:SetWidth(ScreenWidth())
r1.t=r1:Texture()
r1.t:Clear(255,255,255,255)
r1.t:UseCamera()
r1.t:SetRotation(math.pi*6/4)
r1:Show()
r1:EnableInput(true)
r1.t:SetTiling(false)
r1:EnableResizing(true)
r1:Handle("OnUpdate", GatherVis)
r1:Handle("OnDoubleTap", SwitchCamera)
 
r2=Region()
r2:SetHeight(50)
r2:SetWidth(8*ScreenWidth()/28)
r2:SetAnchor("BOTTOMLEFT", 1*ScreenWidth()/28, 10)
r2.t=r2:Texture()
r2.t:SetTexture(0,0,0,255)
r2:Show()
r2:EnableInput(true)
    
 
r3=Region()
r3:SetHeight(44)
r3:SetWidth((8*ScreenWidth()/28)-6)
r3:SetAnchor("CENTER", r2, "CENTER", 0, 0)
r3.t=r3:Texture()
--r3.t:SetTexture(255,255,255,255)
r3.t:SetGradientColor("HORIZONTAL", 240, 240,240,255, 210,210,210,255)
r3.tl=r3:TextLabel();
r3.tl:SetLabel("Start")
r3.tl:SetColor(0,0,0,255)
r3.tl:SetFontHeight(28)
r3:Handle("OnTouchDown", start)
 
r3:Show()
r3:EnableInput(true)
 
r4=Region()
r4:SetHeight(50)
r4:SetWidth(8*ScreenWidth()/28)
r4:SetAnchor("BOTTOMLEFT", 10*ScreenWidth()/28, 10)
r4.t=r4:Texture()
r4.t:SetTexture(0,0,0,255)
r4:Show()
r4:EnableInput(true)
    
 
r5=Region()
r5:SetHeight(44)
r5:SetWidth((8*ScreenWidth()/28)-6)
r5:SetAnchor("CENTER", r4, "CENTER", 0, 0)
r5.t=r5:Texture()
r5.t:SetGradientColor("HORIZONTAL", 240, 240,240,255, 210,210,210,255)
--r5.t:SetTexture(255,255,255,255)
r5.tl=r5:TextLabel();
r5.tl:SetLabel("Stop")
r5.tl:SetColor(0,0,0,255)
r5.tl:SetFontHeight(28)
r5:Show()
r5:EnableInput(true)
r5:Handle("OnTouchDown", stop)
 
 
r6=Region()
r6:SetHeight(50)
r6:SetWidth(8*ScreenWidth()/28)
r6:SetAnchor("BOTTOMLEFT", 19*ScreenWidth()/28, 10)
r6.t=r6:Texture()
r6.t:SetTexture(0,0,0,255)
r6:Show()
r6:EnableInput(true)
    
 
r7=Region()
r7:SetHeight(44)
r7:SetWidth((8*ScreenWidth()/28)-6)
r7:SetAnchor("CENTER", r6, "CENTER", 0, 0)
r7.t=r7:Texture()
r7.t:SetGradientColor("HORIZONTAL", 240, 240,240,255, 210,210,210,255)
--r7.t:SetTexture(255,255,255,255)
r7.tl=r7:TextLabel();
r7.tl:SetLabel("Decay")
r7.tl:SetColor(0,0,0,255)
r7.tl:SetFontHeight(28)
r7:Show()
r7:EnableInput(true)
 
 
--Worked on by Tony and Mike
function change(self)
    if(self.index == 1) then
        lowPush1:Push(one[1])
        medPush1:Push(one[3])
        highPush1:Push(one[5])
        lowPush2:Push(one[6])
        medPush2:Push(one[2])
        highPush2:Push(one[4])
    end
    if(self.index == 2) then
        lowPush1:Push(two[1])
        medPush1:Push(two[3])
        highPush1:Push(two[5])
        lowPush2:Push(two[6])
        medPush2:Push(two[2])
        highPush2:Push(two[4])
    end
    if(self.index == 3) then
        lowPush1:Push(three[1])
        medPush1:Push(three[3])
        highPush1:Push(three[5])
        lowPush2:Push(three[6])
        medPush2:Push(three[2])
        highPush2:Push(three[4])
    end
    if(self.index == 4) then
        lowPush1:Push(four[1])
        medPush1:Push(four[3])
        highPush1:Push(four[5])
        lowPush2:Push(four[6])
        medPush2:Push(four[2])
        highPush2:Push(four[4])
    end
    if(self.index == 5) then
        lowPush1:Push(five[1])
        medPush1:Push(five[3])
        highPush1:Push(five[5])
        lowPush2:Push(five[6])
        medPush2:Push(five[2])
        highPush2:Push(five[4])
    end
    if(self.index == 6) then
        lowPush1:Push(six[1])
        medPush1:Push(six[3])
        highPush1:Push(six[5])
        lowPush2:Push(six[6])
        medPush2:Push(six[2])
        highPush2:Push(six[4])
    end
    if(self.index == 7) then
        lowPush1:Push(seven[1])
        medPush1:Push(seven[3])
        highPush1:Push(seven[5])
        lowPush2:Push(seven[6])
        medPush2:Push(seven[2])
        highPush2:Push(seven[4])
    end
    if(self.index == 8) then
        lowPush1:Push(eight[1])
        medPush1:Push(eight[3])
        highPush1:Push(eight[5])
        lowPush2:Push(eight[6])
        medPush2:Push(eight[2])
        highPush2:Push(eight[4])
    end
    if(self.index == 9) then
        lowPush1:Push(nine[1])
        medPush1:Push(nine[3])
        highPush1:Push(nine[5])
        lowPush2:Push(nine[6])
        medPush2:Push(nine[2])
        highPush2:Push(nine[4])
    end
end
    
butt = {}
for k = 1,3 do
for j = 1,3 do
    i = k+(j-1)*3
    r = Region()
--    r:SetHeight(32)
--    r:SetWidth(32)
--    r:SetAnchor("TOPLEFT",UIParent,"TOPLEFT",(i-1)*(ScreenWidth()/10+3)+4,0)
    r:SetHeight(ScreenWidth()/6)
    r:SetWidth(ScreenWidth()/6)
    r:SetAnchor("TOPLEFT",UIParent,"TOPLEFT",(j-1)*(ScreenWidth()/3)+ScreenWidth()/12,(k-1)*(-ScreenWidth()/3)-ScreenWidth()/12)
    r.t = r:Texture(255,255,255,60)
    r.t:SetBlendMode("BLEND")
    r.tl = r:TextLabel()
    r.tl:SetLabel(i)
    r.tl:SetFontHeight(r:Height()/3)
    r.index = i
    r:Show()
    butt[i] = r
    butt[i]:EnableInput(true)
    butt[i]:Handle("OnEnter",change)
    butt[i]:Handle("OnTouchDown",change)
end
end

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
