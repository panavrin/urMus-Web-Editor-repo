--Last update: 4-13-13
--1)added more buttons, sound functionality not added yet
--2)fixed pixel sampling to get appropriate pixel
--
--To Do:
--1)Sample from pixelated camera texture instead of regular camera
--2)Hard code in chord frequencies for new buttons
--3)Fix low rumbly sound

--Last updated: 4-12-13 by Spencer/Sudarshan
--1)changed orientation to landscape
--2)changed indexing scheme to start from 1 instead of 0
--3)adjusted for camera scaling (independent of device now)
--4)created 3 sets of scales/chords for frequencies to be set to
--  would be nice to add more!

--Last updated: 4-9-13 by Spencer/Sudarshan
--Added High threshold and low threshold to minimize fluctuation when squares get triggered
--on/off.

--Things we need to add or change:
-- 1) Possibly less overall grid blocks
-- 2) Try to change view to landscape
-- 3) Consider having buttons determine a chord to be played, and then triggered notes are only
-- from that chord in order to ensure the music sounds “good” and the conductor has complete
-- control over the chord progression
-- 4) Performance aspect: shine flashlight on audience member to demo functionality, letting audience
-- participate afterwards


--Tyler Hughes
--Spencer Maxfield
--Ethan Manilow
--Sudarshan Sivaramakrishnan

--Contributions for this assignment:
--Getting slider to appear and move across the regions: Tyler, Ethan, Sudarshan
--Setting up lua sine oscillators, calculating frequencies, and getting each note to
--play when triggered: all group members
--Aligning grids with camera input Tyler

FreeAllRegions()
FreeAllFlowboxes()
time = 0           	-- starting time
timeMax = 0.5      	-- time to move slider
count = 1          	-- starting count
n = 8             	-- num columns
m = 8             	-- num rows
numbuttons = 4     	-- number color buttons
intensityHighCutoff = 75
intensityLowCutoff = 40  -- minumum intensity (out of 765)
shift = 0

DPrint("")

local log = math.log   

sidespace = ScreenWidth()/10
hsidespace = sidespace*4.325
width = ScreenWidth() - 2*sidespace
height = ScreenHeight() - 5.325*sidespace

harm = {}
amp = {}
dac = FBDac
osc = {}
sample = {}
samp = {}
pos = {}

local drumkit = {"kick.wav","snare.wav","hihat.wav","hihat2.wav","low_tom.wav","high_tom.wav","crash.wav","cowbell.wav"}
local beatbox = {"BBkick.wav","BBsnare.wav","BBhihat.wav","BBclick.wav","BBlongboom.wav","BBbreath.wav","BBahh.wav","BBuhuh.wav"}

for j = 1, n do
    harm[j] = FlowBox(FBPush)
	amp[j] = FlowBox(FBPush)
    osc[j] = FlowBox(FBSinOsc)
    sample[j] = FlowBox(FBSample)
    sample[j]:AddFile(drumkit[j])
    sample[j]:AddFile(beatbox[j])
    pos[j] = FlowBox(FBPush)
    samp[j] = FlowBox(FBPush)
    samp[j].Out:SetPush(sample[j].Sample)
    pos[j].Out:SetPush(sample[j].Loop)
    pos[j]:Push(-1)
    pos[j].Out:RemovePush(sample[j].Loop)
    pos[j].Out:SetPush(sample[j].Pos)
    pos[j]:Push(-1)
    dac.In:SetPull(sample[j].Out)
    dac.In:SetPull(osc[j].Out)
    harm[j].Out:SetPush(osc[j].Freq)
	amp[j].Out:SetPush(osc[j].Amp)
end


--Arrays of frequencies
freqCDEFGABC = {523.25, 587.33, 659.26, 698.46, 783.99, 880.0, 987.77, 1046.50}
freqACCEGGCD = {440, 523.25, 523.25, 659.26, 783.99, 783.99, 1046.50, 1174.66}
freqBDDFAACD = {493.88, 587.33, 587.33, 698.46, 880.0, 880.0, 1046.50, 1174.66}
freqAEGBEGDB = {440, 659.26, 783.99, 987.77, 1318.51, 783.99, 1174.66, 987.77}
freqCFACFDCF = {261.63, 349.23, 440, 523.25, 698.46, 587.33, 523.25, 698.46}
freqGGBDFACD = {392, 392, 493.88, 587.33, 698.46, 880, 1046.50, 587.33}

frequencies = freqACCEGGCD --select frequency array to use

--Make the regions go visible when touched
function Visible(self)
	self:Show()
end

--Make the regions go invisible when not touched
function Hidden(self)
	self:Hide()
end

--Change the camera filter color via button press
function MakeRed(self)
    usesamples = null
	frequencies = freqCDEFGABC
end

function MakeGreen(self)
    usesamples = null
	frequencies = freqACCEGGCD
end

function MakeBlue(self)
    usesamples = null
	frequencies = freqBDDFAACD
end

function MakeWhite(self)
    usesamples = null
	frequencies = freqAEGBEGDB 
end

function MakePurple(self)
    usesamples = null
	frequencies = freqCFACFDCF 
end

function MakeOrange(self)
    usesamples = null
	frequencies = freqGGBDFACD 
end

function MakeGrey(self)
    usesamples = 0
	frequencies = freqAEGBEGDB 
end

function MakePink(self)
    usesamples = 1
	frequencies = freqAEGBEGDB 
end

function React(self, elapsed)
    x,y = self:Center()
    i = self.indexX
    j = self.indexY
	--scale x and y because camera pixels are scaled to screen pixels
--   r,g,b,a = camBG.t:PixelColor(x*3/camBG.scaleW,y*4/camBG.scaleH)
	local x2,y2=x/camBG:Width()*camBG.t:Width(),y/camBG:Height()*camBG.t:Height()
	local r,g,b,a = camBG.t:PixelColor(x2,y2-10) -- Left square
--	DPrint(x.." "..y.."|"..x2.." "..y2..":"..r.." "..g.." "..b)
	local r2,g2,b2,a2 = camBG.t:PixelColor(x2,y2+10) -- Right square
--   r,g,b,a = camBG.t:PixelColor(x*3/camBG.scaleW,y*4/camBG.scaleH)
	--r,g,b,a = camBG.t:PixelColor(480, 640)
    if (r+b+g) > intensityHighCutoff or (r2+b2+g2) > intensityHighCutoff then
   	 self:Show()
   	 Activated[i][j] = 1
    elseif (r+b+g) < intensityLowCutoff and (r2+b2+g2) < intensityLowCutoff then
   	 Activated[i][j] = 0
   	 self:Hide()
    end
    --self.tl:SetLabel(r+b+g)
end

function Freq2Norm(freq)
    return 12.0/96.0*log(freq/55)/log(2)
end

function MoveSlider(self, elapsed)
    time = time + elapsed
    if time > timeMax then
   	 slider:SetAnchor("TOPLEFT", sidespace, hsidespace + height - (count-1)*height/m)
   	 for j = 1, n do
   		 harm[j]:Push(0)
		 amp[j]:Push(0)
--         pos[j]:Push(1)
   	 end
   	 for j = 1, n do
   		 if Activated[j][count] == 1 then
            if not usesamples then
   			 harm[j]:Push(Freq2Norm(frequencies[j]*(1.1224^shift)))
			 amp[j]:Push(1)
            else
             samp[j]:Push(usesamples)
             pos[j]:Push(-1)
            end
   		 end
   	 end
   	 time = time - timeMax
   	 --DPrint("play "..count)
   	 count = count + 1
   	 if count == m+1 then
   		 count = 1
   	 end
    end
end

--CAMERA INPUT HERE:
camBG = Region() --camera background
camBG:Show()
camBG.widthActual = camBG:Width() --actual camera width
camBG.heightActual = camBG:Height() --actual camera height
camBG:SetWidth(ScreenWidth()) --scale camera image to screen width
camBG:SetHeight(ScreenHeight()) --scale camera image to screen height
--DPrint(camBG.widthActual..","..camBG.heightActual);
camBG.scaleW = camBG:Width()/camBG.widthActual --scaling factor
camBG.scaleH = camBG:Height()/camBG.heightActual --scaling factor
camBG.t = camBG:Texture(255,255,255,0)
camBG.t:UseCamera()
camBG.t:SetFilter("PIXELLATE")
camBG.t:SetFilterParameter(-0.85)
--camBG:Hide()

camBG2 = Region() --camera background
camBG2:Show()
camBG2.widthActual = camBG2:Width() --actual camera width
camBG2.heightActual = camBG2:Height() --actual camera height
camBG2:SetWidth(ScreenWidth()) --scale camera image to screen width
camBG2:SetHeight(ScreenHeight()) --scale camera image to screen height
--DPrint(camBG.widthActual..","..camBG.heightActual);
camBG2.scaleW = camBG2:Width()/camBG.widthActual --scaling factor
camBG2.scaleH = camBG2:Height()/camBG.heightActual --scaling factor
camBG2.t = camBG2:Texture(255,255,255,0)
camBG2.t:UseCamera()
--camBG2:Hide()  -- Hide this to see pixel readout

SetExternalOrientation(2)


--Create the grid regions
Activated = {}
for i = 1, n do
    Activated[i] = {}
	for j = 1, m do
   	 Activated[i][j] = 0
    	local r = Region()
    	r:SetWidth(width/n)
   	 r.indexX = i
   	 r.indexY = j
    	r:SetHeight(height/m)
    	r.t = r:Texture(10,255,100,100)
   	 r.t:SetBlendMode("BLEND")
    	r:SetAnchor("TOPLEFT", sidespace + width*(i-1)/n, hsidespace + height*(1- (j-1)/m))
    	r:Show()--r:Hide()
    	r:Handle("OnTouchDown", Visible)
    	r:Handle("OnTouchUp", Hidden)
   	 r:Handle("OnUpdate", React)
    	r:EnableInput(true)
   	-- DPrint(m)
   	 r.tl = r:TextLabel() --used for testing
   	 r.tl:SetLabel("")
   		 
   	 --horizontal grid lines
  		 local gh = Region()
  		 gh:SetWidth(width) --need to subtract horizontal sidespacing
  		 gh:SetHeight(1) --4 pixel thickness
  		 gh.t = gh:Texture(255,0,0,255)
  		 gh:SetAnchor("BOTTOMLEFT", sidespace, hsidespace + height/m*(j-1))
  		 gh:Show()

  		 --vertical grid lines
  		 local gv = Region()
  		 gv:SetWidth(1) --4 pixel thickness
  		 gv:SetHeight(height) --need to subtract vertical sidespacing
  		 gv.t = gv:Texture(255,0,0,255)
  		 gv:SetAnchor("BOTTOMLEFT", sidespace + width/n + width/n*(i-1), hsidespace)
  		 gv:Show()
   	 end
	end

-- slider
slider = Region()
slider.t = slider:Texture(255,0,0,100)
slider.t:SetBlendMode("BLEND")
slider:SetAnchor("TOPLEFT", sidespace, height + hsidespace)
slider:Handle("OnUpdate", MoveSlider)
slider:SetWidth(width)
slider:SetHeight(height/m)
slider:Show()
slider:EnableInput(true)

--extra grid lines

gv2 = Region()
gv2:SetWidth(1) --4 pixel thickness
gv2:SetHeight(height) --need to subtract vertical sidespacing
gv2.t = gv2:Texture(255,0,0,255)
gv2:SetAnchor("BOTTOMLEFT", sidespace, hsidespace)
gv2:Show()

gh2 = Region()
gh2:SetWidth(width) --need to subtract horizontal sidespacing
gh2:SetHeight(1) --4 pixel thickness
gh2.t = gh2:Texture(255,0,0,255)
gh2:SetAnchor("BOTTOMLEFT", sidespace, ScreenHeight()-sidespace)
gh2:Show()

--red button
red = Region()
red:SetWidth(sidespace)
red:SetHeight(sidespace*2)
red.t = red:Texture(200,10,10,255)
red:SetAnchor("BOTTOMLEFT", ScreenWidth()/2 - sidespace*4 , sidespace)
red:Show()
red:EnableInput(true)
red:Handle("OnTouchDown", MakeRed)

--green button
green = Region()
green:SetWidth(sidespace)
green:SetHeight(sidespace*2)
green.t = green:Texture(10,200,10,255)
green:SetAnchor("BOTTOMLEFT", ScreenWidth()/2 - sidespace*2.8 , sidespace)
green:Show()
green:EnableInput(true)
green:Handle("OnTouchDown", MakeGreen)

--blue button
blue = Region()
blue:SetWidth(sidespace)
blue:SetHeight(sidespace*2)
blue.t = blue:Texture(10,10,200,255)
blue:SetAnchor("BOTTOMLEFT", ScreenWidth()/2 - sidespace * 1.8 , sidespace)
blue:Show()
blue:EnableInput(true)
blue:Handle("OnTouchDown", MakeBlue)

--white button
white = Region()
white:SetWidth(sidespace)
white:SetHeight(sidespace*2)
white.t = white:Texture(250,250,250,255)
white:SetAnchor("BOTTOMLEFT", ScreenWidth()/2 - sidespace * .8, sidespace)
white:EnableInput(true)
white:Show()
white:Handle("OnTouchDown", MakeWhite)

--Purple button
purple = Region()
purple:SetWidth(sidespace)
purple:SetHeight(sidespace*2)
purple.t = purple:Texture(250,0,250,255)
purple:SetAnchor("BOTTOMLEFT", ScreenWidth()/2 + sidespace * .3, sidespace)
purple:EnableInput(true)
purple:Show()
purple:Handle("OnTouchDown", MakePurple)

--Orange button
orange = Region()
orange:SetWidth(sidespace)
orange:SetHeight(sidespace*2)
orange.t = orange:Texture(155,50,175,255)
orange:SetAnchor("BOTTOMLEFT", ScreenWidth()/2 + sidespace*1.3, sidespace)
orange:EnableInput(true)
orange:Show()
orange:Handle("OnTouchDown", MakeOrange)

--Grey button
grey = Region()
grey:SetWidth(sidespace)
grey:SetHeight(sidespace*2)
grey.t = grey:Texture(40,40,40,255)
grey:SetAnchor("BOTTOMLEFT", ScreenWidth()/2 + sidespace*2.3, sidespace)
grey:EnableInput(true)
grey:Show()
grey:Handle("OnTouchDown", MakeGrey)

--Pink button
pink = Region()
pink:SetWidth(sidespace)
pink:SetHeight(sidespace*2)
pink.t = pink:Texture(155,75,10,255)
pink:SetAnchor("BOTTOMLEFT", ScreenWidth()/2 + sidespace*3.3, sidespace)
pink:EnableInput(true)
pink:Show()
pink:Handle("OnTouchDown", MakePink)

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

