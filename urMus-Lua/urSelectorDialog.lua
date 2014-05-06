
function HighlightButton(self)
    self.t:SetSolidColor( 0,255,255,160)      
end

function UnhighlightButton(self)
    self.t:SetSolidColor( 0,2/3*255,2/3*255,160)      
end

function SelectButton(self)
    UnhighlightButton(self)
    editborder:Hide()
    if self.func then
        self.func()
    end
end

function SelectorDialog(label,num,...)

    finished = finishhandler
    
    str = str or ""

    w = w or ScreenWidth()/2
    h = h or ScreenHeight()/22
    x = x or ScreenWidth()/4
    y = y or ScreenHeight()/2-h/2
    fh = fh or ScreenHeight()/24
    editborder = Region()
    editborder:SetLayer("TOOLTIP")
    r = r or 0
    g = g or 255
    b = b or 255
    a = a or 160
    if label then
        labelbox = Region()
        labelbox:SetWidth(w)
        labelbox.tl = labelbox:TextLabel()
        labelbox.tl:SetLabel(label)
        labelbox.tl:SetVerticalAlign("TOP")
        labelbox.tl:SetHorizontalAlign("CENTER")
        labelbox.tl:SetFontHeight(fh*0.6)
        labelbox:SetAnchor("TOPLEFT",editborder,"TOPLEFT",8,0)
        labelbox:SetLayer("TOOLTIP")
        labelbox:Show()
    end
    border = border or 16
    editborder:SetWidth(w+border)
    editborder:SetAnchor("BOTTOMLEFT",x,y)
    editborder.t = editborder:Texture(r/2,g/2,b/2,a)
    editborder.t:SetBlendMode("BLEND")
    editborder:Show()

    if num > 0 then
        barbutton = {}
    end
    for i=1,num do
        local label = select(i*2-1,...)
        local func = select(i*2,...)
        barbutton[i]=Region()
        barbutton[i]:SetWidth(w/num*0.8)
        barbutton[i]:SetHeight(h)
        barbutton[i]:SetLayer("TOOLTIP")
        barbutton[i]:SetAnchor('BOTTOMLEFT',editborder,"BOTTOMLEFT",(i-1)*w/num+w/num*0.1,-(h-fh)/2+fh)
        barbutton[i]:EnableClamping(true)
        barbutton[i].func = func
        barbutton[i]:Handle("OnTouchDown", HighlightButton)
        barbutton[i]:Handle("OnEnter", HighlightButton)
        barbutton[i]:Handle("OnLeave", UnhighlightButton)
        barbutton[i]:Handle("OnTouchUp", SelectButton)
        barbutton[i].t = barbutton[i]:Texture(2/3*r,2/3*g,2/3*b,a)
        barbutton[i].t:SetBlendMode("BLEND")
        barbutton[i]:EnableInput(true)
        barbutton[i]:Show()
        barbutton[i].textlabel=barbutton[i]:TextLabel()
        barbutton[i].textlabel:SetFont(urfont)
        barbutton[i].textlabel:SetHorizontalAlign("CENTER")
        barbutton[i].textlabel:SetLabel(label)
        barbutton[i].textlabel:SetFontHeight(fh)
        barbutton[i].textlabel:SetColor(255,255,255,255)
        barbutton[i].textlabel:SetShadowColor(0,0,0,190)
        barbutton[i].textlabel:SetShadowBlur(2.0)
    end
end

--SelectorDialog("Delete?",2,"OK",ConfirmDelete,"Cancel",nil)

