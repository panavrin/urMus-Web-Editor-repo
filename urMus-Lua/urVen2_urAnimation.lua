-----------------------------------------------------------
--                     Animation                         --
-----------------------------------------------------------
-- Allows users to set up animation using sprite sheets for regions.

function MenuAnimation(opt,vv)
    OpenAnimDialog(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function AnimateEvent (self,elapsed)
    self.frameCount = self.frameCount + 1
    if self.frameCount >= self.speed then
        self.curFrame = self.curFrame + 1
        self.col = self.col + 1
        if self.col > self.maxCol then
            self.row = self.row + 1
            self.col = 1
        end
        
        if self.curFrame > (self.maxCol*self.maxRow) then
            self.curFrame = 1
            self.col = 1
            self.row = 1
        end
        self.frameCount = 0
        self.t:SetTexCoord((self.col-1)/self.maxCol,self.row/self.maxRow,self.col/self.maxCol,self.row/self.maxRow,(self.col-1)/self.maxCol,(self.row-1)/self.maxRow,self.col/self.maxCol,(self.row-1)/self.maxRow)
        
    end
    
end

function StartAnimating(vv,col,row,speed)
    vv.frameCount = 0
    vv.curFrame = 1
    vv.maxCol = col
    vv.maxRow = row
    vv.col = 1
    vv.row = 1
    vv.speed = speed
    if vv.eventlist["OnUpdate"]["animate"] == 0 then
        table.insert(vv.eventlist["OnUpdate"],AnimateEvent)
        vv.eventlist["OnUpdate"]["animate"] = 1
    end
end
function CloseAnimDialog(self)
    self.title:Hide()
    for i = 1,#self.tooltips do
        self[i][1]:Hide()
        self[i][2]:Hide()
        self[i][2]:EnableInput(false)
    end
    
    self[#self.tooltips][1]:EnableInput(false)
    mykp:Hide()
    mykb:Hide()
    self.ready = 0
    backdrop:EnableInput(true)
end

function OKAnimclicked(self)
    local dd = self.parent 
    local region = dd.caller
    
    columns = tonumber(dd[1][2].tl:Label())
    rows = tonumber(dd[2][2].tl:Label())
    speed = tonumber(dd[3][2].tl:Label())
    
    
    StartAnimating(region,columns,rows,speed)
    --local spriteSheet = region.bkg
    
    --region:Handle("OnUpdate", animate)
    
    CloseAnimDialog(self.parent)
end

function CANCELAnimclicked(self)
    CloseAnimDialog(self.parent)
end


function CreateAnimOptions(txt,w)
    local r = Region('region','dialog',UIParent)
    r.tl = r:TextLabel()
    r.tl:SetLabel(tostring(txt))
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

animdialog = {}
animdialog.title = Region('region','dialog',UIParent)
animdialog.title.t = animdialog.title:Texture(240,240,240,255)
animdialog.title.tl = animdialog.title:TextLabel()
animdialog.title.tl:SetLabel("Animation")
animdialog.title.tl:SetFontHeight(16)
animdialog.title.tl:SetColor(0,0,0,255) 
animdialog.title.tl:SetHorizontalAlign("JUSTIFY")
animdialog.title.tl:SetShadowColor(255,255,255,255)
animdialog.title.tl:SetShadowOffset(1,1)
animdialog.title.tl:SetShadowBlur(1)
animdialog.title:SetWidth(400)
animdialog.title:SetHeight(50)
animdialog.title:SetAnchor("BOTTOM",UIParent,"CENTER",0,100)
animdialog.tooltips = {{"Columns:","6"},{"Rows","1"},{"Speed","10"},{"OK","CANCEL"}}

animdialog.caller = nil
for i = 1,#animdialog.tooltips do
    animdialog[i] = {}
    animdialog[i][1] = CreateAnimOptions(tostring(animdialog.tooltips[i][1]),250)
    animdialog[i][2] = CreateAnimOptions(animdialog.tooltips[i][2],150)
    animdialog[i][2]:SetAnchor("LEFT",animdialog[i][1],"RIGHT",0,0)
    animdialog[i][1].parent = animdialog
    animdialog[i][2].parent = animdialog
end

animdialog[1][2]:Handle("OnTouchDown",OpenOrCloseKeyPad)
animdialog[2][2]:Handle("OnTouchDown",OpenOrCloseKeyPad)
animdialog[3][2]:Handle("OnTouchDown",OpenOrCloseKeyPad)
animdialog[4][1]:Handle("OnTouchDown",OKAnimclicked)
animdialog[4][2]:Handle("OnTouchDown",CANCELAnimclicked)

animdialog[1][1]:SetAnchor("TOPLEFT",animdialog.title,"BOTTOMLEFT",0,0)

for i = 2,#animdialog.tooltips do
    animdialog[i][1]:SetAnchor("TOPLEFT",animdialog[i-1][1],"BOTTOMLEFT",0,0)
end



----------Function To Open Menu-----------
function OpenAnimDialog(v)
    animdialog.title:Show()
    animdialog.title:MoveToTop()
    animdialog.caller = v
    DPrint("Animation configuration for "..v:Name())
    
    animdialog[1][2].tl:SetLabel(tostring(animdialog.tooltips[1][2]))
    animdialog[2][2].tl:SetLabel(tostring(animdialog.tooltips[2][2]))
    animdialog[3][2].tl:SetLabel(tostring(animdialog.tooltips[3][2]))
    animdialog[4][2].tl:SetLabel(tostring(animdialog.tooltips[4][2]))
    for i = 1,#animdialog.tooltips do
        animdialog[i][1]:Show()
        animdialog[i][2]:Show()
        animdialog[i][1]:MoveToTop()
        animdialog[i][2]:MoveToTop()
        animdialog[i][2]:EnableInput(true)
    end
    animdialog[#animdialog.tooltips][1]:EnableInput(true)
    backdrop:EnableInput(false)
end
