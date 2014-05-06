local clat
local clong

function Rotate(self,x,y,z,h)
    self.t:SetRotation(h*math.pi)           
--    self.t:SetTexture(DocumentPath("map.png"))
end

function GPS(self,lat,long)
--    local x,y = InputPosition()
    if lat ~= clat or long~= clong then
--        lat = 43.69064547/180 + x / 4000
--        long = -82.98623126/180 + y / 4000
        DPrint(lat .. " " ..long.." center="..(lat*180)..","..(long*180))
        WriteURLData("http://maps.google.com/maps/api/staticmap?center="..(lat*180)..","..(long*180).."&zoom=14&size=512x512&maptype=roadmap&sensor=false&format=png", "map.png")
--        WriteURLData("http://maps.google.com/maps/api/staticmap?center=43.69064547,-82.98623126&zoom=14&size=512x512&maptype=roadmap&sensor=false&format=png", "map.png")
        clat = lat
        clong = long
    end
    self.t:SetTexture(DocumentPath("map.png"))
end

WriteURLData("http://maps.google.com/maps/api/staticmap?center=Brooklyn+Bridge,New+York,NY&zoom=14&size=512x512&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318&markers=color:red%7Ccolor:red%7Clabel:C%7C40.718217,-73.998284&sensor=false&format=png", "map.png")
r = Region()
r:SetWidth(2*1024)
r:SetHeight(2*1024)
r:SetAnchor("CENTER",UIParent,"CENTER", 0,0)
--r.t = r:Texture(DocumentPath("map.png"))
r.t = r:Texture("map.png")
--r.t = r:Texture(255,255,255,255)
r:Show()
r:Handle("OnHeading",Rotate)
r:Handle("OnLocation",GPS)
--r:Handle("OnTouchDown",GPS)

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