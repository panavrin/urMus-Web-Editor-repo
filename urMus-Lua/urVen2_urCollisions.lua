-----------------------------------------------------------
--                    Collisions                         --
-----------------------------------------------------------
--Script dedicated to setting up collisions and the
--nessecary functions to make them happen

----------     Collision Functions      ----------
function colcheckregionregion(self)
    for i = 1,#self.regionregion do
        if self:RegionOverlap(regions[self.regionregion[i]]) then
            RemoveV(regions[self.regionregion[i]])
            table.remove(self.regionregion,i)
        end
    end
end            


function colcheckregionproj(self)
    for i = 1,#self.regionproj do
        for j = 1,regions[self.regionproj[i]].numProjectiles do
            if regions[self.regionproj[i]][j].live then
                if self:RegionOverlap(regions[self.regionproj[i]]) then
                    regions[self.regionproj[i]][j].live = false
                    regions[self.regionproj[i]][j]:Hide()
                end
            end
        end
    end
end

function colcheckprojregion(self)
    for i = 1,#self.projregion do
        for j = 1,self.numProjectiles do
            if self[j].live then                
                if self[j]:RegionOverlap(regions[self.projregion[i]]) then
                    self[j].live = false                   
                    self[j]:Hide()
                end
            end
        end
    end
end

function colcheckprojproj(self)
    for i = 1,#self.projproj do
        for j = 1,self.numProjectiles do
            if self[j].live then
                for k = 1,regions[self.projproj[i]].numProjectiles do
                    if regions[self.projproj[i]][k].live then
                        if self[j]:RegionOverlap(regions[self.projproj[i]][k]) then
                            self[j].live = false
                            regions[self.projproj[i]][k].live = false
                            self[j]:Hide()
                            regions[self.projproj[i]][k]:Hide()
                        end
                    end
                end
            end
        end
    end
end


function StartCollisionEvent(self,elapsed)
    if #self.regionregion > 0 then
        colcheckregionregion(self)
    end
    if #self.regionproj > 0 then
        colcheckregionproj(self)
    end
    if #self.projregion > 0 then
        colcheckprojregion(self)
    end
    if #self.projproj > 0 then
        colcheckprojproj(self)
    end
end

function StartCollision(vv)
    if vv.eventlist["OnUpdate"]["collision"] == 0 then
        table.insert(vv.eventlist["OnUpdate"],StartCollisionEvent)
        vv.eventlist["OnUpdate"]["collision"] = 1
    end
    vv.eventlist["OnUpdate"].currentevent = StartCollisionEvent
    vv:Handle("OnUpdate",nil)
    vv:Handle("OnUpdate",VUpdate)
end


---------- Collision Menu and Functions ----------
function MenuCollisions(opt, vv)
    OpenColDialog(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function CollisionObject(self)
    if self.id == coldialog.caller.id then
        DPrint("Please select objects other than "..coldialog.caller:Name())
        return
    end
    local found1 = 0 -- regionregion
    local found2 = 0 -- regionproj
    local found3 = 0 -- projregion
    local found4 = 0 -- projproj
    for i = 1,#coldialog.projproj do
        if coldialog.projproj[i] == self.id then
            found4 = 1
            break
        end
    end
    if found4 == 0 then
        for i = 1,#coldialog.projregion do
            if coldialog.projregion[i] == self.id then
                found3 = 1
                break
            end
        end
    end
    if found4 == 0 and found3 == 0 then
        for i = 1,#coldialog.regionproj do
            if coldialog.regionproj[i] == self.id then
                found2 = 1
                break
            end
        end
    end
    if found4 == 0 and found3 == 0 and found2 == 0 then
        for i = 1,#coldialog.regionproj do
            if coldialog.regionregion[i] == self.id then
                found1 = 1
                break
            end
        end
    end
    
    if found1 == 0 and found2 == 0 and found3 == 0 and found4 == 0 then
        if coldialog.coltype == 0 then
            table.insert(coldialog.regionregion,self.id)
            coldialog[1][2].tl:SetLabel(coldialog[1][2].tl:Label().." #"..self.id)
            coldialog.regionregion.touch = 1
            DPrint(self:Name().." selected to Region Region collision")
        elseif coldialog.coltype == 1 then
            table.insert(coldialog.regionproj,self.id)
            coldialog[2][2].tl:SetLabel(coldialog[2][2].tl:Label().." #"..self.id)
            coldialog.regionproj.touch = 1
            DPrint(self:Name().." selected to Region Projectile collision")
        elseif coldialog.coltype == 2 then
            table.insert(coldialog.projregion,self.id)
            coldialog[3][2].tl:SetLabel(coldialog[3][2].tl:Label().." #"..self.id)
            coldialog.projregion.touch = 1
            DPrint(self:Name().." selected to Projectile Region collision")
        else
            table.insert(coldialog.projproj,self.id)
            coldialog[4][2].tl:SetLabel(coldialog[4][2].tl:Label().." #"..self.id)
            coldialog.projproj.touch = 1
            DPrint(self:Name().." selected to Projectile Projectile collision")
        end
    else
        DPrint(self:Name().. " already selected.")
    end        
end

function OKColclicked(self)
    local dd = self.parent 
    local region = dd.caller
    
    region.regionregion = dd.regionregion
    region.regionproj = dd.regionproj
    region.projregion = dd.projregion
    region.projproj = dd.projproj    
    
    CloseColDialog(self.parent)
    
    StartCollision(region)
end

function CloseColDialog(self)
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

function CANCELColclicked(self)
    CloseColDialog(self.parent)
end

function Selectregionregion(self)
    self.parent.coltype = 0
    if self.parent.regionregion.touch == 0 then
        self.parent[1][2].tl:SetLabel("")
    end    
end

function Selectregionproj(self)
    self.parent.coltype = 1
    if self.parent.regionproj.touch == 0 then
        self.parent[2][2].tl:SetLabel("")
    end    
end

function Selectprojregion(self)
    self.parent.coltype = 2
    if self.parent.projregion.touch == 0 then
        self.parent[3][2].tl:SetLabel("")
    end    
end

function Selectprojproj(self)
    self.parent.coltype = 3
    if self.parent.projproj.touch == 0 then
        self.parent[4][2].tl:SetLabel("")
    end    
end


coldialog = {}
coldialog.title = Region('region','dialog',UIParent)
coldialog.title.t = coldialog.title:Texture(240,240,240,255)
coldialog.title.tl = coldialog.title:TextLabel()
coldialog.title.tl:SetLabel("Collisions")
coldialog.title.tl:SetFontHeight(16)
coldialog.title.tl:SetColor(0,0,0,255) 
coldialog.title.tl:SetHorizontalAlign("JUSTIFY")
coldialog.title.tl:SetShadowColor(255,255,255,255)
coldialog.title.tl:SetShadowOffset(1,1)
coldialog.title.tl:SetShadowBlur(1)
coldialog.title:SetWidth(550)
coldialog.title:SetHeight(50)
coldialog.title:SetAnchor("BOTTOM",UIParent,"CENTER",0,300)
coldialog.tooltips = {{"Region to Region Collisions:","Tap Here"},{"Region to Projectile Collisions with:","Tap Here"},{"Projectile to Region Collisions:","Tap Here"},{"Projectile to Projectile Collisions:","Tap Here"},{"OK","CANCEL"}}
coldialog.regionregion = {}
coldialog.regionproj = {}
coldialog.projregion = {}
coldialog.projproj = {}

coldialog.ready = 0
coldialog.caller = nil

for i = 1,#coldialog.tooltips do
    coldialog[i] = {}
    coldialog[i][1] = CreateAnimOptions(tostring(coldialog.tooltips[i][1]),400)
    coldialog[i][2] = CreateAnimOptions(coldialog.tooltips[i][2],150)
    coldialog[i][2]:SetAnchor("LEFT",coldialog[i][1],"RIGHT",0,0)
    coldialog[i][1].parent = coldialog
    coldialog[i][2].parent = coldialog
end

coldialog[1][2]:Handle("OnTouchDown",Selectregionregion)
coldialog[2][2]:Handle("OnTouchDown",Selectregionproj)
coldialog[3][2]:Handle("OnTouchDown",Selectprojregion)
coldialog[4][2]:Handle("OnTouchDown",Selectprojproj)
coldialog[5][1]:Handle("OnTouchDown",OKColclicked)
coldialog[5][2]:Handle("OnTouchDown",CANCELColclicked)

coldialog[1][1]:SetAnchor("TOPLEFT",coldialog.title,"BOTTOMLEFT",0,0)

for i = 2,#coldialog.tooltips do
    coldialog[i][1]:SetAnchor("TOPLEFT",coldialog[i-1][1],"BOTTOMLEFT",0,0)
end

function OpenColDialog(v)
    coldialog.title:Show()
    coldialog.title:MoveToTop()
    coldialog.caller = v
    DPrint("Collsion configuration for "..v:Name())
    while #coldialog.regionregion > 0 do
        table.remove(coldialog.regionregion)
    end
    while #coldialog.regionproj > 0 do
        table.remove(coldialog.regionproj)
    end
    while #coldialog.projregion > 0 do
        table.remove(coldialog.projregion)
    end
    while #coldialog.projproj > 0 do
        table.remove(coldialog.projproj)
    end
    while #coldialog.caller.regionregion > 0 do
        table.remove(coldialog.caller.regionregion)
    end
    while #coldialog.caller.regionproj > 0 do
        table.remove(coldialog.caller.regionproj)
    end
    while #coldialog.caller.projregion > 0 do
        table.remove(coldialog.caller.projregion)
    end
    while #coldialog.caller.projproj > 0 do
        table.remove(coldialog.caller.proj)
    end
    for i = 1,#coldialog.tooltips do
        coldialog[i][1]:Show()
        coldialog[i][2]:Show()
        coldialog[i][1]:MoveToTop()
        coldialog[i][2]:MoveToTop()
        coldialog[i][2].tl:SetLabel(tostring(coldialog.tooltips[i][2]))
        coldialog[i][2]:EnableInput(true)
    end
    coldialog[#coldialog.tooltips][1]:EnableInput(true)
    coldialog.ready = 1
    coldialog.coltype = 0
    coldialog.regionregion.touch = 0
    coldialog.regionproj.touch = 0
    coldialog.projregion.touch = 0
    coldialog.projproj.touch = 0
    
    backdrop:EnableInput(false)
end
