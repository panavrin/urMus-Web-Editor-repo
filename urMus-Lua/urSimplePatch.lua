-- blank file to do testing

function MakePatch(self)
    sinosc = FlowBox(FBSinOsc)
    sinosc2 = FlowBox(FBSinOsc)
--    nop = FlowBox(FBNope)
    push = FlowBox(FBPush)
    accel = FlowBox(FBAccel)
    mic = FlowBox(FBMic)
    dac = FBDac

    dac.In:SetPull(sinosc2.Out)
--    sinosc2.Freq:SetPull(sinosc.Out)
    accel.X:SetPush(sinosc.Freq)
    sinosc.Freq:SetPull(accel.X)
    mic.Out:SetPush(sinosc2.Amp)
    if not rrr then
        rrr = Region()
        rrr.t = rrr:Texture(255,0,0,255)
    end
    rrr:Show()
end

function DestroyPatch(self)
--    FreeAllRegions()
    FreeAllFlowboxes()
--    FreeAllFlowboxes()
--    sinosc = nil
--    r=Region()
--    r:SetWidth(ScreenWidth())
--    r:SetHeight(ScreenHeight())
--    r:Handle("OnTouchDown",MakePatch)
--    r:Handle("OnTouchUp", DestroyPatch)
--    r:EnableInput(true)
    rrr:Hide()
end

r=Region()
r:SetWidth(ScreenWidth())
r:SetHeight(ScreenHeight())
r:Handle("OnTouchDown",MakePatch)
r:Handle("OnTouchUp", DestroyPatch)
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