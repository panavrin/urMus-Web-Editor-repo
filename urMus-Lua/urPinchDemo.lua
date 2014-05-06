FreeAllRegions()

local oldx1, oldx2,oldy1,oldy2
local scale = 1
local distancetoscale = 1 -- Change this to change pinch zoom sensitivity


function handleTouchUp(self)
    oldx1 = nil   
--    DPrint("up")
end

function toggleLock(self)
    self.ei = not self.ei
    self:EnableMoving(self.ei)
    self:EnableResizing(not self.ei)
--    self:EnableInput(self.ei)
end

function handleResize(self,x1,y1,x2,y2)
    r2:SetWidth(r:Width()-2*borderw)
    r2:SetHeight(r:Height()-2*borderh)
   
    if oldx1 then
        local olddist = math.sqrt((oldx2-oldx1)*(oldx2-oldx1)+(oldy2-oldy1)*(oldy2-oldy1))
        local dist = math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
        local ddist = dist-olddist
        scale = scale + ddist/self:Width()/distancetoscale
        DPrint(x1.." "..y1..", "..x2.." "..y2..":"..scale.." ("..ddist..")")
        if(scale > 0.5) then scale = 0.5 end
        if(scale < -0.5) then scale = -0.5 end
        r3.t:SetTexCoord(-scale+0.5,0.5+scale,-scale+0.5,0.5+scale)
        r4.t:SetTexCoord(-scale+0.5,0.5+scale,-scale+0.5,0.5+scale)
    end
    oldx1 = x1
    oldx2 = x2
    oldy1 = y1
    oldy2 = y2
   
end

r = Region()
r.t = r:Texture()
r:Show()
r.t:SetTexture(255,0,0,255)
r:EnableMoving(true)
r:EnableInput(true)
r:EnableResizing(true)
r.ei = true
r:Handle("OnSizeChanged", handleResize)
r:Handle("OnDoubleTap", toggleLock)

r:SetAnchor("BOTTOMLEFT",100,100)

borderw = r:Width()/2
borderh = r:Height()/2

r2 = Region()
r2.t = r2:Texture()
r2:SetWidth(r:Width()/2)
r2:SetHeight(r:Height()/2)


r2:SetAnchor("CENTER",r,"CENTER",0,0)
r2.t:SetTexture(0,255,0,255)
r2:Show()

r3 = Region()
r3.t = r3:Texture()
r3.t:SetTexture("Ornament1.png")
r3:Show()
r3:EnableMoving(true)
r3:EnableInput(true)
r3.ei = true
--r3:EnableResizing(true)
r3:Handle("OnSizeChanged", handleResize)
r3:Handle("OnTouchUp", handleTouchUp)
r3:Handle("OnDoubleTap", toggleLock)

r4 = Region()
r4:SetWidth(ScreenWidth()/2)
r4:SetHeight(ScreenHeight()/2)
r4.t = r4:Texture()
r4.t:SetTexture("Ornament1.png")
--r4.t:UseCamera()
r4:Show()
r4:EnableMoving(true)
r4:EnableResizing(false)
r4:EnableInput(true)
r4.ei = true
--r3:EnableResizing(true)
r4:Handle("OnSizeChanged", handleResize)
r4:Handle("OnTouchUp", handleTouchUp)
--r4:Handle("OnDoubleTap", toggleLock)
r4:SetAnchor("BOTTOMLEFT",ScreenWidth()/2,ScreenHeight()/2)

local pagebutton=CreatePagerButton()

