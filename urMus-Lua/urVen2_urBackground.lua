-----------------------------------------------------------
--                     Background                        --
-----------------------------------------------------------

-- Allows user to select a region to become a background
-- Only animated in release mode.

function Backgroundmove(self,elapsed)   
    if self.bgdir == "U" then
        self.pos2 = self.pos2 - self.bgspeed/1000
    elseif self.bgdir == "D" then
        self.pos2 = self.pos2 + self.bgspeed/1000
    elseif self.bgdir == "R" then
        self.pos1 = self.pos1 - self.bgspeed/1000
    elseif self.bgdir == "L" then
        self.pos1 = self.pos1 + self.bgspeed/1000
    end
    
    self.t:SetTexCoord(0+self.pos1,1+self.pos1,0+self.pos2,1+self.pos2)
end

function StartBackgroundEvent(self,elapsed)
    if current_mode == modes[1] then
        if self:IsShown() then
            self:Hide()
            self.pos1 = 0
            self.pos2 = 0
        end
    else
        if not self:IsShown() then
            self:Show()
        end
        
        Backgroundmove(self,elapsed)
    end
end

function StartBackground(vv)
    vv.bgframeCount = 0
    vv.bgcurFrame = 1
    vv.pos1 = 0
    vv.pos2 = 0
    vv.t:SetTiling(true)
    if vv.eventlist["OnUpdate"]["background"] == 0 then
        table.insert(vv.eventlist["OnUpdate"],StartBackgroundEvent)
        vv.eventlist["OnUpdate"]["background"] = 1
    end
    vv.eventlist["OnUpdate"].currentevent = StartBackgroundEvent
    vv:Handle("OnUpdate",nil)
    vv:Handle("OnUpdate",VUpdate)
end

function MenuBackGround(opt,vv)
    OpenBackDialog(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function OKBackclicked(self)
    local dd = self.parent 
    local region = dd.caller
    
    region.bgdir = tostring(dd[1][2].tl:Label())
    region.bgspeed = tonumber(dd[2][2].tl:Label())
    region:SetHeight(ScreenHeight())
    region:SetWidth(ScreenWidth())
    region:SetAnchor("BOTTOMLEFT",0,0)
    region:SetLayer("BACKGROUND")
    region:EnableInput(false)
    region.t:SetBlendMode("ALPHAKEY")
    CloseBackDialog(self.parent)
    
    StartBackground(region)
end

function CloseBackDialog(self)
    self.title:Hide()
    for i = 1,#self.tooltips do
        self[i][1]:Hide()
        self[i][2]:Hide()
        self[i][2]:EnableInput(false)
    end
    
    self[#self.tooltips][1]:EnableInput(false)
    mykb:Hide()
    self.ready = 0
    backdrop:EnableInput(true)
end

function CANCELBackclicked(self)
    CloseBackDialog(self.parent)
end

backdialog = {}
backdialog.title = Region('region','dialog',UIParent)
backdialog.title.t = backdialog.title:Texture(240,240,240,255)
backdialog.title.tl = backdialog.title:TextLabel()
backdialog.title.tl:SetLabel("BackGround")
backdialog.title.tl:SetFontHeight(16)
backdialog.title.tl:SetColor(0,0,0,255) 
backdialog.title.tl:SetHorizontalAlign("JUSTIFY")
backdialog.title.tl:SetShadowColor(255,255,255,255)
backdialog.title.tl:SetShadowOffset(1,1)
backdialog.title.tl:SetShadowBlur(1)
backdialog.title:SetWidth(550)
backdialog.title:SetHeight(50)
backdialog.title:SetAnchor("BOTTOM",UIParent,"CENTER",0,300)
backdialog.tooltips = {{"Direction (U,D,R,L) to move:","U"},{"Speed:","10"},{"OK","CANCEL"}}

backdialog.ready = 0
backdialog.caller = nil

for i = 1,#backdialog.tooltips do
    backdialog[i] = {}
    backdialog[i][1] = CreateAnimOptions(tostring(backdialog.tooltips[i][1]),400)
    backdialog[i][2] = CreateAnimOptions(backdialog.tooltips[i][2],150)
    backdialog[i][2]:SetAnchor("LEFT",backdialog[i][1],"RIGHT",0,0)
    backdialog[i][1].parent = backdialog
    backdialog[i][2].parent = backdialog
end

backdialog[1][2]:Handle("OnTouchDown",OpenOrCloseKeyboard)
backdialog[2][2]:Handle("OnTouchDown",OpenOrCloseNumericKeyboard)
backdialog[3][1]:Handle("OnTouchDown",OKBackclicked)
backdialog[3][2]:Handle("OnTouchDown",CANCELBackclicked)

backdialog[1][1]:SetAnchor("TOPLEFT",backdialog.title,"BOTTOMLEFT",0,0)
for i = 2,#backdialog.tooltips do
    backdialog[i][1]:SetAnchor("TOPLEFT",backdialog[i-1][1],"BOTTOMLEFT",0,0)
end

function OpenBackDialog(v)
    backdialog.title:Show()
    backdialog.title:MoveToTop()
    backdialog.caller = v
    DPrint("BackGround configuration for "..v:Name())
    for i = 1,#backdialog.tooltips do
        backdialog[i][1]:Show()
        backdialog[i][2]:Show()
        backdialog[i][1]:MoveToTop()
        backdialog[i][2]:MoveToTop()
        backdialog[i][2].tl:SetLabel(tostring(backdialog.tooltips[i][2]))
        backdialog[i][2]:EnableInput(true)
    end
    backdialog[#backdialog.tooltips][1]:EnableInput(true)
    backdialog.ready = 1
    
    backdrop:EnableInput(false)
end
