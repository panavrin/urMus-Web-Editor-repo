-----------------------------------------------------------
--                  Gradient Menu                        --
-----------------------------------------------------------
--Allows for user defined gradients on regions
--Note: When the region is long pressed the gradient disapears.

--dofile("urVen2.lua")

--Functions--
function menuGradient(opt,vv)
    OpenGradDialog(vv)
    UnHighlight(opt)
    CloseMenuBar()
end

function CreateOptionsGrad(txt,w)
    local r = Region('region','dialog',UIParent)
    r.tl = r:TextLabel()
    r.tl:SetLabel(txt)
    r.tl:SetFontHeight(16)
    r.tl:SetColor(0,0,0,255) 
    r.tl:SetHorizontalAlign("JUSTIFY")
    r.tl:SetShadowColor(255,255,255,255)
    r.tl:SetShadowOffset(1,1)
    r.tl:SetShadowBlur(1)
    r.t = r:Texture(200,200,200,255)
    r:SetWidth(w)
    r:SetHeight(50)
    return r
end


function CloseGradDialog(self)
    self.title:Hide()
    for i = 1,#self.sub do
        self[i][1]:Hide()
        self[i][2]:Hide()
        self[i][2]:EnableInput(false)
    end
    
    self[#self.sub][1]:EnableInput(false)
    mykb:Hide()
    color_wheel:Hide()
    color_wheel:EnableInput(false)
    self.ready = 0
    backdrop:EnableInput(true)
end
function CancelGradClicked(self)
    CloseGradDialog(self.parent)
end
function OKGradClicked(self)
    local dd = self.parent
    region = dd.caller
    r1,g1,b1,a1=grad[1][2].t:SolidColor()
    r2,g2,b2,a2=grad[2][2].t:SolidColor()
    r3,g3,b3,a3=grad[3][2].t:SolidColor()
    r4,g4,b4,a4=grad[4][2].t:SolidColor()
    region.t:SetGradientColor("TOP",r1,g1,b1,a1,r2,g2,b2,a2)
    region.t:SetGradientColor("BOTTOM",r3,g3,b3,a3,r4,g4,b4,a4)
    CloseGradDialog(self.parent)
    CloseColorWheel(color_wheel)
end

function MenuChangeColorGrad(opt,vv)
    color_wheel:Show()
    color_wheel.region = opt
    color_wheel:EnableInput(true)
    backdrop:EnableInput(false)
    UnHighlight(opt)
    opt.tl:SetLabel("")
    CloseMenuBar()
end

--Region Creation--
grad={}
grad.title = Region('region','dialog',UIParent)
grad.title.t = grad.title:Texture(240,240,240,255)
grad.title.tl = grad.title:TextLabel()
grad.title.tl:SetLabel("Gradient Menu")
grad.title.tl:SetFontHeight(16)
grad.title.tl:SetColor(0,0,0,255) 
grad.title.tl:SetHorizontalAlign("JUSTIFY")
grad.title.tl:SetShadowColor(255,255,255,255)
grad.title.tl:SetShadowOffset(1,1)
grad.title.tl:SetShadowBlur(1)
grad.title:SetWidth(400)
grad.title:SetHeight(50)
grad.title:SetAnchor("BOTTOM",UIParent,"CENTER",0,100)
grad.sub = {{"Color 1","Click Here"},{"Color 2","Click Here"},{"Color 3","Click Here"},{"Color 4","Click Here"},{"OK","CANCEL"}}

for i = 1, #grad.sub do
    grad[i] = {}
    grad[i][1] = CreateOptionsGrad(grad.sub[i][1],250)
    grad[i][2] = CreateOptionsGrad(grad.sub[i][2],150)
    grad[i][2]:SetAnchor("LEFT",grad[i][1],"RIGHT",0,0)
    grad[i][1].parent = grad
    grad[i][2].parent = grad
end
grad[1][2]:Handle("OnTouchDown",MenuChangeColorGrad)
grad[2][2]:Handle("OnTouchDown",MenuChangeColorGrad)
grad[3][2]:Handle("OnTouchDown",MenuChangeColorGrad)
grad[4][2]:Handle("OnTouchDown",MenuChangeColorGrad)
grad[5][2]:Handle("OnTouchDown",CancelGradClicked)
grad[5][1]:Handle("OnTouchDown",OKGradClicked)

grad[1][1]:SetAnchor("TOPLEFT",grad.title,"BOTTOMLEFT",0,0)
for i = 2,#grad.sub do
    grad[i][1]:SetAnchor("TOPLEFT",grad[i-1][1],"BOTTOMLEFT",0,0)
end

--Open Function--
function OpenGradDialog(v)
    grad.title:Show()
    grad.title:MoveToTop()
    grad.caller = v
    DPrint("Gradient configuration for "..v:Name())
    for i = 1,#grad.sub do
        grad[i][2].t=grad[i][2]:Texture(200,200,200,255)
        if i < 5 then
            grad[i][2].tl:SetLabel("Click Here")
        end
        grad[i][1]:Show()
        grad[i][2]:Show()
        grad[i][1]:MoveToTop()
        grad[i][2]:MoveToTop()
        grad[i][2]:EnableInput(true)
    end
    grad[5][1]:EnableInput(true)
    backdrop:EnableInput(false)   
end
