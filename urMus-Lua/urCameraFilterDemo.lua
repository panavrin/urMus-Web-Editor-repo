-- OpenGl2 Camera Filter demo
-- Hacked by Georg Essl
-- Created: 7/9/2012

function SetParams(self,x,y,dx,dy)
DPrint(activefilter.effect.."\n"..x/self:Width()*2-1)
SetCameraFilterParameter(x/self:Width()*2-1)
end

brush = Region()
brush.t = brush:Texture("Ornament1.png")
brush:UseAsBrush()

cameraregion = Region()
cameraregion:SetWidth(ScreenWidth())
cameraregion:SetHeight(ScreenHeight()/2)
cameraregion.t = cameraregion:Texture(255,255,255,255)
cameraregion.t:UseCamera()
cameraregion.t:SetBlendMode("BLEND")
cameraregion.t:SetTiling()
cameraregion:SetAnchor("TOPLEFT",UIParent,"TOPLEFT",0,0)
cameraregion:Show()
cameraregion:Handle("OnMove",SetParams)
cameraregion:EnableInput(true)

local minfps = 100
local maxfps = 0
local meanfps = 0

function ShowFPS(self,elapsed)
	local fps = 1.0/elapsed
	if minfps > fps then minfps = fps end
	if maxfps < fps then maxfps = fps end
	meanfps = meanfps*24/25 + fps/25.0
	local str = "Current: "..fps.."\nMean: "..meanfps.."\nMin: "..minfps.."\nMax: "..maxfps
	DPrint(str)
end

local cam = 1

local fmode = 1
local fmodes = { CameraFilters() }

function SwitchEffect(self)
    activefilter.t:SetSolidColor(80,80,80);
    self.t:SetSolidColor(160,160,160);
    SetCameraFilter(self.effect)
    DPrint(self.effect)
    activefilter = self
end

lastbutton = 1
buttons =  {}
local bborder = 3
for k,v in pairs(fmodes) do
    buttons[lastbutton] = Region()
    buttons[lastbutton]:SetWidth(ScreenWidth()/8-bborder)
    buttons[lastbutton]:SetHeight(ScreenWidth()/16-bborder)
    buttons[lastbutton].t = buttons[lastbutton]:Texture(80,80,80);
    buttons[lastbutton]:Show();
    buttons[lastbutton]:SetAnchor("BOTTOMLEFT",((lastbutton-1) % 8)*ScreenWidth()/8, math.floor((lastbutton-1) / 8)*ScreenWidth()/16)
    buttons[lastbutton].tl = buttons[lastbutton]:TextLabel()
    buttons[lastbutton].tl:SetLabel(v)
    buttons[lastbutton].effect = v
    buttons[lastbutton]:Handle("OnTouchDown", SwitchEffect)
    buttons[lastbutton]:EnableInput(true)
    buttons[lastbutton]:SetLayer("HIGH")
    lastbutton = lastbutton + 1
end

activefilter = buttons[1];
buttons[1].t:SetSolidColor(160,160,160);

function SwitchCamera(self)
	DPrint(cam)
	if cam == 1 then cam = 2 else cam = 1 end
	SetActiveCamera(cam)
    SetCameraAutoBalance(cam-1)
end

if not pagersize then
pagersize = 32
end
local pagebutton=Region()
--local pagebutton=Region('region', 'pagebutton', UIParent)
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4) 
pagebutton:EnableClamping(true)
--pagebutton:Handle("OnDoubleTap", FlipPage)
pagebutton:Handle("OnDoubleTap", FlipPage)
--pagebutton:Handle("OnTouchDown", SwitchCamera)
--pagebutton:Handle("OnUpdate", ShowFPS)
pagebutton:Handle("OnAccelerate", Flashy)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()
--pagebutton:Handle("OnPageEntered", nil)

