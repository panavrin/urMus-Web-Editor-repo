-- urAnim example
-- by Georg Essl 9/13/2010

FreeAllRegions()

--local maxanim = 3
--local anim = {"cloud-drop1.png","cloud-drop2.png","cloud-drop3.png"}

local maxanim = 95
local anim = {}
local i = 1
local step = 0.25
local floor = math.floor

for j=1,maxanim do
    anim[j] = "urMus-Intro_1"..string.format("%02d", j)
end

function animate(self, elapsed)
    i = i + step
    if step > 0 and floor(i) > maxanim then
        i = i - maxanim
    end
    if step < 0 and floor(i) < 1 then
        i = i + maxanim
    end
    self.t:SetTexture(anim[floor(i)])
end

r = Region()
r.t = r:Texture()
r:Show()
r:Handle("OnUpdate",animate)
r:EnableMoving(true)
r:EnableInput(true)
r:EnableResizing(true)

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