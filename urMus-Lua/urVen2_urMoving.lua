-----------------------------------------------------------
--                        Moving                         --
-----------------------------------------------------------
--This Script gives all nessecary funcitons to give movement to 
--A region. Includes movemnet funcitons and functions to build
--A interactive menu to adjust paramenters

--------------Moving Functions---------------
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


-------------Menu Building Functions----------------
function MenuMoving(opt,vv)
    OpenMyDialog(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function CreateOptions(txt,w)
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

function CloseMyDialog(self)
    self.title:Hide()
    for i = 1,#self.hint do
        self[i][1]:Hide()
        self[i][2]:Hide()
        self[i][2]:EnableInput(false)
    end
    
    self[#self.hint][1]:EnableInput(false)
    mykb:Hide()
    mykp:Hide()
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

------------Menu Region--------------
mydialog = {}
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
mydialog.hint = {{"Speed (1 to 20, slow to fast)","8"},{"Direction (degrees)","45"},{"Select Vs to bounce from","Click here"},{"Select Vs to bounce from and remove","Click here"},{"OK","CANCEL"}}
mydialog.bounceobjects = {}
mydialog.bounceremoveobjects = {}
mydialog.bouncetype = 0 -- 1:remove after bounce, 0:just bounce
mydialog.ready = 0
mydialog.caller = nil
for i = 1,#mydialog.hint do
    mydialog[i] = {}
    mydialog[i][1] = CreateOptions(tostring(mydialog.hint[i][1]),250)
    mydialog[i][2] = CreateOptions(mydialog.hint[i][2],150)
    mydialog[i][2]:SetAnchor("LEFT",mydialog[i][1],"RIGHT",0,0)
    mydialog[i][1].parent = mydialog
    mydialog[i][2].parent = mydialog
end
mydialog[1][2]:Handle("OnTouchDown",OpenOrCloseKeyPad)
mydialog[2][2]:Handle("OnTouchDown",OpenOrCloseKeyPad)
mydialog[3][2]:Handle("OnTouchDown",SelectBounceObject)
mydialog[4][2]:Handle("OnTouchDown",SelectBounceObjectRemove)
mydialog[5][1]:Handle("OnTouchDown",OKclicked)
mydialog[5][2]:Handle("OnTouchDown",CANCELclicked)

mydialog[1][1]:SetAnchor("TOPLEFT",mydialog.title,"BOTTOMLEFT",0,0)
for i = 2,#mydialog.hint do
    mydialog[i][1]:SetAnchor("TOPLEFT",mydialog[i-1][1],"BOTTOMLEFT",0,0)
end


----------Function To Open Menu-----------
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
    mydialog[1][2].tl:SetLabel(tostring(mydialog.hint[1][2]))
    mydialog[2][2].tl:SetLabel(tostring(mydialog.hint[2][2]))
    mydialog[3][2].tl:SetLabel(tostring(mydialog.hint[3][2]))
    mydialog[4][2].tl:SetLabel(tostring(mydialog.hint[4][2]))
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
