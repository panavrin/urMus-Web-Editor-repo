
local function NewConnection(self, name, btype)
    notRegion.tl:SetLabel("Connected: "..name.."\n"..btype)
--DPrint("connect "..name)
end

local function LostConnection(self, name, btype)
    notRegion.tl:SetLabel("Disconnected: "..name.."\n"..btype)
--    DPrint("disconnect "..name)
end

function Highlight(self)
    self.t:SetSolidColor(0,0,255,255)
end

function Trigger(self)
    if not self.triggered then
        self.triggered = true
        StartNetAdvertise("testomatic",8888)
        self.tl:SetLabel("Advertising")
        self.t:SetSolidColor(190,0,0,255)
    else
        self.triggered = nil
        StopNetAdvertise("testomatic")
        self.tl:SetLabel("Advertise")
        Deselect(self)
    end
end

function Deselect(self)
    self.t:SetSolidColor(0,0,190,255)
end

function Trigger2(self)
    if not self.triggered2 then
        self.triggered2 = true
        self.tl:SetLabel("Discovering")
        StartNetDiscovery("testomatic")
        self.t:SetSolidColor(190,0,0,255)
    else
        self.triggered2 = nil
        StopNetDiscovery("testomatic")
        self.tl:SetLabel("Discover")
        Deselect(self)
    end
end

adRegion = Region()
adRegion:SetWidth(ScreenWidth()/2)
adRegion:SetHeight(ScreenHeight()/3)
adRegion:SetAnchor("CENTER",UIParent,"CENTER",0,ScreenHeight()/4)
adRegion.t = adRegion:Texture(0,0,190,255)
adRegion.tl = adRegion:TextLabel()
adRegion.tl:SetLabel("Advertise")
adRegion.tl:SetFontHeight(adRegion:Height()/8)
adRegion:Show()
adRegion:Handle("OnTouchDown", Highlight)
adRegion:Handle("OnTouchUp", Trigger)
adRegion:Handle("OnLeave", Deselect)
adRegion:Handle("OnEnter", Highlight)
adRegion:EnableInput(true)

discRegion = Region()
discRegion:SetWidth(ScreenWidth()/2)
discRegion:SetHeight(ScreenHeight()/3)
discRegion:SetAnchor("CENTER",UIParent,"CENTER",0,-ScreenHeight()/4)
discRegion.t = discRegion:Texture(0,0,190,255)
discRegion.tl = discRegion:TextLabel()
discRegion.tl:SetLabel("Discover")
discRegion.tl:SetFontHeight(discRegion:Height()/8)
discRegion:Show()
discRegion:Handle("OnTouchDown", Highlight)
discRegion:Handle("OnTouchUp", Trigger2)
discRegion:Handle("OnLeave", Deselect)
discRegion:Handle("OnEnter", Highlight)
discRegion:EnableInput(true)

notRegion = Region()
notRegion:SetWidth(ScreenWidth())
notRegion:SetHeight(ScreenHeight()/3)
notRegion:SetAnchor("CENTER",UIParent,"CENTER",0,0)
notRegion.tl = notRegion:TextLabel()
notRegion.tl:SetLabel("")
notRegion.tl:SetFontHeight(notRegion:Height()/8)
notRegion:Show()
notRegion:Handle("OnNetConnect", NewConnection)
notRegion:Handle("OnNetDisconnect", LostConnection)

