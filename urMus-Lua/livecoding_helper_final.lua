SetPage(2)
FreeAllRegions()
WriteMovie("lc.mp4",0,0,ScreenWidth(), ScreenHeight())

DPrint("livecoding ready")
noteNames = { "C#","D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C",}

base_note = 24
num_notes = 24

log = math.log
pow = math.pow
floor = math.floor
random = math.random
abs = math.abs
offX = 100
offY = 50
sw = ScreenWidth()
sh = ScreenHeight()
bgW = ScreenHeight() - offX;
bgH = ScreenWidth() - offY;


function freq2Norm(freqHz)
	return 12.0/96.0*log(freqHz/55)/log(2)
end

function noteNum2Freq(num)
	return pow(2,(num-57)/12) * 440 
end

function note2Norm(num)
	return freq2Norm(noteNum2Freq(num))
end


function createRegion(width, height, posX, posY, parent, red, green, blue, alpha, anchorPoint)
	local newregion = Region()
	local anchorPoint = anchorPoint or "BOTTOMLEFT" 
	local width = width or 100
	local height = height or 100
	local posX = posX or 0
	local posY = posY or 0
	local red = red or 255
	local green = green or 255
	local blue = blue or 255
	local alpha = alpha or 255
	local parent = parent or nil
	newregion:SetWidth(width)
	newregion:SetHeight(height)
	newregion.t = newregion:Texture(red,green,blue,alpha)
	newregion.t:SetBlendMode("BLEND")
	if parent == nil then
		newregion:SetAnchor(anchorPoint, posX, posY)
	else
		newregion:SetAnchor(anchorPoint, parent, "BOTTOMLEFT", posX, posY)
	end
	newregion.tl = nil
	newregion.SetText = function(self, text, size, red, green, blue, alpha, angle )
		if self.tl == nil then
			self.tl = self:TextLabel()
		end
		local size = size or self:Width()/10
		local red = red or 0
		local green = green or 0
		local blue = blue or 0
		local alpha = alpha or 255
		local angle = angle or 0
		self.tl:SetColor(red,green,blue,alpha)
		self.tl:SetFontHeight(size)
		self.tl:SetLabel(text)
		self.tl:SetRotation(angle)
	end
	newregion.MoveTo = function(self,x,y)
		self:SetAnchor("CENTER", self:Parent(), "BOTTOMLEFT", x,y)
	end
	newregion:Show()
	return newregion
end

-- offsetY / length required
function createNoteName(i, w, h)
	--	labels = labels or {}
	local newregion = createRegion(w, h, w/4 + sw/2,offX+ i* h, nil, i*30,150,i*20,180,"CENTER")
	local noteNum = (base_note+i-1)%12+1
	--DPrint(noteNum.."_"..i) 
	newregion:SetText(noteNames[noteNum]..math.floor((base_note+i)/12), offY/3, 0, 0, 0, 255, -90)
	if labels[i] then
		labels[i]:Hide()
		labels[i] = nil;
	end
	return newregion
end

--Cameron's Additions:

FreeAllRegions()

chatLog = Region()
chatLog:SetWidth(ScreenWidth())
chatLog:SetHeight(ScreenWidth())
chatLog.texture = chatLog:Texture()
chatLog.texture:SetTexture(0,0,0,255)
chatLog:SetAnchor("BOTTOMLEFT", 20, 20)
chatLog:Show()

chatLog.message = chatLog:TextLabel()
chatLog.message:SetRotation(270)
chatLog.message:SetVerticalAlign("TOP")
chatLog.message:SetHorizontalAlign("LEFT")
chatLog.message:SetColor(255,255,0,255)
chatLog.message:SetShadowColor(255,255,0,255)
chatLog.message:SetFontHeight(30)

chatLog.message:SetLabel("Chat Area")

chatAction = Region()
chatAction:SetWidth(50)
chatAction:SetHeight(ScreenHeight()*.20)
chatAction.texture = chatAction:Texture()
chatAction.texture:SetTexture(0,0,0,255)

chatAction:SetAnchor("BOTTOMLEFT", 0, ScreenHeight()*.80)
chatAction:Show()

chatAction.message = chatAction:TextLabel()
chatAction.message:SetRotation(270)
chatAction.message:SetColor(0,0,0,255)
chatAction.message:SetFontHeight(23)
chatAction.message:SetLabel("RUN!")
chatAction:EnableInput(true)

fxToRun = nil

function runCode(self)
	fxToRun()
	self.texture:SetTexture(0,0,0,255)
	self:Handle("OnDoubleTap", nil)
	
end


function updateRunFunction(fx, name)
	fxToRun = _G[fx]
	chatAction:Handle("OnDoubleTap", runCode)
	chatAction.texture:SetTexture(255,0,0,255)
	updateChatLog(name.." submitted a function: "..fx)
	
end

function foo()
	DPrint("123")
end
function foo2()
	DPrint("456")
end

function killMsg(self)
	if Time() > self.timeToKill then
		chatLog.message:SetLabel("")
		chatLog:Handle("OnUpdate", nil)
	end
end

chatInterval = 5
function updateChatLog(string)
	chatLog.message:SetLabel(string)
	chatLog.timeToKill = Time() + chatInterval
	chatLog:Handle("OnUpdate", killMsg)
end

function rec(region)
	centerX,centerY = region:Center()
	region.path = {}
	region.path[1] = {}
	region.path[1][1] = centerX
	region.path[1][2] = centerY
	region.path[1][3] = 0.0
	region:Handle("OnUpdate", recordPath)
	region.i = 2
	region.time = 0.0
end

function recordPath(self, elapsed)
	
	centerX,centerY = self:Center()
	self.time = self.time + elapsed
	
	if self.path[self.i-1][1] == centerX and self.path[self.i-1][2] == centerY then
		self.path[self.i-1][3] = self.time
		return
	end
	
	self.path[self.i] ={}
	self.path[self.i][1] = centerX
	self.path[self.i][2] = centerY
	self.path[self.i][3] = self.time
	self.i = self.i + 1
	--	DPrint("(x,y) = ("..centerX..","..centerY..")"..self.time)
end
function play(region)
	if region.path == nil then
		DPrint("Error:No recorded path available.")
	end
	region.pathTime = 0
	region.count = region.i
	region.i = 1
	region.key2 = createRegion(100,100,200,300,bg, 200,200,200,100)
	--DPrint("count:"..region.count..",(x,y,time) = ("..region.path[region.count-1][1]..","..region.path[region.count-1][2]..","..region.path[region.count-1][3]..")")
	
	region:Handle("OnUpdate", playPath)
end
function playPath(self,elapsed)
	self.pathTime = self.pathTime + elapsed
	if self.pathTime < self.path[self.i][3] then
		return
	end
	while self.pathTime >= self.path[self.i][3] do
		self.i = self.i+1
		if self.i >= self.count then
			self.i = 1
			self.pathTime = 0
		end
	end
	self.key2:MoveTo(self.path[self.i][1]-offY, self.path[self.i][2]-offX)
end
function stop(region)
	region:Handle("OnUpdate", nil)
	if region.key2 ~= nil then
		region.key2:Hide()
		region.key2 = nil
	end
	
end

function createYhair(parent)
	return createRegion(bgH, 2, 0,0, parent, 255,100,100,255)
end

function createXhair(parent)
	return createRegion(2, bgW, 0,0, parent, 255,100,100,255)
end

function SetBrush(self)
	self.t:SetTexCoord(0,bgH/ScreenHeight(),bgW/ScreenHeight(),0.0)
	r = Region()
	r.t = r:Texture(255,255,255,255)
	r.t:SetTexture("Ornament1.png")
	self.t:SetBlendMode("BLEND")
	r:UseAsBrush()
	self.t:SetBrushSize(64)
	bg.t:Clear(255,255,255,255)

end
function clearBG()
	bg.t:Clear(255,255,255,255)
	end
function createClear()
	clearButton = createRegion( 50, offX,offY, 0, nil, 100,100,255,255)
	clearButton:EnableInput(true)
	clearButton:SetText("Clear", 19, 255,255,255,255,-90)
	clearButton:Handle("OnDoubleTap", clearBG)
-- text, size, red, green, blue, alpha, angle )
	end
