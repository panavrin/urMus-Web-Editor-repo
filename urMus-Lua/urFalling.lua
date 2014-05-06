FreeAllRegions()
FreeAllFlowboxes()
DPrint("")

red = 255
blue = 0
green = 0
deviceNum = 0
StartAudio()

local baseAddr= "192.168.1.113"

SetOSCPort(8888)
host, port = StartOSCListener()


-- page displaying data when not falling
r = Region()
r.t = r:Texture(80,10,75,255)
r:SetHeight(ScreenHeight())
r:SetWidth(ScreenWidth())
r:Show()


-- page to display when in freefall
r2 = Region()
r2.t = r2:Texture()
r2:SetHeight(ScreenHeight())
r2:SetWidth(ScreenWidth())
r2.t:SetTexture(0,0,0,255)

function setNote(self)
	if(self.index < 9) then 
	for i=1,8 do
		btnArray[i].t:SetSolidColor(255,0,0,255)
	end
	self.t:SetSolidColor(255,128,128,255)
	SendOSCMessage(baseAddr,8888,"/urMus/numbers",(self.index +10*(deviceNum-1)))
	else
		deviceNum = self.index - 8
		DPrint(deviceNum)
	end
end

btnArray = {}
for i=1,12 do
    btnArray[i] = Region()
    btnArray[i].t = btnArray[i]:Texture()
    btnArray[i]:Show()
    btnArray[i]:Handle("OnTouchDown",setNote)
	btnArray[i].t:SetTexture(255,0,0,255)
	btnArray[i]:SetHeight(ScreenHeight()/4)
	btnArray[i]:SetWidth(ScreenWidth()/4)
    btnArray[i]:EnableInput(true)
	btnArray[i].index = i
end



function setText(self,note)
	self.tl=self:TextLabel()
	self.tl:SetLabel(note)
end

setText(btnArray[1],"C")   
setText(btnArray[2],"D")
setText(btnArray[3],"E")
setText(btnArray[4],"F")   
setText(btnArray[5],"G")   
setText(btnArray[6],"A")
setText(btnArray[7],"B")
setText(btnArray[8],"C")
setText(btnArray[9],"1")
setText(btnArray[10],"2")
setText(btnArray[11],"3")
setText(btnArray[12],"4")

btnArray[1]:SetAnchor("BOTTOMLEFT",0,0)
btnArray[2]:SetAnchor("BOTTOMLEFT",ScreenWidth()/4,0)
btnArray[3]:SetAnchor("BOTTOMLEFT",ScreenWidth()/2,0)
btnArray[4]:SetAnchor("BOTTOMLEFT",3*ScreenWidth()/4,0)
btnArray[5]:SetAnchor("BOTTOMLEFT",0,ScreenHeight()/4)
btnArray[6]:SetAnchor("BOTTOMLEFT",ScreenWidth()/4,ScreenHeight()/4)
btnArray[7]:SetAnchor("BOTTOMLEFT",ScreenWidth()/2,ScreenHeight()/4)
btnArray[8]:SetAnchor("BOTTOMLEFT",3*ScreenWidth()/4,ScreenHeight()/4)
btnArray[9]:SetAnchor("TOPLEFT",0,ScreenHeight())
btnArray[10]:SetAnchor("TOPLEFT",ScreenWidth()/4,ScreenHeight())
btnArray[11]:SetAnchor("TOPLEFT",ScreenWidth()/2,ScreenHeight())
btnArray[12]:SetAnchor("TOPLEFT",3*ScreenWidth()/4,ScreenHeight())



-- called when in freefall
function flash(self, elapsed)
	if (red == 255) then
		red = 0;
	else
		red = 255
	self.t:SetTexture(red,blue,green,255)
	end
end
i = 0
-- logic to switch pages 
function display(self, x, y, z)
    if (math.abs(x) < .1 and math.abs(y) < .1 and math.abs(z) < .1 and hasFallen ~= 1 ) then  -- if falling
		hasFallen = 1
		DPrint(i)
		i = i+1
        r2:Show()
        r:Hide()
       -- r2:Handle("OnUpdate",flash)
		SendOSCMessage(baseAddr,8888,"/urMus/numbers",1+10*(deviceNum-1))
	elseif(math.abs(x) < .1 and math.abs(y) < .1 and math.abs(z) < .1) then
		time_falling = time_falling + .03003
		distance = 16*math.pow (time_falling, 2)
    else      -- show the info screen
		if(hasFallen == 1) then
	        r2:Handle("OnUpdate",nil)
			hasFallen = 0
		SendOSCMessage(baseAddr,8888,"/urMus/numbers",0+ 10*(deviceNum-1))
		end
		time_falling = 0
        r2:Hide()
        r:Show()
    end
end

r:Handle("OnAccelerate", display)

