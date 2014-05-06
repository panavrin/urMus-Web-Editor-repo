-- urTicTacToe
-- Concept by: Georg Essl & Nate Derbinsky
-- Initial Hack by: Georg Essl 04/29/10

FreeAllRegions()

function topow2(x)
    local pow2 = 1;
    while  pow2 < x do pow2 = pow2 *2 end
    return pow2
end
        

local rescalex = ScreenWidth()/320
local rescaley = ScreenHeight()/480

local backdrop = Region()
backdrop:SetWidth(ScreenWidth())
backdrop:SetHeight(ScreenHeight())
backdrop.t = backdrop:Texture("tictactoegrid-empty.png")
--backdrop.t:SetTexture("Default.png")
--if ScreenWidth() == 320.0 then
--  backdrop.t:SetTexCoord(0,backdrop:Width()/backdrop.t:Width(),backdrop:Height()/backdrop.t:Height(),0.0);
--else
--  backdrop.t:SetTexCoord(0,ScreenWidth()/1024.,1.0,0.0);
--end
--backdrop.t:Clear(255,255,255,255);
backdrop:SetLayer("BACKGROUND")
backdrop:Show()

if SoarEnabled() then
    backdrop:SoarLoadRules("tictactoe", "soar")
end

function FreshBoard()
    return
--[[    backdrop.t:Clear(255,255,255,255)
    backdrop.t:SetBrushColor(255,0,0,192)
    backdrop.t:SetBrushSize(4)
    backdrop.t:Line(ScreenWidth()/3, 0, ScreenWidth()/3,ScreenHeight())
    backdrop.t:Line(2*ScreenWidth()/3, 0, 2*ScreenWidth()/3,ScreenHeight())
    backdrop.t:Line(0,ScreenHeight()/3,ScreenWidth(),ScreenHeight()/3)
    backdrop.t:Line(0,2*ScreenHeight()/3,ScreenWidth(),2*ScreenHeight()/3)--]]
end

--FreshBoard()

local buttoncols = 3
local buttonrows = 3
buttons = {} -- Create rows
for i=1,buttonrows do
    buttons[i] = {} -- Create columns
end

local turn
if SoarEnabled() then
    turn = 0
else
    turn = math.random(0,1)
end
local won
local move = 1

function TextureCol(t,r,g,b,a)
    t:SetGradientColor("TOP",r,g,b,a,r,g,b,a)
    t:SetGradientColor("BOTTOM",r,g,b,a,r,g,b,a)
end

if SoarEnabled() then
gameresult = nil

function CreateSoarBoard(first)
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
end

function ResetAgent(outcome)

    backdrop:SoarDelete(gameresult)
    if outcome==0 then -- tie
        gameresult = backdrop:SoarCreateConstant(0, "turn", "tie")
    elseif outcome==1 then -- lose
        gameresult = backdrop:SoarCreateConstant(0, "turn", "lose")
    elseif outcome==2 then -- win
        gameresult = backdrop:SoarCreateConstant(0, "turn", "win")
    end

    backdrop:SoarFinish()
    backdrop:SoarInit()

    CreateSoarBoard(0)
end
end

function CheckWin()

    local win

    for c=1,buttoncols do
        if buttons[c][1].state and buttons[c][1].state == buttons[c][2].state and buttons[c][2].state == buttons[c][3].state then
--          backdrop.t:Line(0,(2*c-1)*ScreenHeight()/6,ScreenWidth(),(2*c-1)*ScreenHeight()/6)
            win = true
        end
    end
    for r=1,buttonrows do
        if buttons[1][r].state and buttons[1][r].state == buttons[2][r].state and buttons[2][r].state == buttons[3][r].state then
--          backdrop.t:Line((2* r-1)*ScreenWidth()/6, 0, (2*r-1)*ScreenWidth()/6,ScreenHeight())
            win = true
        end
    end
    
    if buttons[1][1].state and buttons[1][1].state == buttons[2][2].state and buttons[2][2].state == buttons[3][3].state then
--          backdrop.t:Line(0, 0, ScreenWidth(),ScreenHeight())
            win = true
    end
    if buttons[3][1].state and buttons[3][1].state == buttons[2][2].state and buttons[2][2].state == buttons[1][3].state then
--          backdrop.t:Line(0, ScreenHeight(), ScreenWidth(),0)
            win  = true
    end
    
    return win
end


function SingleDown(self)
    if won then
        --DPrint("won="..won.." move="..move.." turn="..turn)
    else
        --DPrint("move="..move)
    end
    if won or move > 9 then -- New game
        if SoarEnabled() then
            turn = 0
        else
            turn = won and 1-won or turn
        end
        move = 1
        FreshBoard()
        for ix = 1, buttoncols do
            for iy = 1, buttonrows do
                buttons[ix][iy].state = nil
                buttons[ix][iy].t:SetTexture(255,255,255,0)
            end
        end
        won = nil
    end

    if not self.state then
    if SoarEnabled() then
        if turn <0.5 then
            self.t:SetTexture("x-alpha.png")
            TextureCol(self.t,0,255,0,255)
            self.state = turn

            backdrop:SoarDelete(self.contents)
            self.contents = backdrop:SoarCreateConstant(self.id, "contents", "opponent")
            move = move + 1

            if CheckWin() then
                won = turn              
                ResetAgent(1)
            elseif move>9 then
                won = turn
                ResetAgent(0)
            else                
                local other = nil

                repeat
                name, params =  backdrop:SoarGetOutput()


                if name ~= "go" then
                    DPrint("A baby wabbit died!")
                else
                -- print("attempted: ("..params.x..","..params.y..")")
                end


                other = buttons[params.y][params.x]
                if (other.state~=nil) then
                    backdrop:SoarSetOutputStatus(0)
                end                 
                until (other.state==nil)                

                backdrop:SoarDelete(other.contents)
                other.contents = backdrop:SoarCreateConstant(other.id, "contents", "me")
                backdrop:SoarSetOutputStatus(1)

                other.state = 1 - turn
                other.t:SetTexture("o-alpha.png")
                TextureCol(other.t,0,0,255,255)
                if CheckWin() then
                    won = 1 - turn
                    ResetAgent(2)
                end

                move = move + 1
            end
        end

    else
        if turn <0.5 then
            self.t:SetTexture("x-alpha.png")
            TextureCol(self.t,0,255,0,255)
            self.state = turn
            if CheckWin() then won = turn end
        else
            self.t:SetTexture("o-alpha.png")
            TextureCol(self.t,0,0,255,255)
            self.state = turn
            if CheckWin() then won = turn end
        end
        turn = 1 - turn
        move = move + 1
    end
    end
end

function SingleUp(self)
end

function DoubleTap(self)
end

for ix = 1, buttoncols do
    for iy = 1, buttonrows do
        local newbutton
        newbutton = Region('region','button'..ix..":"..iy,UIParent)
        newbutton.t = newbutton:Texture(255,255,255,0)
        newbutton.t:SetBlendMode("BLEND")
        newbutton:SetHeight(96*rescaley)
        newbutton:SetWidth(96*rescalex)
        local x = 5+(ix-1)*(ScreenWidth()/3)
        local y = 12+(iy-1)*(ScreenHeight()/3)
        newbutton:SetAnchor("BOTTOMLEFT", x,y)
        newbutton:Show()
        newbutton:Handle("OnTouchDown", SingleDown)
        newbutton:Handle("OnTouchUp", SingleUp)
        newbutton:Handle("OnDoubleTap", DoubleTap)
        newbutton:EnableInput(true)
        newbutton.index = ix + (iy-1)*buttoncols
        buttons[iy][ix] = newbutton
    end
end

if SoarEnabled() then
CreateSoarBoard(1)
end

pagebutton=Region('region', 'pagebutton', UIParent);
pagebutton:SetWidth(pagersize);
pagebutton:SetHeight(pagersize);
pagebutton:SetLayer("TOOLTIP");
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show();

