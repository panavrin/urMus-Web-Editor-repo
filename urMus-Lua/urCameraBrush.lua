-- Using the camera as a brush example. Adapted from urPaint and urCameraDemo.
-- A preview of the video is locked in the bottom left of the screen while
--    dragging elsewhere uses the camera texture as a brush.

-- Pat O'Keefe - 3/23/11

FreeAllRegions()

local cregions = {}
crecycledregions = {}

function cRecycleSelf(self)
self:EnableInput(false)
self:EnableMoving(false)
self:EnableResizing(false)
self:Hide()
table.insert(crecycledregions, self)
for k,v in pairs(cregions) do
if v == self then
table.remove(cregions,k)
end
end
end

function cCreateorRecycleregion()
local region
if #crecycledregions > 0 then
region = crecycledregions[#crecycledregions]
table.remove(crecycledregions)
else
region = Region()
region.t = region:Texture(255,255,255,255)
--region.t:SetBlendMode("BLEND")
--region.t:SetTiling()
end
return region
end

local pi = math.pi

function TextureCol(t,r,g,b,a)
t:SetGradientColor("TOP",r,g,b,a,r,g,b,a)
t:SetGradientColor("BOTTOM",r,g,b,a,r,g,b,a)
end

local random = math.random

function cCreateRegionAt(x,y)
local region = cCreateorRecycleregion()
TextureCol(region.t,255,255,255,255)
region.t:UseCamera()
--region.t:SetRotation(-pi/2)
region:Show()
region:EnableMoving(true)
region:EnableResizing(true)
region:EnableInput(true)
--region:Handle("OnDoubleTap", cRecycleSelf)
--region:Handle("OnUpdate", GatherVis)
--region.t:SetTiling()

--region.t:SetRotation(random()*2.0*pi)
--region:SetAnchor("CENTER",x,y)
region:SetAnchor("BOTTOMLEFT",x,y)
table.insert(cregions, region)
return region
end

local lastx =-1
local lasty =-1
local lastdx = -1
local lastdy = -1

function cDraw(self,elapsed)

    if lastx ~= -1 and lasty ~= -1 then
cbrush1:UseAsBrush()
cbrush1.t:SetBrushSize(64)
-- The rotation of -pi/2 is necessary to get a righ-side-up camera texture
cbrush1.t:SetRotation(-pi/2)
self.texture:SetBrushColor(255,255,255,255)
self.texture:Line(lastx, lasty, lastx+lastdx, lasty+lastdy)
lastx = -1
lasty = -1
end
end

function cPaint(self,x,y,dx,dy,n)
cbrush1:UseAsBrush()
cbrush1.t:SetBrushSize(64)
-- The rotation of -pi/2 is necessary to get a righ-side-up camera texture
--cbrush1.t:SetRotation(-pi/2)
self.texture:SetBrushColor(255,255,255,255)
self.texture:Line(x, y, x+dx, y+dy)
--[[if lastx == -1 and lasty == -1 then
lastdx = dx
lastdy = dy
lastx = x
lasty = y
else
lastdx = lastdx + dx
lastdy = lastdy + dy
end--]]
end

function cBrushDown(self,x,y)
self:Handle("OnMove", cPaint)
end

function cBrushUp(self)
self:Handle("OnMove", nil)
end

function cClear(self)
csmudgebackdropregion.texture:Clear(255,255,255,0)
end

csmudgebackdropregion=Region('region', 'smudgebackdropregion', UIParent)
csmudgebackdropregion:SetWidth(ScreenWidth())
csmudgebackdropregion:SetHeight(ScreenHeight())
csmudgebackdropregion:SetLayer("BACKGROUND")
csmudgebackdropregion:SetAnchor('BOTTOMLEFT',0,0)
csmudgebackdropregion.texture = csmudgebackdropregion:Texture()
csmudgebackdropregion.texture:SetTexture(255,255,255,255)

function npow2ratio(n)
    local npow = 1
    while npow < n do
        npow = npow*2
    end
    DPrint(n .. " "..npow)
    return n/npow
end


--csmudgebackdropregion.texture:SetTexCoord(0,npow2ratio(ScreenWidth()),npow2ratio(ScreenHeight()),0.0)

--[[
if ScreenWidth() == 320.0 then
csmudgebackdropregion.texture:SetTexCoord(0,320.0/512.0,480.0/512.0,0.0)
else
csmudgebackdropregion.texture:SetTexCoord(0,ScreenWidth()/1024.0,1.0,0.0)
end
--]]

csmudgebackdropregion:Handle("OnDoubleTap", cClear)
csmudgebackdropregion:Handle("OnTouchDown", cBrushDown)
csmudgebackdropregion:Handle("OnTouchUp", cBrushUp)
--csmudgebackdropregion:Handle("OnUpdate", cDraw)
csmudgebackdropregion:EnableInput(true)
csmudgebackdropregion:Show()


dummp = Region()
dummp.t = dummp:Texture()
dummp.t:UseCamera()
dummp:Show()
--dummp:SetAnchor("BOTTOMLEFT",dummp:Width(),0)
dummp:SetAnchor("BOTTOMLEFT",-dummp:Width(),0)
dummp.t:SetTiling()

--CreateRegionAt(ScreenWidth()/4,ScreenWidth()/4)
preview=cCreateRegionAt(ScreenWidth()/2,ScreenWidth()/4)
--CreateRegionAt(ScreenWidth(),ScreenWidth()/4)


cbrush1=Region('region','brush',UIParent)
cbrush1.t=cbrush1:Texture()
cbrush1.t:SetTiling()
cbrush1.t:UseCamera()
cbrush1:UseAsBrush()


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
