bg = Region()
bg:SetWidth(ScreenWidth())
bg:SetHeight(ScreenHeight())
bg.t = bg:Texture(0,0,90,255)
bg:Show()

--local urfont2 = "Trebuchet MS"
--[[
r={}
for i=1,8 do
    r[i] = Region()
    r[i]:SetHeight((8+4*(i-1))*1.47)
    r[i]:SetWidth(ScreenWidth())
    r[i].tl = r[i]:TextLabel()
    r[i].tl:SetFont(urfont)
    r[i].tl:SetFontHeight(8+4*(i-1))
    r[i].tl:SetLabel("A quick brown fox jumps over the lazy dog")
    r[i].tl:SetColor(255,255,255,255)
    if i==1 then
        r[i]:SetAnchor("TOPLEFT",0,ScreenHeight())
    else
        r[i]:SetAnchor("TOPLEFT",r[i-1],"BOTTOMLEFT",0,0)
    end
    r[i]:Show()
end
--]]
r2={}
local xoff = 4
local yoff = -4
for i=1,8 do
    yoff = - math.max((8+4*(i-1))/10,1)
    r2[i] = Region()
    r2[i]:SetHeight((8+4*(i-1))*1.47)
    r2[i]:SetWidth(ScreenWidth())
    r2[i].tl = r2[i]:TextLabel()
    r2[i].tl:SetOutline(2,math.max((8+4*(i-1))/10,1),255,0,0,255)
    r2[i].tl:SetFont(urfont2)
    r2[i].tl:SetFontHeight(8+4*(i-1))
    r2[i].tl:SetColor(255,60,60,190)
    r2[i].tl:SetLabel("A quick brown fox jumps over the lazy dog")
    r2[i].tl:SetShadowColor(0,0,0,190)
    r2[i].tl:SetShadowBlur(2.0)
    if i==1 then
        r2[i]:SetAnchor("TOPLEFT",0,ScreenHeight())
--        r2[i]:SetAnchor("TOPLEFT",r[8],"BOTTOMLEFT",0+xoff,-16+yoff)
    else
        r2[i]:SetAnchor("TOPLEFT",r2[i-1],"BOTTOMLEFT",0+xoff,0+yoff)
    end
    r2[i]:Show()
end
--[[
r3={}
for i=1,8 do
r3[i] = Region()
r3[i]:SetHeight((8+4*(i-1))*1.47)
r3[i]:SetWidth(ScreenWidth())
r3[i].tl = r3[i]:TextLabel()
r3[i].tl:SetFont(urfont2)
r3[i].tl:SetFontHeight(8+4*(i-1))
r3[i].tl:SetLabel("A quick brown fox jumps over the lazy dog")
r3[i].tl:SetColor(255,255,255,255)
r3[i].tl:SetShadowColor(0,0,0,190)
r3[i].tl:SetShadowBlur(2.0)
if i==1 then
r3[i]:SetAnchor("TOPLEFT",r[8],"BOTTOMLEFT",0,-16)
else
r3[i]:SetAnchor("TOPLEFT",r2[i-1],"BOTTOMLEFT",0,0)
end
r3[i]:Show()
end
--]]

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
