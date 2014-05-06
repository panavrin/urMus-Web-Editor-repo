-----------------------------------------------------------
--                      Keyboard                         --
-----------------------------------------------------------
--Brings up a usable on-screen keyboard

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

function Keyboard.CreateKeyPad(area)
    local kb = {}
    setmetatable(kb, Keyboard)
    kb.open = 0
    kb.typingarea = area
    kb.w = ScreenWidth()
    kb.face = 1 -- 1: low case, 2: upper case, 3: numbers and symbols
    kb:CreateKBLine("789","","",1,key_w)
    kb[2] = {}
    kb[2][1] = kb:CreateKey("4"," "," ",key_w)
    kb[2][2] = kb:CreateKey("5"," "," ",key_w)
    kb[2][3] = kb:CreateKey("6"," "," ",key_w)
    kb[2][1]:SetAnchor("TOPLEFT",kb[1][1],"BOTTOMRIGHT",0,key_margin)
    kb[2][2]:SetAnchor("TOPLEFT",kb[2][1],"TOPRIGHT",key_margin,0)
    kb[2][3]:SetAnchor("TOPLEFT",kb[2][2],"TOPRIGHT",key_margin,0)
    kb:CreateKBLine("123","","",3,key_w)
    -- kb(3) has SHIFT key
    kb[4] = {}
    kb[4].num = 3
    kb[4][1] = kb:CreateKey("0","","",key_w*2.07)
    kb[4][2] = kb:CreateKey("."," "," ",key_w)
    kb[4][3] = kb:CreateKey("<=","<=","<=",key_w*2.2)
    kb[4][4] = kb:CreateKey("clear","clear","clear",key_w*0.7)
    kb[4][2]:SetAnchor("TOPLEFT",kb[4][1],"TOPRIGHT",key_margin,0)
    kb[4][3]:SetAnchor("TOPLEFT",kb[4][2],"TOPRIGHT",key_margin,0)
    kb[4][4]:SetAnchor("TOPLEFT",kb[4][3],"TOPRIGHT",key_margin,0)
    kb[4][3]:Handle("OnTouchDown",KeyTouchDownBack)
    kb[4][4]:Handle("OnTouchDown",KeyTouchDownClear)
    
    kb[4][1]:SetAnchor("BOTTOMLEFT",ScreenWidth()/2-key_w*1.5,key_margin)
    kb[3][1]:SetAnchor("BOTTOMLEFT",kb[4][1],"TOPLEFT",0,key_margin)
    kb[2][1]:SetAnchor("BOTTOMLEFT",kb[3][1],"TOPLEFT",0,key_margin)
    kb[1][1]:SetAnchor("BOTTOMLEFT",kb[2][1],"TOPLEFT",0,key_margin)
    
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



mykb = Keyboard.Create()
mykp = Keyboard.CreateKeyPad()
function OpenOrCloseKeyboard(self)
    if mykb.enabled == 1 or current_mode == modes[1] then
        if mykb.open == 0 then 
            mykb.typingarea = self
            DPrint("DoubleTap to close keyboard. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykb:Show(1)
            mykp:Hide()
            self.kbopen = 1
            if self.text_sharee and self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 1
            end
            backdrop:SetClipRegion(0,mykb.h,ScreenWidth(),ScreenHeight())
        elseif self.kbopen == 0 then
            mykb.typingarea.kbopen = 0
            mykb.typingarea = self
            self.kbopen = 1
            if self.text_sharee and self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 1
            end
            DPrint("DoubleTap to close keyboard. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykb:Show(1)
        else
            DPrint("Keyboard closed. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykb:Hide()
            self.kbopen = 0
            if self.text_sharee and self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 0
            end
            backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
        end
    else
        DPrint("Keyboard disabled. Go to EDIT Mode->Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
    end
end

function OpenOrCloseKeyPad(self)
    if mykp.enabled == 1 or current_mode == modes[1] then
        if mykp.open == 0 then 
            mykp.typingarea = self
            DPrint("DoubleTap to close keyboard. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykp:Show(1)
            mykb:Hide()
            self.kbopen = 1
            if self.text_sharee and self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 1
            end
            backdrop:SetClipRegion(0,mykp.h,ScreenWidth(),ScreenHeight())
        elseif self.kbopen == 0 then
            mykp.typingarea.kbopen = 0
            mykp.typingarea = self
            self.kbopen = 1
            if self.text_sharee and self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 1
            end
            DPrint("DoubleTap to close keyboard. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykp:Show(1)
        else
            DPrint("Keyboard closed. Go to Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
            mykp:Hide()
            self.kbopen = 0
            if self.text_sharee and self.text_sharee ~= -1 then
                regions[self.text_sharee].kbopen = 0
            end
            backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight())
        end
    else
        DPrint("Keyboard disabled. Go to EDIT Mode->Menubar->Global Control->Keyboard Control to enable/disable in RELEASE mode.")
    end
end