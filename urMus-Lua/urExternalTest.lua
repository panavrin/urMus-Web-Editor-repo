pageadd = Page()

SetPage(pageadd)

function DragMe(self,x,y,dx,dy)
--    SetPage(pageadd+1)
--    DPrint(x.." "..y)
    r2.anglespeed = (1-2*x/ScreenWidth())*6*math.pi
    r2.intensity = y/ScreenHeight()*255
--    SetPage(pageadd)
end

function DPageMe(self)
    DisplayExternalPage(pageadd+1)

end

function DPageMeNot(self)
    LinkExternalDisplay(true)
end

r = Region()
r:SetWidth(ScreenWidth())
r:SetHeight(ScreenHeight())
r.t = r:Texture("Steering.png")
r.t:SetSolidColor(255,0,0,255)
r.t:SetBlendMode("BLEND")
r:Show()
r:Handle("OnMove", DragMe)
r:EnableInput(true)
r:SetAnchor("CENTER",UIParent,"CENTER",0,0)
r:Handle("OnPageEntered", DPageMe)
r:Handle("OnPageLeft", DPageMeNot)

SetPage(pageadd+1)

function RotateMe(self,elapsed)
    r2.angle = r2.angle + elapsed * r2.anglespeed
    r2.t:SetRotation(r2.angle)
    r2.t:SetSolidColor(r2.intensity,r2.intensity,r2.intensity,255)
end

r2 = Region()
if ScreenWidth() > 320 then
    r2:SetWidth(512)
    r2:SetHeight(512)
else
    r2:SetWidth(256)
    r2:SetHeight(256)
end

r2.t = r2:Texture("Ornament1.png")
r2.t:SetBrushColor(0,0,0,0)
r2.t:SetBrushSize(3)
local p = r2.t:Width()-1
r2.t:Line(1,p,p,p)
r2.t:Line(p,1,p,p)
r2.t:Line(1,p,1,1)
r2.t:Line(p,1,1,1)
r2.t:SetBlendMode("BLEND")
r2.t:SetTiling()
r2.anglespeed = 2*math.pi
r2.intensity = 255
r2.angle = 0
r:Handle("OnUpdate",RotateMe)
r2:Show()

SetPage(pageadd)

DisplayExternalPage(pageadd+1)

function FlipPage2(self)
    LinkExternalDisplay(true)
    FlipPage(self)
end

pagebutton=Region('region', 'pagebutton', UIParent);
pagebutton:SetWidth(pagersize);
pagebutton:SetHeight(pagersize);
pagebutton:SetLayer("TOOLTIP");
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
--pagebutton:Handle("OnDoubleTap", FlipPage)
pagebutton:Handle("OnTouchDown", FlipPage2)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show();
