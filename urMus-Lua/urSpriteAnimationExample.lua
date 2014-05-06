-- Sprite Animation Demo
-- By: Taylor Cronk
-- Framework and demo for using sprites from a sprite sheet for animation
-- rather than multiple images

-- Sprites made by Reiner "Tiles" Prokein
-- Sprites used are found on http://www.reinerstilesets.de/ 
-- All sprites are free to use for both non commerical and commercial usage under
-- license guidlines given by the copyright holder (mentioned above)


FreeAllRegions()

function AnimateEvent (self,elapsed)
    --Animation Framework, use elapsed to make animations smoother for
    --possible slowdown
    self.frameCount = self.frameCount + 1
    if self.frameCount >= self.speed then
        self.curFrame = self.curFrame + 1
        self.col = self.col + 1
        if self.col > self.maxCol then
            self.row = self.row + 1
            self.col = 1
        end
        
        if self.curFrame > (self.maxCol*self.maxRow) then
            self.curFrame = 1
            self.col = 1
            self.row = 1
        end
        self.frameCount = 0
        self.t:SetTexCoord((self.col-1)/self.maxCol,self.row/self.maxRow,self.col/self.maxCol,self.row/self.maxRow,(self.col-1)/self.maxCol,(self.row-1)/self.maxRow,self.col/self.maxCol,(self.row-1)/self.maxRow)                        
    end
    --Moves The sprite across the screen
    self.x = self.x + self.dx
    
    if self.x > ScreenWidth() then
        self.x = -256
    end
    self:SetAnchor("BOTTOMLEFT",self.x,self.y)
end

-- Sprite Set up, all of the nessecary data for anim in stored with the sprite
sprite = Region()
sprite.t = sprite:Texture("monster.png")
--sprite.t:SetTexCoord(0,0,1/8,0,0,1,1/8,0)
sprite.t:SetBlendMode("ALPHAKEY")
sprite:SetAnchor("BOTTOMLEFT",-256,ScreenHeight()/2-100)
sprite:SetHeight(256)
sprite:SetWidth(256)
sprite.frameCount = 0
sprite.speed = 5
sprite.curFrame = 1
sprite.col = 1
sprite.row = 1
sprite.maxCol = 8
sprite.maxRow = 1
sprite.x = -256
sprite.y = ScreenWidth()/2-100
sprite.dx = 5
sprite.dy = 0
sprite.t:SetTexCoord((sprite.col-1)/sprite.maxCol,sprite.row/sprite.maxRow,sprite.col/sprite.maxCol,sprite.row/sprite.maxRow,(sprite.col-1)/sprite.maxCol,(sprite.row-1)/sprite.maxRow,sprite.col/sprite.maxCol,(sprite.row-1)/sprite.maxRow)
sprite:Handle("OnUpdate",AnimateEvent)
sprite:SetLayer("HIGH")
sprite:Show()

-- Background Region, just because
bg = Region()
bg:SetWidth(ScreenWidth())
bg:SetHeight(256)
bg.t = bg:Texture("cliff-padded.png")
bg.t:SetTiling(true)
bg.t:SetTexCoord(0,5.0,1.0,0)
bg:SetAnchor("BOTTOMLEFT",0,ScreenHeight()/2-356)
bg:SetLayer("BACKGROUND")
bg:Show()
    

pagebutton=Region('region', 'pagebutton', UIParent);
pagebutton:SetWidth(pagersize);
pagebutton:SetHeight(pagersize);
pagebutton:SetLayer("TOOLTIP");
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
--pagebutton:Handle("OnDoubleTap", FlipPage)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show();
--pagebutton:Handle("OnPageEntered", nil)


