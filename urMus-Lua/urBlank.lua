-- blank file to do testing


local rescalex = ScreenWidth()/320.0
local rescaley = ScreenHeight()/480.0

smudgebackdropregion=Region('region', 'smudgebackdropregion', UIParent);
smudgebackdropregion:SetWidth(ScreenWidth());
smudgebackdropregion:SetHeight(ScreenHeight());
smudgebackdropregion:SetLayer("BACKGROUND");
smudgebackdropregion:SetAnchor('BOTTOMLEFT',0,0); 
smudgebackdropregion.texture = smudgebackdropregion:Texture();
smudgebackdropregion.texture:SetTexture(255,255,255,255);
if ScreenWidth() == 320.0 then
smudgebackdropregion.texture:SetTexCoord(0,320.0/512.0,480.0/512.0,0.0);
else
smudgebackdropregion.texture:SetTexCoord(0,ScreenWidth()/1024.0,1.0,0.0);
end
smudgebackdropregion:Show();

smudgebackdropregion.texture:ClearBrush()
smudgebackdropregion.texture:SetBrushSize(1)
smudgebackdropregion.texture:SetBrushColor(0,0,255,255)
smudgebackdropregion.texture:Line(20,20,300,300)
--[[smudgebackdropregion.texture:SetBrushSize(4)
smudgebackdropregion.texture:SetBrushColor(0,255,255,255)
smudgebackdropregion.texture:Ellipse(160*rescalex, 240*rescaley, 120*rescalex, 120*rescaley)
smudgebackdropregion.texture:SetFill(true)
smudgebackdropregion.texture:SetBrushColor(255,0,255,190)
smudgebackdropregion.texture:Ellipse(160*rescalex, 240*rescaley, 120*rescalex, 120*rescaley)
smudgebackdropregion.texture:SetBrushColor(255,0,0,90)
smudgebackdropregion.texture:Rect(40*rescalex,40*rescaley,100*rescalex,100*rescaley)
smudgebackdropregion.texture:SetFill(false)
smudgebackdropregion.texture:SetBrushColor(0,255,0,60)
smudgebackdropregion.texture:SetBrushSize(4)
smudgebackdropregion.texture:Quad((320-20)*rescalex,(480-20)*rescaley,(320-300)*rescalex,(480-40)*rescaley,(320-40)*rescalex,(480-400)*rescaley,(320-290)*rescalex,(480-390)*rescaley)

for i=1,100 do
smudgebackdropregion.texture:SetBrushSize(math.random(1,16))
smudgebackdropregion.texture:SetBrushColor(math.random(128,255),0,0,60)
smudgebackdropregion.texture:Point(math.random(0,ScreenWidth()),math.random(0,ScreenHeight()))
end
--]]
brush1=Region('region','brush',UIParent)
brush1.t=brush1:Texture()
brush1.t:SetTexture("circlebutton-16.png");
brush1.t:SetSolidColor(127,0,0,15)
brush1:UseAsBrush();

for i=1,100 do
smudgebackdropregion.texture:SetBrushSize(math.random(1,16))
smudgebackdropregion.texture:SetBrushColor(0,math.random(128,255),0,128)
smudgebackdropregion.texture:Point(math.random(0,ScreenWidth()),math.random(0,ScreenHeight()))
end

smudgebackdropregion.texture:SetBrushSize(8)
smudgebackdropregion.texture:SetBrushColor(0,0,255,190)
smudgebackdropregion.texture:Line(200,200,500,500)
--[[
smudgebackdropregion.texture:Ellipse((320-160)*rescalex, (480-240)*rescaley, 120*rescalex, 80*rescaley)
smudgebackdropregion.texture:SetBrushColor(0,255,0,60)
smudgebackdropregion.texture:Quad(20*rescalex,20*rescaley,300*rescalex,40*rescaley,40*rescalex,400*rescaley,290*rescalex,390*rescaley)
smudgebackdropregion.texture:SetBrushColor(255,0,0,90)
smudgebackdropregion.texture:Rect((320-40-100)*rescalex,(480-40-100)*rescaley,100*rescalex,100*rescaley)

smudgebackdropregion.texture:SetBrushColor(255,127,0,30)

brush1.t:SetBrushSize(32);
--]]

