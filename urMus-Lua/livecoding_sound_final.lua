pushFreq = FlowBox(FBPush)
pushNon = FlowBox(FBPush)
pushAsymp = FlowBox(FBPush)
pushTau = FlowBox(FBPush)

cmap = FlowBox(FBCMap)
rev = FlowBox(FBPRCRev)
gain = FlowBox(FBGain)
drain = FlowBox(FBDrain)
dac = FlowBox(FBDac)
asymp = FlowBox(FBAsymp)

pushFreq.Out:SetPush(cmap.Out)
pushNon.Out:SetPush(cmap.NonL)
drain.In:SetPull(asymp.Out)
drain.Out:SetPush(gain.Amp)
pushAsymp.Out:SetPush(asymp.In)
pushTau.Out:SetPush(asymp.Tau)
pushTau:Push(0)
gain.In:SetPull(cmap.Out)
dac.In:SetPull(drain.Time)
dac.In:SetPull(gain.Out)

gain.In:RemovePull(cmap.Out)
rev.In:SetPull(cmap.Out)
gain.In:SetPull(rev.Out)

pushLooperGain = FlowBox(FBPush)
looperGain = FlowBox(FBGain)

loopDrain = FlowBox(FBDrain)
loopDrain.In:SetPull(gain.Out)
dac.In:SetPull(loopDrain.Time)
looper = FlowBox(FBLooper)
dac.In:SetPull(looperGain.Out)
looperGain.In:SetPull(looper.Out)
loopDrain.Out:SetPush(looper.In)
pushLooperGain.Out:SetPush(looperGain.Amp)

looperRecord = FlowBox(FBPush)
looperPlay = FlowBox(FBPush)


looperRecord.Out:SetPush(looper.Record)
looperPlay.Out:SetPush(looper.Play)

function record()
	looperRecord:Push(1)
end

function endplay()
	looperPlay:Push(0)
end

--[[
looperRecord:Push(1)
looperRecord:Push(0)
looperPlay:Push(1)
looperPlay:Push(0)


pushLooperGain:Push(0.4)--]]


