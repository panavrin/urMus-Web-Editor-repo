bg = createRegion(bgH, bgW, offY, offX, nil, 100,100,100,255)
bg:EnableInput(true)
bg.key = createRegion(100,100,200,300,bg, 200,200,200,100)
DPrint("livecoding ready")
yhair = createYhair(bg)
xhair = createXhair(bg)

function pDown(self,y,x)
	self.key.t:SetSolidColor(255,100,100,200)
	self.key:MoveTo(y,x)
	yhair:MoveTo(bgH/2,x)
	xhair:MoveTo(y,bgW/2)
	local xval = x / bgW * num_notes + base_note
	
	pushFreq:Push(freq2Norm(noteNum2Freq(xval)))
	local yval = (y/bgH -0.5 ) 
--	self.t:SetSolidColor(50*(xval),50*(xval*2),100*yval+255,255)
	
	if yval >= 0 then
		yval = pow (yval,3)
	end
	
	pushNon:Push(yval)
	pushAsymp:Push(0.3)
	local w = ScreenWidth()/100

--	bg.t:SetBrushColor(math.random(128,255),0,0,20)
--	bg.t:Point(y,x+offX)
	--,ey,ex)
end

bg:Handle("OnTouchDown", pDown)
bg:Handle("OnMove", pDown)

function pUp(self,y,x)
	self.key.t:SetSolidColor(100,100,255,200)
	self.t:SetSolidColor(100,50,50,255)
	pushAsymp:Push(0)
end

bg:Handle("OnTouchUp", pUp)


bg.t:SetTexCoord(0,bgH/ScreenHeight(),bgW/ScreenHeight(),0.0)
r = Region()
r.t = r:Texture(255,255,255,255)
r.t:SetTexture("Ornament1.png")
bg.t:SetBlendMode("BLEND")

bg.t:Clear(255,255,255,255)

r:UseAsBrush()
bg.t:SetBrushSize(64)


--createClear()


labels={}
for i=0,num_notes-1 do
	labels[i] = createNoteName(i,50,bgW/num_notes)
end