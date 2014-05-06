
local random = math.random
function Paint(self,x,y,dx,dy)
--    local x,y = self.fingerposx, self.fingerposy
    self.texture:Line(x,y,x+dx,y+dy)
--    self.fingerposx = self.fingerposx + dx
--    self.fingerposy = self.fingerposy + dy
end

function BrushDown(self,x1,y1)

--    self.fingerposx = x1
--    self.fingerposy = y1
    self:Handle("OnMove",Paint)
end

function BrushUp(self)
    self:Handle("OnMove",nil)
end

function ToggleMovable(self)
    if self.moving then
        self:EnableMoving(false)
        self.texture:SetBrushColor(random(0,255),random(0,255),random(0,255),random(5,50))
        self.moving = nil
    else
        self:MoveToTop()
        self:EnableMoving(true)
        self.moving = true
    end
end

tilebackdropregion = {}
for y=1,2 do
    for x=1,2 do
        local i = (x-1)*2+y
        tilebackdropregion[i]=Region('region', 'tilebackdropregion[i]', UIParent)
        tilebackdropregion[i]:SetWidth(ScreenWidth()/2)
        tilebackdropregion[i]:SetHeight(ScreenHeight()/2)
        tilebackdropregion[i]:SetLayer("BACKGROUND")
        tilebackdropregion[i]:SetAnchor('BOTTOMLEFT',(x-1)*ScreenWidth()/2,(y-1)*ScreenHeight()/2)
        tilebackdropregion[i]:EnableClamping(true)
        tilebackdropregion[i]:EnableMoving(false)
        tilebackdropregion[i].texture = tilebackdropregion[i]:Texture();
        tilebackdropregion[i].texture:Clear(255,255,255,255);
        tilebackdropregion[i].texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
        tilebackdropregion[i].texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
 --       if ScreenWidth() == 320.0 then
 --           tilebackdropregion[i].texture:SetTexCoord(0,ScreenWidth()/2.0/256.0,ScreenHeight()/2.0/256.0,0.0);
 --       else
 --           tilebackdropregion[i].texture:SetTexCoord(0,ScreenWidth()/2.0/512.0,ScreenHeight()/2.0/512.0,0.0);
 --       end
        tilebackdropregion[i]:Handle("OnDoubleTap", ToggleMovable);
        tilebackdropregion[i]:Handle("OnTouchDown", BrushDown)
        tilebackdropregion[i]:Handle("OnTouchUp", BrushUp)
        tilebackdropregion[i]:Handle("OnEnter", BrushDown)
        tilebackdropregion[i]:Handle("OnLeave", BrushUp)
        tilebackdropregion[i]:EnableInput(true);
        tilebackdropregion[i]:Show();
        tilebackdropregion[i].texture:SetBrushColor(255,127,0,30)
        tilebackdropregion[i].fingerposx, tilebackdropregion[i].fingerposy = InputPosition()
        tilebackdropregion[i].fingerposx = tilebackdropregion[i].fingerposx*320.0/ScreenWidth() -- Converting texture to screen coordinates (requires for iPad as they mismatch there)
        tilebackdropregion[i].fingerposy = tilebackdropregion[i].fingerposy*480.0/ScreenHeight()
        tilebackdropregion[i].texture:Clear(255,255,255,128)
    end
end

brush1=Region('region','brush',UIParent)
brush1.t=brush1:Texture()
brush1.t:SetTexture("circlebutton-16.png");
brush1.t:SetSolidColor(127,0,0,15)
brush1:UseAsBrush();

brush1.t:SetBrushSize(32);

local pagebutton=Region('region', 'pagebutton', UIParent);
pagebutton:SetWidth(pagersize);
pagebutton:SetHeight(pagersize);
pagebutton:SetLayer("TOOLTIP");
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4);
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show();
