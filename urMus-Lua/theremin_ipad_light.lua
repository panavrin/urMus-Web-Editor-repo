--written by Kevin Chow
FreeAllRegions()

--get clocktime
local prev = os.clock()
xindex = 1
index = 1
max = 10
max2 = 3
xArray = {}

DPrint("")

--looping increment function
function increment()
	if index > max2-1 then
		index = 1
	else
		index = index + 1
	end
end

--looping increment function for xArray
function xincrement()
	if xindex > max-1 then
		xindex = 1
	else
		xindex = xindex + 1
	end
end

--sets the color of the main region texture based on current index value
function getColor()
	if index == 1 then
		r.t:SetTexture(255,0,0,255)
	elseif index == 2 then
		r.t:SetTexture(0,255,0,255)
	elseif index == 3 then
		r.t:SetTexture(0,0,255,255)
	elseif index == 4 then
		r.t:SetTexture(255,255,0,255)
	elseif index == 5 then
		r.t:SetTexture(0,255,255,255)
	elseif index == 6 then
		r.t:SetTexture(255,0,255,255)
	elseif index == 7 then
		r.t:SetTexture(255,255,255,255)
	elseif index == 8 then
		r.t:SetTexture(255,128,0,255)
	elseif index == 9 then
		r.t:SetTexture(255,0,128,255)
	else
		r.t:SetTexture(128,64,200,255)
	end
end

--function to switch color, restricts itself from running more than once every 300ms
function switchColor()
	--checks if it was run previously in last 300ms
	if os.clock() - prev < .3 then
		return
	end
	prev = os.clock()
	getColor()
	increment()
end

--checks if phone has been shaken, calls switch color if it thinks the device has been shaken in x direction
function checkIndex()
	check = xindex-4
	if xArray[check] == nil then
		return
	end
	if check < 0 then
		check = check + max
	end
	if math.abs(xArray[xindex]-xArray[check]) > 2 then
		switchColor()
	end
end

r = Region()
r.t = r:Texture(0,0,0,255)
r:SetWidth(ScreenWidth())
r:SetHeight(ScreenHeight())
r:Show()

function accel(self,x,y,z)
	xArray[xindex] = x
	checkIndex()
	xincrement()
end
r.bpm = 120
r.pattern = {1, 0, 1, 0,0, 0}--, 0, 1}
r.num = 6
r.avgElapsed = 0;
r.alpha = 0.2
r.time = math.ceil(Time())+1;
r.interval =  1/(r.bpm/60)
r.nextTickTime = r.time + r.interval;
r.state = true
r.i = 1

function update(self, elapsed)
	r.currentTime = Time()
	r.avgElapsed = r.avgElapsed * r.alpha + (1-r.alpha) * elapsed;

	if r.currentTime >= r.nextTickTime - r.avgElapsed/2 then
		if r.pattern[r.i] == 1 then
				r.t:SetSolidColor(255,0,0,255)
			else
				r.t:SetSolidColor(0,0,0,255)			
			end
		--DPrint("r.i:"..r.i)
		r.i = (r.i+1)%r.num
		if r.i==0 then r.i = r.num end
		while r.currentTime >= r.nextTickTime - r.avgElapsed/2 do
			r.nextTickTime  = r.nextTickTime + r.interval
		end
	end
end
r.ii = 0
function change(self)
	r.ii = r.ii+1
	if r.ii%2 == 0 then
	r:Handle("OnUpdate",update)
		else
			r:Handle("OnUpdate",nil)
		end

end
r:Handle("OnUpdate",nil)

r:Handle("OnAccelerate",accel)
r:Handle("OnDoubleTap",change)
--r:Handle("OnUpdate",update)

r:EnableInput(true)

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
