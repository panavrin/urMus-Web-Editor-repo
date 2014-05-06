-- urTurn.lua
-- by Georg Essl
-- Created: 2/25/11
-- Demonstrates animated font-type art using rotated text labels

FreeAllRegions()

--local urfont2 = "arial"
local random = math.random

local numrepetitions = 3 --18
local minradius = ScreenWidth()/3
local maxradius = ScreenWidth()/4*3
local minspeed = 1*30.0
local maxspeed = 5*30.0
local minfontsize = 12
local maxfontsize = 48

local words = {"record","fun","urMus","spin","turn","motion","bend","repeat","clock","emerge","period","Moebius","circle","torus","closed","curve","arc","delta"}

rs = {}

function rotate(self, elapsed)
    self.angle = self.angle + self.aspeed*elapsed
    self.tl:SetRotation(self.angle)
    self.alpha = self.alpha - self.alphaspeed*elapsed
    if self.alpha <= 0  then
        self.alpha = 0
        self.alphaspeed = - self.alphaspeed
    end
    if self.alpha >= 255 then
        self.alpha = 255
        self.alphaspeed = - self.alphaspeed
    end
   
    local r,g,b = self.tl:Color()
    self.tl:SetColor(r,g,b,self.alpha)
end



for j=1,numrepetitions do
	for i=1,#words do
		local r = Region()
		r.size = random(minradius,maxradius)
		r:SetAnchor("CENTER",UIParent,"CENTER",0,0)
		r:SetHeight(r.size)
		r:SetWidth(r.size)
--        r.t=r:Texture(255,0,0,255);
		r.tl=r:TextLabel()
		r.tl:SetLabel(words[i])
		r:Show()
		r.angle = random(0,360)
		r.aspeed = random(minspeed,maxspeed)
		r.fsize = random(minfontsize,maxfontsize)
        r.tl:SetFont(urfont2)
		r.tl:SetFontHeight(r.fsize)
		r.tl:SetRotation(r.angle)
		r.tl:SetVerticalAlign("TOP")
		r.alpha = 255
		r.alphaspeed = random(1*30,4*30)
		r.tl:SetColor(random(128,255),random(128,255),random(128,255),128)
		r:Handle("OnUpdate",rotate)
		rs[i+(j-1)*#words] = r
	end
end

local pagebutton = CreatePagerButton()
