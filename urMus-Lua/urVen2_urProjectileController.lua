-----------------------------------------------------------
--               Projectile Controller                   --
-----------------------------------------------------------
-- Allows users to set up a controller to control
-- the production of projectiles from a region.

-- Frame work for 4 directions exist but not yet implemented.
-- Currently only works firing forward(up) on the screen

local move_step = 10
local move_holdtime = 0.01

function CreateGenController()
    local controller = Region('region','controller',UIParent)
    controller:SetWidth(75)
    controller:SetHeight(75)
    controller.t = controller:Texture(SystemPath("buttonarrow.png"))
    controller.t:SetBlendMode("ALPHAKEY")
    controller:Handle("OnTouchUp",GenControllerTouchUp)
    controller:Handle("OnLeave",GenControllerTouchUp)
    return controller
end

function GenControllerTouchUp(self)
    UnHighlight(self)
    self:Handle("OnUpdate",nil)
end

function GenControllerTouchDownB(self)
    CloseSharedStuff(nil)
    if current_mode == modes[2] then
        self:EnableMoving(false)
    else
        self:EnableMoving(true)
    end
    self.holdtime = move_holdtime
    Highlight(self)
end

function RemoveGenController(self)
    if current_mode == modes[1] then
        self:Hide()
        self:EnableInput(false)
        self:EnableMoving(false)
        DPrint("DoubleTap removes the controller. To re-enable it, please repeat its configuration.")
    end
end   

function buttonProjectiles(self)
    for i = 1, self.caller.numProjectiles do        
        if not self.caller[i].live then            
            self.caller[i].live = true
            if self.direction == "U" then  
                self.caller[i].speedy = self.caller.projectileSpeed      
                self.caller[i].speedx = 0                
                self.caller[i].y = self.caller.bottomY                
                self.caller[i].x = self.caller.centerX-25                             
            elseif self.direction == "D" then
                self.caller[i].speedy = -self.caller.projectileSpeed
                self.caller[i].speedx = 0   
                self.caller[i].y = self.caller.topY-50               
                self.caller[i].x = self.caller.centerX-25               
            elseif self.direction == "L" then        
                self.caller[i].speedx = self.caller.projectileSpeed 
                self.caller[i].speedy = 0                   
                self.caller[i].x = self.caller.rightX-50                
                self.caller[i].y = self.caller.centerY-25                
            elseif self.direction == "R" then 
                self.caller[i].speedx = -self.caller.projectileSpeed
                self.caller[i].speedy = 0                   
                self.caller[i].x = self.caller.leftX                
                self.caller[i].y = self.caller.centerY-25                
            end 
            break            
        end        
    end    
end

function TriggerGen(self,e)
    self:MoveToTop()
    self.holdtime = self.holdtime - e
    self.time = self.time + 1
    if self.holdtime <= 0 then
        if self.time >= 15 then
            buttonProjectiles(self)
            self.time = 0
        end
        self.holdtime = move_holdtime
    end
end 

function GenControllerTouchDown(self)
    GenControllerTouchDownB(self)
    buttonProjectiles(self)
    self:Handle("OnUpdate",TriggerGen)
end

function drawControllerProjectiles(self)
    for i = 1, self.numProjectiles do
        if self[i].live then
            self[i]:Show() 
        end
    end
end

function updateControllerProjectiles(self)
    for i = 1, self.numProjectiles do        
        if self[i].live then
            self[i].x = self[i].x + self[i].speedx
            self[i].y = self[i].y + self[i].speedy
            self[i]:SetAnchor("BOTTOMLEFT",self[i].x,self[i].y)
        end
        if self[i].live and self[i].y > ScreenHeight() or self[i].y < 0 or self[i].x > ScreenWidth() or self[i].x < 0 then
            self[i].live = false 
            self[i]:Hide()
        end
    end
end

function ProjectileEvent(self,elapsed)
    self.topY = self:Top()
    self.bottomY = self:Bottom()
    self.rightX = self:Right()
    self.leftX = self:Left()
    self.centerX,self.centerY = self:Center()    
    self.width = self:Width()
    
    drawControllerProjectiles(self)
    updateControllerProjectiles(self)
end    

function MenuProjLeft(opt,vv)
    local direction = "L"
    MenuGenController(opt,vv,direction)
end
function MenuProjRight(opt,vv)
    local direction = "R"
    MenuGenController(opt,vv,direction)
end
function MenuProjDown(opt,vv)
    local direction = "D"
    MenuGenController(opt,vv,direction)
end
function MenuProjUp(opt,vv)
    local direction = "U"
    MenuGenController(opt,vv,direction)
end

function MenuGenController(opt,vv,direction)   
    if direction == "L" then
        if vv.gencontrollerL == nil then
            controller = CreateGenController()
            controller:SetAnchor("LEFT",UIParent,"CENTER",10,0)
            controller.t:SetRotation(-math.pi/2)
            controller.caller = vv
            controller.time = 0
            controller.direction = "L"
            controller:Handle("OnDoubleTap",RemoveGenController)
            controller:Handle("OnTouchDown",GenControllerTouchDown)
            vv.gencontrollerL = controller
        end  
    end
    if direction == "R" then
        if vv.gencontrollerR == nil then
            controller = CreateGenController()
            controller:SetAnchor("RIGHT",UIParent,"CENTER",-10,0)
            controller.t:SetRotation(math.pi/2)
            controller.caller = vv
            controller.time = 0
            controller.direction = "R"
            controller:Handle("OnDoubleTap",RemoveGenController)
            controller:Handle("OnTouchDown",GenControllerTouchDown)
            vv.gencontrollerR = controller
        end  
    end
    if direction == "U" then
        if vv.gencontroller == nil then
            controller = CreateGenController()
            controller:SetAnchor("BOTTOM",UIParent,"CENTER",0,10)
            controller.caller = vv
            controller.time = 0
            controller.direction = "U"
            controller:Handle("OnDoubleTap",RemoveGenController)
            controller:Handle("OnTouchDown",GenControllerTouchDown)
            vv.gencontroller = controller
        end  
    end
    if direction == "D" then
        if vv.gencontrollerD == nil then
            controller = CreateGenController()
            controller:SetAnchor("TOP",UIParent,"CENTER",0,-10)
            controller.t:SetRotation(math.pi)
            controller.caller = vv
            controller.time = 0
            controller.direction = "D"
            controller:Handle("OnDoubleTap",RemoveGenController)
            controller:Handle("OnTouchDown",GenControllerTouchDown)
            vv.gencontrollerD = controller
        end  
    end
    
    vv.numProjectiles = 10
    vv.projectileSpeed = 10
    vv.direction = "U"
    if vv[1] == nil then
        for i = 1,vv.numProjectiles do
            vv[i] = createProjectiles(vv)
        end
    end
    if vv.eventlist["OnUpdate"]["projectile"] == 0 then
        table.insert(vv.eventlist["OnUpdate"],ProjectileEvent)
        vv.eventlist["OnUpdate"]["projectile"] = 1
    end    
    if direction == "L" then
        vv.gencontrollerL:Show()
        vv.gencontrollerL:EnableInput(true)
        vv.gencontrollerL:EnableMoving(true)
    end    
    if direction == "R" then
        vv.gencontrollerR:Show()
        vv.gencontrollerR:EnableInput(true)
        vv.gencontrollerR:EnableMoving(true)
    end 
    if direction == "U" then
        vv.gencontroller:Show()
        vv.gencontroller:EnableInput(true)
        vv.gencontroller:EnableMoving(true)
    end 
    if direction == "D" then
        vv.gencontrollerD:Show()
        vv.gencontrollerD:EnableInput(true)
        vv.gencontrollerD:EnableMoving(true)
    end 
end
