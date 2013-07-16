--[[---------------------------------------------------------
server/blueprints.lua

 - Blueprints
---------------------------------------------------------]]--

-- Grab 2dm:
_2dm = _2dm or {}

-- Grab the blueprint type definitions:
_2dm.blueprint_types = _2dm.blueprint_types or {}

-- Reverse blueprint lookup:
_2dm.blueprint_ids = _2dm.blueprint_ids or {}

-- Grab the blueprint slot:
_2dm.blueprint = _2dm.blueprint or {}

--[[
BLUEPRINT Sending code
]]--

-- Send a single blueprint:
function SendBluePrint(num, filter)
	if not _2dm.blueprint[num] then
		print("Tried to send blueprint with unknown id: "..num)
		return false
	end
	
	net.Start("SendBluePrint")
	net.WriteInt(num, 16)													-- The blueprint's ID
	net.WriteInt(_2dm.blueprint[num].sort, min_bits(#_2dm.blueprint_ids))	-- The blueprint's sort
	net.WriteString(_2dm.blueprint[num].name)								-- The name of the blueprint
	
	-- Blueprint mods:
	for k,v in pairs(_2dm.blueprint[num].mods) do
		net.WriteInt(v, 16)
	end
	
	if not filter or type(filter) == "number" then
		net.Broadcast()
	else
		net.Send(filter)
	end
	
	return true
end

-- Send every blueprint over:
function SendAllBluePrints(filter)
	for k,v in pairs(_2dm.blueprint) do
		SendBluePrint(k, filter)
	end
end

--[[
BLUEPRINT Adding code
]]--

-- Add a blueprint:
function blueprint_add(sort, data)
	-- Grab the blueprint:
	local tab = blueprint_grab(sort, data)
	
	-- Store it:
	local num = table.insert(_2dm.blueprint, tab)
	
	-- Send it:
	SendBluePrint(num)
	
	--return it
	return num
end

--[[
BLUEPRINT Spawning Code
]]--

-- The player wants to spawn a blueprint:
net.Receive("bp_place", function(len, ply)
	local bp = net.ReadInt(16)
	
	-- Ensure a valid backpack slot:
	if not ply.Backpack[bp] then return end
	
	-- Ensure it is a blueprint:
	if ply.Backpack[bp][1] ~= BP_BLU then return end
	
	-- Delete any old ghosts:
	if ply.blueprint_ghost then
		-- Validate it:
		if ply.blueprint_ghost:IsValid() then
			-- Remove it:
			ply.blueprint_ghost:Remove()
			ply.blueprint_ghost = nil
		end
	end
	
	-- Spawn a new ghost:
	local g = ents.Create("ghost_blueprint")
	g.Owner = ply
	g.Sort = ply.Backpack[bp][2]
	g:Spawn()
	
	-- Store our blueprint ghost:
	ply.blueprint_ghost = g
end)

-- The player wants to spawn a blueprint:
net.Receive("bp_pos", function(len, ply)
	-- Furthest away possible:
	local maxlen = 100
	
	-- No BS:
	local pos = math.Clamp(net.ReadInt(8), 0, maxlen)
	
	-- Check if the ghost exists:
	if ply.blueprint_ghost and ply.blueprint_ghost:IsValid() then
		-- Update it's position:
		ply.blueprint_ghost.dt.Pos = pos
	end
end)

-- The player wants to rotate their blueprint:
net.Receive("bp_rot", function(len, ply)
	if ply.blueprint_ghost and ply.blueprint_ghost:IsValid() then
		if ply.blueprint_ghost.dt.Rot == 0 then
			ply.blueprint_ghost.dt.Rot = 180
		else
			ply.blueprint_ghost.dt.Rot = 0
		end
	end
end)

-- The player cancelled spawning the blueprint:
net.Receive("bp_cancel", function(len, ply)
	-- Delete any old ghosts:
	if ply.blueprint_ghost then
		-- Validate it:
		if ply.blueprint_ghost:IsValid() then
			-- Remove it:
			ply.blueprint_ghost:Remove()
			ply.blueprint_ghost = nil
		end
	end
end)
