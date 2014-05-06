-- urKeyboard
-- by by Aaven & Georg Essl
-- Created: July 2011
-- Last modified: 08/11/2011
-- Copyright (c) 2010-11 Georg Essl. All Rights Reserved. See LICENSE.txt for license conditions.

if Keyboard then return end -- Keyboard already instantiated


dofile(SystemPath("FAIAP.lua"))

----------- global helper functions ------------

local function Highlight(r)
	r.t:SetSolidColor(100,100,100,255)
end

local function UnHighlight(r)
	r.t:SetSolidColor(200,200,200,255)
end

----------- keyboard ------------
local key_margin = 5
local key_w = (ScreenWidth() - key_margin * 11) / 10
local key_h = key_w * 0.9

Keyboard = {}
Keyboard.__index = Keyboard

function Keyboard:Width()
	return key_w
end

function Keyboard:Height()
	return self.h
end

function KeyTouchDown(self)
    
    if self.parent.keyfunc then
        self.parent.keyfunc(self.faces[self.parent.face])
    else
        self.parent.typingarea.tl:SetLabel(colorhighlightlib.stripWowColors(self.parent.typingarea.tl:Label())..self.faces[self.parent.face])
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

function Keyboard:CreateKey(ch1,ch2,ch3,w)
    local key = Region('region', 'key', UIParent)
    key.parent = self
    key.faces = {ch1,ch2,ch3} -- 1: low case, 2: upper case, 3: back number
    key.t = key:Texture(200,200,200,255)
    key.tl = key:TextLabel()
    key.tl:SetLabel(ch1)
    key.tl:SetFontHeight(20)
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

function Keyboard:CreateKBLine(str1,str2,str3,line,w) -- as a private function, do not use outside class, only called by Keyboard.Create
    self[line] = {}
    self[line].num = string.len(str1)
    self[line][1] = self:CreateKey(string.char(str1:byte(1)),string.char(str2:byte(1)),string.char(str3:byte(1)),w)
    
    for i=2,self[line].num do
        self[line][i] = self:CreateKey(string.char(str1:byte(i)),string.char(str2:byte(i)),string.char(str3:byte(i)),w)
        self[line][i]:SetAnchor("TOPLEFT",self[line][i-1],"TOPRIGHT",key_margin,0)
    end
end

function Keyboard:UpdateFaces(face)
    self.face = face
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j].tl:SetLabel(self[i][j].faces[face])
        end
    end
    UnHighlight(self[3][10])
end

function KeyTouchDownShift(self)
    if self.parent.face == 1 then
        self.parent:UpdateFaces(2)
        Highlight(self)
    elseif self.parent.face == 2 then
        self.parent:UpdateFaces(1)
        UnHighlight(self)
    else
	    KeyTouchDown(self)
    end
end

function KeyTouchUpShift(self)
	if self.parent.face == 3 then
		UnHighlight(self)
	end
end

function KeyTouchDownFlip(self)
    Highlight(self)
    if self.parent.face == 3 then
        self.parent:UpdateFaces(1)
    else
        self.parent:UpdateFaces(3)
    end
end

function KeyTouchDownBack(self)
    Highlight(self)
    if self.parent.backfunc then
        self.parent.backfunc()
    else
        local s = colorhighlightlib.stripWowColors(self.parent.typingarea.tl:Label())
        if s ~= "" then
            self.parent.typingarea.tl:SetLabel(s:sub(1,s:len()-1))
        end
    end
end

function KeyTouchDownReturn(self)
	if self.parent.enterfunc then
		Highlight(self)
		self.parent.enterfunc(self.parent)
	else
		Highlight(self)
        if self.parent.typingarea then
            self.parent.typingarea.tl:SetLabel(self.parent.typingarea.tl:Label().."\n")
        end
    end
end

function Keyboard.CreateKB()
    local kb = {}
    setmetatable(kb, Keyboard)
    kb.open = 0
    kb.w = ScreenWidth()
    kb.face = 1 -- 1: low case, 2: upper case, 3: back number
    kb:CreateKBLine("qwertyuiop","QWERTYUIOP","1234567890",1,key_w)
    kb:CreateKBLine("asdfghjkl","ASDFGHJKL","-/:;()$&@",2,key_w)
    kb:CreateKBLine("zxcvbnm,.","ZXCVBNM!?","_\\|~<>+='\"",3,key_w)
    -- kb(3) has SHIFT key
--    kb[3][10] = kb:CreateKey("shift","shift","disable",key_w)
    kb[3][10] = kb:CreateKey("shift","shift","\"",key_w)
    kb[3][10]:SetAnchor("TOPLEFT",kb[3][9],"TOPRIGHT",key_margin,0)
    kb[3][10]:Handle("OnTouchDown",KeyTouchDownShift)
    kb[3][10]:Handle("OnTouchUp",KeyTouchUpShift)
    kb[3][10]:Handle("OnLeave",KeyTouchUpShift)
    kb[3].num = kb[3].num + 1
    kb[4] = {}
    kb[4].num = 3
    kb[4][1] = kb:CreateKey("123","123","abc",key_w*2)
    kb[4][2] = kb:CreateKey(" "," "," ",key_w*5.5)
    kb[4][3] = kb:CreateKey("<=","<=","<=",key_w*1.4)
    kb[4][4] = kb:CreateKey("return","return","return",key_w*1.5)
    kb[4][2]:SetAnchor("TOPLEFT",kb[4][1],"TOPRIGHT",key_margin,0)
    kb[4][3]:SetAnchor("TOPLEFT",kb[4][2],"TOPRIGHT",key_margin,0)
    kb[4][4]:SetAnchor("TOPLEFT",kb[4][3],"TOPRIGHT",key_margin,0)
    kb[4][1]:Handle("OnTouchDown",KeyTouchDownFlip)
    kb[4][3]:Handle("OnTouchDown",KeyTouchDownBack)
    kb[4][4]:Handle("OnTouchDown",KeyTouchDownReturn)
    
    kb[4][1]:SetAnchor("BOTTOMLEFT",key_margin,key_margin)
    kb[3][1]:SetAnchor("BOTTOMLEFT",kb[4][1],"TOPLEFT",0,key_margin)
    kb[2][1]:SetAnchor("BOTTOMLEFT",kb[3][1],"TOPLEFT",key_w/2,key_margin)
    kb[1][1]:SetAnchor("BOTTOMLEFT",kb[2][1],"TOPLEFT",0-key_w/2,key_margin)
    
    kb.h = #kb * (key_h+key_margin)
    
    return kb
end

function Keyboard.CreateWithCallbacks(keycb, backcb, returncb)
    local kb = Keyboard.CreateKB()
    kb.keyfunc = keycb
    kb.backfunc = backcb
    kb.enterfunc = returncb
    return kb
end

function Keyboard.Create(area)
    local kb = Keyboard.CreateKB()
    kb.typingarea = area
    return kb
end

function Keyboard:SetEnterHandler(func)
	self.enterfunc = func
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
