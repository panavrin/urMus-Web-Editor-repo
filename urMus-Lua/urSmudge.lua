
local fingerposx, fingerposy = InputPosition()
local random = math.random
local dopaint = false

local rescalex = ScreenWidth()/320.0
local rescaley = ScreenHeight()/480.0

function Paint(self)
	if not dopaint then
		for i=1,10 do
			brush1.t:SetBrushSize(random(1,16));
			self.texture:SetBrushColor(random(0,255),random(0,255),random(0,255),random(1,60))
			self.texture:Point(random(0,ScreenWidth()),random(0,ScreenHeight()+32))
		end
		return
	end
	local x,y = InputPosition()
--	x = x*320.0/ScreenWidth() -- Converting texture to screen coordinates (requires for iPad as they mismatch there)
--	y = y*480.0/ScreenHeight()
	if x ~= fingerposx or y ~= fingerposy then
		brush1.t:SetBrushSize(32)
		y = y + 32
--		brush1.t:SetBrushSize(16)
--		self.texture:SetBrushColor(255,127,0,60)
--		self.texture:Point(x, y)
		self.texture:SetBrushColor(255,127,0,30)
		self.texture:Line(fingerposx, fingerposy, x, y)
		fingerposx, fingerposy = x,y
	end
end

function BrushDown(self)
	dopaint = true
	fingerposx, fingerposy = InputPosition()
--	fingerposx = fingerposx*320.0/ScreenWidth() -- Converting texture to screen coordinates (requires for iPad as they mismatch there)
--	fingerposy = fingerposy*480.0/ScreenHeight()
end

function BrushUp(self)
	dopaint = false
end

function Clear(self)

--    smudgebackdropregion.texture:FinishMovie();

	smudgebackdropregion.texture:Clear(255,255,255,0);
--    DPrint("finishing")
end

smudgebackdropregion=Region('region', 'smudgebackdropregion', UIParent);
smudgebackdropregion:SetWidth(ScreenWidth());
smudgebackdropregion:SetHeight(ScreenHeight());
smudgebackdropregion:SetLayer("BACKGROUND");
smudgebackdropregion:SetAnchor('BOTTOMLEFT',0,0); 
--smudgebackdropregion:EnableClamping(true)
--smudgebackdropregion.texture = smudgebackdropregion:Texture("Default.png");
smudgebackdropregion.texture = smudgebackdropregion:Texture();
smudgebackdropregion.texture:SetTexture(255,255,255,255);
--smudgebackdropregion.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
--smudgebackdropregion.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
--smudgebackdropregion.texture:SetBlendMode("BLEND")
--smudgebackdropregion.texture:SetTexCoord(0,0.63,0.94,0.0);



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
	smudgebackdropregion.texture:SetTexCoord(0,320.0/512.0,480.0/512.0,0.0);
else
	smudgebackdropregion.texture:SetTexCoord(0,ScreenWidth()/1024.0,1.0,0.0);
end
--]]
--smudgebackdropregion.texture:Clear(255,255,255,0);
smudgebackdropregion:Handle("OnUpdate", Paint);
smudgebackdropregion:Handle("OnDoubleTap", Clear);
smudgebackdropregion:Handle("OnTouchDown", BrushDown)
smudgebackdropregion:Handle("OnTouchUp", BrushUp)
smudgebackdropregion:EnableInput(true);
smudgebackdropregion:Show();
--smudgebackdropregion.texture:Clear(0.8,0.8,0.8);

smudgebackdropregion.texture:ClearBrush()
smudgebackdropregion.texture:SetBrushSize(1)
smudgebackdropregion.texture:SetFill(true)
smudgebackdropregion.texture:SetBrushColor(0,0,255,30)
smudgebackdropregion.texture:Ellipse(160*rescalex, 240*rescaley, 120*rescalex, 120*rescaley)
smudgebackdropregion.texture:SetBrushColor(255,0,0,90)
smudgebackdropregion.texture:Rect(40*rescalex,40*rescaley,100*rescalex,100*rescaley)
smudgebackdropregion.texture:SetFill(false)
smudgebackdropregion.texture:SetBrushColor(0,255,0,60)
smudgebackdropregion.texture:Quad((320-20)*rescalex,(480-20)*rescaley,(320-300)*rescalex,(480-40)*rescaley,(320-40)*rescalex,(480-400)*rescaley,(320-290)*rescalex,(480-390)*rescaley)

brush1=Region('region','brush',UIParent)
brush1.t=brush1:Texture()
brush1.t:SetTexture("circlebutton-16.png");
brush1.t:SetSolidColor(127,0,0,15)
brush1:UseAsBrush();

smudgebackdropregion.texture:SetBrushColor(0,0,255,30)
smudgebackdropregion.texture:Ellipse((320-160)*rescalex, (480-240)*rescaley, 120*rescalex, 80*rescaley)
smudgebackdropregion.texture:SetBrushColor(0,255,0,60)
smudgebackdropregion.texture:Quad(20*rescalex,20*rescaley,300*rescalex,40*rescaley,40*rescalex,400*rescaley,290*rescalex,390*rescaley)
smudgebackdropregion.texture:SetBrushColor(255,0,0,90)
smudgebackdropregion.texture:Rect((320-40-100)*rescalex,(480-40-100)*rescaley,100*rescalex,100*rescaley)

smudgebackdropregion.texture:SetBrushColor(255,127,0,30)

brush1.t:SetBrushSize(32);
--smudgebackdropregion.texture:WriteMovie("urMus-test.mp4");

pagersize = pagersize or 32
local pagebutton=Region('region', 'pagebutton', UIParent);
pagebutton:SetWidth(pagersize);
pagebutton:SetHeight(pagersize);
pagebutton:SetLayer("TOOLTIP");
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
--pagebutton:Handle("OnDoubleTap", FlipPage)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show();
