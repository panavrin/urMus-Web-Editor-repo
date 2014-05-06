FreeAllRegions()

local regions={}

local background = Region()
background:SetHeight(ScreenHeight()*6/7)
background:SetWidth(ScreenWidth())
background:EnableInput(true)
background:SetAnchor("TOPLEFT",UIParent,"TOPLEFT",0,0)
background:Texture(240,230,140,255)
background:Show()


function CheckBounds(self,elapsed)
    b = self:Bottom()
    l = self:Left()
    if self:Bottom()< menubar:Top()+10 then
        self:SetAnchor("BOTTOMLEFT",l,menubar:Top()+10)
    end 
    if self:Left()<10 then
        self:SetAnchor("BOTTOMLEFT",10,b)
    end
    if self:Right()>ScreenWidth()-10 then
        self:SetAnchor("BOTTOMRIGHT",ScreenWidth()-10,b)
    end
    if self:Top()> ScreenHeight()-10 then
--        DPrint("TOP")
        self:SetAnchor("TOPLEFT",UIParent,"TOPLEFT",l,-10)
    end
    for i=1, #regions do
        if regions[i]~= self and regions[i]:RegionOverlap(self) then
--            DPrint("Overlap")
        end
    end        
end

function DDisableMove(self)
--    DPrint("Lock")
    self:EnableMoving(false)
    self:EnableResizing(false)
    self:EnableInput(false)
end

function CreateRegionAt(x,y)
    local region
    region = Region()
    region:SetHeight(ScreenHeight()/4)
    region:SetWidth(ScreenHeight()/4)
    region:EnableMoving(true)
    region:EnableResizing(true)
    region:EnableInput(true)
    region:SetAnchor("CENTER", x, y)
    region.t=region:Texture(205,201,201,255)
    region:Show()
--    region:Handle("OnUpdate",CheckBounds)
    region:Handle("OnDoubleTap", DDisableMove)
    --region:EnableClamping(doEnableClamping(true))
    region:EnableClamping(true)
    region:SetClampRegion(10,menubar:Top()+10,ScreenWidth()-20, ScreenHeight()-menubar:Top()-20)
    table.insert(regions, region)
end     

function TouchDown(self)
--    DPrint("TD")
    local x,y = InputPosition()
    CreateRegionAt(x,y)
end

local backdrop = Region()
backdrop:SetWidth(ScreenWidth())
backdrop:SetHeight(ScreenHeight())
backdrop:SetLayer("BACKGROUND")
backdrop:SetAnchor('BOTTOMLEFT',0,0)
backdrop:Handle("OnTouchDown", TouchDown)

backdrop:EnableInput(true)


menubar = Region()
menubar:SetHeight(ScreenHeight()/7)
menubar:SetWidth(ScreenWidth())
menubar:EnableInput(true)
menubar:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
menubar:Texture(70,130,180,255)
menubar:Show()
menubar.tl = menubar:TextLabel()
menubar.tl:SetLabel("MENU")
menubar.tl:SetFontHeight(25)
menubar.tl:SetColor(0,0,0,255)
menubar.tl:SetHorizontalAlign("JUSTIFY")
--menubar:Handle("OnTouchDown",OpenMenu)​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​

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