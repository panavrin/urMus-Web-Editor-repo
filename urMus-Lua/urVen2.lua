-- urVen2.lua
-- Version 1
-- By Aaven Jin, July-August 2011
-- Version 2 
-- By Taylor Cronk, July-August 2012
-- University of Michigan Ann Arbor

-- A multipurpose non-programming environment aimed towards giving the user the ability
-- To create a increasingly more complex application without any coding on the users side.
-- The basis of the script is contained in this file while most of the features are contained
-- the accompianing scripts, listed below.


FreeAllRegions()
SetPage(38)
DPrint("Welcome to urVen2 V2.0 INDEV")
--------------Modular Scripts-----------------

dofile(SystemPath("urVen2_urKeyboard.lua"))
dofile(SystemPath("urVen2_urGradient.lua"))
dofile(SystemPath("urVen2_urMovingController.lua"))
dofile(SystemPath("urVen2_urMoving.lua"))
dofile(SystemPath("urVen2_urColorWheel.lua"))
dofile(SystemPath("urVen2_urPictureLoading.lua"))
dofile(SystemPath("urVen2_urMenu.lua"))
dofile(SystemPath("urVen2_urAnimation.lua"))
dofile(SystemPath("urVen2_urGeneration.lua"))
dofile(SystemPath("urVen2_urCollisions.lua"))
dofile(SystemPath("urVen2_urBackground.lua"))
dofile(SystemPath("urVen2_urProjectileController.lua"))
---------------- constants -------------------
MIN_WIDTH_MENU = 100
MAX_WIDTH_MENU = 200
WIDTH_MODE = 120
HEIGHT_LINE = 40
STICK_MARGIN = 20 -- auto-stick when two regions are within STICK_MARGIN

regions = {}
recycledregions = {}

auto_stick_enabled = 0

moving_default_speed = "8" -- 3 to 10, slow to fast
moving_default_dir = "45" -- direction by degree
boundary = {0,ScreenHeight(),0,ScreenWidth()} -- boundary coordinates to bounce from {minx,maxx,miny,maxy}
pboundary = {0,ScreenHeight(),0,ScreenWidth()} -- boundary coordinates for player regions to bounce from {minx,maxx,miny,maxy}

modes = {"EDIT","RELEASE"}
current_mode = modes[1]

global_text_senders = {}
global_text_receiver = -1 -- currently global_text_receiver allows only one receiver

SixteenPositions = {} -- SixteenPositions(p1)(p2): stickee:SetAnchor(p2,sticker,p1)
-- divide a region into 4 parts, divide the remaining space into 12 parts
-- used for auto-stick checking
function InitializeUrStick()  
    local k = 1
    for i = 1,4 do
        SixteenPositions[i] = {}
    end
    SixteenPositions[1][4] = {"TOPLEFT","BOTTOMRIGHT"}
    SixteenPositions[2][4] = {"TOPLEFT","BOTTOMLEFT"}
    SixteenPositions[3][4] = {"TOPRIGHT","BOTTOMRIGHT"}
    SixteenPositions[4][4] = {"TOPRIGHT","BOTTOMLEFT"}
    SixteenPositions[1][3] = {"TOPLEFT","TOPRIGHT"}
    SixteenPositions[2][3] = {"TOPLEFT","TOPLEFT"}
    SixteenPositions[3][3] = {"TOPRIGHT","TOPRIGHT"}
    SixteenPositions[4][3] = {"TOPRIGHT","TOPLEFT"}
    SixteenPositions[1][2] = {"BOTTOMLEFT","BOTTOMRIGHT"}
    SixteenPositions[2][2] = {"BOTTOMLEFT","BOTTOMLEFT"}
    SixteenPositions[3][2] = {"BOTTOMRIGHT","BOTTOMRIGHT"}
    SixteenPositions[4][2] = {"BOTTOMRIGHT","BOTTOMLEFT"}
    SixteenPositions[1][1] = {"BOTTOMLEFT","TOPRIGHT"}
    SixteenPositions[2][1] = {"BOTTOMLEFT","TOPLEFT"}
    SixteenPositions[3][1] = {"BOTTOMRIGHT","TOPRIGHT"}
    SixteenPositions[4][1] = {"BOTTOMRIGHT","TOPLEFT"}
end
InitializeUrStick()

----------- global helper functions ------------
function VSetTexture(v)
    v.t:SetSolidColor(v.r,v.g,v.b,v.a)
    if v.bkg ~= "" then
        v.t:SetTexture(v.bkg)
    end
    if v.r1 ~= nil then
        v.t:SetGradientColor("TOP",v.r1,v.g1,v.b1,v.a1,v.r2,v.g2,v.b2,v.a2)
        v.t:SetGradientColor("BOTTOM",v.r3,v.g3,v.b3,v.a3,v.r4,v.g4,v.b4,v.a4)
    end
end

function VVSetTexture(newv,oldv) -- copy oldv's texture and blendmode to newv
    newv.r = oldv.r
    newv.g = oldv.g
    newv.b = oldv.b
    newv.a = oldv.a
    newv.bkg = oldv.bkg
    newv.t:SetBlendMode(oldv.t:BlendMode())
    VSetTexture(newv)
end

function Highlight(r) -- change color to highlight when the given region r is tapped
    r.t:SetSolidColor(100,100,100,255)
end

function UnHighlight(r)
    r.t:SetSolidColor(200,200,200,255)
end

function DisableMove(vv)
    DPrint("lock")
    anchorv:Texture("lock.png")
    vv.fixed = 1
    vv:EnableMoving(false)
    vv:EnableResizing(false)
end

function EnableMove(vv)
    DPrint("unlock")
    anchorv:Texture("unlock.png")
    vv.fixed = 0
    vv:EnableMoving(true)
    vv:EnableResizing(true)
end


------------------ v1.backdrop ---------------------
function TouchDown(self)
    CloseSharedStuff(nil)
    
    local region = CreateorRecycleregion('region', 'backdrop', UIParent)
    local x,y = InputPosition()
    region:Show()
    region:SetAnchor("CENTER",x,y)
    DPrint(region:Name().." created, centered at "..x..", "..y)
end

function TouchUp(self)
    --    DPrint("MU")
end

function DoubleTap(self)
    --      DPrint("DT")
end

function Enter(self)
    --    DPrint("EN")
end

function Leave(self)
    --    DPrint("LV")
end

function Move(self,x,y,dx,dy) -- in release mode, when backdrop receives OnMove signal, it moves regions in backdrop's player list within pboundary
    local player_w = 0
    local player_h = 0
    if self.player["bottom"] ~= nil then
        player_w = self.player["bottom"]:Width()
        if x < pboundary[3] + player_w/2 then
            self.player["bottom"]:SetAnchor("BOTTOMLEFT",pboundary[3],pboundary[1])
        elseif x > pboundary[4] - player_w/2 then
            self.player["bottom"]:SetAnchor("BOTTOMRIGHT",pboundary[4],pboundary[1])
        else
            self.player["bottom"]:SetAnchor("BOTTOM",x,pboundary[1])
        end
    end
    
    if self.player["top"] ~= nil then
        player_w = self.player["top"]:Width()
        if x < pboundary[3] + player_w/2 then
            self.player["top"]:SetAnchor("TOPLEFT",pboundary[3],pboundary[2])
        elseif x > pboundary[4] - player_w/2 then
            self.player["top"]:SetAnchor("TOPRIGHT",pboundary[4],pboundary[2])
        else
            self.player["top"]:SetAnchor("TOP",x,pboundary[2])
        end
    end
    
    if self.player["left"] ~= nil then
        player_h = self.player["left"]:Height()
        if y < pboundary[1] + player_h/2 then
            self.player["left"]:SetAnchor("BOTTOMLEFT",pboundary[3],pboundary[1])
        elseif y > pboundary[2] - player_h/2 then
            self.player["left"]:SetAnchor("TOPLEFT",pboundary[3],pboundary[2])
        else
            self.player["left"]:SetAnchor("LEFT",pboundary[3],y)
        end
    end
    
    if self.player["right"] ~= nil then
        player_h = self.player["right"]:Height()
        if y < pboundary[1] + player_h/2 then
            self.player["right"]:SetAnchor("BOTTOMRIGHT",pboundary[4],pboundary[1])
        elseif y > pboundary[2] - player_h/2 then
            self.player["right"]:SetAnchor("TOPRIGHT",pboundary[4],pboundary[2])
        else
            self.player["right"]:SetAnchor("RIGHT",pboundary[4],y)
        end
    end
end

backdrop = Region('region', 'backdrop', UIParent)
backdrop:SetWidth(ScreenWidth())
backdrop:SetHeight(ScreenHeight())
--backdrop:SetBlendMode("MOD")
backdrop:SetLayer("BACKGROUND")
backdrop:SetAnchor('BOTTOMLEFT',0,0)
backdrop:Handle("OnTouchDown", TouchDown)
backdrop:Handle("OnTouchUp", TouchUp)
backdrop:Handle("OnDoubleTap", DoubleTap)
backdrop:Handle("OnEnter", Enter)
backdrop:Handle("OnLeave", Leave)
backdrop:Handle("OnMove",nil)
backdrop:EnableInput(true)
backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
backdrop:EnableClipping(true)
backdrop.player = {} -- store the ids of player regions that need backdrop's OnMove signal

---------------- v2.notification component set -------------------
-- TODO i tried with ShowNotification(note) but nothing shows up
function FadeNotification(self, elapsed)
    if self.staytime > 0 then
        self.staytime = self.staytime - elapsed
        return
    end
    if self.fadetime > 0 then
        self.fadetime = self.fadetime - elapsed
        self.alpha = self.alpha - self.alphaslope * elapsed
        self:SetAlpha(self.alpha)
    else
        self:Hide()
        self:Handle("OnUpdate", nil)
    end
end

function ShowNotification(note)
    notificationregion.textlabel:SetLabel(note)
    notificationregion.staytime = 1.5
    notificationregion.fadetime = 2.0
    notificationregion.alpha = 1
    notificationregion.alphaslope = 2
    notificationregion:Handle("OnUpdate", FadeNotification)
    notificationregion:SetAlpha(1.0)
    notificationregion:Show()
end

local notificationregion=Region('region', 'notificationregion', UIParent)
notificationregion:SetWidth(ScreenWidth())
notificationregion:SetHeight(48*2)
notificationregion:SetLayer("TOOLTIP")
notificationregion:SetAnchor('BOTTOMLEFT',0,ScreenHeight()/2-24) 
notificationregion:EnableClamping(true)
notificationregion:Show()
notificationregion.textlabel=notificationregion:TextLabel()
notificationregion.textlabel:SetFont("Trebuchet MS")
notificationregion.textlabel:SetHorizontalAlign("CENTER")
notificationregion.textlabel:SetLabel("")
notificationregion.textlabel:SetFontHeight(48)
notificationregion.textlabel:SetColor(255,255,255,190)

----------- v3.hold button -------------
-- enable to select multiple regions for the same menu option
function HoldButtonHold(self)
    self.held = 1
    DPrint("Hold button is ON. You can select multiple regions now.")
end 

function HoldButtonRelease(self)
    self.held = 0
    DPrint("Hold button is OFF.")
end

hold_button = Region('region','hold',UIParent)
hold_button:Texture(200,200,200,255)
hold_button:SetHeight(HEIGHT_LINE)
hold_button:SetWidth(WIDTH_MODE)
hold_button.tl = hold_button:TextLabel()
hold_button.tl:SetLabel("HOLD")
hold_button.tl:SetFontHeight(26)
hold_button.tl:SetColor(0,0,0,255)
hold_button:Handle("OnTouchDown",HoldButtonHold)
hold_button:Handle("OnTouchUp",HoldButtonRelease)
hold_button:Handle("OnLeave",HoldButtonRelease)
hold_button:SetAnchor("LEFT",UIParent,"LEFT")
hold_button.held = 0



------------ v4.Menu class -------------
Menu = {}
Menu.__index = Menu
function Menu:OpenMenu() 
    if self.open == 0 then
        for i = 1,self.num do
            self[i]:EnableInput(true)
            self[i]:MoveToTop()
            self[i]:Show()
--            self[i].t:SetTexture(200,200,200,255)
        end
        self.open = 1
    end
end

function Menu:CloseMenu() 
    if self.open == 1 then
        for i = 1,self.num do
            self[i]:Hide()
            self[i]:EnableInput(false)
        end
        
        if self.openopt ~= -1 then
            if #self[self.openopt].menu > 0 then
                self[self.openopt].menu:CloseMenu()
            end
            
            self.openopt = -1
        end
        self.open = 0
    end
end

function Menu:MoveMenuToTop() 
    if self.open == 1 then
        for i = 1,self.num do
            self[i]:MoveToTop()
            if #self[i].menu > 0 then
                if self[i].menu.open == 1 then
                    self[i].menu:MoveMenuToTop()
                end
            end
        end
    end
end

function OpenOrCloseMenu(v)
    DPrint(v.tl:Label())
    if v.menu.open == 0 then
        v.backupfunc(v,v.boss.v)
        v.menu:OpenMenu()
    else 
        v.menu:CloseMenu()
    end
end

function OptEventFunc(self)
    Highlight(self)
    -- first close other opened menu options
    if self.parent.openopt ~= self.k and self.parent.openopt ~= -1 and #self.parent[self.parent.openopt].menu > 0 then
        self.parent[self.parent.openopt].menu:CloseMenu()
    end
    
    self.parent.openopt = self.k
    if self.func == OpenOrCloseMenu then -- when there is sub-menu
        OpenOrCloseMenu(self)
    else
        for k,i in pairs (self.boss.selectedregions) do
            self.func(self,regions[i])
        end
    end
end

function Menu:CreateOption(pair) -- pair: see how function_list and each menu are created
    local opt = Region() 
    opt.parent = self
    opt.menu = {}
    opt.boss = self.caller.boss
    opt.tl = opt:TextLabel()
    opt.tl:SetLabel(pair[1])
    opt.tl:SetFontHeight(16)
    opt.tl:SetColor(0,0,0,255) 
    opt.tl:SetHorizontalAlign("JUSTIFY")
    opt.tl:SetShadowColor(255,255,255,255)
    opt.tl:SetShadowOffset(1,1)
    opt.tl:SetShadowBlur(1)
    opt:SetWidth(self.w)
    opt:SetHeight(self.h)
    opt.t = opt:Texture(200,200,200,255)
    if self.bkg ~= "" then
        opt.t:SetTexture(self.bkg)
    end
    opt.t:SetBlendMode("BLEND")
    opt.backupfunc = pair[2]
    
    if #pair[3] > 0 then
        opt.menu = Menu.Create(opt,"",pair[3],"TOPLEFT","TOPRIGHT")
        opt.func = OpenOrCloseMenu
    else
        opt.func = pair[2]
    end
    opt:Handle("OnTouchDown",OptEventFunc)
    opt:Handle("OnTouchUp",UnHighlight)
    opt:Handle("OnLeave",UnHighlight)
    
    return opt
end

function Menu.Create(region,background,list,anchor,relanchor) 
    -- list: see how function_list and each menu are created
    -- anchor and relanchor are anchor positions for the menu relative to region
    local menu = {}
    setmetatable(menu,Menu)
    menu.w = MIN_WIDTH_MENU
    menu.h = HEIGHT_LINE
    menu.caller = region
    menu.bkg = background
    menu.open = 0
    menu.list = list
    menu.num = #list
    menu.openopt = -1
    
    local len = 0
    for i = 1,menu.num do
        if len < string.len(list[i][1]) then
            len = string.len(list[i][1])
        end
    end
    
    if len >= 20 then -- too long a name will be cut
        menu.w = MAX_WIDTH_MENU
    elseif len > 10 then
        menu.w = len*10
    end
    
    menu[1] = menu:CreateOption(list[1])
    menu[1].k = 1
    menu[1]:SetAnchor(anchor,menu.caller,relanchor)
    menu[1]:Hide()
    
    for i = 2,menu.num do
        menu[i] = menu:CreateOption(list[i])
        menu[i].k = i
        menu[i]:SetAnchor("BOTTOMLEFT",menu[i-1],"TOPLEFT")
        menu[i]:Hide()
    end
    
    return menu
end

------------- menu helper functions and events --------------
text_size_list = {"8","10","12","14","16","20","24","28","32","36"}
text_position_list = {"top left","top center","top right","middle left","centered","middle right","bottom left","bottom center","bottom right"}
text_position_hor_list = {"LEFT","CENTER","RIGHT","LEFT","CENTER","RIGHT","LEFT","CENTER","RIGHT"}
text_position_ver_list = {"TOP","TOP","TOP","MIDDLE","MIDDLE","MIDDLE","BOTTOM","BOTTOM","BOTTOM"}
blend_mode_list = {"DISABLED", "BLEND", "ALPHAKEY", "ADD", "MOD", "SUB"}

function Unstick(v)
    output = ""
    local er = v.sticker
    local id = v.id
    local flag = 0
    if er ~= -1 then -- it is sticked to other
        output = output.."R#"..v.sticker.." releases "..v:Name()..". "
        for k,ee in pairs(regions[er].stickee) do
            if ee == id then
                table.remove(regions[er].stickee,k)
            end
        end
        v.sticker = -1
        v:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
        EnableMove(v)
        v:EnableInput(true)
        v:EnableResizing(true)
        v.group = id
        flag = 1
    end
    if (#v.stickee > 0) then
        output = output.." "..v:Name().." releases"
        flag = 1
        for k,ee in pairs(v.stickee) do -- other is sticked to it
            output = output.." R#"..ee
            regions[ee].sticker = -1
            regions[ee]:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
            EnableMove(regions[ee])
            regions[ee]:EnableInput(true)
            regions[ee]:EnableResizing(true)
            regions[ee].group = regions[ee].id
        end
        while #v.stickee > 0 do
            table.remove(v.stickee)
        end
    end
    
    if flag == 0 then
        DPrint("Nothing to unstick for "..v:Name())
    else
        DPrint(output)
    end
end

function TouchObject(r,other) -- when r is moving, check whether r is about to touch the "other"
    -- if yes, let r touch the "other", and change dx or dy and r's moving direction
    local bb = r:Bottom() + r.dy
    local tt = r:Top() + r.dy
    local ll = r:Left() + r.dx
    local rr = r:Right() + r.dx
    local b2 = other:Bottom()
    local t2 = other:Top()
    local l2 = other:Left()
    local r2 = other:Right()
    
    if (l2 < ll and ll < r2 or l2 < rr and rr < r2) and (b2 < tt and tt < t2 or b2 < bb and bb < t2) then
        -- two regions is about to overlap
        if bb <= t2 and tt >= t2 and r:Bottom() >= t2 then
            -- DPrint("bottom")
            r.y = r.y + t2 - bb + r.dy
            r.dy = math.abs(r.dy)
            r.touch = "bottom"
            if r.dx < 0 then
                r.dir = (r.dir - 90)%360
            elseif r.dx > 0 then
                r.dir = (r.dir + 90)%360
            else
                r.dir = (r.dir - 180)%360
            end
        elseif ll <= r2 and rr >= r2 and r:Left() >= r2 then
            -- DPrint("left")
            r.x = r.x + r2 - ll + r.dx
            r.dx = math.abs(r.dx)
            r.touch = "left"
            if r.dy < 0 then
                r.dir = (r.dir + 90)%360
            elseif r.dy > 0 then
                r.dir = (r.dir - 90)%360
            else
                r.dir = (r.dir - 180)%360
            end
        elseif tt >= b2 and bb <= b2 and r:Top() <= b2 then
            -- DPrint("top")
            r.y = r.y + b2 - tt + r.dy
            r.dy = -math.abs(r.dy)
            r.touch = "top"
            if r.dx < 0 then
                r.dir = (r.dir + 90)%360
            elseif r.dx > 0 then
                r.dir = (r.dir - 90)%360
            else
                r.dir = (r.dir - 180)%360
            end
        elseif rr >= l2 and ll <= l2 and r:Right() <= l2 then
            -- DPrint("right")
            r.x = r.x + l2- rr + r.dx
            r.dx = -math.abs(r.dx)
            r.touch = "right"
            if r.dy < 0 then
                r.dir = (r.dir - 90)%360
            elseif r.dy > 0 then
                r.dir = (r.dir + 90)%360
            else
                r.dir = (r.dir - 180)%360
            end
        end
    end
end

function TouchBound(r) -- when r is moving, check whether r is about to touch its bound
    -- if yes, let r touch the bound, and change dx or dy and r's moving direction
    if r:Bottom() + r.dy <= r.bound[1] then
        -- DPrint("bottom")
        r.y = r.y + r.bound[1] - r:Bottom()
        r.dy = math.abs(r.dy)
        r.touch = "bottom"
        if r.dx < 0 then
            r.dir = (r.dir - 90)%360
        elseif r.dx > 0 then
            r.dir = (r.dir + 90)%360
        else
            r.dir = (r.dir - 180)%360
        end
    elseif r:Left() + r.dx <= r.bound[3] then
        -- DPrint("left")
        r.x = r.x + r.bound[3] - r:Left()
        r.dx = math.abs(r.dx)
        r.touch = "left"
        if r.dy < 0 then
            r.dir = (r.dir + 90)%360
        elseif r.dy > 0 then
            r.dir = (r.dir - 90)%360
        else
            r.dir = (r.dir - 180)%360
        end
    elseif r:Top() + r.dy >= r.bound[2] then
        -- DPrint("top")
        r.y = r.y + r.bound[2] - r:Top()
        r.dy = -math.abs(r.dy)
        r.touch = "top"
        if r.dx < 0 then
            r.dir = (r.dir + 90)%360
        elseif r.dx > 0 then
            r.dir = (r.dir - 90)%360
        else
            r.dir = (r.dir - 180)%360
        end
    elseif r:Right() + r.dx >= r.bound[4] then
        -- DPrint("right")
        r.x = r.x + r.bound[4] - r:Right()
        r.dx = -math.abs(r.dx)
        r.touch = "right"
        if r.dy < 0 then
            r.dir = (r.dir - 90)%360
        elseif r.dy > 0 then
            r.dir = (r.dir + 90)%360
        else
            r.dir = (r.dir - 180)%360
        end
    end
end



function SelfColor(self,e)
    self.colortime = self.colortime - e
    if self.colortime <= 0 then
        self.r = math.random(0,255)
        self.g = math.random(0,255)
        self.b = math.random(0,255)
        self.a = math.random(0,255)
        VSetTexture(self)
        self.colortime = 1
    end
end

function TextSharing(self)
    if self.is_text_sender == 1 then
        if self.text_sharee ~= -1 then
            regions[self.text_sharee].text_sharee = self.id
            regions[self.text_sharee].tl:SetLabel(self.tl:Label())
        end
    end
end



------------------- v5.menu function list ------------------
-- function_list[i] = {"menubar option label", {func_list}} where func_list:
-- func_list[i] = {"menu option label", event, {func_list for sub-menu}
function_list = {}

function_list[1] = {"Basics", {
        {"About",MenuAbout,{}},
        {"Load Picture",loadPicture,{}},       
        {"Random Gradient", MenuGradientRandom,{}},
        {"Random Color",MenuColorRandomly,{}},
        {"Clear Background",MenuClearToWhite,{}},
        {"Unstick",MenuUnstick,{}},
        {"Remove",MenuRecycleSelf,{}}
    }
}

function_list[2] = {"Edit", {
        {"Color Wheel",MenuChangeColor,{}},
        {"Gradient Selection",menuGradient,{}},
        {"Transparency",MenuTransparency,{
                {blend_mode_list[1],MenuBlendMode,{}},
                {blend_mode_list[2],MenuBlendMode,{}},
                {blend_mode_list[3],MenuBlendMode,{}},
                {blend_mode_list[4],MenuBlendMode,{}},
                {blend_mode_list[5],MenuBlendMode,{}},
                {blend_mode_list[6],MenuBlendMode,{}}
            }},
        {"Text Position",MenuText,{
                {text_position_list[1],MenuTextPosition,{}},
                {text_position_list[2],MenuTextPosition,{}},
                {text_position_list[3],MenuTextPosition,{}},
                {text_position_list[4],MenuTextPosition,{}},
                {text_position_list[5],MenuTextPosition,{}},
                {text_position_list[6],MenuTextPosition,{}},
                {text_position_list[7],MenuTextPosition,{}},
                {text_position_list[8],MenuTextPosition,{}},
                {text_position_list[9],MenuTextPosition,{}}
            }},
        {"Text Font",MenuText,{
                {text_size_list[1],MenuTextSize,{}},
                {text_size_list[2],MenuTextSize,{}},
                {text_size_list[3],MenuTextSize,{}},
                {text_size_list[4],MenuTextSize,{}},
                {text_size_list[5],MenuTextSize,{}},
                {text_size_list[6],MenuTextSize,{}},
                {text_size_list[7],MenuTextSize,{}},
                {text_size_list[8],MenuTextSize,{}},
                {text_size_list[9],MenuTextSize,{}},
                {text_size_list[10],MenuTextSize,{}}
            }},
        {"Clear Text",MenuClearText,{}},
        {"Duplicate",MenuDuplicate,{}}
    }
}

function_list[3] = {"Advanced", {
        {"Animation",MenuAnimation,{}},
        {"Generation Off",MenuGenerationOff,{}},
        {"Generation",MenuGeneration,{}},
        {"Projectile Controller",MenuProjectileController,{
                {"Left",MenuProjLeft,{}},
                {"Right",MenuProjRight,{}},
                {"Top",MenuProjUp,{}},
                {"Bottom",MenuProjDown,{}}
            }},
        {"Collisions",MenuCollisions,{}},
        {"Move",MenuMoving,{}},
        {"Self Fly",MenuSelfFly,{}},
        {"Self Show and Hide",MenuSelfShowHide,{}},
        {"Self Change Color",MenuSelfColor,{}},
        {"Stick to Boundery",MenuStickBoundary,{
                {"Left",MenuStartPlayerLeft,{}},
                {"Right",MenuStartPlayerRight,{}},
                {"Top",MenuStartPlayerTop,{}},
                {"Bottom",MenuStartPlayerBottom,{}}
            }},
        {"Add Moving Controller",MenuMoveController,{
                {"Left",MenuControllerLeft,{}},
                {"Right",MenuControllerRight,{}},
                {"Top",MenuControllerUp,{}},
                {"Bottom",MenuControllerDown,{}}
            }},
        {"Global Text Sharing",MenuGlobalTextSharing,{
                {"Set as Sender",MenuSetGlobalTextSender,{}},
                {"Set as Receiver",MenuSetGlobalTextReceiver,{}}
            }}
    }
}

function_list[4] = {"Global Control", {
        {"Autostick Control",MenuStickControl,{}},
        {"Keyboard Control",MenuKeyboardControl,{}},
        {"BackGround Control",MenuBackGround,{}},
        {"FPS Control", MenuFPS,{}}
            
    }
}

--function_list[5] = {"Test"}


------------ v6.global menubar -------------
function OpenOrCloseMenubarItemEvent(self) -- call by menubar[i]
    local bar = self.boss
    DPrint(self.tl:Label())
    if self.menu.open == 0 then
        if bar.openmenu ~= -1 then
            bar[bar.openmenu].menu:CloseMenu()
        end
        bar.openmenu = self.k
        self.menu:OpenMenu()
    else 
        bar.openmenu = -1
        self.menu:CloseMenu()
    end
end

local menubar = {}
menubar.menus = function_list
menubar.v = nil -- caller v
menubar.openmenu = -1
menubar.show = 0
menubar.selectedregions = {}

for k,name in pairs (menubar.menus) do
    local r = Region('region','menu',UIParent)
    r.tl = r:TextLabel()
    r.tl:SetLabel(menubar.menus[k][1])
    r.tl:SetFontHeight(18)
    r.tl:SetColor(0,0,0,255) 
    r.tl:SetHorizontalAlign("JUSTIFY")
    r.tl:SetShadowColor(255,255,255,255)
    r.tl:SetShadowOffset(1,1)
    r.tl:SetShadowBlur(1)
    r.t = r:Texture(250,250,250,255)
    r.k = k
    r.boss = menubar
    r.menu = Menu.Create(r,"",menubar.menus[k][2],"BOTTOMLEFT","TOPLEFT")
    r:SetWidth((ScreenWidth()-2*HEIGHT_LINE)/#menubar.menus)
    r:SetHeight(HEIGHT_LINE)
    r:EnableInput(false)
    r:EnableMoving(false)
    r:EnableResizing(false)
    r:Handle("OnTouchDown",OpenOrCloseMenubarItemEvent)
    menubar[k] = r
end

menubar[1]:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT")
for i=2,#menubar do
    menubar[i]:SetAnchor("LEFT",menubar[i-1],"RIGHT")
    menubar[i]:Hide()
end
menubar[1]:Hide()

------------ v7.edit/release mode --------------
function ChangeMode(self)
    if current_mode == modes[1] then
        current_mode = modes[2]
        CloseSharedStuff(nil)
        backdrop:Handle("OnMove",Move)
        backdrop:Handle("OnTouchDown",nil)
        anchorv:Hide()
        anchorv:EnableInput(false)
        DPrint("mode: RELEASE")
    else 
        current_mode = modes[1]
        CloseSharedStuff(nil)
        backdrop:Handle("OnMove",nil)
        backdrop:Handle("OnTouchDown",TouchDown)
        anchorv:Hide()
        anchorv:EnableInput(true)
        DPrint("mode: EDIT")
    end
    self.tl:SetLabel(current_mode)
end

local moderegion = Region('region','mode',UIParent) -- gessl: if this is global weird things happen on iPad1s. Mysterious bug somewhere!
moderegion:Texture(200,200,200,255)
moderegion:SetHeight(HEIGHT_LINE)
moderegion:SetWidth(WIDTH_MODE)
moderegion.tl = moderegion:TextLabel()
moderegion.tl:SetLabel(current_mode)
moderegion.tl:SetFontHeight(26)
moderegion.tl:SetColor(0,0,0,255)
moderegion:EnableInput(true)
moderegion:Handle("OnDoubleTap",ChangeMode)
moderegion:SetAnchor("TOPLEFT",UIParent,"TOPLEFT")
moderegion:Show()


------------- v8.trashbin -------------
local trashbin = Region('region','trashbin',UIParent)
trashbin.t = trashbin:Texture("trashbin.png")
trashbin:SetWidth(2*HEIGHT_LINE)
trashbin:SetHeight(2*HEIGHT_LINE)
trashbin:SetAnchor("BOTTOMRIGHT",UIParent,"BOTTOMRIGHT")
trashbin.yes = 0

function MoveToTrashbin(v)
    RemoveV(v)
    CloseMenuBar()
end

-------------- v9.anchorv --------------
-- shows on each created region, click to un/lock region's position
function LockOrUnlock(self)
    if anchorv.caller.fixed == 1 then
        if self.caller.sticker ~= -1 then
            DPrint(self.caller:Name().." is sticked to R#"..self.caller.sticker..". Go to Menubar->Basics->Unstick.")
        else
            EnableMove(self.caller)
        end
    else
        DisableMove(self.caller)
    end
end

anchorv = Region('region','anchor',UIParent)
anchorv:EnableInput(true)
anchorv:Handle("OnTouchDown",LockOrUnlock)
anchorv:SetWidth(30)
anchorv:SetHeight(30)
anchorv.caller = nil


----------- v10. events --------------
function CloseMenubarHelper()
    if menubar.show == 1 then
        for i = 1,#menubar do
            menubar[i]:Hide()
            menubar[i]:EnableInput(false)
        end
        menubar.show = 0
        backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
    end
end

function CloseMenuBar(self)
    if menubar.openmenu ~= -1 then
        menubar[menubar.openmenu].menu:CloseMenu()
        menubar.openmenu = -1 
    end
    CloseMenubarHelper()
    menubar.v = nil
    hold_button:Hide()
    hold_button:EnableInput(false)
end

function OpenMenuBar(self)
    if menubar.show == 0 then
        for i = 1,#menubar do
            menubar[i]:Show()
            menubar[i]:EnableInput(true)
            menubar[i]:MoveToTop()
        end
        menubar.v = self
        
        while #menubar.selectedregions > 0 do
            regions[menubar.selectedregions[1]].selected = 0
            table.remove(menubar.selectedregions,1)
        end
        table.insert(menubar.selectedregions,self.id)
        self.selected = 1
        menubar.show = 1
        CloseColorWheel(color_wheel)
        mykb:Hide()
        backdrop:SetClipRegion(0,HEIGHT_LINE,ScreenWidth(),ScreenHeight())
        hold_button:Show()
        hold_button:MoveToTop()
        hold_button:EnableInput(true)
    end
end

function SelectObj(self)
    local op = self:Name().." selected. "
    if self.sticker ~= -1 then
        op = self:Name().." is sticked to R#"..self.sticker..". "
    end
    if hold_button.held == 0 then
        DPrint(op.."LongTap to open menubar.")
        self:MoveToTop()
    else
        if self.id ~= nil then
            if self.selected == 0 then
                table.insert(menubar.selectedregions,self.id)
                self.selected = 1
                DPrint(op)
            else
                DPrint(self:Name().." already selected.")
            end
        end
    end
end

function StickToClosestAnchorPoint(ee,er)
    local hw = er:Width()/2
    local hh = er:Height()/2
    local eex,eey = ee:Center()
    local erx = er:Left()
    local ery = er:Bottom()
    local dx = math.ceil((eex - erx)/hw) + 1
    local dy = math.ceil((eey - ery)/hh) + 1
    if dx > 4 then dx = 4 end
    if dx < 1 then dx = 1 end
    if dy > 4 then dy = 4 end
    if dy < 1 then dy = 1 end
    
    ee:SetAnchor(SixteenPositions[dx][dy][2],er,SixteenPositions[dx][dy][1])
    table.insert(er.stickee,ee.id)
    ee.sticker = er.id
    ee.group = er.group
    DisableMove(ee)
    
    output = SixteenPositions[dx][dy][1].."+"..SixteenPositions[dx][dy][2].." new stickee "..ee:Name().."! sticker "..er:Name().." now has stickees: "
    for i = 1,#er.stickee do
        output = output.." R#"..er.stickee[i]
    end
    DPrint(output)
end

function AutoCheckStick(self)
    if auto_stick_enabled == 1 and self.sticker == -1 then
        local x,y = self:Center()
        self.large:SetWidth(self:Width() + STICK_MARGIN * 2)
        self.large:SetHeight(self:Height() + STICK_MARGIN * 2)
        
        for i = 1,#regions do -- v is sticker, self is stickee
            local v = regions[i]
            if v ~= self and v.usable == 1 then
                -- DPrint("there are other regions")
                if v.sticker ~= self.id and self.sticker ~= v.id and v.group ~= self.group then
                    -- DPrint("there are other regions to stick to")
                    if v:RegionOverlap(self.large) then
                        -- DPrint("they overlap")
                        if not v:RegionOverlap(self) then
                            StickToClosestAnchorPoint(self,v)
                        end
                    end
                end
            end
        end
    end
end

function CloseSharedStuff(self) -- argument can be nil for global use
    if hold_button.held == 0 then
        -- close menubar
        CloseMenuBar()
    end
    
    -- close keyboard
    if self ~= mykb.typingarea then
        mykb:Hide()
    end
    
    -- close color wheel
    color_wheel:Hide()
    color_wheel:EnableInput(false)
    
end

function AddAnchorIcon(self)
    if self.fixed == 1 then
        anchorv:Texture("lock.png")
    else
        anchorv:Texture("unlock.png")
    end
    anchorv:SetAnchor("TOPLEFT",self,"TOPLEFT")
    anchorv:MoveToTop()
    anchorv:Show()
    anchorv.caller = self
end

function BeBouncedObject(self) -- add self.id to mydialog.bounceobjects or bounceremoveobjects list with no duplicates
    if self.id == mydialog.caller.id then
        DPrint("Please select objects other than "..mydialog.caller:Name())
        return
    end
    local found1 = 0 -- bounceobjects
    local found2 = 0 -- bounceremoveobjects
    for i = 1,#mydialog.bounceremoveobjects do
        if mydialog.bounceremoveobjects[i] == self.id then
            found2 = 1
            break
        end
    end
    if found2 == 0 then
        for i = 1,#mydialog.bounceobjects do
            if mydialog.bounceobjects[i] == self.id then
                found1 = 1
                break
            end
        end
    end
    
    if found1 == 0 and found2 == 0 then
        if mydialog.bouncetype == 0 then
            table.insert(mydialog.bounceobjects,self.id)
            mydialog[3][2].tl:SetLabel(mydialog[3][2].tl:Label().." #"..self.id)
            mydialog.bounceobjects.dirty = 1
            DPrint(self:Name().." selected to bounceobjects")
        else
            table.insert(mydialog.bounceremoveobjects,self.id)
            mydialog[4][2].tl:SetLabel(mydialog[4][2].tl:Label().." #"..self.id)
            mydialog.bounceremoveobjects.dirty = 1
            DPrint(self:Name().." selected to bounceremoveobjects")
        end
    else 
        DPrint(self:Name().." already selected.")
    end
end

function OverlapTrashbinEvent(self) -- event to check whether self overlaps with trashbin
    if self:RegionOverlap(trashbin) then 
        DPrint("Release and remove "..self:Name())
        self.t:SetTexture(255,0,0,250)
        trashbin.yes = 1
    else
        DPrint("To remove "..self:Name()..", move it to bottomright corner")
        VSetTexture(self)
        trashbin.yes = 0
    end
end

function HoldToTrigger(self, elapsed) -- for long tap
    x,y = self:Center()
    
    if self.holdtime <= 0 then
        self.x = x 
        self.y = y
        DPrint("Menu Opened. Use HOLD to select multiple Vs.")
        OpenMenuBar(self)
        trashbin:Show()
        trashbin:MoveToTop()
        self:Handle("OnUpdate",nil)
        self:Handle("OnUpdate",OverlapTrashbinEvent)
    else 
        if math.abs(self.x - x) > 10 or math.abs(self.y - y) > 10 then
            self:Handle("OnUpdate",nil)
            self:Handle("OnUpdate",VUpdate)
        end
        self.holdtime = self.holdtime - elapsed
    end
end

function HoldTrigger(self) -- for long tap
    self.holdtime = 0.5
    self.x,self.y = self:Center()
    self:Handle("OnUpdate",nil)
    self:Handle("OnUpdate",HoldToTrigger)
    self:Handle("OnLeave",DeTrigger)
end

function DeTrigger(self) -- for long tap
    self.eventlist["OnUpdate"].currentevent = nil
    self:Handle("OnUpdate",nil)
    self:Handle("OnUpdate",VUpdate)
    
    if trashbin.yes == 1 then
        MoveToTrashbin(self)
        trashbin.yes = 0
    end
    if trashbin:IsShown() then
        trashbin:Hide()
    end
end

function CallEvents(signal,vv)
    local list = {}
    if current_mode == modes[1] then
        list = vv.eventlist[signal]
    else
        list = vv.reventlist[signal]
    end
    for k = 1,#list do
        list[k](vv)
    end
end

function VDoubleTap(self)
    CallEvents("OnDoubleTap",self)
end

function VTouchUp(self)
    CallEvents("OnTouchUp",self)
end

function VTouchDown(self)
    if mydialog.ready == 1 and current_mode == modes[1] then
        BeBouncedObject(self)
    elseif coldialog.ready == 1 and current_mode == modes[1] then
        CollisionObject(self)
        
        
    else
        CallEvents("OnTouchDown",self)
    end
end

function VUpdate(self,e)
    if current_mode == modes[1] then
        if self.eventlist["OnUpdate"].currentevent ~= nil then
            self.eventlist["OnUpdate"].currentevent(self,e)
        end
    else
        for k = 1,#self.eventlist["OnUpdate"] do
            self.eventlist["OnUpdate"][k](self,e)
        end
    end
end

function PlainVRegion(r) -- customized parameter initialization of region, events are initialized in VRegion()
    r.selected = 0 -- for multiple selection of menubar
    r.kbopen = 0 -- for keyboard isopen
    
    -- initialize for events and signals
    r.eventlist = {}
    r.eventlist["OnTouchDown"] = {HoldTrigger,CloseSharedStuff,SelectObj,AddAnchorIcon}
    r.eventlist["OnTouchUp"] = {AutoCheckStick,DeTrigger} 
    r.eventlist["OnDoubleTap"] = {CloseSharedStuff,OpenOrCloseKeyboard} 
    r.eventlist["OnUpdate"] = {} 
    r.eventlist["OnUpdate"]["selfshowhide"] = 0
    r.eventlist["OnUpdate"]["selfcolor"] = 0
    r.eventlist["OnUpdate"]["move"] = 0
    r.eventlist["OnUpdate"]["animate"] = 0
    r.eventlist["OnUpdate"]["generate"] = 0
    r.eventlist["OnUpdate"]["collision"] = 0
    r.eventlist["OnUpdate"]["background"] = 0
    r.eventlist["OnUpdate"]["projectile"] = 0
    r.eventlist["OnUpdate"]["fps"] = 0
    r.eventlist["OnUpdate"].currentevent = nil
    r.reventlist = {} -- eventlist for release mode
    r.reventlist["OnTouchDown"] = {}
    r.reventlist["OnTouchUp"] = {AutoCheckStick} 
    r.reventlist["OnDoubleTap"] = {OpenOrCloseKeyboard}
    
    -- auto stick
    r.group = r.id
    r.sticker = -1
    r.stickee = {}
    r.large = Region()
    r.large:SetAnchor("CENTER",r,"CENTER")
    
    -- Initialize for generation
    r.gencontrollerL = nil
    r.gencontrollerR = nil
    r.gencontrolle = nil
    r.gencontrollerD = nil
    r[1] = nil
    
    -- initialize for moving
    r.random = 0
    r.speed = tonumber(moving_default_speed)
    r.dir = tonumber(moving_default_dir)
    r.moving = 0
    r.dx = 0
    r.dy = 0
    r.bounceobjects = {}
    r.bounceremoveobjects = {}
    r.bound = boundary
    
    -- Initialize for Collisions
    r.regionregion = {}
    r.regionproj = {}
    r.projregion = {}
    r.projproj = {}
    
    -- Initialize for Background
    r.bgspeed = 0
    r.bgdir = 0
    
    -- initialize texture, label and size
    r.r = 255
    r.g = 255
    r.b = 255
    r.a = 255
    r.bkg = ""
    --initialize gradient
    r.r1 = nil
    r.r2 = nil
    r.r3 = nil
    r.r4 = nil
    r.g1 = nil
    r.g2 = nil
    r.g3 = nil
    r.g4 = nil
    r.b1 = nil
    r.b2 = nil
    r.b3 = nil
    r.b4 = nil
    r.a1 = nil
    r.a2 = nil
    r.a3 = nil
    r.a4 = nil
    r.t:SetTexture(r.r,r.g,r.b,r.a)
    r.tl:SetLabel(r:Name())
    r.tl:SetFontHeight(18)
    r.tl:SetColor(0,0,0,255) 
    r.tl:SetHorizontalAlign("JUSTIFY")
    r.tl:SetVerticalAlign("MIDDLE")
    r.tl:SetShadowColor(255,255,255,255)
    r.tl:SetShadowOffset(1,1)
    r.tl:SetShadowBlur(1)
    r:SetWidth(200)
    r:SetHeight(200)
    
    -- anchor
    r.fixed = 0
    AddAnchorIcon(r)
    
    -- move controller
    r.left_controller = nil
    r.right_controller = nil
    r.up_controller = nil
    r.down_controller = nil
    
    -- global text exchange
    r.is_text_sender = 0
    r.is_text_receiver = 0
    r.text_sharee = -1
    
    -- stickboundary
    r.stickboundary = "none"
end

function VRegion(ttype,name,parent,id) -- customized initialization of region
    local r = Region(ttype,"R#"..id,parent)
    r.tl = r:TextLabel()
    r.t = r:Texture()
    
    -- initialize for regions{} and recycledregions{}
    r.usable = 1
    r.id = id
    PlainVRegion(r)
    
    r:EnableMoving(true)
    r:EnableResizing(true)
    r:EnableInput(true)
    
    r:Handle("OnDoubleTap",VDoubleTap)
    r:Handle("OnTouchDown",VTouchDown)
    r:Handle("OnTouchUp",VTouchUp)
    
    return r
end

function CreateorRecycleregion(ftype, name, parent)
    local region
    if #recycledregions > 0 then
        region = regions[recycledregions[#recycledregions]]
        table.remove(recycledregions)
        region:EnableMoving(true)
        region:EnableResizing(true)
        region:EnableInput(true)
        region.usable = 1
    else
        region = VRegion(ftype, name, parent, #regions+1)
        table.insert(regions,region)
    end
    
    region:MoveToTop()
    return region
end

----------------- v11.pagebutton -------------------
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
