FreeAllRegions()

function flip(self)
	local tile = self.t:Tiling()
	self.t:SetTiling(not tile)
end
		
		
r = Region()
r.t = r:Texture("Ornament1.png")
r.t:SetTexCoord(0,2,0,2)
r.t:SetTiling(false)
r:Show()
r:Handle("OnDoubleTap", flip)
r:EnableInput()
