-- urColorMemory
-- by Georg Essl 1/10/11
-- The classical color memory musical game having soar play it


--FreeAllRegions()

--backdrop = Region()
local backdrop = Region('region','backdrop',UIParent)
--backdrop:SoarLoadRules("simon-wm", "soar")
--backdrop:SoarLoadRules("simon-smem", "soar")
--backdrop:SoarLoadRules("simon-rl", "soar")

-- Inform default urMus interface that we plan to use 2 pages
next_free_page = next_free_page + 1

local pageadd = Page()

SetPage(pageadd)
local rand = math.random

b = {}
c = {{255,0,0,255},{0,255,0,255},{0,0,255,255},{255,255,0,255}}

nrpads = 4
nrx = 2
nry = 2

local tw, th

memory = {}

--[[function CreateSoarRules(first)
 if first==1 then
 board = backdrop:SoarCreateID(0, "board") -- 0 is magic for core of input (per Nate)        
 else
 backdrop:SoarDelete(gameresult)
 end
 gameresult = backdrop:SoarCreateConstant(0, "turn", "me")
 
 for ix = 1, buttoncols do
 for iy = 1, buttonrows do
 local me = buttons[iy][ix]
 
 if first==1 then
 me.id = backdrop:SoarCreateID(board, "spot") -- Create spots inside the bored (yawn)        
 me.sx = backdrop:SoarCreateConstant(me.id, "x", ix)
 me.sy = backdrop:SoarCreateConstant(me.id, "y", iy)
 else
 backdrop:SoarDelete(me.contents)
 end
 
 me.contents = backdrop:SoarCreateConstant(me.id, "contents", "empty")
 end
 end
 end--]]



local maxsequence = 10

function GenerateSequence()
	
	for i = 1,maxsequence do
		memory[i] = rand(1,4)
	end
	
end



local waittime = 0.5

local currwait = 0

local currpos = 1
local currmax = 1


local currshow = false


function Playing(self, elapsed)
	
	currwait = currwait + elapsed
	
	if currwait > waittime then
		
		currwait = currwait - waittime
		
		
		if not currshow then
			
			if b[memory[currpos]] then
				TouchedPad(b[memory[currpos]])
				else
				DPrint(currpos)
			end
			
			
			currshow = true
			else
			LeftPad(b[memory[currpos]])
			
			currshow = false
			currpos = currpos + 1
			
			if currpos > currmax then
				currpos = 1
				currmax = currmax + 1
				if currmax > maxsequence then
					currmax = 1   
					GenerateSequence()   
				end
			end
		end
	end
end


function EraseMemory(self)
	--    self:SoarDelete(gameresult)
end

local lastDecision = math.floor(Time()*10)
local delayDecisions
local clickcount = 0
local maxclicks = 10

function soarGenerateNext()
	-- tell soar about the task
	taskWme = backdrop:SoarCreateConstant(0, "task", "generate")

	local name, params =  backdrop:SoarGetOutput()

	if name ~= "press" then
		DPrint("A baby wabbit died!")
	else
		-- print("attempted: ("..params.x..","..params.y..")")
	end
	
	
	local result = params.button
	backdrop:SoarSetOutputStatus(1)

	-- clear task
	backdrop:SoarDelete(taskWme)
	
	return result
end

local nextpad
local gencount = 0
local maxgencount = 10
local seq = {}

function soarGenerate(self, elapsed)
	currwait = currwait + elapsed
	

	if currwait > waittime then
		
		currwait = currwait - waittime
		
		
		if not currshow then
			
			nextpad = soarGenerateNext()
			seq[gencount+1] = nextpad
            ucPushA1:Push(b[nextpad].sample+0.125)
            ucPushA2:Push(0.0)
			TouchColorPad(b[nextpad])
	
			gencount = gencount + 1
	
			currshow = true
		else
			LeftPad(b[nextpad])
			
			currshow = false
            if gencount > maxgencount then
            --				local str = self:SoarExec("stats")
            --				str = str .. self:SoarExec("stats --max")
            --				str = str .. self:SoarExec("print --rl")
            --				str = str .. self:SoarExec("print --rl --full")
            --				for i=1,maxgencount do
            --					str = str .. seq[i]
            --				end
            --				DPrint(str)
                self:Handle("OnUpdate", nil)
                self:SoarExec("smem --init")
            --               backdrop:SoarLoadRules("simon-rl", "soar")
                clickcount = 0
                learning = false
                currshow = false
                currwait = 0
                gencount = 0
                SetPage(pageadd+1)
            end
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

function soarLearning(index)
	if not learning then
	learning = true
	backdrop:SoarExec("step "..delayDecisions)

	-- create inputs
	clickcount = clickcount + 1
	timeWme = backdrop:SoarCreateConstant(0, "time", clickcount)
	listenWme = backdrop:SoarCreateConstant(0, "listen", index)

	-- wait
	backdrop:SoarExec("step "..delayDecisions)

--	DPrint(backdrop:SoarExec("p --depth 10 s1"))
			
	-- remove inputs
	backdrop:SoarDelete(timeWme)
	timeWme = nil
	backdrop:SoarDelete(listenWme)
	listenWme = nil
			
	-- wait
	backdrop:SoarExec("step "..delayDecisions)
	learning = false
	end
	
	if clickcount == maxclicks then
		backdrop:Handle("OnUpdate", soarGenerate)
	end
end

function TouchColorPad(self)
	self.t:SetSolidColor(self.c[1]/2,self.c[2]/2,self.c[3]/2,self.c[4])
end

function TouchedPad(self)
	TouchColorPad(self)

	local time = math.floor(Time()*10)
	delayDecisions = time - lastDecision
--	DPrint(delayDecisions)
	lastDecision = time

	if clickcount < maxclicks then
--		DPrint(clickcount..": "..self.index)
        ucPushA1:Push(self.sample+0.125)
        ucPushA2:Push(0.0)
		soarLearning(self.index)
		
	end
end

function LeftPad(self)
	self.t:SetSolidColor(self.c[1],self.c[2],self.c[3],self.c[4])
end


for k=1,nrx do
	for j=1,nry do
		i = k+nrx*(j-1)
		b[i] = Region()
		b[i]:SetWidth(ScreenWidth()/3)
		b[i]:SetHeight(ScreenHeight()/3)
		b[i]:SetAnchor("BOTTOMLEFT",ScreenWidth()/12+(k-1)*ScreenWidth()/2,ScreenHeight()/12+(j-1)*ScreenHeight()/2)
		b[i].t = b[i]:Texture()
		b[i].t:SetSolidColor(c[i][1],c[i][2],c[i][3],c[i][4])
		b[i]:Show()
		
		b[i].t:SetBlendMode("BLEND")
		
		b[i].c = c[i]
		b[i]:Handle("OnTouchDown",TouchedPad)
--		b[i]:Handle("OnEnter",TouchedPad)
		b[i]:Handle("OnTouchUp",LeftPad)
--		b[i]:Handle("OnLeave",LeftPad)
		b[i]:Handle("OnDoubleTap", EraseMemory)
		b[i]:EnableInput(true)
		b[i]:EnableClamping(true)
		b[i].index = i
        b[i].sample = (i-1)/4.0
	end
end

-- Blows up everything!!!! self:SoarExec("smem --init")

--GenerateSequence()

--backdrop:Handle("OnUpdate",Playing)

ucSample = FlowBox("object","Sample", _G["FBSample"])

ucSample:AddFile("Red-Mono.wav")
ucSample:AddFile("Orange-Mono.wav")
ucSample:AddFile("Yellow-Mono.wav")
ucSample:AddFile("Green-Mono.wav")

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

SetPage(pageadd+1)

function ColorMemIt(self)
    backdrop:SoarLoadRules(self.rules, "soar")
    SetPage(pageadd)
end

r1 = Region()
r1:SetWidth(ScreenWidth()*0.7)
r1:SetHeight(ScreenHeight()*0.25)
r1.t = r1:Texture(220,220,220,255)
r1.tl = r1:TextLabel()
r1.tl:SetFontHeight(18)
r1.tl:SetLabel("Working Memory")
r1:SetAnchor("BOTTOMLEFT",ScreenWidth()*0.15,ScreenHeight()*0.20/3)
r1.rules = "simon-wm"
r1:Handle("OnTouchUp", ColorMemIt)
r1:EnableInput(true)
r1:Show()

r2 = Region()
r2:SetWidth(ScreenWidth()*0.7)
r2:SetHeight(ScreenHeight()*0.25)
r2.t = r2:Texture(220,220,220,255)
r2.tl = r2:TextLabel()
r2.tl:SetLabel("Semantic Memory")
r2.tl:SetFontHeight(18)
r2:SetAnchor("BOTTOMLEFT",ScreenWidth()*0.15,ScreenHeight()*0.20/3*2+ScreenHeight()*0.25)
r2.rules = "simon-smem"
r2:Handle("OnTouchUp", ColorMemIt)
r2:EnableInput(true)
r2:Show()

r3 = Region()
r3:SetWidth(ScreenWidth()*0.7)
r3:SetHeight(ScreenHeight()*0.25)
r3.t = r3:Texture(220,220,220,255)
r3.tl = r3:TextLabel()
r3.tl:SetLabel("Reinforcement Learning")
r3.tl:SetFontHeight(18)
r3:SetAnchor("BOTTOMLEFT",ScreenWidth()*0.15,ScreenHeight()*0.20/3*3+ScreenHeight()*0.25*2)
r3.rules = "simon-rl"
r3:Handle("OnTouchUp", ColorMemIt)
r3:EnableInput(true)
r3:Show()

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


