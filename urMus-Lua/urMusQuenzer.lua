-- urMusQuenzer.lua
-- by Georg Essl & Nate Derbinsky

--[SoarImprov]

--;c="CEG_ EGB_ FAC_"
--;n="CEGE EGBG FACA"

--c="CEG_ GBD_ ACE_ EGB_ FAC_ CEG_ FAC_ GBD_"
--n="EGGE DGGD CEEC BEEB ACCA GCCG ACCE DCDD"

trainchords = {"CEG", "GBD", "ACE", "EGB", "FAC", "CEG", "FAC", "GBD"}
trainnotes = {"EGGE", "DGGD", "CEEC", "BEEB", "ACCA", "GCCG", "ACCE", "DCDD"}

local maxchords = #trainchords
local maxnotes = 4
local currchord = 1
local currnote = 1

--FreeAllRegions()

--backdrop = Region()
local backdrop = Region('region','backdrop',UIParent)
backdrop:SoarLoadRules("MusQuenzer", "soar")

local rand = math.random

b = {}
c = {{255,0,0,255},{0,255,0,255},{0,0,255,255},{255,255,0,255},{255,0,255,255},{0,255,255,255},{255,255,255,255}}

nrpads = 4
nrx = 1
nry = 7

local tw, th

memory = {}


local maxsequence = 10

function GenerateSequence()
	
	for i = 1,maxsequence do
		memory[i] = rand(1,4)
	end
	
end



function EraseMemory(self)
	--    self:SoarDelete(gameresult)
end

local lastDecision = math.floor(Time()*10)
local delayDecisions = 50
local clickcount = 0
local maxclicks = 10

local maxgenchords = 5
local genchords = {}

function soarGenerateNextChord()
	-- tell soar about the task
	taskWme = backdrop:SoarCreateConstant(0, "task", "chord")

	for i = 1, maxgenchords do
		local name, params =  backdrop:SoarGetOutput()
		genchords[i] = {}
		genchords[i][1] = params.chord1
		genchords[i][2] = params.chord2
		genchords[i][3] = params.chord3
		backdrop:SoarSetOutputStatus(1)
	end

	-- clear task
	backdrop:SoarDelete(taskWme)
	
end

local maxgennotes = maxgenchords * 4
local gennotes = {}

function soarGenerateNextNote()
	-- tell soar about the task
	taskWme = backdrop:SoarCreateConstant(0, "task", "note")

	for i = 1, maxgennotes do
		local name, params =  backdrop:SoarGetOutput()
		gennotes[i] = params.note
		backdrop:SoarSetOutputStatus(1)
	end

	-- clear task
	backdrop:SoarDelete(taskWme)
	
end

local nextpad
local gencount = 0
local maxgencount = 10

function soarGenerate(self, elapsed)
	currwait = currwait + elapsed
	

	if currwait > waittime then
		
		currwait = currwait - waittime
		
		
		if not currshow then
			
			nextpad = soarGenerateNext()
			TouchColorPad(b[nextpad])
	
			gencount = gencount + 1
			if gencount > maxgencount then
				local str = self:SoarExec("stats")
				str = str .. self:SoarExec("stats --max")
--				DPrint(str)
				self:Handle("OnUpdate", nil)
			end
	
			currshow = true
		else
			LeftPad(b[nextpad])
			
			currshow = false
--			currpos = currpos + 1
			
--			if currpos > currmax then
--				currpos = 1
--				currmax = currmax + 1
--				if currmax > maxsequence then
--					currmax = 1   
--					GenerateSequence()   
--				end
--			end
		end
	end
end

local learning = false

local chords = trainchords
local notes = trainnotes

local noteLength = 4

function soarLearning(index)

    for i=1,maxchords do --  Optional for interactions.
        local chordWmes = {}
        for j=1,3 do
            chordWmes[j] = backdrop:SoarCreateConstant(0, "chord"..j, chords[i]:sub(j,j))
        end
        
        time1Wme = backdrop:SoarCreateConstant(0, "time-chord", i)
    
        for j=1,noteLength do
            backdrop:SoarExec("step "..delayDecisions)
                    
            -- time+note
            time2Wme = backdrop:SoarCreateConstant(0, "time-note", (i-1)*noteLength + j)
            listenWme = backdrop:SoarCreateConstant(0, "note", notes[i]:sub(j,j))
    
                    
            -- wait
            backdrop:SoarExec("step "..delayDecisions)
--				DPrint(backdrop:SoarExec("print --depth 10 s1"))
                    
            -- remove time+note
            backdrop:SoarDelete(time2Wme)
            time2Wme = nil
            backdrop:SoarDelete(listenWme)
            listenWme = nil				
            -- wait
            backdrop:SoarExec("step "..delayDecisions)
        end
    
        backdrop:SoarDelete(time1Wme)
        time1Wme = nil
    
        -- clear chord inputs
        for j=1,3 do
            backdrop:SoarDelete(chordWmes[j]);
            chordWmes[j] = nil
        end
    end
end

function TouchColorPad(self)
	self.t:SetSolidColor(self.c[1]/2,self.c[2]/2,self.c[3]/2,self.c[4])
end

function DisableAllChordButtons(index)
    for i=1,7 do
        b[i]:EnableInput(false)
        if i ~= index then
            b[i]:Hide()
        end
    end
end

function EnableAllChordButtons(index)
    for i=1,7 do
        b[i]:EnableInput(true)
        b[i]:Show()
        LeftPad(b[i])
    end
end

function EnableKeyboard()
    DPrint("")
    for i=1,8 do
        pkeys[i]:Show()
        pkeys[i]:EnableInput(true)
    end
end

function DisableKeyboard()
    for i=1,8 do
        pkeys[i]:Hide()
        pkeys[i]:EnableInput(false)
    end
end

function TouchedPad(self)
	TouchColorPad(self)

	local time = math.floor(Time()*10)
	delayDecisions = time - lastDecision
--	DPrint(delayDecisions)
	lastDecision = time

	if clickcount < maxclicks then
--		DPrint(clickcount..": "..self.index)
--		soarLearning(self.index)
        trainchords[currchord] = self.chord[1]..self.chord[2]..self.chord[3]
        DisableAllChordButtons()
        EnableKeyboard()
	end
end

function LeftPad(self)
	self.t:SetSolidColor(self.c[1],self.c[2],self.c[3],self.c[4])
end


local waittime = 0.5

local currwait = 0

local currpos = 1
local currmax = 1


local currshow = false

local cindex = { c=7,d=6,e=5,f=4,g=3,a=2,b=1 }


function ShowChord(c)
    if not genchords[c] then
--        DPrint("yikes"..c)
        return
    end
    local idx = cindex[genchords[c][1]:lower()]

--    DPrint("c:"..idx)
    for i=1,7 do
        if i == idx then
            b[i]:Show()
        else
            b[i]:Hide()
        end
    end
end

function ShowNote(n,c)
    if not gennotes[4*(c-1)+n] then
--        DPrint("yikes"..4*(c-1)+n)
        return
    end
    local idx = cindex[gennotes[4*(c-1)+n]:lower()]
--    DPrint("n:"..(idx or gennotes[4*(c-1)+n]:lower()).." "..gennotes[4*(c-1)+n]:lower())
    for i=1,8 do
        if i == idx+1 then
            pkeys[i]:Show()
            ucPushA1:Push((7-idx)/7+0.125)
            ucPushA2:Push(0.0)
        else
            pkeys[i]:Hide()
        end
    end
end

function Playing(self, elapsed)

    currwait = currwait + elapsed

    if currwait > waittime then

        currwait = currwait - waittime

        if currpnote+(currpchord-1)*4 > #gennotes then
            StopPlayback()
        end
        if currpnote > 4 then
            currpnote = 1
            currpchord = currpchord + 1
            if currpchord > maxchords then
                StopPlayback()
            end
            ShowChord(currpchord)
        end
        ShowNote(currpnote,currpchord)
        currpnote = currpnote + 1
    end
end

function StopPlayback()
    backdrop:Handle("OnUpdate",nil)
    EnableAllChordButtons()
    DisableKeyboard()
end


function StartPlayback()
    currpnote = 5
    currpchord = 0
    currwait = 0
    waittime = 0.5
    backdrop:Handle("OnUpdate",Playing)
end

function TouchedPKey(self)
    self.tl:SetColor(180,180,180,255)

    local time = math.floor(Time()*10)
    delayDecisions = time - lastDecision
--    DPrint(delayDecisions)
    lastDecision = time

    ucPushA1:Push(self.sample+0.125)
    ucPushA2:Push(0.0)


    if clickcount < maxclicks then
    --		DPrint(clickcount..": "..self.index)
    --		soarLearning(self.index)
        local str
        if currnote == 1 then
            trainnotes[currchord] = ""
        end
        trainnotes[currchord] = trainnotes[currchord] .. self.note
        currnote = currnote + 1
        if currnote > maxnotes then
            DisableKeyboard()
            currnote = 1
            currchord = currchord + 1
            if currchord > maxchords then
                DisableAllChordButtons(0)
                soarLearning()
                soarGenerateNextChord()
                soarGenerateNextNote()
                local str = backdrop:SoarExec("stats")
                str = str .. backdrop:SoarExec("stats --max")
--                DPrint(str)
                --DPrint(backdrop:SoarExec("stats"))

                local str = "GOGO: "
                for i = 1, #genchords do
                    str= str..genchords[i][1]..genchords[i][2]..genchords[i][3].." "
                    for j = 1, 4 do
                        str = str..gennotes[4*(i-1)+j]
                    end
                    str = str .."\n"
                end
--                DPrint(str)
                currchord = 1
                currnote = 1
                StartPlayback()
            end
            EnableAllChordButtons()
        end
    end
end

function LeftPKey(self)
    self.tl:SetColor(60,60,60,255)
end



local chlabel = {"I", "II", "III", "IV", "V", "VI", "VII"}

local scale = {"c","d","e","f","g","a","b","c","d","e","f","g","a","b"}

for k=1,nrx do
	for j=1,nry do
		i = k+nrx*(j-1)
		b[i] = Region()
		b[i]:SetWidth(ScreenWidth()/3)
		b[i]:SetHeight(ScreenHeight()/(nry*1.5))
		b[i]:SetAnchor("BOTTOMLEFT",ScreenWidth()/12+(k)*ScreenWidth()/2,ScreenHeight()/36+(j-1)*ScreenHeight()/nry)
		b[i].t = b[i]:Texture()
		b[i].t:SetSolidColor(c[i][1],c[i][2],c[i][3],c[i][4])
		b[i].tl = b[i]:TextLabel()
		b[i].tl:SetLabel(chlabel[8-i])
		b[i].tl:SetFont(urfont)
		b[i].tl:SetHorizontalAlign("CENTER")
		b[i].tl:SetFontHeight(20)
		b[i].tl:SetColor(255,255,255,255)
		b[i].tl:SetShadowColor(0,0,0,230)
		b[i].tl:SetShadowBlur(4.0)
		b[i]:Show()
		
		b[i].t:SetBlendMode("BLEND")
		
		b[i].c = c[i]
		b[i]:Handle("OnTouchDown",TouchedPad)
		b[i]:Handle("OnEnter",TouchedPad)
		b[i]:Handle("OnTouchUp",LeftPad)
		b[i]:Handle("OnLeave",LeftPad)
		b[i]:Handle("OnDoubleTap", EraseMemory)
		b[i]:EnableInput(true)
		b[i]:EnableClamping(true)
		b[i].index = i
        b[i].chord = {}
        b[i].chord[1]=scale[i]
        b[i].chord[2]=scale[i+2]
        b[i].chord[3]=scale[i+4]
	end
end

pianoregion=Region('region', 'pianoregion', UIParent);
pianoregion:SetWidth(ScreenWidth()/2);
pianoregion:SetHeight(ScreenHeight());
pianoregion:SetLayer("FULLSCREEN");
pianoregion:SetAnchor('BOTTOMLEFT',0,0); 
pianoregion.texture = pianoregion:Texture("piano.png");
pianoregion.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pianoregion.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pianoregion.texture:SetTexCoord(0,0.63,0.94,0.0);
--pianoregion:Handle("OnPressure", CollectAveragePressure)
pianoregion:Show();

pkeys = {}
local plabel = {"c", "d", "e", "f", "g", "a", "b", "c"}

for i=1,8 do
    pkeys[i] = Region()
    pkeys[i]:SetWidth(ScreenWidth()/8)
    pkeys[i]:SetHeight(ScreenHeight()/(nry*1.5))
    pkeys[i]:SetAnchor("BOTTOMLEFT",0,ScreenHeight()/14+(i-1)*ScreenHeight()/8.6)
    pkeys[i]:SetLayer("TOOLTIP")
    pkeys[i].tl = pkeys[i]:TextLabel()
    pkeys[i].tl:SetLabel(plabel[9-i])
    pkeys[i].tl:SetFont(urfont)
    pkeys[i].tl:SetHorizontalAlign("CENTER")
    pkeys[i].tl:SetFontHeight(20)
    pkeys[i].tl:SetColor(60,60,60,255)
    pkeys[i].tl:SetShadowColor(0,0,0,230)
    pkeys[i].tl:SetShadowBlur(4.0)
    pkeys[i]:Show()

    pkeys[i]:Handle("OnTouchDown",TouchedPKey)
    pkeys[i]:Handle("OnEnter",TouchedPKey)
    pkeys[i]:Handle("OnTouchUp",LeftPKey)
    pkeys[i]:Handle("OnLeave",LeftPKey)
--    pkeys[i]:Handle("OnDoubleTap", EraseMemory)
    pkeys[i]:EnableInput(true)
    pkeys[i].index = i
    pkeys[i].sample = (8-i)/8
    pkeys[i].note = plabel[9-i]
end

DisableKeyboard()

soarLearning()
soarGenerateNextChord()
soarGenerateNextNote()
local str = backdrop:SoarExec("stats")
str = str .. backdrop:SoarExec("stats --max")
--DPrint(str)
--DPrint(backdrop:SoarExec("stats"))

local str = ""
for i = 1, #genchords do
	str= str..genchords[i][1]..genchords[i][2]..genchords[i][3].." "
	for j = 1, 4 do
		str = str..gennotes[4*(i-1)+j]
	end
	str = str .."\n"
end
--DPrint(str)

DisableAllChordButtons(0)
StartPlayback()


ucSample = FlowBox("object","Sample", _G["FBSample"])

--[[
ucSample:AddFile("harp-c.wav")
ucSample:AddFile("harp-d.wav")
ucSample:AddFile("harp-e.wav")
ucSample:AddFile("harp-f.wav")
ucSample:AddFile("harp-g.wav")
ucSample:AddFile("harp-a.wav")
ucSample:AddFile("harp-b.wav")
ucSample:AddFile("harp-high-c.wav")
--]]

ucSample:AddFile("wC4.aif")
ucSample:AddFile("wD4.aif")
ucSample:AddFile("wE4.aif")
ucSample:AddFile("wF4.aif")
ucSample:AddFile("wG4.aif")
ucSample:AddFile("wA4.aif")
ucSample:AddFile("wB4.aif")
ucSample:AddFile("wC5.aif")


ucPushA1 = FlowBox("object","PushA1", _G["FBPush"])
ucPushA2 = FlowBox("object","PushA2", _G["FBPush"])

dac = _G["FBDac"]

dac:SetPullLink(0, ucSample, 0)
ucPushA1:SetPushLink(0,ucSample, 4)  
ucPushA1:Push(-1.0); -- Turn looping off
ucPushA1:RemovePushLink(0,ucSample, 4)  
ucPushA1:SetPushLink(0,ucSample, 3)  -- Sample switcher
ucPushA1:Push(0) -- AM wobble
ucPushA2:SetPushLink(0,ucSample, 2) -- Reset pos
ucPushA2:Push(1) -- AM wobble

-- page button
pagebutton=Region()
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
