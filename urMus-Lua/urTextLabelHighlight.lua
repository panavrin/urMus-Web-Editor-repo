
dofile(SystemPath("FAIAP.lua"))


FreeAllRegions()

local waiter = 0.1
local cnt = 0

recycles = {}

hl = {}

function RecycleOrCreateHighlight(xs,ys,xe,ye)

    if #recycles == 0 then
		local r2 = Region()
		r2:SetAnchor("BOTTOMLEFT",xs+r:Left(),ys+r:Bottom())
		r2:SetWidth(xe-xs)
		r2:SetHeight(ye-ys)
		r2.t = r2:Texture(255,0,0,50)
		r2.t:SetBlendMode("BLEND")
		r2:Show()
        return r2
    end
end

function wait(self, elapsed)
    if cnt > waiter then
		local xs,ys,xe,ye = r.tl:LabelBounds(0,0)
        DPrint((xs or "nil").." "..(ys or "nil").." : "..(xe or "nil").." "..(ye or "nil"))
        r3 = Region()
        r3:SetAnchor("BOTTOMLEFT",xs+r:Left(),ys+r:Bottom())
        r3:SetWidth(3)
        r3:SetHeight(ye-ys)
        r3.t = r3:Texture(0,0,255,50)
        r3:Show()
        hl[1] = RecycleOrCreateHighlight(xs,ys,xe,ye)
		self:Handle("OnUpdate", nil)
    end
    cnt = cnt + elapsed
end

startpos = 0
endpos = 1

function highlightbounds(startpos,endpos)
    local bounds = pack(r.tl:LabelBounds(startpos,endpos))
    local str = ""
    for k,v in ipairs(bounds) do
        str = str .. v .." "
    end
    DPrint(#bounds..": "..str)
    local j = 1
    for i=1,#bounds,4 do
        local xs,ys,xe,ye = bounds[i],bounds[i+1],bounds[i+2],bounds[i+3]
--        DPrint((startpos or "nil")..":: "..(xs or "nil").." "..(ys or "nil").." : "..(xe or "nil").." "..(ye or "nil"))
        r3:SetAnchor("BOTTOMLEFT",xe+r:Left(),ys+r:Bottom())
        if not hl[j] then
            hl[j] = RecycleOrCreateHighlight(xs,ys,xe,ye)
        end
        hl[j]:SetAnchor("BOTTOMLEFT",xs+r:Left(),ys+r:Bottom())
        hl[j]:SetWidth(xe-xs)
        hl[j]:SetHeight(ye-ys)
        hl[j]:Show()
        j = j + 1
    end
    
    for k=j,#hl do
        hl[k]:Hide()
    end

end

function selecthighlight(self)
	local x,y = InputPosition()
	startpos = self.tl:CharPosition(x,y)
--	DPrint(startpos or "nil")
    if startpos >= 0 and endpos >= 0 then
        if endpos <= startpos then endpos = startpos+1 end
        highlightbounds(startpos,endpos)
    end
end

function draghighlight(self,x,y,dx,dy)
	endpos = self.tl:CharPosition(x,y)
    if startpos >= 0 and endpos >= 0 then
        if startpos >= endpos then startpos = endpos-1 end
        highlightbounds(startpos,endpos)
    end
end

function pack(...)
    return arg
end

--local code = 'local test="yo"\nDPrint(|cff0000fftest|cffffffff)\nif test=="yo||" then\nDPrint("yo")\nend'
local code = 'local test="yo"\nDPrint(test)\nif test=="yo||" then\nDPrint("yo")\nend'



colorTable = colorhighlightlib.defaultColorTable
colorTable[0] = "|r"

--newcode = colorhighlightlib.colorCodeCode(code, colorTable, 0)
newcode = colorhighlightlib.indentCode(code, 2, colorTable, 0)
DPrint(newcode)
r = Region()
r:SetWidth(ScreenWidth())
r:SetHeight(ScreenHeight())
r.tl = r:TextLabel()
r.tl:SetLabel(newcode)
r.tl:SetHorizontalAlign("LEFT")
--r.tl:SetHorizontalAlign("RIGHT")
--r.tl:SetVerticalAlign("BOTTOM")
r.tl:SetVerticalAlign("TOP")
r.tl:SetFontHeight(32)
r:Show()
r:Handle("OnUpdate", wait)
r:Handle("OnTouchDown", selecthighlight)
r:Handle("OnMove", draghighlight)
r:EnableInput(true)

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