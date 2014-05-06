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

function loadPicture(opt,vv)
    local pictureentries = {}
    for v in lfs.dir(SystemPath("")) do
        if v ~= "." and v ~= ".." and string.find(v,"%.png$") then
            local entry = { v, nil, nil, LoadAndActivateInterface, {84,84,84,255}, SystemPath(""),SystemPath(v)}
            table.insert(pictureentries, entry)            
        end
    end
    for v in lfs.dir(DocumentPath("")) do
        if v ~= "." and v ~= ".." and string.find(v,"%.png$") then
            local entry = { v, nil, nil, LoadAndActivateInterface, {84,84,84,255}, DocumentPath(""),DocumentPath(v)}
            table.insert(pictureentries, entry)            
        end
    end
    urPictureList:OpenScrollListPage1(39, "Load a Picture",nil,nil,pictureentries,vv)
    placeholder = {}
    
    
end

function MenuColorRandomly(opt,vv)
    vv.r = math.random(0,255)
    vv.g = math.random(0,255)
    vv.b = math.random(0,255)
    vv.a = math.random(0,255)
    vv.t:SetSolidColor(vv.r,vv.g,vv.b,vv.a)
    DPrint(vv:Name().." random color (r,g,b,a): ("..vv.r..","..vv.g..","..vv.b..","..vv.a..")")
end

function MenuGradientRandom(opt, vv)
    vv.r1 = math.random(0,255)
    vv.r2 = math.random(0,255)
    vv.r3 = math.random(0,255)
    vv.r4 = math.random(0,255)
    vv.g1 = math.random(0,255)
    vv.g2 = math.random(0,255)
    vv.g3 = math.random(0,255)
    vv.g4 = math.random(0,255)
    vv.b1 = math.random(0,255)
    vv.b2 = math.random(0,255)
    vv.b3 = math.random(0,255)
    vv.b4 = math.random(0,255)
    vv.a1 = math.random(0,255)
    vv.a2 = math.random(0,255)
    vv.a3 = math.random(0,255)
    vv.a4 = math.random(0,255)
    vv.t:SetGradientColor("TOP",vv.r1,vv.g1,vv.b1,vv.a1,vv.r2,vv.g2,vv.b2,vv.a2)
    vv.t:SetGradientColor("BOTTOM",vv.r3,vv.g3,vv.b3,vv.a3,vv.r4,vv.g4,vv.b4,vv.a4)
end

function MenuClearToWhite(opt,vv)
    DPrint(vv:Name().." clear to white")
    vv.r = 255
    vv.g = 255
    vv.b = 255
    vv.a = 255
    vv.bkg = ""
    vv.r1 = nil
    vv.r2 = nil
    vv.r3 = nil
    vv.r4 = nil
    vv.g1 = nil
    vv.g2 = nil
    vv.g3 = nil
    vv.g4 = nil
    vv.b1 = nil
    vv.b2 = nil
    vv.b3 = nil
    vv.b4 = nil
    vv.a1 = nil
    vv.a2 = nil
    vv.a3 = nil
    vv.a4 = nil
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

function menuGradient(opt,vv)
    OpenGradDialog(vv,pics)
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

function MenuProjectileController(opt,vv)
    DPrint("Use a controller to control the projectiles from "..vv:Name())
end

function MenuControllerLeft(opt,vv) -- this set of 4 functions are for moving controllers
    if vv.left_controller == nil then
        controller = CreateController()
        controller.t = controller:Texture('left.png')
        controller.t:SetBlendMode("ALPHAKEY")
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
        controller.t = controller:Texture('right.png')
        controller.t:SetBlendMode("ALPHAKEY")
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
        controller.t:SetBlendMode("ALPHAKEY")
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
        controller.t:SetBlendMode("ALPHAKEY")
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

function MenuGenerationOff(opt,vv)
    if vv.eventlist["OnUpdate"]["generate"] == 1 then
        table.remove(vv.eventlist["OnUpdate"],#vv.eventlist["OnUpdate"])
        vv.eventlist["OnUpdate"]["generate"] = 0
    end
    UnHighlight(opt)
    CloseMenuBar()
end


function FPSEvent(self, elapsed)
    self.fps = self.fps + 1/elapsed
    self.count = self.count +1
    self.sec = elapsed + self.sec
    if (self.sec > .0001) then
        
        self.tl:SetLabel( math.floor(self.fps/self.count))
        self.sec = 0
    end 
end

function MenuFPS(opt, vv)
    if vv.eventlist["OnUpdate"]["fps"] == 0 then
        table.insert(vv.eventlist["OnUpdate"],FPSEvent)
        vv.eventlist["OnUpdate"]["fps"] = 1
    end
    
    vv.count = 0
    vv.fps = 0
    vv.sec = 0
    UnHighlight(opt)
    CloseMenuBar()
end
