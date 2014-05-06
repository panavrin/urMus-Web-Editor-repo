-----------------------------------------------------------
--                      Color Wheel                      --
-----------------------------------------------------------


local color_w = 256
local color_h = 256


function MenuChangeColor(opt,vv)
    color_wheel:Show()
    color_wheel.region = vv
    color_wheel:EnableInput(true)
    backdrop:EnableInput(false)
    UnHighlight(opt)
    CloseMenuBar()
end


function UpdateColor(self,x,y,dx,dy)
    local xx = (x+dx)*1530/color_w
    local yy = y+dy
    local r=0
    local g=0
    local b=0
    self.region.a=yy-1
    
    if xx < 255 then
        r = 255
        g = xx
        b = 0
    elseif xx < 510 then
        r = 510 - xx
        g = 255
        b = 0
    elseif xx < 765 then
        r = 0
        g = 255
        b = xx - 510
    elseif xx < 920 then
        r = 0 
        g = 920 - xx
        b = 255
    elseif xx < 1175 then
        r = xx - 920
        g = 0
        b = 255
    else
        r = 255
        g = 0
        b = 1530 - xx
    end
    
    self.region.r = r*self.region.a/255
    self.region.g = g*self.region.a/255
    self.region.b = b*self.region.a/255
    
    VSetTexture(self.region)
    DPrint("r"..math.floor(self.region.r).." g"..math.floor(self.region.g).." b"..math.floor(self.region.b).." a"..math.floor(self.region.a)..". Double tap to close.")
end

function CloseColorWheel(self)
    self:Hide()
    self:EnableInput(false)
    backdrop:EnableInput(true)
    DPrint("color wheel closed")
end

color_wheel = Region('region','colorwheel',UIParent)
color_wheel.t = color_wheel:Texture()
color_wheel.t:SetTexture('color_map.png')
color_wheel:SetWidth(color_w)
color_wheel:SetHeight(color_h)
color_wheel:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT") 
color_wheel:MoveToTop()
color_wheel:EnableInput(false)
color_wheel:EnableMoving(false)
color_wheel:EnableResizing(false)
color_wheel:Handle("OnMove",UpdateColor)
color_wheel:Handle("OnDoubleTap",CloseColorWheel)
