
SetPage(2)
FreeAllRegions()
FreeAllFlowboxes()
DPrint("")

local baseNum = 60
oct = 0
-- note key mapping
n = Region()
n.notes = {"C", "G", "D", "E", "F", "A", "D#", "B", "-", "G#", "-","A#","F#", "C#", "-"}
n.noteNums = {0, 7, 2, 4, 5, 9, 3, 11, -1, 8, -1,10,6, 1, -1}
n.notes[0] = ""
n.chan = 1 


n.keys = {}
n.keyColors = {{255,100,100}, {100,255,100},{100,100,255},{200,100,200}}
n.keyIndex = 0
local floor = math.floor
local log = math.log
local pow = math.pow
local abs = math.abs
local min = math.min

n.freqInterval = .1
function updateFreq(self, elapsed)
	if Time() - n.freqTime < n.freqInterval then
		return
	end
	n.keyIndex = 0
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
	if n.noteNums[n.keyIndex] == -1 then
		return 
	end
	r.time = Time()
	r:Handle("OnUpdate", updateLevel)
	totalLevel = 0
	
	--	n.keyIndex = n.keyIndex + pow(2,i-1)
	local noteNum = baseNum + (oct-2)* 12 +  n.noteNums[n.keyIndex]
	--DPrint(baseNum.."_"..oct.."_"..n.keyIndex.."_"..noteNum.."+"..n.noteNums[n.keyIndex])
	n:Handle("OnUpdate", nil)
	generateSound(noteNum)
	
end

n:Handle("OnUpdate", nil)
-- keyPressed to update key index for the selected pitch based on combination of what keys are pressed
function keyPressed(self)
	local prevIndex = n.keyIndex
	local i = self.i
	n.keyIndex = 0
	self.pressed = true;
	n.freqTime = Time()
--	DPrint(n:ReadHandle("OnUpdate").."??"..n.freqTime)
--	if n:ReadHandle("OnUpdate") == 0 then
		n:Handle("OnUpdate", updateFreq)
--	end
	
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
			n.freqTime = Time()
						n:Handle("OnUpdate", updateFreq)

--[[
			n.noteName.tl:SetLabel(n.notes[n.keyIndex])
			local noteNum = baseNum + (oct-2)* 12 +  n.noteNums[n.keyIndex]
			--DPrint(baseNum.."_"..oct.."_"..n.keyIndex.."_"..noteNum.."+"..n.noteNums[n.keyIndex])
			
			generateSound(noteNum)
			]]
			
			--DPrint(self.i.."-"..n.chan.."-"..n.keyIndex.."-" )
		elseif n.keyIndex == 0 then
		n.noteName.tl:SetLabel("-")
			r:Handle("OnUpdate", nil)
			n:Handle("OnUpdate", nil)
			pushAsymp[n.chan]:Push(0)
			totalLevel = 0
			prevLevel = -1
			--DPrint(self.i.."-"..n.chan.."-"..n.keyIndex.."-"..n:ReadHandle("OnUpdate") )
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

-- draw four keys
for i=1,4 do 
	
	n.keys[i] = Region();
	n.keys[i]:SetWidth(100)
	n.keys[i]:SetHeight(100)
	n.keys[i].t = n.keys[i]:Texture(255,255,255,100)
	n.keys[i]:EnableInput(true)
	n.keys[i]:EnableMoving(true)
	n.keys[i].tl = n.keys[i]:TextLabel()
	n.keys[i].tl:SetFontHeight(ScreenWidth()/25)
	n.keys[i].tl:SetColor(0,0,0,255)
	n.keys[i].tl:SetLabel("Key "..i)
	n.keys[i].tl:SetRotation(90)
	
	n.keys[i].i = i
	n.keys[i]:Show()
	n.keys[i].pressed = false;
	n.keys[i]:SetAnchor("CENTER",UIParent,"CENTER", 0,ScreenHeight()/4 * (2.5-i))
	
end

-- toggle mode between config mode and play mode
function toggleMode(self)
	if self.playMode then
		self.tl:SetLabel("Config\nMode")
		n.toggleButton.tl:SetColor(0,0,0,255)
		for i=1,4 do
			n.keys[i]:EnableMoving(true)
			n.keys[i]:Handle("OnTouchDown", nil)
			n.keys[i]:Handle("OnTouchUp", nil)
			n.keys[i]:Handle("OnLeave", nil)
		end
		
	else 
		self.tl:SetLabel("Play\nMode")
		n.toggleButton.tl:SetColor(100,50,50,255)
		for i=1,4 do
			n.keys[i]:Handle("OnTouchDown", keyPressed)
			n.keys[i]:Handle("OnTouchUp", keyReleased)
			n.keys[i]:Handle("OnLeave", keyOnLeave)
			n.keys[i]:EnableMoving(false)
			n.keys[i]:EnableInput(true)
		end
	end
	n.toggleButton.playMode = not n.toggleButton.playMode 
	
	
end

-- draw toggle button
n.toggleButton = Region()

n.toggleButton:SetWidth(70)
n.toggleButton:SetHeight(75)
n.toggleButton.t = n.toggleButton:Texture(200,200,255,100)
n.toggleButton:EnableInput(true)
n.toggleButton.tl = n.toggleButton:TextLabel()
n.toggleButton.tl:SetFontHeight(ScreenWidth()/20)
n.toggleButton.tl:SetColor(0,0,0,255)
n.toggleButton.tl:SetLabel("Config\nMode")
n.toggleButton.tl:SetRotation(90)
n.toggleButton:Handle("OnTouchUp", toggleMode);
n.toggleButton:Show();
n.toggleButton:SetAnchor("BOTTOMLEFT", UIParent, "BOTTOMLEFT", ScreenWidth()/30, ScreenWidth()/30)
n.toggleButton.playMode = false


-- draw note name indicator
n.noteName = Region()

n.noteName:SetWidth(70)
n.noteName:SetHeight(75)
n.noteName.t = n.noteName:Texture(200,200,255,100)
n.noteName:EnableInput(true)
n.noteName.tl = n.noteName:TextLabel()
n.noteName.tl:SetFontHeight(ScreenWidth()/10)
n.noteName.tl:SetColor(0,0,0,255)
n.noteName.tl:SetLabel("-")
n.noteName.tl:SetRotation(90)
n.noteName:Show();
n.noteName:SetAnchor("TOPLEFT", UIParent, "TOPLEFT", ScreenWidth()/30, -ScreenWidth()/30)
n.noteName.playMode = false 

-- Sang's Part begins for part ii) Camera part

-- connect camera to pull 
cam = FBCam;
nopeRed = FlowBox(FBNope)
pullRed = FlowBox(FBPull)
nopeGreen = FlowBox(FBNope)
pullGreen = FlowBox(FBPull)
nopeBlue = FlowBox(FBNope)
pullBlue = FlowBox(FBPull)

cam.Red:SetPush(nopeRed.In)
nopeRed.Out:SetPush(pullRed.In)
cam.Green:SetPush(nopeGreen.In)
nopeGreen.Out:SetPush(pullGreen.In)
cam.Blue:SetPush(nopeBlue.In)
nopeBlue.Out:SetPush(pullBlue.In)

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
octLabel:SetAnchor("BOTTOMLEFT", UIParent, "BOTTOMLEFT",0,ScreenHeight()*3/5)

octLabel.tl = octLabel:TextLabel()
octLabel.tl:SetLabel("1")
octLabel.tl:SetFontHeight(30)
--Uses accel flowbox, a NOPE connection, and VIS to move data around
accel = FlowBox(FBAccel)
nope = FlowBox(FBNope)
vis = FlowBox(FBVis)
nope.Out:SetPush(vis.In)
accel.Z:SetPush(nope.In)
--To smooth out the data, a continuous time average is running.  Alpha determines the rate of the average.
average = 0
alpha = .15
function UpdateOct (Self)
	local z = FBVis:Get()
	average = alpha*z+(1-alpha)*average
	if average < -.5 then
		octLabel.t:SetTexture(255,0,255,255)
		octLabel.tl:SetLabel("1")
		oct = 1
		if average < -.7 then
			average = -.7 --prevents average from getting too low
		end
	elseif average <= .5 then
		octLabel.t:SetTexture(0,255,255,255)
		octLabel.tl:SetLabel("2")
		oct = 2
	elseif average > .333 then
		octLabel.t:SetTexture(255,255,0,255)
		octLabel.tl:SetLabel("3")
		oct = 3
		if average >.7 then --prevents average from getting too high
			average = .7
		end
	end
end
octLabel:Handle("OnUpdate",UpdateOct)


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
n.overTone=1
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

	pushTau[j]:Push(1)
	pushAsymp[j]:Push(0)
end

for i=1,n.overTone do
	pushAmp[i]:Push(1/i)
--	pushAmp[i]:Push(1)
end
q=-299/300
pushQ:Push(q)
--scale = {0,12,19,24,28}
scale = {0,19,28,12,24}

--r:Handle("OnUpdate", updateLevel)
function generateSound(noteNum)
	pushAsymp[n.chan]:Push(0)
	n.chan = (n.chan+1)%2
--	DPrint("press"..n.chan)
	--       C   C G C E
	-- 		1	1/2 1/3 1/4 1/5
	--       C E G A B
	for i=1,n.overTone do
		pushFreq[n.chan][i]:Push(freq2Norm(noteNum2Freq(noteNum+scale[i])))
	end
end
--generateSound(baseNum)
r= Region()
r.t = r:Texture()
r:SetWidth(100)
r:SetHeight(40)
r:Show()
r.t:SetTexture(255,100,100,255)
r:SetAnchor("LEFT", UIParent, "BOTTOMLEFT",0,ScreenHeight()*2.5/5)
r.tl = r:TextLabel()
r.tl:SetLabel("r")
r.tl:SetFontHeight(20)
g= Region()
g.t = g:Texture()
g:SetWidth(100)
g:SetHeight(40)
g:Show()
g.t:SetTexture(100,255,100,255)
g:SetAnchor("LEFT", UIParent, "BOTTOMLEFT",0,ScreenHeight()*2.0/5)
g.tl = g:TextLabel()
g.tl:SetLabel("g")
g.tl:SetFontHeight(20)
b= Region()
b.t = b:Texture()
b:SetWidth(100)
b:SetHeight(40)
b:Show()
b.t:SetTexture(100,100,255,255)
b:SetAnchor("LEFT", UIParent, "BOTTOMLEFT",0,ScreenHeight()*1.5/5)
b.tl = b:TextLabel()
b.tl:SetLabel("b")
b.tl:SetFontHeight(20)

prevLevel = -1
totalLevel = 0
dRate = 1.0
alpha2 = 0.1


function updateLevel(self, elapsed)
	r.time = r.time + elapsed
	redLevel = pullRed:Pull()
	greenLevel = pullGreen:Pull()
	blueLevel = pullBlue:Pull()
	if prevLevel == -1 then
		prevLevel = redLevel + blueLevel
	end
	totalLevel = (1-alpha2) * totalLevel+ alpha2 * abs(redLevel + blueLevel - prevLevel) 
	--	totalLevel = totalLevel - elapsed * decRate
	
	if totalLevel<0 then
		totalLevel = 0
	elseif totalLevel >1 then
		totalLevel = 1
	end
	prevLevel = redLevel + blueLevel
	self.tl:SetLabel((floor(totalLevel*100)/100).."\n"..floor(redLevel*100));
	g.tl:SetLabel((floor(redLevel/greenLevel*100)/100).."\n"..floor(greenLevel*100));
	b.tl:SetLabel((floor(redLevel/blueLevel*100)/100).."\n"..floor(blueLevel*100));
	n.qlevel2 = min(1.5,redLevel/blueLevel) / 1.5
	n.qlevel = -(399/400) * n.qlevel2 + -(200/300) * (1-n.qlevel2)
	pushQ:Push(n.qlevel)
	pushAsymp[n.chan]:Push(totalLevel*dRate )
	
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


