-- urTopBar
-- by Georg Essl
-- Created: August 2011
-- Last modified: 08/11/2011
-- Copyright (c) 2010-11 Georg Essl. All Rights Reserved. See LICENSE.txt for license conditions.

-- CreateTopBar
-- Syntax, num, label1, function1, label2, function2,...
function grabLabelFunction(label, func, ...)
	return label, func, ...
end

local menubottonheight = 28

function CreateTopBar(num,...)
	if num > 0 then
		barbutton = {}
	end
	for i=1,num do
		local label = select(i*2-1,...)
		local func = select(i*2,...)
		barbutton[i]=Region()
		barbutton[i]:SetWidth(ScreenWidth()/num)
		barbutton[i]:SetHeight(menubottonheight)
		barbutton[i]:SetLayer("TOOLTIP")
		barbutton[i]:SetAnchor('BOTTOMLEFT',(i-1)*ScreenWidth()/num,ScreenHeight()-menubottonheight) 
		barbutton[i]:EnableClamping(true)
		barbutton[i]:Handle("OnDoubleTap", func)
		barbutton[i].texture = barbutton[i]:Texture("button.png")
		barbutton[i].texture:SetGradientColor("TOP",128,128,128,255,128,128,128,255)
		barbutton[i].texture:SetGradientColor("BOTTOM",128,128,128,255,128,128,128,255)
		barbutton[i].texture:SetBlendMode("BLEND")
		barbutton[i].texture:SetTexCoord(0,1.0,0,0.625)
		barbutton[i]:EnableInput(true)
		barbutton[i]:Show()
		barbutton[i].textlabel=barbutton[i]:TextLabel()
		barbutton[i].textlabel:SetFont(urfont)
		barbutton[i].textlabel:SetHorizontalAlign("CENTER")
		barbutton[i].textlabel:SetLabel(label)
		barbutton[i].textlabel:SetFontHeight(16)
		barbutton[i].textlabel:SetColor(255,255,255,255)
		barbutton[i].textlabel:SetShadowColor(0,0,0,190)
		barbutton[i].textlabel:SetShadowBlur(2.0)
	end
end
