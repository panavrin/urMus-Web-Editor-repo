--Andrew Hayhurst and Michael Musick - Problem 7 - 11.24.2010

-- The differences between this instrument and the one I submitted last week are as follows:

-- Adjusted the Push3Value (frequency of modulating oscillator) range of the slider index.
--   Different ranges for AM and FM
-- SATB regions each have a new and unique OnDoubleTap functionality:
--   S stops audio.
--   A resets the frequency of the modulating oscillator (two different reset values for AM and FM)
--   T switches between the default sine wave and a sine wave with a transfer function.
--   B switches between the default amplitude modulation and frequency modulation
    

FreeAllRegions()

w = ScreenWidth()
h = ScreenHeight()

r = Region()
r:SetWidth(w)
r:SetHeight(h)
r.t = r:Texture()
r.t:SetGradientColor("VERTICAL", 80, 0, 120, 0, 105, 200, 220, 200)
r:Show()

l1 = Region()
l1:SetWidth(w)
l1:SetHeight(2)
l1:SetAnchor("LEFT", 0, h/4)
l1.t = l1:Texture()
l1.t:SetSolidColor(255,255,255,255)
l1:Show()

l2 = Region()
l2:SetWidth(w)
l2:SetHeight(2)
l2:SetAnchor("LEFT", 0, h/20)
l2.t = l2:Texture()
l2.t:SetSolidColor(255,255,255,255)
l2:Show()

l3 = Region()
l3:SetWidth(w)
l3:SetHeight(2)
l3:SetAnchor("LEFT", 0, h/6)
l3.t = l3:Texture()
l3.t:SetSolidColor(255,255,255,255)
l3:Show()

function Play()
    push2:Push(0.9)
    push4:Push(0.2)
end

function Stop()
    push2:Push(0)
    push4:Push(0)
end

function AmpModReset()
    if currentmod == 0 then
        push3:Push(-0.4)
    else
        push3:Push(0.4)
    end
end

currentwave = 0

function TryNewWave()
    if currentwave == 0 then
        dac:RemovePullLink(0, oscil1, 0)
        dac:SetPullLink(0, gain, 0)
        currentwave = 1
    else
        dac:RemovePullLink(0, gain, 0)
        dac:SetPullLink(0, oscil1, 0)
        currentwave = 0
    end
end

currentmod = 0

function SwitchMod()
    if currentmod == 0 then
        push3:Push(0.4)
        oscil1:RemovePullLink(1, oscil2, 0)
        oscil1:SetPullLink(0, oscil2, 0)
        currentmod = 1
        for i,v in pairs(slider) do
            --push3value: go from 0 to 1
            push3value[i] = i/38
        end
    else
        oscil1:RemovePullLink(0, oscil2, 0)
        oscil1:SetPullLink(1, oscil2, 0)
        currentmod = 0
        for i,v in pairs(slider) do
            --push3value: go from -0.8 to 0.2
            push3value[i] = (i/38) - .8
        end
    end
    push2:Push(0.9)
end    
    

strings = {}

for i=1,3 do
    strings[i] = Region()
    strings[i]:SetWidth(2)
    strings[i]:SetHeight(h-h/4)
    local xoffset = (((w/3)*i) - w/6)
    strings[i]:SetAnchor("BOTTOM", xoffset, h/4)
    strings[i].t = strings[i]:Texture()
    strings[i].t:SetSolidColor(255,255,255,255)
    strings[i]:Show()
end

function Appear(self)
    self:Show()
    for i,v in pairs(slider) do
        if v == self then
            push3:Push(push3value[i])
        end
    end
end

function Disappear(self)
    self:Hide()
end

function VocalRange(self)
    for i,v in pairs(satb) do
        satb[i].t:SetSolidColor(25, 180, 150, 150)
        if self == v then
            local rangeoffset = 0
            for i=0, 3 do
                if satb[i] ~= v then
                    rangeoffset = rangeoffset + 12
                else
                    break
                end
            end
            self.t:SetSolidColor(30,100,75,255)
            for i,v in pairs(strings) do
                for k=1, 4 do
                    local index = k+((i-1)*4)
                    pushvalue[index] = freq[index+rangeoffset]
                end
            end
        end
    end
end
                       

satb = {}
for i=0, 3 do
    local newregion = Region()
    newregion:SetWidth(40)
    newregion:SetHeight(40)
    local xoffset = ((i*w)/4)+(w/8)
    local yoffset = 0
    newregion:SetAnchor("CENTER", l2, "LEFT", xoffset, yoffset)
    newregion.t = newregion:Texture()
    newregion.t:SetSolidColor(25, 180, 150, 150)
    newregion.tl = newregion:TextLabel()
    newregion:Handle("OnTouchDown", VocalRange)
    newregion:Show()
    newregion:EnableInput(true)
    satb[i]  = newregion
end

satb[3]:Handle("OnDoubleTap", Stop) --"S" for Stop
satb[2]:Handle("OnDoubleTap", AmpModReset) --"A" for Amplitude Modulator Reset
satb[1]:Handle("OnDoubleTap", TryNewWave) --"T" for Try New Wave
satb[0]:Handle("OnDoubleTap", SwitchMod) -- "B" for Believe in yourself

slider = {}
push3value = {}

for i=0, 38 do
    local newregion = Region()
    newregion:SetWidth(w/12)
    newregion:SetHeight(w/6)
    local xoffset = i*(w/38)
    local yoffset = 0
    newregion:SetAnchor("LEFT", l3, LEFT, xoffset, yoffset)
    newregion.t = newregion:Texture()
    newregion.t:SetGradientColor("HORIZONTAL", 255-(i*6.7), 0, i*6.7, 100, 255-(i*6.7)-6.7, 0, (i*6.7)+7, 100)
    newregion:Handle("OnEnter", Appear)
    newregion:Handle("OnLeave", Disappear)
    newregion:Handle("OnTouchDown", Appear)
    newregion:Handle("OnTouchUp", Disappear)
    newregion:Handle("OnDoubleTap", Reset)
    newregion:EnableInput(true)
    slider[i]  = newregion
    --push3value: go from -0.8 to 0.2
    push3value[i] = (i/38) - .8
end


function TurnRed(self)
    for i,v in pairs(pitches) do
        if self == v then
            if colorcheck[i] == "blue" then
                self.t:SetSolidColor(255,0,0,255)
                push1:Push(pushvalue[i])
                Play()
                colorcheck[i] = "red"
            end
        end
    end
end

function TurnBlue(self)
    for i,v in pairs(pitches) do
        if self == v and colorcheck[i] ~= "purple" then
            self.t:SetSolidColor(0,0,255,255)
            colorcheck[i] = "blue"
        end
    end
end

function TurnPurple(self)
    for i,v in pairs(pitches) do
        if self == v then
            if colorcheck[i] ~= "purple" then
                self.t:SetSolidColor(255,0,255,255)
                colorcheck[i] = "purple"
            else
                self.t:SetSolidColor(0,0,255,255)
                colorcheck[i] = "notpurple"
            end
        end
    end
end



pitches = {}

oscil1 = FlowBox("object","oscil1", _G["FBSinOsc"])
oscil2 = FlowBox("object","oscil2", _G["FBSinOsc"])
oscil3 = FlowBox("object","oscil3", _G["FBSinOsc"])

pgate = FlowBox("object", "pgate", _G["FBPGate"])
gain = FlowBox("object", "gain", _G["FBGain"])

push1 = FlowBox("object","push1", _G["FBPush"])
push2 = FlowBox("object","push2", _G["FBPush"])
push3 = FlowBox("object","push3", _G["FBPush"])
push4 = FlowBox("object","push4", _G["FBPush"])
push5 = FlowBox("object","push5", _G["FBPush"])

dac = _G["FBDac"]

dac:SetPullLink(0, oscil1, 0)

pgate:SetPullLink(0, oscil1, 0)
push5:Push(2.3)
gain:SetPullLink(0, pgate, 0)
push5:SetPushLink(0, gain, 1)



push1:SetPushLink(0, oscil1, 0)
push2:SetPushLink(0, oscil1, 1)
oscil1:SetPullLink(1, oscil2, 0)
push3:SetPushLink(0, oscil2, 0)
push4:SetPushLink(0, oscil2, 1)


push3:Push(-0.4)
push4:Push(0.2)

push2:Push(0)
push1:Push(0)

pushvalue = {}

freq = {}
local log = math.log


freq[1] = 12.0/96.0*log(130.81/55)/log(2) --C3
freq[2] = 12.0/96.0*log(138.59/55)/log(2)
freq[3] = 12.0/96.0*log(146.83/55)/log(2)
freq[4] = 12.0/96.0*log(155.56/55)/log(2)
freq[5] = 12.0/96.0*log(164.81/55)/log(2)
freq[6] = 12.0/96.0*log(174.61/55)/log(2)
freq[7] = 12.0/96.0*log(185.00/55)/log(2)
freq[8] = 12.0/96.0*log(196.00/55)/log(2)
freq[9] = 12.0/96.0*log(207.65/55)/log(2)
freq[10] = 12.0/96.0*log(220.00/55)/log(2)
freq[11] = 12.0/96.0*log(233.08/55)/log(2)
freq[12] = 12.0/96.0*log(246.94/55)/log(2)
freq[13] = 12.0/96.0*log(261.63/55)/log(2) --C4
freq[14] = 12.0/96.0*log(277.18/55)/log(2)
freq[15] = 12.0/96.0*log(293.66/55)/log(2)
freq[16] = 12.0/96.0*log(311.13/55)/log(2)
freq[17] = 12.0/96.0*log(329.63/55)/log(2)
freq[18] = 12.0/96.0*log(349.23/55)/log(2)
freq[19] = 12.0/96.0*log(369.99/55)/log(2)
freq[20] = 12.0/96.0*log(392.00/55)/log(2)
freq[21] = 12.0/96.0*log(415.30/55)/log(2)
freq[22] = 12.0/96.0*log(440.00/55)/log(2)
freq[23] = 12.0/96.0*log(466.16/55)/log(2)
freq[24] = 12.0/96.0*log(493.88/55)/log(2)
freq[25] = 12.0/96.0*log(523.25/55)/log(2)
freq[26] = 12.0/96.0*log(554.37/55)/log(2)
freq[27] = 12.0/96.0*log(587.33/55)/log(2)
freq[28] = 12.0/96.0*log(622.25/55)/log(2)
freq[29] = 12.0/96.0*log(659.26/55)/log(2)
freq[30] = 12.0/96.0*log(698.46/55)/log(2)
freq[31] = 12.0/96.0*log(739.99/55)/log(2)
freq[32] = 12.0/96.0*log(783.99/55)/log(2)
freq[33] = 12.0/96.0*log(830.61/55)/log(2)
freq[34] = 12.0/96.0*log(880.00/55)/log(2)
freq[35] = 12.0/96.0*log(932.33/55)/log(2)
freq[36] = 12.0/96.0*log(987.77/55)/log(2)
freq[37] = 12.0/96.0*log(1046.50/55)/log(2) --C6
freq[38] = 12.0/96.0*log(1108.73/55)/log(2)
freq[39] = 12.0/96.0*log(1174.66/55)/log(2)
freq[40] = 12.0/96.0*log(1244.51/55)/log(2)
freq[41] = 12.0/96.0*log(1318.51/55)/log(2)
freq[42] = 12.0/96.0*log(1396.91/55)/log(2)
freq[43] = 12.0/96.0*log(1479.98/55)/log(2)
freq[44] = 12.0/96.0*log(1567.98/55)/log(2)
freq[45] = 12.0/96.0*log(1661.22/55)/log(2)
freq[46] = 12.0/96.0*log(1760.00/55)/log(2)
freq[47] = 12.0/96.0*log(1864.66/55)/log(2)
freq[48] = 12.0/96.0*log(1975.53/55)/log(2)


        


for i,v in pairs(strings) do
    for k=1, 4 do
        local newregion = Region()
        newregion:SetWidth(60)
        newregion:SetHeight(60)
        newregion:SetAnchor("CENTER", v, "TOP", 0, -((k*2)-1)/8 * (h*(3/4)))
        newregion.t = newregion:Texture()
        newregion.t:SetSolidColor(0,0,255,255)
        newregion:Show()
        newregion:Handle("OnTouchDown", TurnRed)
        newregion:Handle("OnTouchUp", TurnBlue)
        newregion:Handle("OnEnter", TurnRed)
        newregion:Handle("OnLeave", TurnBlue)
        newregion:Handle("OnDoubleTap", TurnPurple)
        newregion:EnableInput(true)
        newregion.tl = newregion:TextLabel()
        pitches[k+((i-1)*4)] = newregion
        
    end
end

colorcheck = {}
for i,v in pairs(pitches) do
    colorcheck[i] = "blue"
end

pitches[1].tl:SetLabel("C")
pitches[2].tl:SetLabel("C#")
pitches[3].tl:SetLabel("D")
pitches[4].tl:SetLabel("Eb")
pitches[5].tl:SetLabel("E")
pitches[6].tl:SetLabel("F")
pitches[7].tl:SetLabel("F#")
pitches[8].tl:SetLabel("G")
pitches[9].tl:SetLabel("Ab")
pitches[10].tl:SetLabel("A")
pitches[11].tl:SetLabel("Bb")
pitches[12].tl:SetLabel("B")

satb[0].tl:SetLabel("B")
satb[1].tl:SetLabel("T")
satb[2].tl:SetLabel("A")
satb[3].tl:SetLabel("S")

VocalRange(satb[1])

DPrint("") 

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