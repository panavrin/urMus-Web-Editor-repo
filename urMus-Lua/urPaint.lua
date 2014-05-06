
function Paint(self,x,y,dx,dy,n)
    brush1.t:SetBrushSize(32)
    self.texture:SetBrushColor(255,127,(6-n)*50,30)
    self.texture:Line(x, y, x+dx, y+dy)
    fingerposx, fingerposy = fingerposx+dx,fingerposy+dy
end

function BrushDown(self,x,y)
    fingerposx, fingerposy = x, y
    self:Handle("OnMove", Paint)
end

function BrushUp(self)
    self:Handle("OnMove", nil)
end

function Clear(self)
    smudgebackdropregion.texture:Clear(255,255,255,0)
end

smudgebackdropregion=Region('region', 'smudgebackdropregion', UIParent)
smudgebackdropregion:SetWidth(ScreenWidth())
smudgebackdropregion:SetHeight(ScreenHeight())
smudgebackdropregion:SetLayer("BACKGROUND")
smudgebackdropregion:SetAnchor('BOTTOMLEFT',0,0)
smudgebackdropregion.texture = smudgebackdropregion:Texture()
smudgebackdropregion.texture:SetTexture(255,255,255,255)


function npow2ratio(n)
    local npow = 1
    while npow < n do
        npow = npow*2
    end
    DPrint(n .. " "..npow)
    return n/npow
end


--smudgebackdropregion.texture:SetTexCoord(0,npow2ratio(ScreenWidth()),npow2ratio(ScreenHeight()),0.0)
--[[
if ScreenWidth() == 320.0 then
    smudgebackdropregion.texture:SetTexCoord(0,320.0/512.0,480.0/512.0,0.0)
else
    smudgebackdropregion.texture:SetTexCoord(0,ScreenWidth()/1024.0,1.0,0.0)
end
--]]

smudgebackdropregion:Handle("OnDoubleTap", Clear)
smudgebackdropregion:Handle("OnTouchDown", BrushDown)
smudgebackdropregion:Handle("OnTouchUp", BrushUp)
smudgebackdropregion:EnableInput(true)
smudgebackdropregion:Show()

local pi = math.pi

brush1=Region('region','brush',UIParent)
brush1.t=brush1:Texture()
brush1.t:SetTexture("circlebutton-16.png")
brush1.t:SetSolidColor(127,0,0,15)
brush1:UseAsBrush()

smudgebackdropregion.texture:SetBrushColor(255,127,0,30)

brush1.t:SetBrushSize(32)

local pagebutton=Region('region', 'pagebutton', UIParent)
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4)
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()