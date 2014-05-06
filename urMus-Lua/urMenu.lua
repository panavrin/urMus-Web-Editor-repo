-- urMenu.lua
-- Aaven Jin
-- June, 2011

MIN_WIDTH_MENU = 100
MAX_WIDTH_MENU = 200
MAX_NUM_MENU_OPT = 20
HEIGHT_MENU_OPT = 30

DPrint("Welcome to urMenu!")

function PictureRandomly(self)
    DPrint("in PictureRandomly")
    self.parent.caller.t:SetTexture(pics[math.random(1,5)])
end

function ColorRandomly(self)
    DPrint("in ColorRandomly")
    self.parent.caller.t:SetSolidColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end

function ClearToWhite(self)
    DPrint("in ClearToWhite")
    self.parent.caller.t:SetTexture(255,255,255,255) -- TODO original texture not removed
    self.parent.caller.t:SetSolidColor(255,255,255,255)
end

function RecycleSelf(self)
    DPrint("in RecycleSelf")
    self.parent.caller:EnableInput(false)
    self.parent.caller:EnableMoving(false)
    self.parent.caller:EnableResizing(false)
    self.parent.caller:Hide()

    CloseMenu(self)
    
end

function CloseMenu(self)
    DPrint("in CloseMenu")
    
    for i = 1,self.parent.num do
        self.parent[i]:EnableInput(false)
        self.parent[i]:Hide()
    end
end

Menu = {}
Menu.__index = Menu

function Menu:CreateOption(name,background,w,h,func)
    local opt = Region() -- TODO ?? local ??
    opt.parent = self
    opt.type = name
    opt.tl = opt:TextLabel()
    opt.tl:SetLabel(name)
    opt.tl:SetFontHeight(14)
    opt.tl:SetColor(0,0,0,255) 
    opt.tl:SetHorizontalAlign("JUSTIFY")
    opt.tl:SetShadowColor(255,255,255,255)
    opt.tl:SetShadowOffset(1,1)
    opt.tl:SetShadowBlur(1)
    opt:SetWidth(w)
    opt:SetHeight(h)
    opt.t = opt:Texture()
    opt.t:SetTexture(background) -- TODO how to fill rgb value
    opt.t:SetBlendMode("BLEND")
    opt:Handle("OnTouchUp",func)
    
    return opt
end

-- caller has width and height
function Menu.Create(region,background,optionList,funcionList,numOptions)
    
    if numOptions > MAX_NUM_MENU_OPT or numOptions <= 0 then
        return -1
    end
    
    local menu = {}
    setmetatable(menu,Menu)
    local w
    local h = HEIGHT_MENU_OPT
    menu.caller = region
    menu.num = numOptions
    menu.bkg = background
    
    w = MIN_WIDTH_MENU -- TODO temp value for w, should be a proper length against length of option desc
    if w < MIN_WIDTH_MENU then
        w = MIN_WIDTH_MENU
    elseif w > MAX_WIDTH_MENU then
         w = MAX_WIDTH_MENU
    end

    for i = 1,numOptions do
        -- create an option
        local opt = menu:CreateOption(optionList[i],background,w,h,funcionList[i])
        
        opt:SetAnchor("TOPLEFT",menu.caller,"TOPRIGHT",0,(1-i)*h)
        opt.parent[i] = opt
    end
    
    return menu
end


function OpenMenu(self)
    for i = 1,self.menu.num do
        self.menu[i]:Show()
        self.menu[i]:EnableInput(true)
    end
end

FreeAllRegions()

r = Region()
r.t = r:Texture(255,255,255,255)
r:EnableInput(true)
r:EnableMoving(true)
r:EnableResizing(true)
r:Show()

txt = {"Random pic","Random color","Clear","Remove","Cancel"}
pics = {"vinyl.png","Ornament1.png","Pirate1.png","Play.png","Right.png"}
tap = {PictureRandomly, ColorRandomly, ClearToWhite, RecycleSelf, CloseMenu}
menu = Menu.Create(r,"Sequence 01008.png",txt,tap,5)

r.menu = menu
r:Handle("OnDoubleTap",OpenMenu)


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

