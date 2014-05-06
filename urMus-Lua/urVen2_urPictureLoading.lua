-- Name urPictureLoading.lua
-- Description: Provides a full page vertical scroll list of text items that can be fed by a data set containing of three text labels
-- and two optional textures (one for a small icon, one for background)
--
-- Author: Georg Essl
-- Created: 11/23/09
-- Copyright (c) 2010 Georg Essl. All Rights Reserved. See LICENSE.txt for license conditions.

-- Edited by: Taylor Cronk
-- For use with urVen2
-- June 2012

-- Constants

-- Height to reserve for title
local titleHeight = 40
local titleFont = "Trebuchet MS"
local titleColor = { 255 ,255, 255, 255}
local normativeScrollRegionHeight = 55
local maxVisiblescrollRegions = (ScreenHeight()-titleHeight)/normativeScrollRegionHeight
local scrollRegionGap = 1
local scrollRegionHeight = (ScreenHeight() - titleHeight - maxVisiblescrollRegions*scrollRegionGap)/maxVisiblescrollRegions
local text1Font = "Trebuchet MS"
local text1Width = ScreenWidth()*2/3
local text1Size = 20
local text1Color = { 255, 255, 255, 255 }
local text2Font = "Trebuchet MS"
local text2Width = ScreenWidth()/2
local text2Size = 14
local text2Color = { 255, 255, 0, 255 }
local text3Font = "Trebuchet MS"
local text3Width = ScreenWidth()/2
local text3Size = 16
local text3Color = { 255, 0, 0, 255 }

-- Create local name-space
if not urPictureList then
    urPictureList = {}
    urPictureList.scrollRegions = {}
end

-- Functions to support the scrolling action itself
-- To be used with OnVerticalScroll, currently assumes a bottom boundary at 0.
local abs = math.abs
function urPictureList.ScrollBackdrop(self,diff)
    
    local bottom = self:Bottom()+diff
    
    if bottom < (0 + maxVisiblescrollRegions*(scrollRegionHeight+scrollRegionGap)) - self:Height() then
        bottom = (0 + maxVisiblescrollRegions*(scrollRegionHeight+scrollRegionGap)) - self:Height()
    end
    if bottom > 0 then
        bottom = 0
    end
    
    self:SetAnchor('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', self:Left() ,bottom)
    for k,v in ipairs(urPictureList.scrollRegions) do
        v.highlit = nil
        v.t:SetTexture(unpack(v.color))
    end
end

-- Scroll action ended, check if we need to align
function urPictureList.ScrollEnds(self)
    local bottom = self:Bottom() - 0
    local div
    div = bottom / (scrollRegionHeight+scrollRegionGap)
    bottom = bottom % (scrollRegionHeight+scrollRegionGap)
    
    if bottom < (scrollRegionHeight+scrollRegionGap)/2 then
        self:SetAnchor('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', self:Left() ,self:Bottom()-bottom)
    else
        self:SetAnchor('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', self:Left() ,self:Bottom()-bottom+(scrollRegionHeight+scrollRegionGap))
    end
end

-- Initialize the ScrollList from an entries table
-- Format for the entries table is {{"text1","text2","text3",icontexture, backdroptexture}}
function urPictureList:InitScrollList(title, titleicontexture, titlebackdroptextre, entries, vv)
    
    -- Create Backdrop
    if not urPictureList.BackdropRegion then
        urPictureList.BackdropRegion = Region('region', 'backdrop', UIParent)
        urPictureList.BackdropRegion:SetWidth(ScreenWidth())
        urPictureList.BackdropRegion:SetLayer("LOW")
        urPictureList.BackdropRegion:Handle("OnLeave", urPictureList.ScrollEnds)
        urPictureList.BackdropRegion:Handle("OnTouchUp", urPictureList.ScrollEnds)
        urPictureList.BackdropRegion:Handle("OnVerticalScroll",urPictureList.ScrollBackdrop)
        urPictureList.BackdropRegion:EnableVerticalScroll(true)
        urPictureList.BackdropRegion:EnableInput(true)
        urPictureList.BackdropRegion:Show()
    end
    urPictureList.BackdropRegion:SetHeight(1) -- Hacky
    urPictureList.BackdropRegion:SetAnchor('TOPLEFT',UIParent,'TOPLEFT',0,-titleHeight)--+scrollRegionHeight) 
    
    if #self.scrollRegions > 0 then
        self:FreeScrollList()
    end
    
    if not self.titleregion then
        local region = Region('region','ScrollListTitle', UIParent)
        region:SetWidth(ScreenWidth())
        region:SetHeight(titleHeight)
        region:SetLayer("MEDIUM")
        region:SetAnchor('TOPLEFT', UIParent, 'TOPLEFT', 0, 0)
        region.tl = region:TextLabel()
        region.tl:SetHorizontalAlign("CENTER")
        region.tl:SetFontHeight(titleHeight-16)
        region.tl:SetFont(titleFont)
        region.tl:SetColor(unpack(titleColor))
        region.tl:SetShadowColor(0,0,0,80)
        region.tl:SetShadowBlur(2.0)
        region.tl:SetShadowOffset(2,-3)
        region:Handle("OnDoubleTap", urPictureList.LeaveScrollList)
        region:EnableInput(true)
        region:Show()
        
        self.titleregion = region
    end
    self.titleregion.tl:SetLabel(title)
    self.parent = vv
    for k, v in pairs(entries) do
        self:CreatescrollRegion(unpack(v))
        self.scrollRegions[k].parent = self
    end
end

urPictureList.recycledRegions = {}

-- Free and recycle an existing scroll list
function urPictureList:FreeScrollList()
    
    for k, v in pairs(self.scrollRegions) do
        table.insert(urPictureList.recycledRegions, v)
        v:SetParent(UIParent)
        v:EnableInput(false)
        v:Hide()
        v = nil
    end
    urPictureList.scrollRegions = {}
end

-- Create a single scroll region and insert at given position (or end if nil)
function urPictureList:CreatescrollRegion(text1, text2, text3, callback, color, path, icontexture, backdroptexture, position)
    local region
    if not position then
        position = #self.scrollRegions + 1
    end
    
    local height = urPictureList.BackdropRegion:Height()
    if height == 1 then
        height = 0
    end
    urPictureList.BackdropRegion:SetHeight(height + scrollRegionHeight + scrollRegionGap)
    
    if #self.recycledRegions > 0 then
        region = table.remove(urPictureList.recycledRegions,1) -- Bug hunt: If we remove last from table this bugs, that shouldn't be. NYI flagging it for checking.
        
        --previewregion.t = region:Texture(icontexture)
    else
        region = Region('region', 'scrollregion'..text1,UIParent)
        region:SetWidth(ScreenWidth()/2)
        region:SetHeight(scrollRegionHeight)
        region:SetLayer("MEDIUM")
        region.t = region:Texture()
        region:Handle("OnTouchDown", urPictureList.HighlightControl)
        region:Handle("OnTouchUp",urPictureList.SelectscrollRegion)
        region:SetClipRegion(0,0,ScreenWidth(),(scrollRegionHeight+scrollRegionGap)*maxVisiblescrollRegions)
        region:EnableClipping(true)
        --[[
        previewregion = Region()
        previewregion:SetWidth(scrollRegionHeight)
        previewregion:SetHeight(scrollRegionHeight)
        previewregion:SetLayer("HIGH")
        previewregion.t = previewregion:Texture(icontexture)
        previewregion.t:SetBlendMode("BLEND")
        previewregion:SetClipRegion(0,0,ScreenWidth(),(scrollRegionHeight+scrollRegionGap)*maxVisiblescrollRegions)
        previewregion:EnableClipping(true)
        previewregion:SetAnchor("BOTTOMRIGHT",region,"BOTTOMRIGHT",0,0)
        DPrint("icon "..icontexture)
        previewregion:Show()]]--
    end
    
    
    
    if backdroptexture then
        region.t:SetTexture(backdroptexture)
    else
        region.t:SetTexture(unpack(color))
    end
    region:EnableInput(true)
    
    region.callback = callback
    region.data = text1
    region.data2 = path
    region.color = color
    if position == 1 then
        region:SetAnchor("TOP", self.BackdropRegion, "TOP", -190, -scrollRegionGap) -- Anchor first one with backdrop
    else
        region:SetAnchor("TOP", self.scrollRegions[position-1], "BOTTOM", 0, -scrollRegionGap) -- Rest honor their predecessors (they might be giants!)
    end
    if not region.text1region then
        region.text1region = urPictureList:CreateTextRegion(text1, text1Width, text1Font, text1Size, text1Color, "LEFT")
        region.text2region = urPictureList:CreateTextRegion(text2, text2Width, text2Font, text2Size, text2Color, "RIGHT")
        region.text3region = urPictureList:CreateTextRegion(text3, text3Width, text3Font, text3Size, text3Color, "RIGHT")
        region.text1region:SetAnchor("TOPLEFT", region, "TOPLEFT", 0,0)
        region.text2region:SetAnchor("TOPRIGHT", region, "TOPRIGHT", 0, 0)
        region.text3region:SetAnchor("BOTTOMRIGHT", region, "BOTTOMRIGHT", 0,0)
    else
        urPictureList:SetLabelRegion(region.text1region, text1, text1Font, text1Color)
        urPictureList:SetLabelRegion(region.text2region, text2, text2Font, text2Color)
        urPictureList:SetLabelRegion(region.text3region, text3, text3Font, text3Color)
    end
    region:Show()
    
    table.insert(self.scrollRegions, position, region)
end

-- Sets attributes of text regions
function urPictureList:SetLabelRegion(region, label, font, color)
    region.tl:SetLabel(label or "")
    region.tl:SetColor(unpack(color))
    region.tl:SetShadowColor(0,0,0,190)
    region.tl:SetShadowBlur(2.0)
    region.tl:SetShadowOffset(2,-3)
    region.tl:SetFont(font)
end

-- Creates a text-carrying region without texture
function urPictureList:CreateTextRegion(label, width, font, size, color, justify)
    local region
    region = Region('region', 'label'..(label or ""), UIParent)
    region:SetHeight(size+2)
    region:SetWidth(width)
    region:SetLayer("HIGH")
    region.tl = region:TextLabel()
    urPictureList:SetLabelRegion(region, label, font, color)
    region.tl:SetFontHeight(size)
    region.tl:SetHorizontalAlign(justify)
    region.tl:SetVerticalAlign("TOP")
    region:Show()
    region:SetClipRegion(0,0,ScreenWidth(),(scrollRegionHeight+scrollRegionGap)*maxVisiblescrollRegions)
    
    region:EnableClipping(true)
    return region
end

function cancelButton()
    for k,v in ipairs(urPictureList.scrollRegions) do
        v.highlit = nil
        v.t:SetTexture(unpack(v.color))
    end
    loadScreen.preview:Hide()
    loadScreen.load:Hide()
    loadScreen.cancel:Hide()
    SetPage(38)
end

function loadButton(self)
    self.parent.parent.parent.t:SetTexture(self.name)  
    loadScreen.preview:Hide()
    loadScreen.load:Hide()
    loadScreen.cancel:Hide()
    SetPage(38)
    
end

--Creates loading menu and preview
function urPictureList:OpenLoadMenu(self, name, path)
    --urPictureList.HighlightControl(self)
    loadScreen = {}
    if not loadScreen.preview then
        loadScreen.preview = Region()
        loadScreen.preview.t = loadScreen.preview:Texture()
        loadScreen.preview:SetAnchor("BOTTOMLEFT",ScreenWidth()/2+42,ScreenHeight()/2-50)
        loadScreen.preview:SetHeight(300)
        loadScreen.preview:SetWidth(300)
    end
    loadScreen.preview.t:SetTexture(tostring(name))
    loadScreen.preview:Show()
    
    if not loadScreen.load then
        loadScreen.load = Region()
        
        loadScreen.load.t = loadScreen.load:Texture(90,90,90,255)
        loadScreen.load.tl = loadScreen.load:TextLabel()
        loadScreen.load.tl:SetLabel("Load")
        loadScreen.load.tl:SetColor(255,255,255,255)
        loadScreen.load.tl:SetShadowColor(0,0,0,190)
        loadScreen.load.tl:SetShadowBlur(2.0)
        loadScreen.load.tl:SetShadowOffset(2,-3)
        loadScreen.load.tl:SetFont("Trebuchet MS")
        loadScreen.load.tl:SetFontHeight(20)
        loadScreen.load:SetHeight(50)
        loadScreen.load:SetWidth(149)
        loadScreen.load:SetAnchor("BOTTOMLEFT", ScreenWidth()/2+42,ScreenHeight()/2-101)
        loadScreen.load:Handle("OnTouchDown",loadButton)
        loadScreen.load:EnableInput(true)
        loadScreen.load:MoveToTop()
    
    end
    loadScreen.load.parent = self
    loadScreen.load:Show()
    loadScreen.load.name = name
    
    
    if not loadScreen.cancel then
        loadScreen.cancel = Region()
        loadScreen.cancel.t = loadScreen.cancel:Texture(90,90,90,255)
        loadScreen.cancel.tl = loadScreen.cancel:TextLabel()
        loadScreen.cancel.tl:SetLabel("Cancel")
        loadScreen.cancel.tl:SetColor(255,255,255,255)
        loadScreen.cancel.tl:SetShadowColor(0,0,0,190)
        loadScreen.cancel.tl:SetShadowBlur(2.0)
        loadScreen.cancel.tl:SetShadowOffset(2,-3)
        loadScreen.cancel.tl:SetFont("Trebuchet MS")
        loadScreen.cancel.tl:SetFontHeight(20)
        loadScreen.cancel:SetHeight(50)
        loadScreen.cancel:SetWidth(149)
        loadScreen.cancel:SetAnchor("BOTTOMLEFT", ScreenWidth()/2+193,ScreenHeight()/2-101)
        loadScreen.cancel:Handle("OnTouchDown",cancelButton)
        loadScreen.cancel:EnableInput(true)
        loadScreen.cancel:MoveToTop()
    end
    loadScreen.cancel:Show()    
end

function urPictureList:OpenScrollListPage1(page, ...)
    self:ReopenScrollListPage(page)
    self:InitScrollList(...)
end

function urPictureList:ReopenScrollListPage(page)
    urScrollList.returnPage = Page()
    --DPrint(page)
    SetPage(page)
end

function urPictureList.HighlightControl(self)
    if self.highlit then
        self.t:SetTexture(unpack(self.color))
        self.highlit = nil
    else
        local r,g,b = unpack(self.color)
        self.t:SetTexture(r+50,g+50,b+50,255)
        self.highlit = true
    end
end   

function urPictureList.LeaveScrollList(self)
    SetPage(urPictureList.returnPage)
end

function urPictureList.SelectscrollRegion(self)
    if self.highlit then
        urPictureList:OpenLoadMenu(self, self.data, self.data2)
    end
end
