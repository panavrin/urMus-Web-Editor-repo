if __urMus__chat__username == nil then
    __urMus__chat__username ={}
    __urMus__chat__index = 0
    __urMus__chat__index_for_new_join = -1
    __urMus__chat__message = {}
    __urMus__broadcast_chat = false

     --    function createRegion(width, height, posX, posY, parent, red, green, blue, alpha, anchorPoint, input, moving)
    __urMus__current_message_anchor_y = 10
    __urMus__current_message_num = 0
    __urMus__current_remote_run_anchor_y = 10
    __urMus__current_remote_run_num = 0
    __chat_box_alpha = 150
    __remote_run_alpha = 200
    __chat_fade_out_start_interval = 2
    __chat_fade_out_duration= 1
    __urMus_box_font_size = 20
    -- TODO replace dofile with something else. 
    function dofile() 
        error("Do not use dofile. ", 2)
    end
    rawpairs = pairs
    function pairs(t)
        local k = nil
        return
        function ()
            local v
            repeat k,v=next(t,k) until string.find(tostring(k),"__newindex__")== nil or k==nil
           -- DPrint("namespace pairs:"..tostring(k)..","..tostring(v))
            return k,v
        end
    end

    function __fadeout__ChatBox(self, elapsed)
        if self.fadeOutStartTime > Time() then
            return
        end
        local interval = 1-(Time()-self.fadeOutStartTime ) / self.interval
        if interval < 0 then
            self:Hide()
            self:Handle("OnUpdate", nil)
            if self.num == __urMus__current_message_num-1 then
                __urMus__current_message_anchor_y = 10
                __urMus__current_message_num = 0
            end
        else
            self.tl:SetColor(255,255,255,255 * interval)
            self.t:SetTexture(0,0,0,__chat_box_alpha * interval)
        end
    end
    function __urMus__display_chat(chat_message,user)
        local string_length = string.len(chat_message)
        local string_length2 = string.len(chat_message)
        local user = user or false;
        local user_length = 0
        local blue_color = 255
        if user then
            user_length = string.len(user) + 4
            user = " "..user.." : "
        else 
            blue_color = 0
            user = "   "
        end
        local newline_str = ""
        local newline_num = 0
        local width = ScreenWidth()* 0.6
        local height = newline_num * __urMus_box_font_size * 3
        local x = (ScreenWidth() - width) / 2
        local ratio = 1.6666666

        while string_length2 > 0 do
            newline_str = newline_str..string.sub(chat_message, 1, (width - __urMus_box_font_size*user_length/ratio)/(__urMus_box_font_size/ratio))
            chat_message = string.sub(chat_message,((width - __urMus_box_font_size*user_length/ratio)/(__urMus_box_font_size/ratio) + 1))
            if string.len(chat_message) > 0 then
                newline_str = newline_str.."\n"
                for i=1, math.floor(user_length) do
                    newline_str = newline_str.." "
                end
            end

            newline_num = newline_num+1
            string_length2 = string.len(chat_message)
        end
        local height = (newline_num +1)* __urMus_box_font_size 
        --    function createRegion(width, height, posX, posY, parent, red, green, blue, alpha, anchorPoint, input, moving)
        
        local __box = __urMus__createRegion(width, height, x, -__urMus__current_message_anchor_y , UIParent,0, 0, 0, __chat_box_alpha,"TOPLEFT","TOPLEFT", false, false)
        __urMus__current_message_anchor_y = __urMus__current_message_anchor_y + height + 2
        __box.num = __urMus__current_message_num
        __urMus__current_message_num = __urMus__current_message_num + 1
        __box:SetText(user..newline_str, __urMus_box_font_size, 255, 255, blue_color)
        __box.tl:SetHorizontalAlign("LEFT")
        __box:SetLayer("TOOLTIP")
        __box.fadeOutStartTime = Time() + __chat_fade_out_start_interval
        __box.interval = __chat_fade_out_duration
        __box:Handle("OnUpdate", __fadeout__ChatBox)
    end

    function __fadeOut_remoteRun(self, elapsed)
        local interval = 1-(Time()-self.fadeOutStartTime ) / self.interval
        if interval < 0 then
            self:Hide()
            self:Handle("OnUpdate", nil)
            if self.num == __urMus__current_remote_run_num-1 then
                __urMus__current_remote_run_anchor_y = 10
                __urMus__current_remote_run_num = 0
            end
        else
            self.tl:SetColor(0, 0, 0,255 * interval)
            self.t:SetTexture(255,120,0,__remote_run_alpha * interval)
        end
        
    end

    function __urMus__reject_remote_function(self)
        __urMus_chat_post_message("The urMus user", " rejcted "..self:Parent().user.."'s function ".. self:Parent().fn..".", "remote")
        self:Parent().fadeOutStartTime = Time()
        self:Hide()
        self:Parent().__accept:Hide()
        self:Parent():SetText("   Rejected the function "..self:Parent().fn, __urMus_box_font_size, 0,0,0)
        self:Parent():Handle("OnUpdate", __fadeOut_remoteRun)
    end

    function __urMus__run_remote_function(self)
        __urMus_chat_post_message("The urMus user", " ran "..self:Parent().user.."'s function ".. self:Parent().fn..".", "remote")
        self:Parent().fadeOutStartTime = Time()
        self:Hide()
        self:Parent().__reject:Hide()
        self:Parent():SetText("   Ran the function "..self:Parent().fn, __urMus_box_font_size, 0,0,0)
        self:Parent():Handle("OnUpdate", __fadeOut_remoteRun)
        self:Parent().namespace[self:Parent().fn]()
        self:Parent().namespace = nil
    end

    function __urMus__execute_remotely(fn_name,user)
        if getfenv(3)[fn_name] == nil then
            error("there is no function named ".. fn_name.. " env:"..tostring(getfenv(3)))
        end
        
        local width = ScreenWidth()* 0.6
        local height = __urMus_box_font_size * 5
        local x = (ScreenWidth() - width) / 2
        local __box = __urMus__createRegion(width, height, x, __urMus__current_remote_run_anchor_y , UIParent,255, 120, 0, __remote_run_alpha,"BOTTOMLEFT","BOTTOMLEFT", false, false)
        __box.__accept = __urMus__createRegion(width * 0.15, height*0.3, width * 0.66, height*0.15 , __box,50, 200 , 50, __remote_run_alpha,"BOTTOMLEFT","BOTTOMLEFT", true, false)
        __box.__reject = __urMus__createRegion(width*0.15, height*0.3, width * 0.83, height*0.15 , __box,255, 50, 50, __remote_run_alpha,"BOTTOMLEFT","BOTTOMLEFT", true, false)
        __box.__accept:SetText("Run", __urMus_box_font_size*1.2, 255,0,0)
        __box.__reject:SetText("Reject", __urMus_box_font_size,0,0,0)   
        __box.__accept:Handle("OnDoubleTap", __urMus__run_remote_function)
        __box.__reject:Handle("OnDoubleTap", __urMus__reject_remote_function)
        __box.fn = fn_name
        __box.user = user
        __box.namespace = getfenv(3)
        __box:SetText("\n   "..user.." submitted a function "..fn_name, __urMus_box_font_size, 0,0,0)
        __box.tl:SetHorizontalAlign("LEFT")
        __box.tl:SetVerticalAlign("TOP")

        __box.interval = 3
        __box.num = __urMus__current_remote_run_num
        __box:SetLayer("TOOLTIP")
        __box.__accept:SetLayer("TOOLTIP")
        __box.__reject:SetLayer("TOOLTIP")
        __urMus__current_remote_run_num = __urMus__current_remote_run_num + 1
        __urMus__current_remote_run_anchor_y = __urMus__current_remote_run_anchor_y + height+ 10
    end
    
    function __urMus__createRegion(width, height, posX, posY, parent, red, green, blue, alpha, anchorPoint,originPoint, input, moving)
        local newregion = Region()
        local anchorPoint = anchorPoint or "BOTTOMLEFT"
        local originPoint = originPoint or "BOTTOMLEFT"
        local width = width or 100
        local height = height or 100
        local posX = posX or 0
        local posY = posY or 0
        local red = red or 255
        local green = green or 255
        local blue = blue or 255
        local alpha = alpha or 255
        local parent = parent or nil
        local moving = (moving == nil) or moving;
        local input = (input == nil) or input
        newregion:SetWidth(width)
        newregion:SetHeight(height)
        newregion.t = newregion:Texture(red,green,blue,alpha)
        newregion.t:SetBlendMode("BLEND")
        if parent == nil then
            newregion:SetAnchor(anchorPoint, nil, originPoint, posX, posY)
        else
            newregion:SetAnchor(anchorPoint, parent, originPoint, posX, posY)
        end
        newregion.tl = nil
        newregion.SetText = function(self, text, size, red, green, blue, alpha, halign, valign, angle )
            if self.tl == nil then
                self.tl = self:TextLabel()
            end
            local size = size or self:Width()/10
            local red = red or 0
            local green = green or 0
            local blue = blue or 0
            local alpha = alpha or 255
            local angle = angle or 0
            if halign == "LEFT" or halign == "RIGHT" or halign == "CENTER"  then
                self.tl:SetHorizontalAlign(align)
            end
            if valign == "TOP" or valign == "BOTTOM" or valign == "MIDDLE"  then
                self.tl:SetVerticalAlign(align)
            end
            self.tl:SetColor(red,green,blue,alpha)
            self.tl:SetFontHeight(size)
            self.tl:SetLabel(text)
            self.tl:SetRotation(angle)
        end
        newregion.MoveTo = function(self,x,y)
            self:SetAnchor("CENTER", self:Parent(), "BOTTOMLEFT", x,y)
        end
        newregion:Show()
        newregion:EnableInput(input)
        newregion:EnableMoving(moving)

        return newregion
    end

    function __urMus_chat_register_id(username)
        if type(username) ~= "string" then
            error("user name must be string type")
        end
        if __urMus__chat__username[username] == true then
            error("user name "..username.." already exists.")
        end
        if string.match(username, "[_%w]+") ~= username then
            error("Username shall be a sequence of one or more alphanumeric characters and underscores.")
        end
        __urMus__chat__username[username] = true
        rawset(_G,"__"..username,{})
        rawset(_G["__"..username],"__newindex__list",{})
        rawset(_G["__"..username],"__newindex__length", 0)
        rawset(_G["__"..username],"__newindex__table", {})
        setmetatable(_G["__"..username],metatable_for_namespaces)
          
        __urMus__chat__index_for_new_join = __urMus__chat__index;
        __urMus_chat_post_message(username, " joined.", "join");
        NPrint(TableToXml(__urMus__chat__username));


    end

    function __urMus_chat_rename_chat_id(new_username, old_username)
        if type(new_username) ~= "string" then
            error("user name must be string type")
        end
        if type(old_username) ~= "string" then
            error("user name must be string type")
        end
        if string.match(new_username, "[_%w]+") ~= new_username then
            error("Username shall be a sequence of one or more alphanumeric characters and underscores.")
        end
        if new_username == old_username then
            return;
        end
        if __urMus__chat__username[new_username] == true then
            error("user name "..username.." already exists.")
        end
        if __urMus__chat__username[old_username] == false then
            error("user name "..username.." does not exists.")
        end
        __urMus__chat__username[old_username] = nil
        __urMus__chat__username[new_username] = true
        rawset(_G,"__"..new_username,rawget(_G,"__"..old_username))
        rawset(_G,"__"..old_username, nil)
        --__urMus_chat_post_message(new_username, " joined.", "join");
        __urMus__chat__index_for_new_join = __urMus__chat__index;


    end

    function __urMus_chat_post_message(username, message, msgType, data)
        if type(username) ~= "string" then
            error("Screen name must be string type")
        end

        message = string.gsub(message, "<br />", "\n")


        __urMus__chat__index =__urMus__chat__index + 1
        __urMus__chat__message[__urMus__chat__index] = {}
        __urMus__chat__message[__urMus__chat__index].username = username 
        __urMus__chat__message[__urMus__chat__index].message = message
        __urMus__chat__message[__urMus__chat__index].type = msgType or "chat"
        __urMus__chat__message[__urMus__chat__index].data = data or "null"

        if string.sub(message,1,1) == ":" then
            __urMus__execute_remotely(string.sub(message,2), username)
        end
        
        if __urMus__chat__index > 10 then
            __nullify(__urMus__chat__message,__urMus__chat__index-10);
        end
        if  __urMus__broadcast_chat then
            __urMus__display_chat( (msgType == "chat") and message or username..message, (msgType == "chat") and username or nil )
        end

        return __urMus__chat__index
    end
    
    function __urMus__broadcast_chat_toggle()
        __urMus__broadcast_chat = not __urMus__broadcast_chat
        if __urMus__broadcast_chat then
            __urMus_chat_post_message("urMus", " Chat messages are on." , "log")
        else
            __urMus_chat_post_message("urMus", " Chat messages are off.", "log")
        end
    end

    function __urMus_share_variable(namespace, key)
        if _G[key] ~= nil then
            error("Variable name("..key..")has a conflict to be shared in the global namespace")
        end
        local temp = namespace[key]
        namespace[key] = nil
        _G[key] = temp -- this order matters! 
--DPrint("key:" .. key .. " _G[key]:".. tostring(_G[key]).. " namespace[key]:"..tostring(namespace[key]))
    end

    function __urMus_chat_get_message_in_xml(client, index)
        if index < 1 or index > __urMus__chat__index then
            error("chat index out of range")
        end
        local returnStr = "<chat><i>"..index.."</i><t>"..__urMus__chat__message[index].type.."</t><u>"
        returnStr = returnStr..__urMus__chat__message[index].username.."</u><m>"
        returnStr = returnStr..__urMus__chat__message[index].message.."</m><d>"
        returnStr = returnStr..__urMus__chat__message[index].data.."</d></chat>\n"
        return returnStr
    end

    function __urMus_chat_get_messages_in_xml(client, from_index)
        local return_str = "<chatxml>"
        for i=from_index,__urMus__chat__index do
            return_str = return_str..__urMus_chat_get_message_in_xml(client, i)
        end
        return return_str.."</chatxml>"
    end

    function __urMus_chat_leave_chat_room(username)
        __urMus__chat__username[username] = nil
        return __urMus_chat_post_message(username, username.." left the room.", "left")
    end


    function __setmetatable(v)
        if v["__newindex__list"] == nil then
           -- DPrint("2: setting_metaTable"..tostring(v))
            rawset(v,"__newindex__list",{})
            rawset(v,"__newindex__table",{})
            rawset(v,"__newindex__length", 0)
            rawset(v,"__newindex__replaced",true)
     --       DPrint("adding "..tostring(v).." to the metatable")
            if type(v[0]) ~= "userdata" then
                for key, val in pairs(v) do
                  --  DPrint("adding "..key.." to the metatable")
                    v.__newindex__length = v.__newindex__length + 1
                    v.__newindex__list[v.__newindex__length] = key
                    if type(val) == "table" then
                        __setmetatable(val)
                    end
                    v.__newindex__table[key] = val;
                end
            end
        end
        setmetatable(v,default_metatable_for_table)
    end

    default_metatable_for_table = {
        __index = function (t,k)
   --         DPrint("__index t:".. tostring(t).. " k:"..k)
            if string.find(k,"__newindex__") == nil and rawget(t,"__newindex__table") ~= nil and rawget(rawget(t,"__newindex__table"),k)~=nil then  
                return rawget(t,"__newindex__table")[k]
            end
            return rawget(t,k)
        end,
        __newindex = function (t,k,v)
            -- t:table, k:index, v:value
            if type(v) == "table" then
              --     DPrint("1: setting metatable of "..k)
                __setmetatable(v)
            end
             if  (string.find(k,"__urMusReturn")== nil) then -- due to __urmusReturn
                if rawget(t.__newindex__table,k) ==nil then
                    t.__newindex__length = t.__newindex__length + 1
                    t.__newindex__list[t.__newindex__length] = k
                elseif rawget(t.__newindex__table,k) ~=nil and type(t[k]) == "table" then  -- a table is overwritten 
                    t[k].__newindex__length = 0
                    t[k].__newindex__replaced = true
                end
            -- DPrint("111 update of element " .. tostring(k) .." to " .. tostring(v) .. "in t:".. tostring(t))
            end
            rawset(t.__newindex__table,k,v)
        end
        --[[,
        __pairs=
        function (t)
            local k=nil
            return
            function ()
                local v
                repeat k,v=next(t,k) until string.find(k,"__newindex__")== nil or k==nil
                    DPrint("table pairs:"..k..","..tostring(v))
                return k,v
            end
        end]]
    }

    metatable_for_namespaces = {
    -- if index is accessible in _G, you should access the other t
        __index = function (t,k)
            if t == _G then
                error("_G is indexed")
            end

            if string.find(k,"__newindex__") == nil then
                --DPrint("6 t:"..tostring(t).." k:"..k)
                -- if you can't find one in the namespace
                -- find it in the global namespace
                if rawget(rawget(t,"__newindex__table"),k) == nil then
                  --  DPrint("7 t:"..tostring(t).." k:"..k .. " _G[k] : ".._G[k])
                    return _G[k] -- this should not be rawget
                end
                --DPrint("8 t:"..tostring(t).." k:"..k .. " var:"..tostring(rawget(rawget(t,"__newindex__table"),k)))
                return rawget(rawget(t,"__newindex__table"),k) -- this is typical variables in the namespace
            end
            return rawget(t,k) -- this is variables with prefix __newindex__
        end,
        __newindex = function (t,k,v)
            if _G[k]~=nil then -- this is the only differnece 
                _G[k] = v
                return
            end
            if type(v) == "table" then
                __setmetatable(v)
            end
            if  (string.find(k,"__urMusReturn")== nil) and rawget(t.__newindex__table,k) == nil then -- due to __urmusReturn
             --   __urMus_chat_post_message("log1","*update ".. tostring(getmetatable(t)).." of element " .. tostring(k) .." to " .. tostring(v) .. "("..tostring(rawget(t,"__newindex__length"))..","..tostring(rawget(t,"__newindex__list"))..")")
                if  rawget(t.__newindex__table,k) ~=nil and type(t[k]) == "table" then -- if you replace existing variables in the namespace 
                    t[k].__newindex__length = 0
                    t[k].__newindex__replaced = true
                elseif rawget(t.__newindex__table,k) ==nil then --- this is typical case
                    t.__newindex__length = t.__newindex__length + 1
                    t.__newindex__list[t.__newindex__length] = k
                end
            end
            rawset(t.__newindex__table,k,v)
        end
    }

    function __nullify(var,key)
        --DPrint("__nullify start.."..tostring(var))
        if type(var) == "table" then
            if key then
                if type(var[key]) == "table" then
                    __nullify(var[key])
                end
                var[key] = nil
            else
                for k,v in rawpairs(var) do
                    if type(var[k]) == "table" then
                        __nullify(var[k])
                    end
                    var[k] = nil;
                    --DPrint("nullified:("..k..","..tostring(v)..") of "..tostring(var))
                end
            end
        end
        --  DPrint("__nullify end.."..tostring(var))
    end

    function __newindex_table_to_xml(var, startindex, endindex)
        
        if type(var) ~= "table" then
            error("__newindex_table_to_xml error: var is not table type. ")
        end
        if var.__newindex__length == nil or var.__newindex__list == nil then
            error("__newindex_table_to_xml error:__newindex__length is nil("..var.__newindex__length..").")
        end
        local end_index = endindex or var.__newindex__length
        local returnStr = "<lua_table>"
        for i=startindex, end_index do
            if var.__newindex__list[i] == nil  then
                error("__newindex_table_to_xml error:__newindex__list["..i.."] is nil.")
            end
            if type(var.__newindex__list[i]) ~= "string" and type(var.__newindex__list[i]) ~= "number"  then
                error("__newindex_table_to_xml error:var.__newindex__list[i] is "..type(var.__newindex__list[i]).." type.")
            end
            returnStr = returnStr.. "<e><k>"..i.."</k><kt>number</kt><t>"..type(var.__newindex__list[i]).."</t><v>"..var.__newindex__list[i].."</v></e>\n"
        end
        if var.__newindex__replaced ~= nil then var.__newindex__replaced = false end
        return returnStr.."</lua_table>"
    end
    rawset(_G,"__newindex__table",{})
    rawset(_G,"__newindex__list",{})
    rawset(_G,"__newindex__length", 0)
                
    setmetatable(_G, default_metatable_for_table)

end
