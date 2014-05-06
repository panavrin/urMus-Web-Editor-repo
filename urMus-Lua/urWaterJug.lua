-- urWaterJug.lua
-- by Nate Derbinsky May/June 2011
-- with minor fixes by Georg Essl
-- Illustrates reinforcement learning in Soar

local pageadd = Page()

-- Inform default urMus interface that we plan to use 2 pages
next_free_page = next_free_page + 1

-- handle demo page first
SetPage(pageadd)

-- agent region
agent=Region()
agent.time=nil
agent.max_time=1
agent.ops=0

-- background
back=Region()
back:SetWidth(ScreenWidth())
back:SetHeight(ScreenHeight())
back:SetLayer("BACKGROUND")
back.t=back:Texture(255,255,255,255)
back:SetAnchor("BOTTOMLEFT",0,0)
back:Show()

-- page button
pagebutton=Region()
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4) 
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()

-- jugs
jugs = {}

function add_jug(volume,goal)
	j = {}
	j["volume"]=volume
	j["contents"]=nil
	j["regions"]={}
	j["goal"]=goal

	table.insert(jugs, j)

	j["soar-jug-id"], j["soar-jug-wme"] = agent:SoarCreateID(0, "jug")
	j["soar-volume-wme"] = agent:SoarCreateConstant( j["soar-jug-id"], "volume", j["volume"] )
	j["soar-contents-wme"] = nil

	if goal~=nil then
		j["soar-goal-id"], j["soar-goal-wme"] = agent:SoarCreateID(0, "goal")
		j["soar-goal_volume-wme"] = agent:SoarCreateConstant( j["soar-goal-id"], "volume", j["volume"] )
		j["soar-goal_contents-wme"] = agent:SoarCreateConstant( j["soar-goal-id"], "contents", j["goal"] )
	end
end

add_jug(5,nil)
add_jug(3,1)

max_volume=0
for k,v in pairs(jugs) do
	if v["volume"]>max_volume then
		max_volume=v["volume"]
	end
end

-- jug regions
r_width=75
r_height=50
r_break=20

for k,v in pairs(jugs) do
	for i=0,v["volume"] do
		r=Region()
		r:SetWidth(r_width)
		r:SetHeight(r_height)
		r:SetLayer("LOW")
		r:SetAnchor("BOTTOMLEFT",2*r_break+((k-1)*r_width)+((k-1)*r_break),i*r_height)

		if i==0 then
			r.tl=r:TextLabel()
			r.tl:SetColor(0,0,0,255)
			r.tl:SetLabel("foo "..k.."\nyo")
		else
			r.t=r:Texture(0,0,255,255)
		end

		r:Show()

		jugs[k]["regions"][i] = r
	end
end

-- meter
for i=1,max_volume do
	r=Region()
	r:SetWidth(2*r_break)
	r:SetHeight(r_height)
	r:SetLayer("LOW")
	r:SetAnchor("BOTTOMLEFT",0,i*r_height)
	r.tl=r:TextLabel()
	r.tl:SetColor(0,0,0,255)
	r.tl:SetLabel(i)
	r:Show()

	if i~=1 then
		r=Region()
		r:SetWidth(ScreenWidth())
		r:SetHeight(1)
		r:SetLayer("MEDIUM")
		r:SetAnchor("BOTTOMLEFT",0,i*r_height)
		r.t=r:Texture(255,255,255,255)
		r:Show()
	end
end

-- jug contents
function display_state()
	for k,v in pairs(jugs) do
		for i=0,v["volume"] do
			if i==0 then
				v["regions"][i].tl:SetLabel("Volume: "..v["volume"].."\nContents: "..v["contents"])
			else
				if i<=v["contents"] then
					v["regions"][i].t:SetSolidColor(0,0,255,255)
				else
					v["regions"][i].t:SetSolidColor(255,255,255,255)
				end
			end
		end
	end
end

function set_state(contents)
	for k,v in pairs(contents) do
		if jugs[k]["contents"]~=v then
			if jugs[k]["soar-contents-wme"]~=nil then
				agent:SoarDelete( jugs[k]["soar-contents-wme"] )
				jugs[k]["soar-contents-wme"]=nil
			end

			jugs[k]["contents"]=v
			jugs[k]["soar-contents-wme"] = agent:SoarCreateConstant( jugs[k]["soar-jug-id"], "contents", v )
		end
	end
end

-- execution control
function set_runner(fun)
	if fun=="run" then
		agent.runner.fun="run"
		agent.runner.tl:SetLabel("Run")
	else
		agent.runner.fun="stop"
		agent.runner.tl:SetLabel("stop")
	end
end

function soar_handler(self)
	agent:Handle("OnSoarOutput",nil)

	local name, params =  agent:SoarGetOutput()
	agent:SoarSetOutputStatus(1)
	agent.ops=agent.ops+1

	new_state = {}
	dprint_str=""

	if name=="fill" then
		target=params["jug"]
		
		for k,v in pairs(jugs) do
			if v["volume"]==target then
				table.insert( new_state, v["volume"] )
			else
				table.insert( new_state, v["contents"] )
			end
		end

		dprint_str=("("..agent.ops..") Fill: "..target)

	elseif name=="empty" then
		target=params["jug"]

		for k,v in pairs(jugs) do
			if v["volume"]==target then
				table.insert( new_state, 0 )
			else
				table.insert( new_state, v["contents"] )
			end
		end

		dprint_str=("("..agent.ops..") Empty: "..target)
	elseif name=="pour" then
		target1=params["from"]
		target2=params["to"]

		current_from=0
		current_to=0
		limit_to=0
		for k,v in pairs(jugs) do
			if v["volume"]==target1 then
				current_from=v["contents"]
			elseif v["volume"]==target2 then
				current_to=v["contents"]
				limit_to=v["volume"]
			end
		end

		for k,v in pairs(jugs) do
			if v["volume"]==target1 then
				if limit_to-current_to>=current_from then
					table.insert( new_state, 0 )
				else
					table.insert( new_state, current_from-(limit_to-current_to) )
				end
			elseif v["volume"]==target2 then
				if current_from+v["contents"]>v["volume"] then
					table.insert( new_state, v["volume"] )
				else
					table.insert( new_state, current_from+v["contents"] )
				end
			else
				table.insert( new_state, v["contents"] )
			end
		end

		dprint_str=("("..agent.ops..") Pour: "..target1.." to "..target2)
	end

	set_state(new_state)
	display_state()

	-- check for goal condition
	goal_achieved = true
	for k,v in pairs(jugs) do
		if v["goal"]~=nil then
			if v["contents"]~=v["goal"] then
				goal_achieved=false
			end
		end
	end

	if goal_achieved then
		dprint_str=(dprint_str.."\n".."Goal!")

		agent:SoarExec("set-stop-phase -Ad")
		agent:SoarExec("step")
		print(agent:SoarExec("stats --max"))

		agent.time=nil
		set_runner("run")
	end

	if agent.time~=nil then
		agent.time=agent.max_time
		agent:Handle("OnUpdate",count_down)
	end

	DPrint(dprint_str)
end

function count_down(self)
	if agent.time==nil then
		agent:Handle("OnUpdate",nil)
	elseif agent.time>0 then
		agent.time=agent.time-1
	else
		agent:Handle("OnUpdate",nil)
		agent:Handle("OnSoarOutput",soar_handler)
	end
end

function run(self)
	if self.fun=="run" then
		agent.time=agent.max_time
		set_runner("stop")
		agent:Handle("OnUpdate",count_down)
	else
		agent.time=nil
		set_runner("run")
	end
end

function init(self)
	DPrint("")
	agent.ops=0
	agent:Handle("OnSoarOutput",nil)
	set_state({0,0})
	display_state()
end

function step(self)
	agent:Handle("OnSoarOutput",soar_handler)
end

for i=1,3 do
	b=Region()
	b:SetWidth(r_width)
	b:SetHeight(r_height)
	b:SetLayer("LOW")
	b:SetAnchor("BOTTOMLEFT",2*r_break+(i-1)*r_width+(i-1)*r_break,ScreenHeight()-2*r_height)

	b.tl=b:TextLabel()
	b.tl:SetColor(255,255,255,255)

	b:EnableInput(true)

	if i==1 then
		b.t=b:Texture(0,255,0,255)
		agent.runner=b
		set_runner("run")
		b:Handle("OnTouchUp",run)
	elseif i==2 then
		b.t=b:Texture(255,0,255,255)
		b.tl:SetLabel("Step")
		b:Handle("OnTouchUp",step)
	elseif i==3 then
		b.t=b:Texture(255,0,0,255)
		b.tl:SetLabel("Reset")
		b:Handle("OnTouchUp",init)
	end

	b:Show()
end

-- default to selection screen
SetPage(pageadd+1)

-- selection
function select(self)
	SetPage(pageadd)

	agent:SoarExec("excise --all")
	agent:SoarLoadRules("wj", "soar")

	if self.a=="naive" then
		agent:SoarExec("rl --set learning off")
	else
		agent:SoarExec("rl --set learning on")
	end

	set_state({0,0})
	display_state()
	DPrint("")
end

agents = {"naive", "rl"}
s_break=50
s_width=ScreenWidth()-2*s_break
s_height=ScreenHeight()/(2*#agents+1)

for k,v in pairs(agents) do
	r=Region()
	r.a=v
	r:SetWidth(s_width)
	r:SetHeight(s_height)
	r:SetLayer("LOW")
	r.t=r:Texture(0,0,255,255)
	r:SetAnchor("BOTTOMLEFT",s_break,s_height+(2*(k-1)*s_height))
	r.tl=r:TextLabel()
	r.tl:SetFontHeight(16)
	r.tl:SetLabel(v)
	r:Show()
	r:EnableInput(true)
	r:Handle("OnTouchUp",select)
end

-- page button
pagebutton=Region()
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4) 
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()
