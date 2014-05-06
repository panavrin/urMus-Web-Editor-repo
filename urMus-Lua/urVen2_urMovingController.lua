-----------------------------------------------------------
--                 Moving Controller                     --
-----------------------------------------------------------

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
