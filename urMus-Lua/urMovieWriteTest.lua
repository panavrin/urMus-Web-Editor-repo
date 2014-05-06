
FreeAllRegions()

wait = 2
current = 0
cnt = 1

function timer(self,elapsed)
    current = current + elapsed
    if current > wait then
        current = current - wait
        if cnt > 1 then
            FinishMovie()
        end
        DPrint(cnt)
        WriteMovie("test"..cnt..".mp4",0,0,ScreenWidth(),ScreenHeight())
        cnt = cnt + 1
    end
end

function Record(self)
    DPrint("Recording ".. "test"..cnt..".mp4")
    WriteMovie("test"..cnt..".mp4",0,0,ScreenWidth(),ScreenHeight())
    cnt = cnt + 1
end

function Finish(self)
    DPrint("Finishing ".. "test"..(cnt-1)..".mp4")
    FinishMovie()
end

r = Region()
r:SetWidth(ScreenWidth())
r:SetHeight(ScreenHeight())
r:SetAnchor("BOTTOMLEFT",0,0)
r.t = r:Texture()
r.t:UseCamera()
r:Show()
--r:Handle("OnUpdate", timer)
r:Handle("OnTouchDown", Record)
r:Handle("OnTouchUp", Finish)
r:EnableInput(true)


