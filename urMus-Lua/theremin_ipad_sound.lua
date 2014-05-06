SetPage(2)
FreeAllRegions()
FreeAllFlowboxes()
DPrint("")

local baseNum = 23
oct = 1
octMax = 2
-- note key mapping
n = Region()
n.notes = {"B","C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#"}
--n.noteNums = {0, 7, 2, 4, 5, 9, 3, 11, -1, 8, -1,10,6, 1, -1}
n.noteNums = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,12}

n.notes[0] = ""
n.chan = 1 

n.keys = {}
n.keyColors = {{255,100,100}, {100,255,100},{100,100,255},{200,100,200}}
n.keyIndex = 0
local floor = math.floor
local log = math.log
local pow = math.pow
local abs = math.abs

n.numSelected = 0
n.numNotes = 1
n.nextchan = 0
function onClick(self)
	if self.pressed then
	DPrint(n.numSelected..",true,"..n.chan)--..","..self.chan)
	else
		DPrint(n.numSelected..",false,"..n.chan)--..","..self.chan)
		end

	if self.pressed then
		self.t = n.keys[self.i]:Texture(200,200,200,50)
		self.pressed = false
		n.numSelected = n.numSelected - 1
		r:Handle("OnUpdate", nil)
		pushAsymp[n.chan]:Push(0)
	else
		if n.numSelected == n.numNotes then
			for j=1,12 do
				if n.keys[j].pressed then
					n.keys[j].pressed = false
					n.keys[j].t = n.keys[j]:Texture(200,200,200,50)
					break
				end
			end
		else
			n.numSelected = n.numSelected + 1
		end
		r:Handle("OnUpdate", updateLevel)
		self.t = n.keys[self.i]:Texture(255,100,100,50)
		self.pressed = true
		local noteNum = baseNum + (oct-2)* 12 +  n.noteNums[self.i]
		pushAsymp[n.chan]:Push(0)

		generateSound(noteNum)
	end
	
end

-- keyPressed to update key index for the selected pitch based on combination of what keys are pressed
function keyPressed(self)
	local prevIndex = n.keyIndex
	local i = self.i
	n.keyIndex = 0
	self.pressed = true;
	
	for i=1,4 do
		if n.keys[i].pressed then
			n.keyIndex = n.keyIndex + pow(2,i-1)
		end
	end
	
	if n.keyIndex < 16 and n.keyIndex> 0 then
		n.noteName.tl:SetLabel(n.notes[n.keyIndex])
		--DPrint(i.." keyPressed:"..n.keyIndex)
	else
		n.keyIndex = prevIndex;
		--DPrint(i.." keyPressed:".."OUT OF RANGE"..n.keyIndex);            
		return
	end
	r:Handle("OnUpdate", updateLevel)
	totalLevel = 0
	
	--	n.keyIndex = n.keyIndex + pow(2,i-1)
	local noteNum = baseNum + (oct-2)* 12 +  n.noteNums[n.keyIndex]
	--DPrint(baseNum.."_"..oct.."_"..n.keyIndex.."_"..noteNum.."+"..n.noteNums[n.keyIndex])
	
	generateSound(noteNum)
	self.t:SetTexture(n.keyColors[i][1],n.keyColors[i][2],n.keyColors[i][3],200)
	
end

-- keyReleased to update key index for the selected pitch based on combination of what keys are pressed
-- do release only when it's pressed(not entered)
function keyReleased(self)
	if self.pressed then
		self.pressed = false;
		local prevIndex = n.keyIndex
		self.t:SetTexture(255,255,255,200)
		
		n.keyIndex = 0
		for i=1,4 do
			if n.keys[i].pressed then
				n.keyIndex = n.keyIndex + pow(2,i-1)
			end
		end		
		if n.keyIndex < 16 and n.keyIndex> 0 then
			n.noteName.tl:SetLabel(n.notes[n.keyIndex])
			local noteNum = baseNum + (oct-2)* 12 +  n.noteNums[n.keyIndex]
			--DPrint(baseNum.."_"..oct.."_"..n.keyIndex.."_"..noteNum.."+"..n.noteNums[n.keyIndex])
			
			generateSound(noteNum)
			
			--DPrint(self.i.." keyReleased:"..n.keyIndex)
		elseif n.keyIndex == 0 then
			r:Handle("OnUpdate", nil)
			pushAsymp[n.chan]:Push(0)
			totalLevel = 0
			prevLevel = -1
			DPrint(n.chan.."?")
		else
			--DPrint(self.i.." keyReleased:".."OUT OF RANGE"..n.keyIndex);
			n.keyIndex = prevIndex;
		end
	end
end

-- Do the same for OnLeave as OnTouchUpEvent (Only when it's pressed and left)
function keyOnLeave(self)
	if self.pressed then
		keyReleased(self)
	else
		--DPrint(self.i.." keyOnLeave:"..self.i.." block, index"..n.keyIndex);
	end
end


mr = Region()
mr.t = mr:Texture()
mr.t:SetTexture(0,0,0,255)
mr:SetHeight(ScreenHeight()/2)
mr:SetWidth(ScreenWidth())
mr:Show()

-- draw twelve keys
for i=1,12 do 
	n.keys[i] = Region();
	n.keys[i]:SetWidth(75)
	n.keys[i]:SetHeight(75)
	n.keys[i].t = n.keys[i]:Texture(200,200,200,50)
	n.keys[i]:EnableInput(true)
	n.keys[i].tl = n.keys[i]:TextLabel()
	n.keys[i].tl:SetFontHeight(ScreenWidth()/35)
	n.keys[i].tl:SetColor(0,0,0,255)
	n.keys[i].tl:SetLabel(n.notes[i])
	n.keys[i].tl:SetRotation(270)
	
	n.keys[i].i = i
	n.keys[i]:Show()
	n.keys[i].pressed = false;
	val = i-1
	n.keys[i]:SetAnchor("TOPLEFT",mr,"TOPLEFT",ScreenHeight()/5*(val/4)+ScreenHeight()/15,
		ScreenWidth()/6*(val%3)-ScreenWidth()/2)
	n.keys[i]:Handle("OnTouchUp",onClick)
end

-- Sang's Part begins for part ii) Camera part

-- connect camera to pull 
cam = FBCam;
nopeRed = FlowBox(FBNope)
pullRed = FlowBox(FBPull)

cam.Red:SetPush(nopeRed.In)
nopeRed.Out:SetPush(pullRed.In)

SetActiveCamera(2)
SetCameraAutoBalance(1)

-- Trent's part begins : detecting tilting position

--This section creates a mechanism to change octaves by tilting the instrument
octLabel = Region()

--octLabel is in the center of the screen and indicates the current octave with number and color
octLabel.t = octLabel:Texture()
octLabel:SetWidth(40)
octLabel:SetHeight(40)
octLabel:Show()
octLabel.t:SetTexture(255,0,255,255)
octLabel:SetAnchor("CENTER", UIParent, "CENTER",0,0)

octLabel.tl = octLabel:TextLabel()
octLabel.tl:SetLabel("1")
octLabel.tl:SetFontHeight(30)
octLabel.tl:SetRotation(270)

octBtnUp = Region()
octBtnUp.t = octBtnUp:Texture()
octBtnUp.t:SetTexture(0,200,0,255)
octBtnUp:SetHeight(105)
octBtnUp:SetWidth(75)
octBtnUp:SetAnchor("TOPRIGHT",UIParent,"TOPRIGHT",-120,-300)
octBtnUp.tl = octBtnUp:TextLabel()
octBtnUp.tl:SetLabel("octave\nup")
octBtnUp.tl:SetFontHeight(20)
octBtnUp.tl:SetRotation(270)
octBtnUp:Show()
octBtnUp:EnableInput(true)

octBtnDown = Region()
octBtnDown.t = octBtnDown:Texture()
octBtnDown.t:SetTexture(200,0,0,255)
octBtnDown:SetHeight(105)
octBtnDown:SetWidth(75)
octBtnDown:SetAnchor("TOPRIGHT",UIParent,"TOPRIGHT",0,-300)
octBtnDown.tl = octBtnDown:TextLabel()
octBtnDown.tl:SetLabel("octave\ndown")
octBtnDown.tl:SetFontHeight(20)
octBtnDown.tl:SetRotation(270)
octBtnDown:Show()
octBtnDown:EnableInput(true)

function setOctUp(self)
	if oct < octMax then
		oct = oct + 1
		DPrint(oct)
	end
end
function setOctDown(self)
	if oct > 0 then
		oct = oct - 1
		DPrint(oct)
	end
end

octBtnUp:Handle("OnTouchUp",setOctUp)
octBtnDown:Handle("OnTouchUp",setOctDown)

--Tone Generator

function freq2Norm(freqHz)
	return 12.0/96.0*log(freqHz/55)/log(2)
end

function noteNum2Freq(num)
	return pow(2,(num-57)/12) * 440 
end

noise={}
biquad={}
pushFreq = {}
pullRed = FlowBox(FBPull)
dac = FBDac
gain = {}
drain={}
cam.Red:SetPush(pullRed.In)
pushQ = FlowBox(FBPush)
pushAmp = {}
pushAsymp={}
pushTau = {}
asymp = {}

n.numChannel = 2
n.overTone=3
n.bandwidth=-290/300

for i=1,n.overTone do
	noise[i]=FlowBox(FBNoise)
	pushAmp[i] = FlowBox(FBPush)
end
for j=0,n.numChannel-1 do
	biquad[j]={}
	pushFreq[j] = {}
	gain[j] = FlowBox(FBGain)
	pushAsymp[j] = FlowBox(FBPush)
	pushTau[j] = FlowBox(FBPush)
	asymp[j] = FlowBox(FBAsymp)
	drain[j] = FlowBox(FBDrain)
	drain[j].In:SetPull(asymp[j].Out)
	dac.In:SetPull(drain[j].Time)

	for i=1,n.overTone do

		biquad[j][i] = FlowBox(FBBandPass)
		pushFreq[j][i] = FlowBox(FBPush)
		pushFreq[j][i].Out:SetPush(biquad[j][i].Freq)
		pushQ.Out:SetPush(biquad[j][i].Q)
		biquad[j][i].In:SetPull(noise[i].Out)
		gain[j].In:SetPull(biquad[j][i].Out)
		pushAmp[i].Out:SetPush(noise[i].Amp)
	end
	dac.In:SetPull(gain[j].Out)
	drain[j].Out:SetPush(gain[j].Amp)
	pushAsymp[j].Out:SetPush(asymp[j].In)
	pushTau[j].Out:SetPush(asymp[j].Tau)

	pushTau[j]:Push(-.5)
	pushAsymp[j]:Push(0)
end

for i=1,n.overTone do
	pushAmp[i]:Push(1/i)
--	pushAmp[i]:Push(1)
end
pushQ:Push(n.bandwidth)
scale = {0,12,19,24,28}

--r:Handle("OnUpdate", updateLevel)
function generateSound(noteNum)
	n.chan = (n.chan + 1) % n.numChannel

	DPrint("press"..n.chan)
	--       C   C G C E
	-- 		1	1/2 1/3 1/4 1/5
	--       C E G A B
	for i=1,n.overTone do
		pushFreq[n.chan][i]:Push(freq2Norm(noteNum2Freq(noteNum+scale[i])))
	end
end

r= Region()
r.t = r:Texture()
r:SetWidth(100)
r:SetHeight(80)
r:Show()
r.t:SetTexture(255,0,0,255)
r:SetAnchor("LEFT", UIParent, "BOTTOMLEFT",0,ScreenHeight()*2.5/5)
r.tl  = r:TextLabel()
r.tl:SetLabel("1")
r.tl:SetFontHeight(20)
r.tl:SetRotation(270)
prevLevel = -1
totalLevel = 0
dRate = 1.0
alpha2 = 0.1
function updateLevel(self, elapsed)
	local redLevel = pullRed:Pull()
	if prevLevel == -1 then
		prevLevel = redLevel
	end
	totalLevel = (1-alpha2) * totalLevel+ alpha2 * redLevel
	--	totalLevel = totalLevel - elapsed * decRate
	
	if totalLevel<0 then
		totalLevel = 0
	elseif totalLevel >1 then
		totalLevel = 1
	end
	prevLevel = redLevel
	self.tl:SetLabel((floor(totalLevel*100)/100).."\n"..floor(redLevel*100));
--	if n.numSelected == n.numNotes then
--		pushAsymp[0]:Push(totalLevel)
--		pushAsymp[1]:Push(totalLevel)
--	else
		pushAsymp[n.chan]:Push(totalLevel)
--	end
end


local pagebutton=Region('region', 'pagebutton', UIParent)
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4)
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", MyFlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()
