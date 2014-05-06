function rules(self)
	self:SoarExec( "sp {prop*init (state <s> ^superstate nil -^ct) --> (<s> ^operator.name init)}" )
	self:SoarExec( "sp {apply*init (state <s> ^operator.name init) --> (<s> ^ct 1 ^max 50000)}" )
	self:SoarExec( "sp {prop*inc (state <s> ^ct <c> ^max <> <c>) --> (<s> ^operator.name inc)}" )
	self:SoarExec( "sp {apply*inc (state <s> ^ct <c> ^operator.name inc) --> (<s> ^ct <c> - (+ <c> 1))}" )
	self:SoarExec( "sp {done (state <s> ^ct <m> ^max <m> ^io.output-link <out>) --> (<out> ^done.foo bar)}" )

	self:SoarExec( "timers -d" )
end

soar=Region()
soar:SetWidth(ScreenWidth())
soar:SetHeight(ScreenHeight())
soar:SetLayer("BACKGROUND")
soar:SetAnchor("BOTTOMLEFT", 0, 0)
soar.t=soar:Texture(255,255,255,255)
soar:Show()

function synch(self)
	self.tl:SetLabel("synch:\n".."counting")
	self:SoarExec("init")
	name,params = self:SoarGetOutput()
	self.tl:SetLabel("synch:\n"..name.." ("..self:SoarGetDecisions()..")")
end

function asynch2(self)
	self:Handle( "OnUpdate", nil )
	name,params = self:SoarGetOutput()
	self.tl:SetLabel("asynch:\n"..name.." ("..self:SoarGetDecisions()..")")
end

function asynch_title(self)
	self.tl:SetLabel("asynch:\n".."counting ("..self:SoarGetDecisions()..")")
end

function asynch(self)
	self:SoarExec("init")
	self:Handle( "OnSoarOutput", asynch2 )
	self:Handle( "OnUpdate", asynch_title )
end

button1=Region()
button1:SetWidth(100)
button1:SetHeight(50)
button1:SetLayer("HIGH")
button1:SetAnchor("BOTTOMLEFT", ScreenWidth()/2-50, 20)
button1.t=button1:Texture(0,0,255,255)
button1:Show()
button1:EnableInput(true)
button1:Handle( "OnTouchUp", synch )
button1.tl=button1:TextLabel()
button1.tl:SetColor(255,255,255,255)
button1.tl:SetLabel("synch")
rules(button1)

button2=Region()
button2:SetWidth(100)
button2:SetHeight(50)
button2:SetLayer("HIGH")
button2:SetAnchor("BOTTOMLEFT", ScreenWidth()/2-50, 90)
button2.t=button2:Texture(0,255,0,255)
button2:Show()
button2:EnableInput(true)
button2:Handle( "OnTouchUp", asynch )
button2.tl=button2:TextLabel()
button2.tl:SetColor(0,0,0,255)
button2.tl:SetLabel("asynch")
rules(button2)

size=10
function set_loc(self)
	self:SetAnchor("BOTTOMLEFT",self.x,self.y)
end

function move(self,elapsed)
	if self.y+size+size>ScreenHeight()-40 then
		self.y=160

		if self.x+size+size>ScreenWidth() then
			self.x=0
		else
			self.x=self.x+size
		end
		
	else
		self.y=self.y+size
	end

	set_loc(self)
end

button3=Region()
button3:SetWidth(size)
button3:SetHeight(size)
button3:SetLayer("MEDIUM")
button3.x=0
button3.y=160
set_loc(button3)
button3.t=button3:Texture(255,255,255,255)
button3:Show()
button3:Handle( "OnUpdate", move )

block=Region()
block:SetWidth(ScreenWidth())
block:SetHeight(ScreenHeight()-160-40)
block:SetLayer("BACKGROUND")
block.t=block:Texture(0,0,0,255)
block:SetAnchor("BOTTOMLEFT",0,160)
block:Show()

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
