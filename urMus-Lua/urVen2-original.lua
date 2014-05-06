-- urVen2.lua
-- By Aaven Jin, July-August 2011
-- University of Michigan Ann Arbor

-- Components: 
-- v1.backdrop v2.notification(not working) v3.hold button v4.color wheel v5.moving controller 
-- v6.moving dialog v7.Menu class v8.menu function list v9.global menubar v10. Keyboard class 
-- v11.edit/release mode v12.trashbin v13.anchorv v14.pagebutton

FreeAllRegions()
SetPage(38)
DPrint("Welcome to urVen2 =)")

---------------- constants -------------------
MIN_WIDTH_MENU = 100
MAX_WIDTH_MENU = 200
WIDTH_MODE = 120
HEIGHT_LINE = 40
STICK_MARGIN = 20 -- auto-stick when two regions are within STICK_MARGIN

local regions = {}
local recycledregions = {}

local auto_stick_enabled = 0
local pics = {"vinyl.png","Ornament1.png","Pirate1.png","Play.png","Right.png"} -- for random pictures

local moving_default_speed = "8" -- 3 to 10, slow to fast
local moving_default_dir = "45" -- direction by degree
local boundary = {0,ScreenHeight(),0,ScreenWidth()} -- boundary coordinates to bounce from {minx,maxx,miny,maxy}
local pboundary = {0,ScreenHeight(),0,ScreenWidth()} -- boundary coordinates for player regions to bounce from {minx,maxx,miny,maxy}

local modes = {"EDIT","RELEASE"}
local current_mode = modes[1]

local global_text_senders = {}
local global_text_receiver = -1 -- currently global_text_receiver allows only one receiver

local SixteenPositions = {} -- SixteenPositions(p1)(p2): stickee:SetAnchor(p2,sticker,p1)
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
    v.t:SetTexture(v.bkg)
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

local backdrop = Region('region', 'backdrop', UIParent)
backdrop:SetWidth(ScreenWidth())
backdrop:SetHeight(ScreenHeight())
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
notificationregion.textlabel:SetFont(urfont)
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

------------  v4.color wheel -------------
local color_w = 256
local color_h = 256

function UpdateColor(self,x,y,dx,dy)
    local xx = (x+dx)*1530/color_w
    local yy = y+dy
    local r=0
    local g=0
    local b=0
    self.region.a=yy-1
    
    if xx < 255 then
        r = 255
        g = xx
        b = 0
    elseif xx < 510 then
        r = 510 - xx
        g = 255
        b = 0
    elseif xx < 765 then
        r = 0
        g = 255
        b = xx - 510
    elseif xx < 920 then
        r = 0 
        g = 920 - xx
        b = 255
    elseif xx < 1175 then
        r = xx - 920
        g = 0
        b = 255
    else
        r = 255
        g = 0
        b = 1530 - xx
    end
    
    self.region.r = r*self.region.a/255
    self.region.g = g*self.region.a/255
    self.region.b = b*self.region.a/255
    
    VSetTexture(self.region)
    DPrint("r"..self.region.r.." g"..self.region.g.." b"..self.region.b.." a"..self.region.a..". Double tap to close.")
end

function CloseColorWheel(self)
    self:Hide()
    self:EnableInput(false)
    DPrint("color wheel closed")
end

local color_wheel = Region('region','colorwheel',UIParent)
color_wheel.t = color_wheel:Texture()
color_wheel.t:SetTexture('color_map.png')
color_wheel:SetWidth(color_w)
color_wheel:SetHeight(color_h)
color_wheel:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT") 
color_wheel:MoveToTop()
color_wheel:EnableInput(false)
color_wheel:EnableMoving(false)
color_wheel:EnableResizing(false)
color_wheel:Handle("OnMove",UpdateColor)
color_wheel:Handle("OnDoubleTap",CloseColorWheel)

----------------- v5.moving controller --------------------
-- moving controller is a clickable region to move its specified caller region
local move_step = 10
local move_holdtime = 0.01

function ControllerTouchDown(self)
    CloseSharedStuff(nil)
    if current_mode == modes[2] then
        DisableMove(self.caller)
        self:EnableMoving(false)
    else
        self:EnableMoving(true)
    end
    self.holdtime = move_holdtime
    Highlight(self)
end

function ControllerTouchUp(self)
    UnHighlight(self)
    self:Handle("OnUpdate",nil)
end

function MoveLeft(self)
    if current_mode == modes[2] then
        local x,y = self.caller:Center()
        if x <= self.caller:Width()/2 then
            self.caller:SetAnchor("LEFT",0,y)
            -- DPrint(self.caller:Name().." kissing left")
            ControllerTouchUp(self)
        else
            self.caller:SetAnchor("CENTER",x-move_step,y)
            -- DPrint(self.caller:Name().." moving left")
        end
    else
        DPrint(self.caller:Name().." will move left in release mode")
    end
end

function MoveRight(self)
    if current_mode == modes[2] then
        local x,y = self.caller:Center()
        if x >= ScreenWidth()-self.caller:Width()/2 then
            self.caller:SetAnchor("RIGHT",ScreenWidth(),y)
            -- DPrint(self.caller:Name().." kissing right")
            ControllerTouchUp(self)
        else
            self.caller:SetAnchor("CENTER",x+move_step,y)
            -- DPrint(self.caller:Name().." moving right")
        end
    else
        DPrint(self.caller:Name().." will move right in release mode")
    end
end
function MoveUp(self)
    if current_mode == modes[2] then
        local x,y = self.caller:Center()
        if y >= ScreenHeight()-self.caller:Height()/2 then
            self.caller:SetAnchor("TOP",x,ScreenHeight())
            -- DPrint(self.caller:Name().." kissing top")
            ControllerTouchUp(self)
        else
            self.caller:SetAnchor("CENTER",x,y+move_step)
            -- DPrint(self.caller:Name().." moving up")
        end
    else
        DPrint(self.caller:Name().." will move up in release mode")
    end
end

function MoveDown(self)
    if current_mode == modes[2] then
        local x,y = self.caller:Center()
        if y <= self.caller:Height()/2 then
            self.caller:SetAnchor("BOTTOM",x,0)
            -- DPrint(self.caller:Name().." kissing bottom")
            ControllerTouchUp(self)
        else
            self.caller:SetAnchor("CENTER",x,y-move_step)
            -- DPrint(self.caller:Name().." moving down")
        end
    else
        DPrint(self.caller:Name().." will move down in release mode")
    end
end

function TriggerLeft(self,e)
    self:MoveToTop()
    self.holdtime = self.holdtime - e
    if self.holdtime <= 0 then
        MoveLeft(self)
        self.holdtime = move_holdtime
    end
end

function TriggerRight(self,e)
    self:MoveToTop()
    self.holdtime = self.holdtime - e
    if self.holdtime <= 0 then
        MoveRight(self)
        self.holdtime = move_holdtime
    end
end

function TriggerUp(self,e)
    self:MoveToTop()
    self.holdtime = self.holdtime - e
    if self.holdtime <= 0 then
        MoveUp(self)
        self.holdtime = move_holdtime
    end
end 

function TriggerDown(self,e)
    self:MoveToTop()
    self.holdtime = self.holdtime - e
    if self.holdtime <= 0 then
        MoveDown(self)
        self.holdtime = move_holdtime
    end
end

function ControllerTouchDownLeft(self) -- event for OnTouchDown of the controller
    ControllerTouchDown(self)
    MoveLeft(self)
    self:Handle("OnUpdate",TriggerLeft)
end

function ControllerTouchDownRight(self)
    ControllerTouchDown(self)
    MoveRight(self)
    self:Handle("OnUpdate",TriggerRight)
end

function ControllerTouchDownUp(self)
    ControllerTouchDown(self)
    MoveUp(self)
    self:Handle("OnUpdate",TriggerUp)
end

function ControllerTouchDownDown(self)
    ControllerTouchDown(self)
    MoveDown(self)
    self:Handle("OnUpdate",TriggerDown)
end

function RemoveController(self)
    if current_mode == modes[1] then
        self:Hide()
        self:EnableInput(false)
        self:EnableMoving(false)
        DPrint("DoubleTap removes the controller. To re-enable it, please repeat its configuration.")
    end
end

function RemoveControllerLeft(self)
    RemoveController(self)
    self.caller.left_controller = nil
end

function RemoveControllerRight(self)
    RemoveController(self)
    self.caller.right_controller = nil
end

function RemoveControllerUp(self)
    RemoveController(self)
    self.caller.up_controller = nil
end

function RemoveControllerDown(self)
    RemoveController(self)
    self.caller.down_controller = nil
end

function CreateController()
    local controller = Region('region','controller',UIParent)
    controller:SetWidth(60)
    controller:SetHeight(60)
    controller:Handle("OnTouchUp",ControllerTouchUp)
    controller:Handle("OnLeave",ControllerTouchUp)
    return controller
end

----------- v10.Keyboard class ------------
local key_margin = 5
local key_w = (ScreenWidth() - key_margin * 11) / 10
local key_h = key_w * 0.9

Keyboard = {}
Keyboard.__index = Keyboard

function KeyTouchDown(self)
    self.parent.typingarea.tl:SetLabel(self.parent.typingarea.tl:Label()..self.faces[self.parent.face])
    if self.parent.typingarea.text_sharee ~= -1 and self.parent.typingarea.text_sharee ~= nil then
        regions[self.parent.typingarea.text_sharee].tl:SetLabel(self.parent.typingarea.tl:Label())
    end
    Highlight(self)
    for i = 1,4 do
        for j = 1,#self.parent[i] do
            self.parent[i][j]:MoveToTop()
        end
    end
end

function KeyTouchUp(self)
    UnHighlight(self)
end

function KeyTouchDownShift(self)
    if self.parent.face == 1 then
        self.parent:UpdateFaces(2)
        Highlight(self)
    elseif self.parent.face == 2 then
        self.parent:UpdateFaces(1)
        UnHighlight(self)
    end
end

function KeyTouchDownFlip(self) -- event for switching number/alphabet mode 
    Highlight(self)
    if self.parent.face == 3 then
        self.parent:UpdateFaces(1)
    else
        self.parent:UpdateFaces(3)
    end
end

function KeyTouchDownBack(self)
    Highlight(self)
    local s = self.parent.typingarea.tl:Label()
    if s ~= "" then
        DPrint(s)
        self.parent.typingarea.tl:SetLabel(s:sub(1,s:len()-1))
    end
end

function KeyTouchDownClear(self)
    Highlight(self)
    self.parent.typingarea.tl:SetLabel("")
    if self.parent.typingarea.text_sharee ~= -1 and self.parent.typingarea.text_sharee ~= nil then
        regions[self.parent.typingarea.text_sharee].tl:SetLabel("")
    end
end

function Keyboard:CreateKey(ch1,ch2,ch3,w)
    local key = Region('region', 'key', UIParent)
    key.parent = self
    key.faces = {ch1,ch2,ch3} -- 1: low case, 2: upper case, 3: back number
    key.t = key:Texture(200,200,200,255)
    key.tl = key:TextLabel()
    key.tl:SetLabel(ch1)
    key.tl:SetFontHeight(22)
    key.tl:SetColor(0,0,0,255) 
    key.tl:SetHorizontalAlign("JUSTIFY")
    key.tl:SetShadowColor(255,255,255,255)
    key.tl:SetShadowOffset(1,1)
    key.tl:SetShadowBlur(1)
    key:SetHeight(key_h)
    key:SetWidth(w)
    key:Handle("OnTouchDown",KeyTouchDown)
    key:Handle("OnTouchUp",KeyTouchUp)
    key:Handle("OnLeave",KeyTouchUp)
    return key
end

function Keyboard:CreateKBLine(str1,str2,str3,line,w) -- as a private function for initialization, only called by Keyboard.Create()
                                                    -- str1, str2, str3 each is a string on a whole line of keyboard
                                                    -- str1 is lower case, str2 is upper case, str3 is number and symbol
    self[line] = {}
    self[line].num = string.len(str1)
    self[line][1] = self:CreateKey(string.char(str1:byte(1)),string.char(str2:byte(1)),string.char(str3:byte(1)),w)
    
    for i=2,self[line].num do
        self[line][i] = self:CreateKey(string.char(str1:byte(i)),string.char(str2:byte(i)),string.char(str3:byte(i)),w)
        self[line][i]:SetAnchor("TOPLEFT",self[line][i-1],"TOPRIGHT",key_margin,0)
    end
end

function Keyboard:UpdateFaces(face) -- update the character on a key when Shift key is hit or number/alphabet mode is switched
    self.face = face
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j].tl:SetLabel(self[i][j].faces[face])
        end
    end
    UnHighlight(self[3][10])
end

function Keyboard.Create(area)
    local kb = {}
    setmetatable(kb, Keyboard)
    kb.open = 0
    kb.typingarea = area
    kb.w = ScreenWidth()
    kb.face = 1 -- 1: low case, 2: upper case, 3: numbers and symbols
    kb:CreateKBLine("qwertyuiop","QWERTYUIOP","1234567890",1,key_w)
    kb:CreateKBLine("asdfghjkl","ASDFGHJKL","-/:;()$&@",2,key_w)
    kb:CreateKBLine("zxcvbnm,.","ZXCVBNM!?","_\\|~<>+='",3,key_w)
    -- kb(3) has SHIFT key
    kb[3][10] = kb:CreateKey("shift","shift","",key_w)
    kb[3][10]:SetAnchor("TOPLEFT",kb[3][9],"TOPRIGHT",key_margin,0)
    kb[3][10]:Handle("OnTouchDown",KeyTouchDownShift)
    kb[3][10]:Handle("OnTouchUp",nil)
    kb[3][10]:Handle("OnLeave",nil)
    kb[3].num = kb[3].num + 1
    kb[4] = {}
    kb[4].num = 3
    kb[4][1] = kb:CreateKey("123","123","abc",key_w*2)
    kb[4][2] = kb:CreateKey(" "," "," ",key_w*5.5)
    kb[4][3] = kb:CreateKey("<=","<=","<=",key_w*2.2)
    kb[4][4] = kb:CreateKey("clear","clear","clear",key_w*0.7)
    kb[4][2]:SetAnchor("TOPLEFT",kb[4][1],"TOPRIGHT",key_margin,0)
    kb[4][3]:SetAnchor("TOPLEFT",kb[4][2],"TOPRIGHT",key_margin,0)
    kb[4][4]:SetAnchor("TOPLEFT",kb[4][3],"TOPRIGHT",key_margin,0)
    kb[4][1]:Handle("OnTouchDown",KeyTouchDownFlip)
    kb[4][3]:Handle("OnTouchDown",KeyTouchDownBack)
    kb[4][4]:Handle("OnTouchDown",KeyTouchDownClear)
    
    kb[4][1]:SetAnchor("BOTTOMLEFT",key_margin,key_margin)
    kb[3][1]:SetAnchor("BOTTOMLEFT",kb[4][1],"TOPLEFT",0,key_margin)
    kb[2][1]:SetAnchor("BOTTOMLEFT",kb[3][1],"TOPLEFT",key_w/2,key_margin)
    kb[1][1]:SetAnchor("BOTTOMLEFT",kb[2][1],"TOPLEFT",0-key_w/2,key_margin)
    
    kb.h = #kb * (key_h+key_margin)
    kb.enabled = 1
    
    return kb
end

function Keyboard:Show(face) 
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j]:EnableInput(true)
            self[i][j]:Show()
            self[i][j]:MoveToTop()
            self[i][j].tl:SetLabel(self[i][j].faces[face])
        end
    end
    UnHighlight(self[3][10])
    self.face = face
    self.open = 1
end

function Keyboard:Hide()
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j]:EnableInput(false)
            self.face = 1
            self[i][j].tl:SetLabel(self[i][j].faces[1])
            self[i][j]:Hide()
        end
    end
    self.open = 0
end

local mykb = Keyboard.Create()

---------------------- v6.moving dialog --------------------------
function CreateOptions(txt,w)
    local r = Region('region','dialog',UIParent)
    r.tl = r:TextLabel()
    r.tl:SetLabel(txt)
    r.tl:SetFontHeight(16)
    r.tl:SetColor(0,0,0,255) 
    r.tl:SetHorizontalAlign("JUSTIFY")
    r.tl:SetShadowColor(255,255,255,255)
    r.tl:SetShadowOffset(1,1)
    r.tl:SetShadowBlur(1)
    r.t = r:Texture(200,200,200,255)
    r:SetWidth(w)
    r:SetHeight(50)
    return r
end

function CloseMyDialog(self)
    self.title:Hide()
    for i = 1,#self.hint do
        self[i][1]:Hide()
        self[i][2]:Hide()
        self[i][2]:EnableInput(false)
    end
    
    self[#self.hint][1]:EnableInput(false)
    mykb:Hide()
    self.ready = 0
    backdrop:EnableInput(true)
end

function OKclicked(self)
    local dd = self.parent
    d1 = tonumber(dd[1][2].tl:Label())
    d2 = tonumber(dd[2][2].tl:Label())
    if d1 <= 0 or d1 > 20 then
        DPrint("Speed must be in the range (0,20]")
        return
    end
    if d2 >= 360 or d2 < 0 then
        DPrint("Direction must be in the range [0,360)")
        return
    end

    local region = dd.caller
    local deg = d2 * math.pi / 180
    region.speed = d1
    region.dy = d1*math.sin(deg)
    region.dx = d1*math.cos(deg)
    region.bounceobjects = dd.bounceobjects
    region.bounceremoveobjects = dd.bounceremoveobjects
    region.bound = boundary 

    CloseMyDialog(self.parent)
    StartMoving(region,0)
end

function CANCELclicked(self)
    CloseMyDialog(self.parent)
end

function SelectBounceObject(self)
    self.parent.bouncetype = 0
    if self.parent.bounceobjects.dirty == 0 then
        self.parent[3][2].tl:SetLabel("")
    end
end

function SelectBounceObjectRemove(self)
    self.parent.bouncetype = 1
    if self.parent.bounceremoveobjects.dirty == 0 then
        self.parent[4][2].tl:SetLabel("")
    end
end

function OpenOrCloseNumericKeyboard(self)
    if mykb.open == 0 then 
        mykb.typingarea = self
        CloseColorWheel(color_wheel)
        DPrint("Keyboard opened.")
        mykb:Show(3)
        backdrop:SetClipRegion(0,mykb.h,ScreenWidth(),ScreenHeight())
    else 
        DPrint("Keyboard closed.")
        mykb:Hide()
        backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
    end
end

local mydialog = {}
mydialog.title = Region('region','dialog',UIParent)
mydialog.title.t = mydialog.title:Texture(240,240,240,255)
mydialog.title.tl = mydialog.title:TextLabel()
mydialog.title.tl:SetLabel("Move! Touch the region to stop moving.")
mydialog.title.tl:SetFontHeight(16)
mydialog.title.tl:SetColor(0,0,0,255) 
mydialog.title.tl:SetHorizontalAlign("JUSTIFY")
mydialog.title.tl:SetShadowColor(255,255,255,255)
mydialog.title.tl:SetShadowOffset(1,1)
mydialog.title.tl:SetShadowBlur(1)
mydialog.title:SetWidth(400)
mydialog.title:SetHeight(50)
mydialog.title:SetAnchor("BOTTOM",UIParent,"CENTER",0,100)
mydialog.hint = {{"Speed (1 to 20, slow to fast)",moving_default_speed},{"Direction (degrees)",moving_default_dir},{"Select Vs to bounce from","Click here"},{"Select Vs to bounce from and remove","Click here"},{"OK","CANCEL"}}
mydialog.bounceobjects = {}
mydialog.bounceremoveobjects = {}
mydialog.bouncetype = 0 -- 1:remove after bounce, 0:just bounce
mydialog.ready = 0
mydialog.caller = nil
for i = 1,#mydialog.hint do
    mydialog[i] = {}
    mydialog[i][1] = CreateOptions(mydialog.hint[i][1],250)
    mydialog[i][2] = CreateOptions(mydialog.hint[i][2],150)
    mydialog[i][2]:SetAnchor("LEFT",mydialog[i][1],"RIGHT",0,0)
    mydialog[i][1].parent = mydialog
    mydialog[i][2].parent = mydialog
end
mydialog[1][2]:Handle("OnTouchDown",OpenOrCloseNumericKeyboard)
mydialog[2][2]:Handle("OnTouchDown",OpenOrCloseNumericKeyboard)
mydialog[3][2]:Handle("OnTouchDown",SelectBounceObject)
mydialog[4][2]:Handle("OnTouchDown",SelectBounceObjectRemove)
mydialog[5][1]:Handle("OnTouchDown",OKclicked)
mydialog[5][2]:Handle("OnTouchDown",CANCELclicked)

mydialog[1][1]:SetAnchor("TOPLEFT",mydialog.title,"BOTTOMLEFT",0,0)
for i = 2,#mydialog.hint do
    mydialog[i][1]:SetAnchor("TOPLEFT",mydialog[i-1][1],"BOTTOMLEFT",0,0)
end

function OpenMyDialog(v)
    mydialog.title:Show()
    mydialog.title:MoveToTop()
    mydialog.caller = v
    DPrint("Moving configuration for "..v:Name())
    while #mydialog.bounceobjects > 0 do
        table.remove(mydialog.bounceobjects)
    end
    while #mydialog.bounceremoveobjects > 0 do
        table.remove(mydialog.bounceremoveobjects)
    end
    while #mydialog.caller.bounceobjects > 0 do
        table.remove(mydialog.caller.bounceobjects)
    end
    while #mydialog.caller.bounceremoveobjects > 0 do
        table.remove(mydialog.caller.bounceremoveobjects)
    end
    mydialog[1][2].tl:SetLabel(mydialog.hint[1][2])
    mydialog[2][2].tl:SetLabel(mydialog.hint[2][2])
    mydialog[3][2].tl:SetLabel(mydialog.hint[3][2])
    mydialog[4][2].tl:SetLabel(mydialog.hint[4][2])
    for i = 1,#mydialog.hint do
        mydialog[i][1]:Show()
        mydialog[i][2]:Show()
        mydialog[i][1]:MoveToTop()
        mydialog[i][2]:MoveToTop()
        mydialog[i][2]:EnableInput(true)
    end
    mydialog[#mydialog.hint][1]:EnableInput(true)
    mydialog.ready = 1
    mydialog.bouncetype = 0
    mydialog.bounceobjects.dirty = 0
    mydialog.bounceremoveobjects.dirty = 0
    backdrop:EnableInput(false)
end

------------ v7.Menu class -------------
Menu = {}
Menu.__index = Menu
function Menu:OpenMenu() 
    if self.open == 0 then
        for i = 1,self.num do
            self[i]:EnableInput(true)
            self[i]:MoveToTop()
            self[i]:Show()
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
    opt.t:SetTexture(self.bkg)
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

function StartMovingEvent(r,e) -- event called with signal OnUpdate. parameters for r are set in StartMoving
    if r.touch ~= "none" then
        r.x = r.x + r.dx
        r.y = r.y + r.dy
        r.touch = "none"
    else
        if r.random == 1 then
            local deg = math.random(-10,10)
            r.dir = (r.dir + deg*math.pi/180)%360
            r.dy = r.speed*math.sin(r.dir)
            r.dx = r.speed*math.cos(r.dir)
        end
    
        for i = 1,#r.bounceobjects do
            TouchObject(r,regions[r.bounceobjects[i]])
            if r.touch ~= "none" then
                break
            end
        end
        
        if r.touch == "none" then
            for k = 1,#r.bounceremoveobjects do
                TouchObject(r,regions[r.bounceremoveobjects[k]])
                if r.touch ~= "none" then
                    RemoveV(regions[r.bounceremoveobjects[k]])
                    table.remove(r.bounceremoveobjects,k)
                    break
                end
            end
        end
    
        if r.touch == "none" then
            TouchBound(r)
            if r.touch == "none" then
                r.x = r.x + r.dx
                r.y = r.y + r.dy
            end
        end
    end
    
    r:SetAnchor("CENTER",r.x,r.y)
end

function StartMoving(vv,random) -- set parameters for region vv to move. with random as 1, vv flies in random directions
    vv.x,vv.y = vv:Center()
    vv.moving = 1
    vv.touch = "none"
    vv.random = random
    
    if vv.eventlist["OnUpdate"]["move"] == 0 then
        table.insert(vv.eventlist["OnUpdate"],StartMovingEvent)
        vv.eventlist["OnUpdate"]["move"] = 1
    end
    vv.eventlist["OnUpdate"].currentevent = StartMovingEvent
    vv:Handle("OnUpdate",nil)
    vv:Handle("OnUpdate",VUpdate)
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

------------- menu functions --------------
-- called by menu option, named starting with Menu-
-- arguments (opt,vv): opt is menu option region, vv is the region that functions should be implemented on

function MenuAbout(opt,vv)
    output = vv:Name()..", sticker #"..vv.sticker..", stickees"
    if #vv.stickee == 0 then
        output = output.." #-1"
    else
        for i = 1,#vv.stickee do
            output = output.." #"..vv.stickee[i]
        end
    end
    DPrint(output)
end

function MenuPictureRandomly(opt,vv)
    vv.bkg = pics[math.random(1,5)]
    vv.t:SetTexture(vv.bkg)
    DPrint(vv:Name().." background pic: "..vv.bkg)
end

function MenuColorRandomly(opt,vv)
    vv.r = math.random(0,255)
    vv.g = math.random(0,255)
    vv.b = math.random(0,255)
    vv.a = math.random(0,255)
    vv.t:SetSolidColor(vv.r,vv.g,vv.b,vv.a)
    DPrint(vv:Name().." random color (r,g,b,a): ("..vv.r..","..vv.g..","..vv.b..","..vv.a..")")
end

function MenuClearToWhite(opt,vv)
    DPrint(vv:Name().." clear to white")
    vv.r = 255
    vv.g = 255
    vv.b = 255
    vv.a = 255
    vv.bkg = ""
    vv.t:SetTexture(255,255,255,255)
end

function MenuUnstick(opt,vv)
    Unstick(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function RemoveV(vv)
    Unstick(vv)
    
    if vv.text_sharee ~= -1 then
        for k,i in pairs(global_text_senders) do
            if i == vv.id then
                table.remove(global_text_senders,k)
            end
        end
        regions[vv.text_sharee].text_sharee = -1
    end
    
    PlainVRegion(vv)
    vv:EnableInput(false)
    vv:EnableMoving(false)
    vv:EnableResizing(false)
    vv:Hide()
    vv.usable = 0

    table.insert(recycledregions, vv.id)
    DPrint(vv:Name().." removed")
end

function MenuRecycleSelf(opt,vv)
    RemoveV(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuStickControl(opt,vv)
    if auto_stick_enabled == 1 then
        DPrint("AutoStick disabled")
        auto_stick_enabled = 0
    else
        DPrint("AutoStick enabled")
        auto_stick_enabled = 1
    end
end

function MenuKeyboardControl(opt,vv)
    if mykb.enabled == 1 then
        DPrint("Keyboard will be disabled in release mode")
        mykb.enabled = 0
    else
        DPrint("Keyboard will be re-enabled in release mode")
        mykb.enabled = 1
    end
end

function MenuDuplicate(opt,oldv)
    local newv = CreateorRecycleregion('region', 'backdrop', UIParent)
    -- size
    newv:SetWidth(oldv:Width())
    newv:SetHeight(oldv:Height())
    -- color
    VVSetTexture(newv,oldv)
    -- text 
    newv.tl:SetFontHeight(oldv.tl:FontHeight())
    newv.tl:SetHorizontalAlign(oldv.tl:HorizontalAlign())
    newv.tl:SetVerticalAlign(oldv.tl:VerticalAlign())
    newv.tl:SetLabel(newv.tl:Label())
    -- position
    local x,y = oldv:Center()
    local h = 10 + oldv:Height()
    newv:Show()
    if y-h < 100 then
        newv:SetAnchor("CENTER",x,y+h)
    else
        newv:SetAnchor("CENTER",x,y-h)
    end
    DPrint(newv.tl:Label().." Color: ("..newv.r..", "..newv.g..", "..newv.b..", "..newv.a.."). Background pic: "..newv.bkg..". Blend mode: "..newv.t:BlendMode())
    
    return newv
end

function MenuTextSize(opt,vv)
    DPrint("Change to font: "..text_size_list[opt.k])
    vv.tl:SetFontHeight(tonumber(text_size_list[opt.k]) * 2) -- scale by 2
    vv.tl:SetLabel(vv.tl:Label())
end

function MenuTextPosition(opt,vv)
    vv.tl:SetHorizontalAlign(text_position_hor_list[opt.k])
    vv.tl:SetVerticalAlign(text_position_ver_list[opt.k])
    vv.tl:SetLabel(vv.tl:Label())
end

function MenuText(opt,vv)
    DPrint("Current text size: " .. vv.tl:FontHeight()/2 .. ", position: " .. vv.tl:VerticalAlign() .. " & " .. vv.tl:HorizontalAlign()) -- TODO wrong output
end

function MenuChangeColor(opt,vv)
    color_wheel:Show()
    color_wheel.region = vv
    color_wheel:EnableInput(true)
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuTransparency(opt,vv)
    DPrint("Current blend mode: " .. vv.t:BlendMode())
end

function MenuBlendMode(opt,vv)
    DPrint("Change to blend mode: " .. blend_mode_list[opt.k])
    vv.t:SetBlendMode(blend_mode_list[opt.k])
end

function MenuMoving(opt,vv)
    OpenMyDialog(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuSelfFly(opt,vv) 
    -- if don't want to let it bounce from other regions, delete the following two while loops
    while #vv.bounceobjects > 0 do
        table.remove(vv.bounceobjects)
    end
    while #vv.bounceremoveobjects > 0 do
        table.remove(vv.bounceremoveobjects)
    end
    
    StartMoving(vv,1)
    DPrint(vv:Name().." randomly flies. Click it to stop.")
    UnHighlight(opt)
    CloseMenuBar()
end

function SelfShowHideEvent(self,e) -- event called with OnUpdate
    self.showtime = self.showtime - e
    if self.showtime <= 0 then
        if self:IsShown() then
            self:Hide()
        else
            self:Show()
        end
        self.showtime = math.random(1,4)/4
    end
end

function MenuSelfShowHide(opt,vv) 
    vv.showtime = math.random(1,4)/4
    if vv.eventlist["OnUpdate"]["selfshowhide"] == 0 then
        table.insert(vv.eventlist["OnUpdate"],SelfShowHideEvent)
        vv.eventlist["OnUpdate"]["selfshowhide"] = 1
    end
    vv.eventlist["OnUpdate"].currentevent = SelfShowHideEvent
    vv:Handle("OnUpdate",nil)
    vv:Handle("OnUpdate",VUpdate)
    DPrint(vv:Name().." randomly shows and hides. Click it to stop.")
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuSelfColor(opt,vv)
    vv.colortime = 1
    if vv.eventlist["OnUpdate"]["selfcolor"] == 0 then
        table.insert(vv.eventlist["OnUpdate"],SelfColor)
        vv.eventlist["OnUpdate"]["selfcolor"] = 1
    end
    vv.eventlist["OnUpdate"].currentevent = SelfColor
    vv:Handle("OnUpdate",nil)
    vv:Handle("OnUpdate",VUpdate)
    DPrint(vv:Name().." randomly changes color. Click it to stop.")
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuStartPlayerLeft(opt,vv) -- this set of 4 functions are for player regions to stick to pboundary when OnMove signal is received by backdrop in release mode
    if vv.stickboundary ~= "left" then
        backdrop.player[vv.stickboundary] = nil
    end
    backdrop.player["left"] = vv
    vv:SetAnchor("LEFT",pboundary[3],(pboundary[2]+pboundary[1])/2)
    DisableMove(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuStartPlayerRight(opt,vv)
    if vv.stickboudary ~= "right" then
        backdrop.player[vv.stickboundary] = nil
    end
    backdrop.player["right"] = vv
    vv:SetAnchor("RIGHT",pboundary[4],(pboundary[2]+pboundary[1])/2)
    DisableMove(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuStartPlayerTop(opt,vv)
    if vv.stickboudary ~= "top" then
        backdrop.player[vv.stickboundary] = nil
    end
    backdrop.player["top"] = vv
    vv:SetAnchor("TOP",(pboundary[3]+pboundary[4])/2,pboundary[2])
    DisableMove(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuStartPlayerBottom(opt,vv)
    if vv.stickboudary ~= "bottom" then
        backdrop.player[vv.stickboundary] = nil
    end
    backdrop.player["bottom"] = vv
    vv:SetAnchor("BOTTOM",(pboundary[3]+pboundary[4])/2,pboundary[1])
    DisableMove(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuClearText(opt,vv)
    vv.tl:SetLabel("")
    if vv.text_sharee ~= -1 then
        regions[vv.text_sharee].tl:SetLabel("")
    end
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuStickBoundary(opt,vv)
    DPrint("Only takes effect in release mode.")
end

function MenuMoveController(opt,vv)
    DPrint("Use a controller to control the move direction of "..vv:Name())
end

function MenuControllerLeft(opt,vv) -- this set of 4 functions are for moving controllers
    if vv.left_controller == nil then
        controller = CreateController()
        controller.t = controller:Texture('Left.png')
        controller:SetAnchor("RIGHT",UIParent,"CENTER",-10,0)
        controller.caller = vv
        controller:Handle("OnDoubleTap",RemoveControllerLeft)
        controller:Handle("OnTouchDown",ControllerTouchDownLeft)
        vv.left_controller = controller
    end        
    controller:Show()
    controller:EnableInput(true)
    controller:EnableMoving(true)
end

function MenuControllerRight(opt,vv)
    if vv.right_controller == nil then
        controller = CreateController()
        controller.t = controller:Texture('Right.png')
        controller:SetAnchor("LEFT",UIParent,"CENTER",10,0)
        controller.caller = vv
        controller:Handle("OnDoubleTap",RemoveControllerRight)
        controller:Handle("OnTouchDown",ControllerTouchDownRight)
        vv.right_controller = controller
    end        
    controller:Show()
    controller:EnableInput(true)
    controller:EnableMoving(true)
end

function MenuControllerUp(opt,vv)
    if vv.up_controller == nil then
        controller = CreateController()
        controller.t = controller:Texture('up.png')
        controller:SetAnchor("BOTTOM",UIParent,"CENTER",0,10)
        controller.caller = vv
        controller:Handle("OnDoubleTap",RemoveControllerUp)
        controller:Handle("OnTouchDown",ControllerTouchDownUp)
        vv.up_controller = controller
    end        
    controller:Show()
    controller:EnableInput(true)
    controller:EnableMoving(true)
end

function MenuControllerDown(opt,vv)
    if vv.down_controller == nil then
        controller = CreateController()
        controller.t = controller:Texture('down.png')
        controller:SetAnchor("TOP",UIParent,"CENTER",0,-10)
        controller.caller = vv
        controller:Handle("OnDoubleTap",RemoveControllerDown)
        controller:Handle("OnTouchDown",ControllerTouchDownDown)
        vv.down_controller = controller
    end
    controller:Show()
    controller:EnableInput(true)
    controller:EnableMoving(true)
end

function MenuGlobalTextSharing(opt,vv)
    if vv.is_text_sharer == 1 then
        DPrint(vv:Name().." is a sharer")
    elseif vv.is_text_receiver == 1 then
        DPrint(vv:Name().." is a receiver")
    else
        DPrint(vv:Name().." is neither a sharer nor a receiver")
    end
end

function MenuSetGlobalTextSender(opt,vv)
    if global_text_receiver == vv.id then
        global_text_receiver = -1
    end
    if vv.is_text_sender == 0 then
        vv.is_text_sender = 1
        table.insert(global_text_senders,vv.id)
        table.insert(vv.eventlist["OnTouchDown"],TextSharing)
        table.insert(vv.reventlist["OnTouchDown"],TextSharing)
        DPrint(vv:Name().." is set as global text sender")
        if global_text_receiver ~= -1 then
            vv.text_sharee = global_text_receiver
            regions[global_text_receiver].text_sharee = vv.id
        end
    end
    UnHighlight(opt)
    CloseMenuBar()
end

function MenuSetGlobalTextReceiver(opt,vv) -- not checking duplicates
    DPrint(vv:Name().." is set as global text receiver")
    if vv.is_text_sender == 1 then
        for i = 1,#global_text_senders do
            if global_text_senders[i] == vv then
                table.remove(global_text_senders,i)
                break
            end
        end
        if regions[global_text_receiver].text_sharee == vv.id then
            if #global_text_senders > 0 then
                regions[global_text_receiver].text_sharee = global_text_senders[1]
            else
                regions[global_text_receiver].text_sharee = -1 
            end
        end
    end
    if vv.id ~= global_text_receiver and global_text_receiver ~= -1 then
        regions[global_text_receiver].text_sharee = -1
    end
        
    vv.is_text_receiver = 1
    global_text_receiver = vv.id
    for i = 1,#global_text_senders do
        regions[global_text_senders[i]].text_sharee = vv.id
    end
    if #global_text_senders > 0 then
        vv.text_sharee = global_text_senders[1]
    end
    
    UnHighlight(opt)
    CloseMenuBar()
end

------------------- v8.menu function list ------------------
-- function_list[i] = {"menubar optoin label", {func_list}} where func_list:
-- func_list[i] = {"menu option label", event, {func_list for sub-menu}
function_list = {}

function_list[1] = {"Basics", {
                                {"About",MenuAbout,{}},
                                {"Random Picture",MenuPictureRandomly,{}},
                                {"Random Color",MenuColorRandomly,{}},
                                {"Clear Background",MenuClearToWhite,{}},
                                {"Unstick",MenuUnstick,{}},
                                {"Remove",MenuRecycleSelf,{}}
                            }
                    }
                    
function_list[2] = {"Edit", {
                                {"Color Wheel",MenuChangeColor,{}},
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
                                {"Keyboard Control",MenuKeyboardControl,{}}
                            }
                    }
                    

------------ v9.global menubar -------------
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

------------ v11.edit/release mode --------------
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


------------- v12.trashbin -------------
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

-------------- v13.anchorv --------------
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


----------- v events --------------
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

function OpenOrCloseKeyboard(self)
    if mykb.enabled == 1 or current_mode == modes[1] then
        if mykb.open == 0 then 
            mykb.typingarea = self
            DPrint("DoubleTap to close keyboard. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykb:Show(1)
            self.kbopen = 1
            if self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 1
            end
            backdrop:SetClipRegion(0,mykb.h,ScreenWidth(),ScreenHeight())
        elseif self.kbopen == 0 then
            mykb.typingarea.kbopen = 0
            mykb.typingarea = self
            self.kbopen = 1
            if self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 1
            end
            DPrint("DoubleTap to close keyboard. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykb:Show(1)
        else
            DPrint("Keyboard closed. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykb:Hide()
            self.kbopen = 0
            if self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 0
            end
            backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
        end
    else
        DPrint("Keyboard disabled. Go to EDIT Mode->Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
    end
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
    
    -- initialize texture, label and size
    r.r = 255
    r.g = 255
    r.b = 255
    r.a = 255
    r.bkg = ""
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

----------------- v14.pagebutton -------------------
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