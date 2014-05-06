-- Load utility and library functions here
dofile(SystemPath("urKeyboard.lua"))
dofile(SystemPath("urTopBar.lua"))

CreateTopBar(5,"Clear",ClearCode,"New",NewCode,"Load",LoadCode,"Save",SaveCode,"Run",RunCode)

local mykb = Keyboard.Create()

EditRegion = Region()
EditRegion:SetWidth(ScreenWidth())
EditRegion:SetHeight(ScreenHeight()-mykb:Height()-28)
EditRegion:SetAnchor("BOTTOMLEFT",0,mykb:Height())
EditRegion.tl = EditRegion:TextLabel()
EditRegion.tl:SetVerticalAlign("TOP")
EditRegion.tl:SetHorizontalAlign("LEFT")
EditRegion.tl:SetFontHeight(ScreenHeight()/20)
EditRegion:Show()

mykb.typingarea = EditRegion
mykb:Show(1)
