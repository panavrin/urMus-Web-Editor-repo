
local function uapShutdown()
    dac:RemovePullLink(0, uapSample, 0)
    dac:RemovePullLink(0, uapSample2, 0)
end

local function uapReInit(self)
    dac:SetPullLink(0, uapSample, 0)
    dac:SetPullLink(0, uapSample2, 0)
end

-- constants
unit = 20
num_special=0
if ScreenWidth() > 320 then
    poissonfactor = 2
else
    poissonfactor = 6

end

-- dudes
function set_loc(self)
	self:SetAnchor("BOTTOMLEFT", self.dx, self.dy)

	if self.soar_x~=nil then
		self:SoarDelete(self.soar_x)
		self:SoarDelete(self.soar_y)
	end

	self.soar_x = self:SoarCreateConstant(0, "x", self.x)
	self.soar_y = self:SoarCreateConstant(0, "y", self.y)
end

function move(self, elapsed)
	do_something = math.random(poissonfactor)
	if do_something==1 then

		if num_special==0 then
			self.target=nil
			dir = math.random(4)
			if dir == 1 then
				self.dx = self.dx - unit
			elseif dir == 2 then
				self.dx = self.dx + unit
			elseif dir == 3 then
				self.dy = self.dy - unit
			elseif dir == 4 then
				self.dy = self.dy + unit
			end
		else
			if self.target==nil then
				--self:SoarExec("d")
				--print(self:SoarExec("p --depth 10 s1"))
				local name, params =  self:SoarGetOutput()
				--print(self:SoarExec("p --depth 10 s1"))
				self:SoarSetOutputStatus(1)
				self.target=bg[math.ceil(params.x)][math.ceil(params.y)]
			end

			diff_x = self.target.x-self.x
			diff_y = self.target.y-self.y

			if (math.abs(diff_x)<=math.abs(diff_y)) then
				self.dy = self.dy + unit*(diff_y/math.abs(diff_y))
			else
				self.dx = self.dx + unit*(diff_x/math.abs(diff_x))
			end
		end

		if self.dx < 0 then
			self.dx = 0
		end

		if self.dy < 0 then
			self.dy = 0
		end

		if self.dx > (ScreenWidth()-unit) then
			self.dx = (ScreenWidth()-unit)
		end

		if self.dy > (ScreenHeight()-unit) then
			self.dy = (ScreenHeight()-unit)
		end

		new_x = math.floor(self.dx/unit)
		new_y = math.floor(self.dy/unit)

		if (new_x~=self.x) or (new_y~=self.y) then

			self.x = new_x
			self.y = new_y
			set_loc(self)

			bg_b = bg[self.x][self.y]

			if bg_b.special then
				bg_b.t:SetTexture(255,255,255,255)
				bg_b.special=false

                upPush2:Push(self.sample+0.125)
                upPush:Push(0.0)


				num_special=num_special-1

				for k,v in pairs(bg_b.wmes) do
					v.a:SoarDelete(v.food)

					--v.a:SoarExec("d")
					--print(v.a:SoarExec("p --depth 10 s1"))
				end
				bg_b.wmes=nil

				for k,v in pairs(dudes) do
					if v.target==bg_b then
						v.target=nil
					end
				end
			end
		end
	end
end

num_dudes = 4
dudes = {}
for i=1,num_dudes do
	a=Region('region',('dude-'..i),UIParent)
	a:SetLayer("HIGH")
	
	a:SetWidth(unit)
	a:SetHeight(unit)
	
	a.t=a:Texture(0,0,255,255)

    a.sample = (i-1)/num_dudes

	--a:EnableClamping(true)
	a:Handle("OnUpdate", move)
	a.dx=i*unit
	a.dy=unit
	a.x=i
	a.y=1
	a.soar_x=nil
	a.soar_y=nil
	a.target=nil
	set_loc(a)

	a:SoarExec("sp {prop*seek (state <s> ^io.input-link.food <f>) (<f> ^x <x> ^y <y>) --> (<s> ^operator <op> + =) (<op> ^name seek ^target <t>) (<t> ^x <x> ^y <y>)}")
	a:SoarExec("sp {apply*seek (state <s> ^operator <op> ^io.output-link <out>) (<op> ^name seek ^target <f>) --> (<out> ^seek <f>)}")
	a:SoarExec("sp {prop*clean (state <s> ^io.output-link.seek.status) --> (<s> ^operator <op> + >) (<op> ^name clean)}")
	a:SoarExec("sp {apply*clean (state <s> ^io.output-link <out> ^operator.name clean) (<out> ^seek <f>) (<f> ^status) --> (<out> ^seek <f> -)}")

	a.tl=a:TextLabel()
	a.tl:SetLabel(i)
	a.tl:SetColor(255,255,255,255)
	
	a:Show()

	dudes[i] = a
end

-- background
function block(self)
	if self.special == false then
		self.t:SetTexture(0,255,0,255)
		self.special=true
		self.wmes={}

		for k,v in pairs(dudes) do
			temp = {}
			foodid,temp.food = v:SoarCreateID(0, "food")
			v:SoarCreateConstant(foodid, "x", self.x)
			v:SoarCreateConstant(foodid, "y", self.y)
			temp.a = v

			--v:SoarExec("d")
			--print(k..".. "..v:SoarExec("p --depth 10 s1"))

			self.wmes[k]=temp
		end

		num_special=num_special+1
	end
end

bg = {}

for x=0,(ScreenWidth()/unit-1) do
	bg[x] = {}

	for y=0,(ScreenHeight()/unit-1) do
		a=Region()
		a.x=x
		a.y=y
		a.special=false
		a.wmes=nil

		a:SetLayer("BACKGROUND")
		a:SetWidth(unit)
		a:SetHeight(unit)
		
		a.t=a:Texture(255,255,255,255)

		a:SetAnchor("BOTTOMLEFT", x*unit, y*unit)
		
		a:EnableInput(true)
		a:Handle("OnTouchUp", block);

		a:Show()

		bg[x][y] = a
	end
end

-- page button!
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

agentBGRegion = Region()
agentBGRegion:Handle("OnPageEntered", uapReInit)
agentBGRegion:Handle("OnPageLeft", uapShutdown)

uapSample = FlowBox("object","mysample", FBSample)
uapSample:AddFile("MerryGo.wav")
-- "Merry Go" Kevin MacLeod (incompetech.com) Licensed under Creative Commons "Attribution 3.0" http://creativecommons.org/licenses/by/3.0/
dac = _G["FBDac"]
uapSample2 = FlowBox("object","mysample2", FBSample)
uapSample2:AddFile("wahoo.wav")
uapSample2:AddFile("donuts.wav")
uapSample2:AddFile("yummy.wav")
uapSample2:AddFile("yummy2.wav")

upPush = FlowBox("object", "mypush", FBPush)
upPush2 = FlowBox("object", "mypush", FBPush)

dac:SetPullLink(0, uapSample, 0)

upPush:SetPushLink(0,uapSample, 0)  
upPush:Push(0.6); -- Turn looping off
upPush:RemovePushLink(0,uapSample, 0)  
upPush:SetPushLink(0,uapSample2, 0)  
upPush:Push(0.7); -- Turn looping off
upPush:RemovePushLink(0,uapSample2, 0)  
upPush:SetPushLink(0,uapSample2, 4)  
upPush:Push(-1.0); -- Turn looping off
upPush:RemovePushLink(0,uapSample2, 4)  
upPush2:SetPushLink(0,uapSample2, 3)  -- Sample switcher
upPush2:Push(0) -- AM wobble
upPush:SetPushLink(0,uapSample2, 2)
upPush:Push(1.0); -- Set position to end so nothing plays.

dac:SetPullLink(0, uapSample2, 0)

