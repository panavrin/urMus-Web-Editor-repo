--MOBILE COLOR ORGAN - Kyle Kramer
--White keys (only) assigned a different sample. (samples will eventually be playing a pitch/key)
--AccelY controls amp on all keys.
--Need samples (pitches) for black keys.


--CONCEPT: A simple interface representing different colors for each note triggered. A projector pointed onto performers will display a large musical staff, and will imply the intended locations of the iPad for different notes. I need to address amplitude visuals, and pick a timbre. The piece will require a conductor, and a simple 4 par chorale.
--Kyle Kramer
--November 17th 2010
--(some code copied from class examples)

FreeAllRegions()
local random = math.random
local screencolors = {{255,0,0,255},{255,128,0},{255,255,0,255},{0,255,0,255},{0,255,255,255},{0,0,255,255},{255,0,255},{255,255,255,255},{255,128,128,255},{128,255,128,255},{128,128,255,255}}

-----


ucSample = FlowBox("object","Sample", _G["FBSample"])
ucPush1 = FlowBox("object","PushA1", _G["FBPush"])
ucPush2 = FlowBox("object","PushA2", _G["FBPush"])
ucAccelY = FlowBox("object","AccelY", _G["FBAccel"])
ucPosSqr = FlowBox("object", "PosSqr", _G["FBPosSqr"])

ucSample:AddFile("wF3.aif") --1
ucSample:AddFile("wGb3.aif")
ucSample:AddFile("wG3.aif")
ucSample:AddFile("wAb3.aif")
ucSample:AddFile("wA3.aif")
ucSample:AddFile("wBb3.aif")
ucSample:AddFile("wB3.aif")
ucSample:AddFile("wC4.aif")
ucSample:AddFile("wDb4.aif")
ucSample:AddFile("wD4.aif")
ucSample:AddFile("wEb4.aif")
ucSample:AddFile("wE4.aif")

ucSample:AddFile("wF4.aif") --13
ucSample:AddFile("wGb4.aif")
ucSample:AddFile("wG4.aif")
ucSample:AddFile("wAb4.aif")
ucSample:AddFile("wA4.aif")
ucSample:AddFile("wBb4.aif")
ucSample:AddFile("wB4.aif")
ucSample:AddFile("wC5.aif")
ucSample:AddFile("wDb5.aif")
ucSample:AddFile("wD5.aif")
ucSample:AddFile("wEb5.aif")
ucSample:AddFile("wE5.aif")

ucSample:AddFile("wF5.aif") -- 25
ucSample:AddFile("wGb5.aif")
ucSample:AddFile("wG5.aif") -- 27

dac = _G["FBDac"]




dac:SetPullLink(0, ucSample, 0)
ucPush1:SetPushLink(0,ucSample, 3)
ucPush1:Push(0)
ucPush2:SetPushLink(0,ucSample, 2)
ucPosSqr:SetPushLink(0,ucSample, 0)
ucAccelY:SetPushLink(1,ucPosSqr, 0)

ucPush2:Push(1.0) 

-----------

function ColorWhite(self)
	ucPush2:Push(1.0) 

	self.t:SetSolidColor(255,255,255,255)
	b.t:SetTexture(0,0,0,0)
end

function ColorBlack(self)
	ucPush2:Push(1.0)

	self.t:SetSolidColor(0,0,0,255)
	b.t:SetTexture(0,0,0,0)
end

colors = {{191,46,51,0},{34,34,173,0},{0,0,255,0},{250,128,114},{130,166,165,0},{127,175,141,0},{135,206,250,0},{202,115,56,0},{139,69,19,0},{255,69,0,0},{254,221,135,0},{0,255,255,0},{191,46,51,0},{34,34,173,0},{0,0,255,0}}

local register = 0
local maxr = 26.0
local splitr = 12.0

function Note(self)
	ucPush1:Push(self.note+register*splitr/maxr)
	ucPush2:Push(0.0)
	b.t:SetTexture(colors[self.index][1],colors[self.index][2],colors[self.index][3],colors[self.index][4])
end

-- Color area


function ToggleRegister(self)
	register = 1-register
end


b = Region()
b.t = b:Texture()
b:SetWidth(ScreenWidth()*.75)
b:SetHeight(ScreenHeight())
b:Show()
b.t:SetTexture(0,0,0,0)
b:SetAnchor("BOTTOMLEFT", ScreenWidth()*.25,0)
b:Handle("OnDoubleTap", ToggleRegister)
b:EnableInput(true)

--WHITE KEYS

rw = {}
--local rwindices = {1,3,5,7,8,10,12,13,15}
--local rwindices = {1,3,4,6,8,9,11,13,15}
local rwindices = {15,13,12,10,8,7,5,3,1}

local scalex = ScreenWidth()/320
local scaley = ScreenHeight()/480

for i=1,9 do
	rw[i] = Region()
	rw[i].index = rwindices[i]
	rw[i].note = (rwindices[i]-1)/maxr
	rw[i]:SetHeight(50*scaley)
	rw[i]:SetWidth(80*scalex)
	rw[i].t = rw[i]:Texture()
	rw[i].t:SetTexture(255,255,255,255)
	rw[i]:Show()
	rw[i]:SetAnchor("BOTTOMLEFT",0,scaley*53*(i-1))
	rw[i]:Handle("OnTouchDown",Note)
	rw[i]:Handle("OnEnter",Note)
	rw[i]:Handle("OnTouchUp",ColorWhite)
	rw[i]:Handle("OnLeave",ColorWhite)
	rw[i]:EnableInput(true)
end

--BLACK KEYS

rb = {}
local rboffsets = {27,133,186,292,345,398}
--local rbindices = {2,4,6,9,11,14}
--local rbindices = {2,5,7,10,12,14}
local rbindices = {14,11,9,6,4,2}

for i=1,6 do
	rb[i] = Region()
	rb[i].index = rbindices[i]
	rb[i].note = (rbindices[i]-1)/maxr
	rb[i]:SetHeight(50*scaley)
	rb[i]:SetWidth(80*scalex)
	rb[i].t = rb[i]:Texture()
	rb[i].t:SetTexture(0,0,0,255)
	rb[i]:Show()
	rb[i]:SetAnchor("BOTTOMLEFT",50*scalex,rboffsets[i]*scaley)
	rb[i]:Handle("OnTouchDown",Note)
	rb[i]:Handle("OnEnter",Note)
	rb[i]:Handle("OnTouchUp",ColorBlack)
	rb[i]:Handle("OnLeave",ColorBlack)
	rb[i]:EnableInput(true)
end

local pagebutton=Region('region', 'pagebutton', UIParent)
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4)
pagebutton:EnableClamping(true)
--pagebutton:Handle("OnDoubleTap", FlipPage)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()
