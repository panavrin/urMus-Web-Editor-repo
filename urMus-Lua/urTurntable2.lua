-- Include keyboard library
dofile(SystemPath("urKeyboard.lua"))

-- Clear Screen
FreeAllRegions()
DPrint("")

-- Default OSC communication info
host = "192.168.1.190"
port = "7408"

-- Initialize Background Layers
bg = Region()
bg.t = bg:Texture()
bg:Show()
bg:SetWidth(ScreenWidth())
bg:SetHeight(ScreenHeight())
bg.t:SetTexture("lightMetal.png")

bg2 = Region()
bg2.t = bg2:Texture()
bg2.t:SetSolidColor(0,0,0,200)
bg2:Show()
bg2:SetWidth(ScreenWidth())
bg2:SetHeight(ScreenHeight())
bg2.t:SetBlendMode("BLEND")

-- Functions for the pad bank
function tap(self)
    if self.index == 5 then
        -- Recording Red
        self.t:SetSolidColor(200,0,0,200)
        writePush:Push(1.0)
    elseif self.index < 10 then
        -- Sample Purple
        self.t:SetSolidColor(99,0,199,200)
		if(oscOn) then
			SendOSCMessage(host,port,"/urMus/trigger",self.index)
		end
        if self.index < 5 then
        	drumSampPush:Push((self.index-1)*0.15)
        else
        	drumSampPush:Push((self.index-2)*0.15)
        end
        drumPosPush:Push(0.0)
    else
        if looping then
            looping = false
        else
            looping = true
        end
    end
end

function release(self)
    if self.index < 10 then
        self.t:SetSolidColor(0,0,0,200)
        if self.index == 5 then
        	writePush:Push(0.0)
        else
        	drumPosPush:Push(1.0)
        end
    elseif looping then
        self.t:SetSolidColor(0,200,0,200)
    else
        self.t:SetSolidColor(0,0,0,200)
    end
end

dac = dac or _G["FBDac"]
mic = mic or FlowBox("object", "mic", _G["FBMic"])

looper = looper or FlowBox("object", "looper", _G["FBLooper"])
loopAmpPush = FlowBox("object", "loopAmpPush", _G["FBPush"])
loopRatePush = FlowBox("object", "loopRatePush", _G["FBPush"])
writePush = FlowBox("object", "writePush", _G["FBPush"])
loopPlayPush = FlowBox("object", "loopPlayPush", _G["FBPush"])
loopPosPush = FlowBox("object", "loopPosPush", _G["FBPush"])

drum = drum or FlowBox("object", "drum", _G["FBSample"])
drumAmpPush = drumAmpPush or FlowBox("object", "drumAmpPush", _G["FBPush"])
drumRatePush = drumRatePush or FlowBox("object", "drumRatePush", _G["FBPush"])
drumPosPush = drumPosPush or FlowBox("object", "drumPosPush", _G["FBPush"])
drumSampPush = drumSampPush or FlowBox("object", "drumSampPush", _G["FBPush"])
drumLoopPush = drumLoopPush or FlowBox("object", "drumLoopPush", _G["FBPush"])
drum:AddFile("Bass.wav")
drum:AddFile("Clap.wav")
drum:AddFile("ClosedHat.wav")
drum:AddFile("OpenHat.wav")
drum:AddFile("sine.wav")
drum:AddFile("square.wav")
drum:AddFile("saw.wav")
drum:AddFile("Scratch.wav")


dac:SetPullLink(0,looper,0)
dac:SetPullLink(0,drum,0)
mic:SetPushLink(0,looper,0)

loopAmpPush:SetPushLink(0,looper,1)
loopRatePush:SetPushLink(0,looper,2)
writePush:SetPushLink(0,looper,3)
loopPlayPush:SetPushLink(0,looper,4)
loopPosPush:SetPushLink(0,looper,5)

drumAmpPush:SetPushLink(0,drum,0)
drumRatePush:SetPushLink(0,drum,1)
drumPosPush:SetPushLink(0,drum,2)
drumSampPush:SetPushLink(0,drum,3)
drumLoopPush:SetPushLink(0,drum,4)

loopAmpPush:Push(0.65)
loopRatePush:Push(0.0)
writePush:Push(0.0)
loopPlayPush:Push(1.0)
loopPosPush:Push(0.0)

drumAmpPush:Push(0.8)
drumRatePush:Push(0.5)
drumPosPush:Push(1.0)
drumSampPush:Push(0.0)
drumLoopPush:Push(0.0)


looping = false
oscOn = true
soundOn = true
editing = false

-- Make the pad bank
pads = {}
for i = 1,5 do
    for j = 0,1 do
        local k = i + 5*j
        pads[k] = Region()
        pads[k].t = pads[k]:Texture()
        pads[k].tl = pads[k]:TextLabel()
        pads[k].tl:SetLabel("Pad\n" .. k)
        pads[k].tl:SetFontHeight(16)
        pads[k].tl:SetColor(255,255,255,255)
        pads[k].tl:SetHorizontalAlign("JUSTIFY")
        pads[k].tl:SetShadowColor(0,0,0,255)
        pads[k].tl:SetShadowOffset(1,1)
        pads[k].tl:SetShadowBlur(1)
        pads[k]:Show()
        pads[k]:SetWidth(ScreenWidth()*5/32)
        pads[k]:SetHeight(ScreenWidth()*5/32)
        pads[k].t:SetTexture("pad.png")
        pads[k].t:SetSolidColor(0,0,0,180);
        pads[k].t:SetBlendMode("BLEND")
        pads[k]:EnableInput(true)
        pads[k]:Handle("OnTouchDown",tap)
        pads[k]:Handle("OnEnter",tap)
        pads[k]:Handle("OnLeave",release)
        pads[k]:Handle("OnTouchUp",release)
        if j == 0 then
            pads[k]:SetAnchor("TOPLEFT", bg, "TOPLEFT", ScreenWidth()*3*(i-0.75)/16, -0.004*ScreenHeight())
        else
            pads[k]:SetAnchor("TOPLEFT", bg, "TOPLEFT", ScreenWidth()*3*(i-0.75)/16, -0.126*ScreenHeight())
        end
        pads[k].index = k
    end
end

function turnDisc(self,offset)
	self.t:SetRotation(self.arg)
	if(8*self.v > 9*ScreenWidth()/111 and 8*self.v < 102*ScreenWidth()/111) then
		fader:SetAnchor("BOTTOMLEFT",bar,"BOTTOMLEFT",8*self.v-287*ScreenWidth()/3552,0)
	end
	if(self.dir == "cw") then
		loopRatePush:Push(math.min(0.5,(self.v+offset)/200))
	else
		loopRatePush:Push(math.max(-0.5,(self.v+offset)/-200))
	end
end

function rotXY(self, x, y, dx, dy)
	local cx = disc:Width()/2 - x
	local cy = disc:Width()/2 - y
	local cx2 = cx + dx
	local cy2 = cy + dy
	local rx = cx2 - cx
	local ry = cy2 - cy
	local det = cx*cy2-cy*cx2

	local c1len = math.sqrt(cx*cx+cy*cy)
	local c2len = math.sqrt(cx2*cx2+cy2*cy2)
	local dangle = math.acos((cx*cx2+cy*cy2)/(c1len*c2len))

	if det < 0 then
		self.dir = "ccw"
	else
		dangle = -dangle
		self.dir = "cw"
	end

	local v = math.sqrt(dx*dx+dy*dy)
	self.v = v/2

	self.arg = (self.arg + dangle) % (2*math.pi)
	turnDisc(self,0)
end

function start(self)
	self:Handle("OnUpdate",spin)
end

function stop(self)
	self.prevArg = disc.arg
	self.v = 0
	self:Handle("OnUpdate",nil)
	turnDisc(self,0)
end

function spin(self, elapsed)
    bg2.t:SetGradientColor("HORIZONTAL",0,0,0,200,0,2*self.v,0,200)
    disc.t:SetSolidColor(255-1.5*self.v,255-2.5*self.v,255-self.v/2,255)
	local offset = 30
	if(oscOn) then
		SendOSCMessage(host,port,"/urMus/spinV",self.v)
	end
	if(self.dir == "cw") then
		self.arg = (self.arg - self.v/200) % (2*math.pi)
	else
		self.arg = (self.arg + self.v/200) % (2*math.pi)
	end
	if not looping then
		self.v = self.v - (elapsed*20)^2
		if self.v <= 0 then
			self.v = 0
			offset = 0
		end
	end
	turnDisc(self,offset)
end

function slide(self,v)
	x,y = InputPosition()
	if(x >= 9*ScreenWidth()/111 and x <= 102*ScreenWidth()/111) then
		fader:SetAnchor("BOTTOMLEFT",bar,"BOTTOMLEFT",x-11*ScreenWidth()/3222-ScreenWidth()/32,0)
		if looping then
			disc.v = x/8
		end
	end
end

disc = Region()
disc.t = disc:Texture()
disc:Show()
disc:SetWidth(ScreenWidth()/1.05)
disc:SetHeight(ScreenWidth()/1.05)
disc:SetAnchor("CENTER",bg,"BOTTOMLEFT",bg:Width()/2,bg:Height()/2.85)
disc.t:SetTexture("vinyl.png")
disc.t:SetBlendMode("BLEND")
disc.t:SetTiling(false)
disc:EnableInput(true)
disc.arg = math.pi
disc.prevArg = math.pi
disc.v = 0
disc.dir = "ccw"
disc:Handle("OnMove", rotXY)
disc:Handle("OnTouchDown",stop)
disc:Handle("OnLeave",stop)
disc:Handle("OnTouchUp",start)
disc:Handle("OnEnter",start)

arm = Region()
arm:SetWidth(ScreenWidth()/3)
arm:SetHeight(ScreenWidth()/1.2)
arm:SetAnchor("BOTTOMLEFT",-20,-35)
arm.t = arm:Texture()
arm.t:SetTexture("arm.png")
arm.t:SetBlendMode("BLEND")
arm:Show()

bar = Region()
bar:SetWidth(ScreenWidth()/1.11)
bar:SetHeight(ScreenWidth()/16)
bar:SetAnchor("CENTER",UIParent,"CENTER",0,ScreenHeight()/4.3)
bar.t = bar:Texture(0,0,0,200)
bar.t:SetBlendMode("BLEND")
bar.tl = bar:TextLabel()
bar.tl:SetLabel("Loop Speed")
bar.tl:SetFontHeight(16)
bar.tl:SetHorizontalAlign("JUSTIFY")
bar.tl:SetShadowColor(0,0,0,255)
bar.tl:SetShadowOffset(2,2)
bar.tl:SetShadowBlur(3)
bar:EnableHorizontalScroll(true)
bar:EnableInput(true)
bar:Show()

fader = Region()
fader:SetWidth(ScreenWidth()/16)
fader:SetHeight(ScreenWidth()/16)
fader:SetAnchor("BOTTOMLEFT",bar,"BOTTOMLEFT",0,0)
fader.t = fader:Texture()
fader.t:SetTexture("star.png")
fader.t:SetBlendMode("BLEND")
fader:Show()
bar:Handle("OnHorizontalScroll",slide)
bar:Handle("OnEnter",slide)
bar:Handle("OnTouchDown",slide)

local button = Region('region', 'button', UIParent)
button:SetWidth(pagersize/1.4)
button:SetHeight(pagersize/1.4)
button:SetLayer("TOOLTIP")
button:SetAnchor("CENTER",disc,"CENTER",0,0)
button.t = button:Texture("Button-128-blurred.png")
button.t:SetBlendMode("BLEND")
button:Show()

local defaultpage = Page()

function MainPage()
	SetPage(defaultpage)
end

function oscMode()
	if oscOn then
		oscOn = false
		oscButton.t:SetSolidColor(200,0,0,200)
		oscButton.tl:SetLabel("OSC OFF")
	else
		oscOn = true
		oscButton.t:SetSolidColor(0,200,0,200)
		oscButton.tl:SetLabel("OSC ON")
	end
end

function soundMode()
	if soundOn then
		soundOn = false
		soundButton.t:SetSolidColor(200,0,0,200)
		soundButton.tl:SetLabel("Sound\nOFF")
		loopAmpPush:Push(0.0)
		drumAmpPush:Push(0.0)
	else
		soundOn = true
		soundButton.t:SetSolidColor(0,200,0,200)
		soundButton.tl:SetLabel("Sound\nON")
		loopAmpPush:Push(0.65)
		drumAmpPush:Push(0.8)
	end
end

function hostChange()
	if not editing then
		editPort:Handle("OnDoubleTap", nil)
		editing = true
		hostLabel2.tl:SetLabel("")
		editHost.t:SetSolidColor(200,0,0,200)
		mykb.typingarea = hostLabel2
		mykb:Show(3)
	else
		editPort:Handle("OnDoubleTap", portChange)
		editing = false
		host = hostLabel2.tl:Label()
		mykb:Hide()
		editHost.t:SetSolidColor(0,200,0,200)
	end
end

function portChange()
	if not editing then
		editHost:Handle("OnDoubleTap", nil)
		editing = true
		portLabel2.tl:SetLabel("")
		editPort.t:SetSolidColor(200,0,0,200)
		mykb.typingarea = portLabel2
		mykb:Show(3)
	else
		editHost:Handle("OnDoubleTap", hostChange)
		editing = false
		port = portLabel2.tl:Label()
		mykb:Hide()
		editPort.t:SetSolidColor(0,200,0,200)
	end
end

function ConfigPage()
	SetPage(defaultpage+1)

	if not bgc then
		bgc = Region()
		bgc.t = bgc:Texture()
		bgc:Show()
		bgc:SetWidth(ScreenWidth())
		bgc:SetHeight(ScreenHeight())
		bgc.t:SetTexture("lightMetal.png")
		bg2:Show()
	end
	if not bgc2 then
		bgc2 = Region()
		bgc2.t = bgc2:Texture()
		bgc2.t:SetGradientColor("HORIZONTAL",0,0,0,200,0,0,0,200)
		bgc2:Show()
		bgc2:SetWidth(ScreenWidth())
		bgc2:SetHeight(ScreenHeight())
		bgc2.t:SetBlendMode("BLEND")
	end
	if not mykb then
		mykb = Keyboard.Create()
	end
	if not hostLabel then
		hostLabel = Region()
		hostLabel:SetWidth(ScreenWidth())
		hostLabel:SetHeight(ScreenHeight()/20)
		hostLabel:SetAnchor("TOPLEFT",bg,"TOPLEFT",20,-20)
		hostLabel.tl = hostLabel:TextLabel()
		hostLabel.tl:SetVerticalAlign("TOP")
		hostLabel.tl:SetHorizontalAlign("LEFT")
		hostLabel.tl:SetFontHeight(ScreenHeight()/20)
		hostLabel:Show()
		hostLabel.tl:SetLabel("Host:")
	end
	if not hostLabel2 then
		hostLabel2 = Region()
		hostLabel2:SetWidth(ScreenWidth())
		hostLabel2:SetHeight(ScreenHeight()/20)
		hostLabel2:SetAnchor("TOPLEFT",bg,"TOPLEFT",160,-20)
		hostLabel2.tl = hostLabel2:TextLabel()
		hostLabel2.tl:SetVerticalAlign("TOP")
		hostLabel2.tl:SetHorizontalAlign("LEFT")
		hostLabel2.tl:SetFontHeight(ScreenHeight()/20)
		hostLabel2:Show()
		hostLabel2.tl:SetLabel(host)
	end
	if not portLabel then
		portLabel = Region()
		portLabel:SetWidth(ScreenWidth())
		portLabel:SetHeight(ScreenHeight()/20)
		portLabel:SetAnchor("TOPLEFT",bg,"TOPLEFT",20,-40 - ScreenHeight()/20)
		portLabel.tl = portLabel:TextLabel()
		portLabel.tl:SetVerticalAlign("TOP")
		portLabel.tl:SetHorizontalAlign("LEFT")
		portLabel.tl:SetFontHeight(ScreenHeight()/20)
		portLabel:Show()
		portLabel.tl:SetLabel("Port:")
	end
	if not portLabel2 then
		portLabel2 = Region()
		portLabel2:SetWidth(ScreenWidth())
		portLabel2:SetHeight(ScreenHeight()/20)
		portLabel2:SetAnchor("TOPLEFT",bg,"TOPLEFT",160,-40 - ScreenHeight()/20)
		portLabel2.tl = portLabel2:TextLabel()
		portLabel2.tl:SetVerticalAlign("TOP")
		portLabel2.tl:SetHorizontalAlign("LEFT")
		portLabel2.tl:SetFontHeight(ScreenHeight()/20)
		portLabel2:Show()
		portLabel2.tl:SetLabel(port)
	end
	if not oscButton then
		oscButton = Region()
		oscButton:SetWidth(bgc:Width()*5/32)
		oscButton:SetHeight(bgc:Width()*5/32)
		oscButton:SetAnchor("BOTTOMLEFT",40,mykb:Height()+20)
		oscButton.tl = oscButton:TextLabel()
		oscButton.tl:SetLabel("OSC ON")
		oscButton.tl:SetFontHeight(16)
		oscButton.tl:SetColor(255,255,255,255)
		oscButton.tl:SetHorizontalAlign("JUSTIFY")
		oscButton.tl:SetShadowColor(0,0,0,255)
		oscButton.tl:SetShadowOffset(1,1)
		oscButton.tl:SetShadowBlur(1)
		oscButton:Handle("OnDoubleTap", oscMode)
		oscButton.t = oscButton:Texture("pad.png")
		oscButton.t:SetBlendMode("BLEND")
		oscButton.t:SetSolidColor(0,200,0,200)
		oscButton:EnableInput(true)
		oscButton:Show()
	end
	if not soundButton then
		soundButton = Region()
		soundButton:SetWidth(bgc:Width()*5/32)
		soundButton:SetHeight(bgc:Width()*5/32)
		soundButton:SetAnchor("BOTTOMLEFT",60+soundButton:Width(),mykb:Height()+20)
		soundButton.tl = soundButton:TextLabel()
		soundButton.tl:SetLabel("Sound\nON")
		soundButton.tl:SetFontHeight(16)
		soundButton.tl:SetColor(255,255,255,255)
		soundButton.tl:SetHorizontalAlign("JUSTIFY")
		soundButton.tl:SetShadowColor(0,0,0,255)
		soundButton.tl:SetShadowOffset(1,1)
		soundButton.tl:SetShadowBlur(1)
		soundButton:Handle("OnDoubleTap", soundMode)
		soundButton.t = soundButton:Texture("pad.png")
		soundButton.t:SetBlendMode("BLEND")
		soundButton.t:SetSolidColor(0,200,0,200)
		soundButton:EnableInput(true)
		soundButton:Show()
	end
	if not editHost then
		editHost = Region()
		editHost:SetWidth(bgc:Width()*5/32)
		editHost:SetHeight(bgc:Width()*5/32)
		editHost:SetAnchor("BOTTOMLEFT",80+2*editHost:Width(),mykb:Height()+20)
		editHost.tl = editHost:TextLabel()
		editHost.tl:SetLabel("Edit\nHost")
		editHost.tl:SetFontHeight(16)
		editHost.tl:SetColor(255,255,255,255)
		editHost.tl:SetHorizontalAlign("JUSTIFY")
		editHost.tl:SetShadowColor(0,0,0,255)
		editHost.tl:SetShadowOffset(1,1)
		editHost.tl:SetShadowBlur(1)
		editHost:Handle("OnDoubleTap", hostChange)
		editHost.t = editHost:Texture("pad.png")
		editHost.t:SetBlendMode("BLEND")
		editHost.t:SetSolidColor(0,200,0,200)
		editHost:EnableInput(true)
		editHost:Show()
	end
	if not editPort then
		editPort = Region()
		editPort:SetWidth(bgc:Width()*5/32)
		editPort:SetHeight(bgc:Width()*5/32)
		editPort:SetAnchor("BOTTOMLEFT",100+3*editPort:Width(),mykb:Height()+20)
		editPort.tl = editPort:TextLabel()
		editPort.tl:SetLabel("Edit\nPort")
		editPort.tl:SetFontHeight(16)
		editPort.tl:SetColor(255,255,255,255)
		editPort.tl:SetHorizontalAlign("JUSTIFY")
		editPort.tl:SetShadowColor(0,0,0,255)
		editPort.tl:SetShadowOffset(1,1)
		editPort.tl:SetShadowBlur(1)
		editPort:Handle("OnDoubleTap", portChange)
		editPort.t = editPort:Texture("pad.png")
		editPort.t:SetBlendMode("BLEND")
		editPort.t:SetSolidColor(0,200,0,200)
		editPort:EnableInput(true)
		editPort:Show()
	end
	if not returnButton then
		returnButton=Region()
		returnButton:SetWidth(bgc:Width()*5/32)
		returnButton:SetHeight(bgc:Width()*5/32)
        returnButton:SetLayer("TOOLTIP")
		returnButton:SetAnchor("BOTTOMLEFT",120+4*returnButton:Width(),mykb:Height()+20)
		returnButton.tl = returnButton:TextLabel()
		returnButton.tl:SetLabel("Return\nto Main\nPage")
		returnButton.tl:SetFontHeight(16)
		returnButton.tl:SetColor(255,255,255,255)
		returnButton.tl:SetHorizontalAlign("JUSTIFY")
		returnButton.tl:SetShadowColor(0,0,0,255)
		returnButton.tl:SetShadowOffset(1,1)
		returnButton.tl:SetShadowBlur(1)
		returnButton:EnableClamping(true)
		returnButton:Handle("OnDoubleTap", MainPage)
		returnButton.t = returnButton:Texture("pad.png")
		returnButton.t:SetBlendMode("BLEND")
		returnButton.t:SetSolidColor(99,0,199,180)
		returnButton:EnableInput(true)
		returnButton:Show()
	end
end

local pagebutton = Region()
pagebutton:SetWidth(3*pagersize)
pagebutton:SetHeight(3*pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor("BOTTOMLEFT",ScreenWidth()-3.5*pagersize-4,ScreenHeight()/2+3*pagersize+4); 
pagebutton:EnableClamping(true)
pagebutton:Handle("OnDoubleTap", ConfigPage)
pagebutton.t = pagebutton:Texture("settingsButton.png")
pagebutton.t:SetBlendMode("BLEND")
pagebutton:EnableInput(true)
pagebutton:Show()
