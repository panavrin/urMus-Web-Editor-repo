-- urTextureDuplication.lua
FreeAllRegions()

r1=Region()
r1.t = r1:Texture("Ornament1.png")
r1:Show()

r2=Region()
r2.t = r2:Texture("Ornament1.png")
r2:Show()
r2:SetAnchor("BOTTOMLEFT",200,200)
r2.t:Line(0,0,r2.t:Width(),r2.t:Height())
