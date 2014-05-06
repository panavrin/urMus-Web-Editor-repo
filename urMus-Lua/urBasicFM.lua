-- urBasicFM.lua
-- Georg Essl 10/24/12
-- Tests a basic FM patch in urMus
-- Modulator freq/amp is controlled by touch X/Y
-- Base frequency is X tilt

FreeAllFlowboxes()
dac= FBDac
sinosc = FlowBox(FBSinOsc)
sinosc2 = FlowBox(FBSinOsc)
add = FlowBox(FBAdd)
touch = FBTouch
accel = FBAccel

touch.X1:SetPush(sinosc.Freq)
touch.Y1:SetPush(sinosc.Amp)
accel.X:SetPush(add.In1)
add.In2:SetPull(sinosc.Out)
sinosc2.Freq:SetPull(add.Out)
dac.In:SetPull(sinosc2.Out)


CreateInstructionText("FM Synthesis!!","Move on the screen to change base and modulation frequency\nTilt device to change modulation strength")

local function exitfunction()
	FreeAllFlowboxes()
end

local pagebutton=CreatePagerButton(exitfunction)