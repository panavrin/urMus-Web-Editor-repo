
function vg_Paint(self, data)
	local visout
    if not self.datafunc then
        visout = data
    else
        visout = self.datafunc()
    end
    if not visout then return end
    local x = self:Width()/2 + visout*self:Width()/2
--	self.texture:SetBrushColor(128-math.abs(visout)*128,128-math.abs(visout)*128,128-math.abs(visout)*128,255,0,0,0,255)
	self.texture:SetBrushColor(128,128,128,255,0,0,0,255)
--    self.texture:SetGradientColor("TOP",128,128,128,255,255,255,255,255)

	self.texture:Line(self.lastx, self.lasty, x, self.lasty+1)
	self.lasty = self.lasty + 1
    if self.lasty > self:Height() then
		self.texture:Clear(255,255,255)
		self.lasty = 0
	end
end

function CreateLineGraph(w,h,datafunc)
	visgraphbackdropregion=Region()
	visgraphbackdropregion:SetWidth(w)
	visgraphbackdropregion:SetHeight(h)
	visgraphbackdropregion:SetLayer("BACKGROUND")
	visgraphbackdropregion:SetAnchor('BOTTOMLEFT',0,0)
	visgraphbackdropregion.texture = visgraphbackdropregion:Texture()
	visgraphbackdropregion.texture:SetSolidColor(255,255,255,255)
--	visgraphbackdropregion.texture:SetTexCoord(0,0.63,0.94,0.0)
    visgraphbackdropregion.Paint = vg_Paint
	visgraphbackdropregion:Show()
	
	visgraphbackdropregion.texture:Clear(255,255,255)
	visgraphbackdropregion.texture:ClearBrush()
	visgraphbackdropregion.lastx = w/2
	visgraphbackdropregion.lasty = h
    visgraphbackdropregion.datafunc = datafunc
    return visgraphbackdropregion
end

