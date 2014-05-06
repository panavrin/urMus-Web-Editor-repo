-----------------------------------------------------------
--    **DEFUNCT**  Picture  Choosing  **DEFUNCT**        --
-----------------------------------------------------------
-- This script is no longer used and is DEFUNCT
-- Allows user to select image to place on a region


function CreateImage(i,j)    
    local r = Region('region', 'dialog', UIParent)
    r.t = r:Texture()
    r:SetWidth(128)
    r:SetHeight(128)
    r:SetAnchor("BOTTOMLEFT",128*j,ScreenHeight()-128*(i+1))
    
    
    return r
end

function CloseLoader()
    loader.bg:Hide()
    loader.bg:EnableInput(false)
    counter = 1
    for i = 0,7 do
        for j = 0,5 do
            if counter <= #pics then
                loader[i][j]:Hide()
                loader[i][j]:EnableInput(false)

                counter = counter + 1
            else
                break
            end
            
        end
    end
    backdrop:EnableInput(true)
end

function selectPicture(self)
    local dd = self.parent
    local region = dd.caller
    region.bkg = pics[self.count]
    region.t:SetTexture(region.bkg)
    
    globalPic = self.count
    
    CloseLoader()
end

loader = {}
loader.bg = Region('region', 'dialog', UIParent)
loader.bg.t = loader.bg:Texture()
loader.bg.t:SetTexture(0,0,0,255)
loader.bg:SetWidth(ScreenWidth())
loader.bg:SetHeight(ScreenHeight())
loader.bg:SetAnchor("BOTTOMLEFT",0,0)
loader.caller = nil
for i = 0,7 do
    loader[i] = {}
    for j = 0,5 do
        loader[i][j] = CreateImage(i,j)
        loader[i][j].parent = loader
    end
end


function OpenPictureDialog(vv)
    loader.bg:Show()
    loader.bg:MoveToTop()
    loader.bg:EnableInput(true)
    loader.caller = vv
    
    backdrop:EnableInput(false)
    
    counter = 1
    for i = 0,7 do
        for j = 0,5 do
            if counter <= #pics then
                loader[i][j]:Show()
                loader[i][j]:MoveToTop()
                loader[i][j].t:SetTexture(pics[counter])
                loader[i][j].count = counter
                loader[i][j]:EnableInput(true)
                loader[i][j]:Handle("OnTouchDown", selectPicture)
                counter = counter + 1
            else
                break
            end
            
        end
    end
    
end
