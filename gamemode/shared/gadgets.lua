--[[---------------------------------------------------------
shared/gadgets.lua

 - Gadgets
---------------------------------------------------------]]--

-- Grab 2dm:
_2dm = _2dm or {}

-- Grab the gadget type definitions:
_2dm.gadget_types = _2dm.gadget_types or {}

-- Reverse gadget lookup:
_2dm.gadgets_ids = _2dm.gadgets_ids or {}

-- Grab the gadgets slot:
_2dm.gadgets = _2dm.gadgets or {}

--[[
GADGET STORING CODE
]]--

-- Grabs a TAB with gadget info:
function gadget_grab(sort, data)
	-- Check the reverse index:
	if not _2dm.gadgets_ids[sort] then
		
		print("Failed to find reverse lookup for id "..sort)
		return -1
	end
	
	-- Store the new sort:
	sortn = _2dm.gadgets_ids[sort]
	
	-- Ensure this sort of gadget exists:
	if not _2dm.gadget_types[sortn] then
		print("Failed to find gadget sort "..sortn)
		return -1
	end
	
	-- Create a new gadget:
	local tab = {}
	
	-- Store the sort:
	tab.sort = sort
	tab.sortn = sortn
	
	-- Store default values:
	tab.mods = {}
	
	-- Merge in the original:
	tab = tmerge(tab, _2dm.gadget_types[sortn])
	
	-- Merge in any changes:
	if data then
		tab = tmerge(tab, data)
	end
	
	-- Return the result:
	return tab
end

-- Add a new type of gadget:
function gadget_type_add(tab)
	if tab then
		if tab.name then
			-- The gadget's ID:
			tab.id = ((#_2dm.gadgets_ids or 0) + 1)
			
			-- Does this gadget already exist:
			if _2dm.gadget_types[tab.name] then
				tab.id = _2dm.gadget_types[tab.name].id
			end
			
			-- Store the gadget:
			_2dm.gadget_types[tab.name] = tab
			
			-- Store the reverse lookup:
			_2dm.gadgets_ids[tab.id] = tab.name
		else
			print("GADGET TYPE ADD FAILED -- You didn't parse a name!")
		end
	else
		print("GADGET TYPE ADD FAILED -- You didn't pass anything")
	end
end

--[[
GADGET DEFINITIONS
]]--

--[[
Glide Boots
]]--

local tab = {}
tab.name = "Glide Boots"
tab.des = "Lower Gravity"
tab.model = "models/props_junk/Shoe001a.mdl"
tab.toggle = true
tab.OnPress = function(ply)
	-- Stop usage:
	if ply.Shield <= 0 then return end
	
	ply:SetGravity(0.25)
	TakeShield(ply, ply.ShieldMax/100)
	GadgetDrain(ply, ply.ShieldMax/100, 0.1, function()
		gadget_off(ply, true)
	end)
end
tab.OnRelease = function(ply)
	ply:SetGravity(1)
	GadgetDrainStop(ply)
end
gadget_type_add(tab)

--[[
Fire Shield
]]--

tab = {}
tab.name = "Fire Shield"
tab.des = "A shield of fire!"
tab.model = "models/props_combine/combine_intmonitor001.mdl"
tab.toggle = true
tab.OnPress = function(ply)
	ply:Extinguish()
	ply.FireProof = true
	ply.FireDamage = 1
	ply.FireOwner = ply
	ply.BurnDamage = 15
	ply:Ignite(86400, 120)
end
tab.OnRelease = function(ply)
	ply.FireProof = false
	ply:Extinguish()
	ply.BurnDamage = 0
end
gadget_type_add(tab)

--[[
Nova Pulse
]]--

tab = {}
tab.name = "Nova Pulse"
tab.des = "Create a nova which blows players away from oneself."
tab.model = "models/props_combine/combine_intmonitor001.mdl"
tab.toggle = false
tab.OnPress = function(ply)
	-- Stop usage:
	if ply.Shield <= 0 then return end
	
	ply.NovaCharageStart = CurTime()
	GadgetDrain(ply, ply.ShieldMax/100, 0.1, function()
		gadget_off(ply, true)
	end)
end
tab.OnRelease = function(ply)
	-- Stop draining shield:
	GadgetDrainStop(ply)
	
	-- Work out how much charge was added:
	local power = math.floor(CurTime() - ply.NovaCharageStart)
	
	-- If they charged it:
	if power > 0 then
		Nova(ply, 512*power/10, power)
	end
end
gadget_type_add(tab)

--[[
Sprinter
]]--

local tab = {}
tab.name = "Sprinter"
tab.des = "Allows you to move faster"
tab.model = "models/props_junk/Shoe001a.mdl"
tab.toggle = true
tab.OnPress = function(ply)
	-- Stop usage:
	if ply.Shield <= 0 then return end
	
	local speedboost = 2.5
	
	-- Store old speeds:
	ply.OldWalk = ply:GetWalkSpeed()
	ply.OldRun = ply:GetRunSpeed()
	
	-- Apply new speeds:
	ply:SetWalkSpeed(ply.OldWalk*speedboost)
	ply:SetRunSpeed(ply.OldRun*speedboost)
	
	-- Take shield:
	TakeShield(ply, ply.ShieldMax/100)
	GadgetDrain(ply, ply.ShieldMax/100, 0.1, function()
		gadget_off(ply, true)
	end)
end
tab.OnRelease = function(ply)
	-- Apply new speeds:
	ply:SetWalkSpeed(ply.OldWalk)
	ply:SetRunSpeed(ply.OldRun)
	
	-- Stop draing shield:
	GadgetDrainStop(ply)
end
gadget_type_add(tab)

--[[
Sloth Boots
]]--

local tab = {}
tab.name = "Sloth Boots"
tab.des = "Gain Shield Regen Speed"
tab.model = "models/props_junk/Shoe001a.mdl"
tab.toggle = true
tab.OnPress = function(ply)
	local speedboost = 0.1
	local regenincrease = 100
	
	-- Store old speeds:
	ply.OldWalk = ply:GetWalkSpeed()
	ply.OldRun = ply:GetRunSpeed()
	
	-- Apply new speeds:
	ply:SetWalkSpeed(ply.OldWalk*speedboost)
	ply:SetRunSpeed(ply.OldRun*speedboost)
	
	-- Apply active regen incrase:
	ply.OldShieldRecharge = ply.ShieldRecharge
	ply.ShieldRecharge = ply.ShieldRecharge * regenincrease
end
tab.OnRelease = function(ply)
	-- Apply new speeds:
	ply:SetWalkSpeed(ply.OldWalk)
	ply:SetRunSpeed(ply.OldRun)
	
	-- Apply old regen rate:
	ply.ShieldRecharge = ply.OldShieldRecharge
end
gadget_type_add(tab)

-- Pushes players within range of ply away:
function Nova(ply, range, power)
	local s = ents.Create("env_shake")
		s:SetOwner(ply)
		s:SetPos(ply:GetPos())
		s:SetKeyValue("amplitude", "200")	-- Power of the shake
		s:SetKeyValue("radius", "250")		-- Radius of the shake
		s:SetKeyValue("duration", "2.5")	-- Time of shake
		s:SetKeyValue("frequency", "255")	-- How har should the screenshake be
		s:SetKeyValue("spawnflags", "4")	-- Spawnflags(In Air)
		s:Spawn()
		s:Activate()
		s:Fire("StartShake", "", 0)
	
	for k,v in pairs(player.GetAll()) do
		if v ~= ply then
			local d = ply:GetPos():Distance(v:GetPos())
			
			if d < range then
				local f =(v:GetPos() - ply:GetPos()):GetNormal()/d*50000*power
				f[2] = 0
				
				v:SetLocalVelocity(Vector(0,0,0))
				v:SetVelocity(f)
			end
		end
	end
end
