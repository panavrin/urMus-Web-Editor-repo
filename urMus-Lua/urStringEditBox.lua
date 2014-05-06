-- Load utility and library functions here
dofile(SystemPath("urKeyboard.lua"))

local finished
local mykb

function OpenStringEditBox(str,label,finishhandler,x,y,w,h,fh,r,g,b,a)

    finished = finishhandler
    
    str = str or ""

    w = w or ScreenWidth()/2
    h = h or ScreenHeight()/22
    x = x or ScreenWidth()/4
    y = y or ScreenHeight()/2-h/2
    fh = fh or ScreenHeight()/24
    editborder = Region()
    editborder:SetLayer("TOOLTIP")
    editbox = Region()
    editbox:SetWidth(w)
    editbox:SetHeight(h)
    editbox:SetAnchor("BOTTOMLEFT", x,y)
    r = r or 0
    g = g or 255
    b = b or 255
    a = a or 160
    editbox.t = editbox:Texture(r,g,b,a)
    editbox.tl = editbox:TextLabel()
    editbox.tl:SetLabel(str)
    editbox.tl:SetFontHeight(fh)
    editbox.tl:SetHorizontalAlign("CENTER")
    editbox:SetLayer("TOOLTIP")
    editbox.t:SetBlendMode("BLEND")
    if label then
        labelbox = Region()
        labelbox.tl = labelbox:TextLabel()
        labelbox.tl:SetLabel(label)
        labelbox.tl:SetVerticalAlign("BOTTOM")
        labelbox.tl:SetHorizontalAlign("LEFT")
        labelbox.tl:SetFontHeight(fh*0.6)
        labelbox:SetAnchor("BOTTOMLEFT",editbox,"TOPLEFT",8,0)
        labelbox:SetLayer("TOOLTIP")
        labelbox:Show()
    end
    border = border or 16
    editborder:SetWidth(w+border)
    if label then
        editborder:SetHeight(h+border+fh*0.6)
          editborder:SetAnchor("CENTER", editbox, "CENTER",0,fh*0.3)
    else
        editborder:SetHeight(h+border)
          editborder:SetAnchor("CENTER", editbox, "CENTER",0,0)
    end
     editborder.t = editborder:Texture(r/2,g/2,b/2,a)
    editborder.t:SetBlendMode("BLEND")
    editborder:Show()
    editbox:Show()
    
    mykb = Keyboard.Create()

    local function FinishEntry()
        mykb:Hide()
        editbox:Hide()
        finished(editbox.tl:Label())
    end

    mykb:SetEnterHandler(FinishEntry)
    
    mykb.typingarea = editbox
    mykb:Show(1)
end



