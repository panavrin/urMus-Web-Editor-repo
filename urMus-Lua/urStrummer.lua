--Strumming piece: Ricardo Rodriguez, Lizzie Paris, Scott Wagner
--App 1 : Strumming mechanism
--Completed by Ricardo and Lizzie


--Known bugs:  
-- 1) hiE gets stuck
-- 2) all keys ("strings") get stuck when strumming... OnLeave does not appear to be working
-- 3) sound is AWFUL and not what we intended when more than one key ("string") is pressed; perhaps a problem with the pure tone?

FreeAllRegions()
DPrint("")

--changes key to bright when touched
function bright(self)
self.t:SetSolidColor(255,255,102,255)
self.tl:SetColor(0,0,0,255)
end

--changes
function backDark(self)
self.t:SetSolidColor(0,0,51,255)
self.tl:SetColor(255,255,255,255)
end

function backMed(self)
self.t:SetSolidColor(0,0,102,255)   
self.tl:SetColor(255,255,255,255)
end

function setReg(self, anchor, color, back, label, fSize)
self:SetWidth(ScreenWidth())
self:SetHeight(ScreenHeight()/6)
self:SetAnchor("BOTTOMLEFT", 0, anchor)
self.t = self:Texture()
self.t:SetSolidColor(0,0,color,255)
self:Handle("OnEnter", bright)
self:Handle("OnLeave", back)
self:Handle("OnTouchDown", bright)
self:Handle("OnTouchUp", back)
self.tl=self:TextLabel()
self.tl:SetLabel(label)
self.tl:SetRotation(90)
self.tl:SetFont(urfont)
self.tl:SetFontHeight(fSize)
self:EnableInput(true)
self:Show()
self.color = color

end

function setOSCReg(self, parent)
self:SetWidth(ScreenWidth()/6)
self:SetHeight(ScreenHeight()/8)
self:SetAnchor("CENTER", parent, "CENTER", -140,0)

--self.t:SetSolidColor(0,0,0,255)
self.tl=self:TextLabel()
--    self.tl:SetLabel("XX")
self.tl:SetRotation(90)
--    self:EnableInput(true)
self:Show()

end

--sets sampleselect value to appropriate index (0 for no fingers, 4 for fourth fret) per string
function gotOSC(self, num)
DPrint(num)

if string.find(num, "0") then
sel=0
elseif string.find(num, "1") then
sel = 1
elseif string.find(num, "2") then
sel = 2
elseif string.find(num, "3") then
sel=3
elseif string.find(num, "4") then
sel=4
end

if string.find(num, "loE") ~= nil then
loEOSC.tl:SetLabel(num)
loESS:Push(sel/4)

elseif string.find(num, "A") ~= nil then
AOSC.tl:SetLabel(num)
ASS:Push(sel/4)

elseif string.find(num, "D") ~= nil then
DOSC.tl:SetLabel(num)
DSS:Push(sel/4)

elseif string.find(num, "G") ~= nil then
GOSC.tl:SetLabel(num)
GSS:Push(sel/4)

elseif string.find(num, "B") ~= nil then
BOSC.tl:SetLabel(num)
BSS:Push(sel/4)

elseif string.find(num, "hiE") ~= nil then
hiEOSC.tl:SetLabel(num)
hiESS:Push(sel/4)        
end

end

dac = _G["FBDac"]

--AddFiles are commented out because we do not have files for all notes yet, so mapping would just be off... will map all 30 tones when we have them



loES = FlowBox("object","loESample",_G["FBSample"])
loESS = FlowBox("object","loESampleSelect", _G["FBPush"])
loESS:SetPushLink(0,loES,3)
loEPos = FlowBox("object", "loEPos", _G["FBPush"])
loEPos:SetPushLink(0,loES,2)
loEVol = FlowBox("object", "loEVol", _G["FBPush"])
loEVol:SetPushLink(0,loES,0)
loEVol:Push(0.2)
--dac:SetPullLink(0,loES,0)
loES:AddFile("loE0.wav")
loES:AddFile("loE1.wav")
loES:AddFile("loE2.wav")
loES:AddFile("loE3.wav")
loES:AddFile("loE4.wav")
loESS:Push(0)

AS = FlowBox("object","ASample",_G["FBSample"])
ASS = FlowBox("object","ASampleSelect",_G["FBPush"])
ASS:SetPushLink(0,AS,3)
APos = FlowBox("object", "APos", _G["FBPush"])
APos:SetPushLink(0,AS,2)
AVol = FlowBox("object", "AVol", _G["FBPush"])
AVol:SetPushLink(0,AS,0)
AVol:Push(0.2)
--dac:SetPullLink(0,AS,0)
AS:AddFile("A0.wav")
AS:AddFile("A1.wav")
AS:AddFile("A2.wav")
AS:AddFile("A3.wav")
AS:AddFile("A4.wav")
ASS:Push(0)

DS = FlowBox("object","DSample",_G["FBSample"])
DSS = FlowBox("object","DSampleSelect",_G["FBPush"])
DSS:SetPushLink(0,DS,3)
DPos = FlowBox("object", "DPos", _G["FBPush"])
DPos:SetPushLink(0,DS,2)
DVol = FlowBox("object", "DVol", _G["FBPush"])
DVol:SetPushLink(0,DS,0)
DVol:Push(0.2)
--dac:SetPullLink(0,DS,0)
DS:AddFile("D0.wav")
DS:AddFile("D1.wav")
DS:AddFile("D2.wav")
DS:AddFile("D3.wav")
DS:AddFile("D4.wav")
DSS:Push(0)

GS = FlowBox("object","GSample",_G["FBSample"])
GSS = FlowBox("object","GSampleSelect",_G["FBPush"])
GSS:SetPushLink(0,GS,3)
GPos = FlowBox("object", "GPos", _G["FBPush"])
GPos:SetPushLink(0,GS,2)
GVol = FlowBox("object", "GVol", _G["FBPush"])
GVol:SetPushLink(0,GS,0)
GVol:Push(0.2)
--dac:SetPullLink(0,GS,0)
GS:AddFile("G0.wav")
GS:AddFile("G1.wav")
GS:AddFile("G2.wav")
GS:AddFile("G3.wav")
GS:AddFile("G4.wav")
GSS:Push(0)

BS = FlowBox("object","BSample",_G["FBSample"])
BSS = FlowBox("object","BSampleSelect",_G["FBPush"])
BSS:SetPushLink(0,BS,3)
BPos = FlowBox("object", "BPos", _G["FBPush"])
BPos:SetPushLink(0,BS,2)
BVol = FlowBox("object", "BVol", _G["FBPush"])
BVol:SetPushLink(0,BS,0)
BVol:Push(0.2)
--dac:SetPullLink(0,BS,0)
BS:AddFile("B0.wav")
BS:AddFile("B1.wav")
BS:AddFile("B2.wav")
BS:AddFile("B3.wav")
BS:AddFile("B4.wav")
BSS:Push(0)

hiES = FlowBox("object","hiES",_G["FBSample"])
hiESS = FlowBox("object","hiESampleSelect", _G["FBPush"])
hiESS:SetPushLink(0,hiES,3)
hiEPos = FlowBox("object", "hiEPos", _G["FBPush"])
hiEPos:SetPushLink(0,hiES,2)
hiEVol = FlowBox("object", "hiEVol", _G["FBPush"])
hiEVol:SetPushLink(0,hiES,0)
hiEVol:Push(0.2)
--dac:SetPullLink(0,hiES,0)
hiES:AddFile("hiE0.wav")
hiES:AddFile("hiE1.wav")
hiES:AddFile("hiE2.wav")
hiES:AddFile("hiE3.wav")
hiES:AddFile("hiE4.wav")
hiESS:Push(0)


function play(self)
if not self.pushed then
dac:SetPullLink(0,self.key,0)       
self.pos:Push(0.0)
self.pushed = true
self.t:SetSolidColor(128,128,self.color,255)
end       
end

function stop(self)
if self.pushed then
dac:RemovePullLink(0,self.key,0)
self.pos:Push(1.0)
self.pushed = nil
self.t:SetSolidColor(0,0,self.color,255)
end
end



loE = Region()
setReg(loE, 0, 51, backDark, "lo E", 36)
loEOSC = Region()
setOSCReg(loEOSC,loE)
loE.pos = loEPos
loE.key = loES
loE:Handle("OnEnter", play)
loE:Handle("OnTouchDown", play)
loE:Handle("OnLeave", stop)
loE:Handle("OnTouchUp", stop)

A = Region()
setReg(A, ScreenHeight()/6, 102, backMed, "A", 48)
AOSC = Region()
setOSCReg(AOSC,A)
A.pos = APos
A.key = AS
A:Handle("OnEnter", play)
A:Handle("OnTouchDown", play)
A:Handle("OnLeave", stop)
A:Handle("OnTouchUp", stop)

D = Region()
setReg(D, 2*ScreenHeight()/6, 51, backDark, "D", 48)
DOSC = Region()
setOSCReg(DOSC,D)
D.pos = DPos
D.key = DS
D:Handle("OnEnter", play)
D:Handle("OnTouchDown", play)
D:Handle("OnLeave", stop)
D:Handle("OnTouchUp", stop)

G = Region()
setReg(G, 3*ScreenHeight()/6, 102, backMed, "G", 48)
GOSC = Region()
setOSCReg(GOSC, G)
G.pos = GPos
G.key = GS
G:Handle("OnEnter", play)
G:Handle("OnTouchDown", play)
G:Handle("OnLeave", stop)
G:Handle("OnTouchUp", stop)

B = Region()
setReg(B, 4*ScreenHeight()/6, 51, backDark, "B", 48)
BOSC = Region()
setOSCReg(BOSC,B)
B.pos = BPos
B.key = BS
B:Handle("OnEnter", play)
B:Handle("OnTouchDown", play)
B:Handle("OnLeave", stop)
B:Handle("OnTouchUp", stop)

hiE= Region()
setReg(hiE, 5*ScreenHeight()/6, 102, backMed, "hi E", 36)
hiEOSC = Region()
setOSCReg(hiEOSC,hiE)
hiE.pos = hiEPos
hiE.key = hiES
hiE:Handle("OnEnter", play)
hiE:Handle("OnTouchDown", play)
hiE:Handle("OnLeave", stop)
hiE:Handle("OnTouchUp", stop)

r = Region()
r:SetWidth(ScreenWidth()/2)
r:SetHeight(ScreenHeight()/2)
r:SetAnchor("CENTER",UIParent,"CENTER", 0,0)
--r:EnableInput(true)
r:Handle("OnOSCMessage", gotOSC)


--r:Handle("OnOSCMessage",gotOSC)

SetOSCPort(8888)
host, port = StartOSCListener()

