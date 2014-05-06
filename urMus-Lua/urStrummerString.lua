--This code will allow a user to choose what string he or she will be "playing" from a list of buttons that show the names of the six strings of a guitar.  Once the user pushes a string button he will see a new page that shows a string split into the first four frets of a guitar.  He can then select which fret he will play in coordination with the other members of the group to form a chord and/or play melodies.
--This section of code is by Scott (String Selector) and Ricardo (Freetboard rendering and Network Communication)


FreeAllRegions()
DPrint("");

local homepage = Page()

local scalex = ScreenWidth()/320.0
local scaley = ScreenHeight()/480.0

---------------------------------------- TAB CONTROL -------------------------------------------------
function PressTab(self)
if( self.index == 1 ) then bgnd.t:SetTexture("freetboard_1.jpg") end
if( self.index == 2 ) then bgnd.t:SetTexture("freetboard_2.jpg") end
if( self.index == 3 ) then bgnd.t:SetTexture("freetboard_3.jpg") end
if( self.index == 4 ) then bgnd.t:SetTexture("freetboard_4.jpg") end
SendOSCMessage(strummer_ip,8888,"/urMus/text", self.note..self.fret)
end

function ReleaseTab(self)
bgnd.t:SetTexture("freetboard_5.jpg")
SendOSCMessage(strummer_ip,8888,"/urMus/text", self.note.."0")
end


function SelectString(self)

SetPage(homepage+1)

bgnd = Region();
bgnd:Show();
bgnd.t = bgnd:Texture(255,255,255,255);
bgnd.t:SetTexture("freetboard_5.jpg");
bgnd:SetWidth(ScreenWidth()-50*scalex);
bgnd:SetHeight(ScreenHeight());
bgnd:SetAnchor("BOTTOMLEFT",50*scalex,0);


positions = {403,277, 149,0}
height    = {108,113,119,137}
for i=1,4 do
local tab = Region()
tab.t = tab:Texture()
tab.t:SetTexture(0, 255, 0, 255)
tab:SetWidth(ScreenWidth()-50*scalex)
tab:SetHeight(height[i]*scaley)
tab:SetAnchor("BOTTOMLEFT", 50*scalex, positions[i]*scaley)
tab.tl = tab:TextLabel()
tab.tl:SetLabel("Exit")
tab:Handle('OnTouchDown', PressTab)
tab:Handle('OnTouchUp', ReleaseTab)
tab:EnableInput(true)
tab.index = i;
tab.note = self.note;
tab.fret = i;
end


exitb = Region()
exitb.t = exitb:Texture()
exitb.t:SetTexture(0, 0, 0, 255)
exitb:SetWidth(50*scalex)
exitb:SetHeight(50*scaley)
exitb:SetAnchor("BOTTOMLEFT", 0,0)
exitb.tl = exitb:TextLabel()
exitb.tl:SetLabel("Exit")
exitb:Handle('OnTouchDown', Showhome)
exitb:EnableInput(true)
exitb:Show()     

stringb = Region()
stringb.t = stringb:Texture()
stringb.t:SetTexture(0, 0, 0, 255)
stringb:SetWidth(50*scalex)
stringb:SetHeight(50*scaley)
stringb:SetAnchor("BOTTOMLEFT", 0,50*scaley)
stringb.tl = stringb:TextLabel()
stringb.tl:SetLabel(self.note)
stringb:Show()     

end

function Showhome(self)
SetPage(homepage)
end


---------------------------- MAIN INTERFACE ----------------------------------------

SetPage(homepage)

-- 6 buttons that have name of string from low to high
r2 = Region() 
r2.t = r2:Texture()
r2.t:SetTexture(0, 0, 255, 255)
r2.w = r2:SetWidth(75*scalex)
r2.h = r2:SetHeight(75*scaley)
r2:SetAnchor("TOP", ScreenWidth()/2,ScreenHeight())
r2.tl = r2:TextLabel()
r2.tl:SetLabel("Low E")
r2.note = "loE"
r2:Show() 

r3 = Region() 
r3.t = r3:Texture()
r3.t:SetTexture(0, 200, 0, 255)
r3.w=r3:SetWidth(75*scalex)
r3.h=r3:SetHeight(75*scaley)
r3:SetAnchor("BOTTOM", ScreenWidth()/2,ScreenHeight()/1.48)
r3.tl = r3:TextLabel()
r3.tl:SetLabel("A")
r3.note = "A"
r3:Show() 

r4 = Region() 
r4.t = r4:Texture()
r4.t:SetTexture(100,0, 155, 255)
r4.w=r4:SetWidth(75*scalex)
r4.h=r4:SetHeight(75*scaley)
r4:SetAnchor("TOP", ScreenWidth()/2,ScreenHeight()/1.5)
r4.tl = r4:TextLabel()
r4.tl:SetLabel("D")
r4.note = "D"
r4:Show() 

r5 = Region() 
r5.t = r5:Texture()
r5.t:SetTexture(10,39,97, 255)
r5.w=r5:SetWidth(75*scalex)
r5.h=r5:SetHeight(75*scaley)
r5:SetAnchor("CENTER", ScreenWidth()/2,ScreenHeight()/2.35)
r5.tl = r5:TextLabel()
r5.tl:SetLabel("G")
r5.note = "G"
r5:Show()

r6 = Region() 
r6.t = r6:Texture()
r6.t:SetTexture(00,100, 100, 255)
r6.w=r6:SetWidth(75*scalex)
r6.h=r6:SetHeight(75*scaley)
r6:SetAnchor("BOTTOM", ScreenWidth()/2,ScreenHeight()/5.5)
r6.tl = r6:TextLabel()
r6.tl:SetLabel("B")
r6.note = "B"
r6:Show()

r7 = Region() --Brown High E string
r7.t = r7:Texture()
r7.t:SetTexture(100,0,0, 255)
r7.w=r7:SetWidth(75*scalex)
r7.h=r7:SetHeight(75*scaley)
r7:SetAnchor("TOP", ScreenWidth()/2,ScreenHeight()/6)
r7.tl = r7:TextLabel()
r7.tl:SetLabel("High E")
r7.note = "hiE"
r7:Show()

--Regiter Handles

r2:Handle("OnTouchUp",SelectString)
r2:EnableInput(true)

r3:Handle("OnTouchUp",SelectString)
r3:EnableInput(true)

r4:Handle("OnTouchUp",SelectString)
r4:EnableInput(true)

r5:Handle("OnTouchUp",SelectString)
r5:EnableInput(true)

r6:Handle("OnTouchUp",SelectString)
r6:EnableInput(true)

r7:Handle("OnTouchUp",SelectString)
r7:EnableInput(true)



---------------------------- NETWORK STUFF ----------------------------------------
strummer_ip = "192.168.1.220"

SetOSCPort(8888)
host, port = StartOSCListener()


local pagebutton=Region()
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
pagebutton:Handle("OnDoubleTap", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetBlendMode("BLEND")
pagebutton:EnableInput(true)
pagebutton:Show()
