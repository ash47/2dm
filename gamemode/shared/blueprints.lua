--[[---------------------------------------------------------
shared/blueprints.lua

 - Blueprints
---------------------------------------------------------]]--

-- Grab 2dm:
_2dm = _2dm or {}

-- Grab the blueprint type definitions:
_2dm.blueprint_types = _2dm.blueprint_types or {}

-- Reverse blueprint lookup:
_2dm.blueprint_ids = _2dm.blueprint_ids or {}

-- Grab the blueprints slot:
_2dm.blueprints = _2dm.blueprints or {}

--[[
BLUEPRINT STORING CODE
]]--

-- Grabs a TAB with blueprint info:
function blueprint_grab(sort, data)
	-- Check the reverse index:
	if not _2dm.blueprint_ids[sort] then
		print("Failed to find reverse lookup for id "..sort)
		return -1
	end
	
	-- Store the new sort:
	sortn = _2dm.blueprint_ids[sort]
	
	-- Ensure this sort of blueprint exists:
	if not _2dm.blueprint_types[sortn] then
		print("Failed to find blueprint sort "..sortn)
		return -1
	end
	
	-- Create a new blueprint:
	local tab = {}
	
	-- Store the sort:
	tab.sort = sort
	tab.sortn = sortn
	
	-- Store default values:
	tab.mods = {}
	
	-- Merge in the original:
	tab = tmerge(tab, _2dm.blueprint_types[sortn])
	
	-- Merge in any changes:
	if data then
		tab = tmerge(tab, data)
	end
	
	-- Return the result:
	return tab
end

-- Add a new type of blueprint:
function blueprint_type_add(tab)
	if tab then
		if tab.name then
			-- The blueprint's ID:
			tab.id = ((#_2dm.blueprint_ids or 0) + 1)
			
			-- Does this blueprint already exist:
			if _2dm.blueprint_types[tab.name] then
				tab.id = _2dm.blueprint_types[tab.name].id
			end
			
			-- Store the blueprint:
			_2dm.blueprint_types[tab.name] = tab
			
			-- Store the reverse lookup:
			_2dm.blueprint_ids[tab.id] = tab.name
		else
			print("BLUEPRINT TYPE ADD FAILED -- You didn't parse a name!")
		end
	else
		print("BLUEPRINT TYPE ADD FAILED -- You didn't pass anything")
	end
end

--[[
BLUEPRINT DEFINITIONS
]]--

--[[
Turret
]]--

local tab = {}
tab.name = "Turret"
tab.des = "Shoots bullets."
tab.model = "models/Combine_turrets/Floor_turret.mdl"
tab.ent = "Some entity or some shit"
blueprint_type_add(tab)

--[[
Medikit
]]--

local tab = {}
tab.name = "Medikit"
tab.des = "Heals or something."
tab.model = "models/items/healthkit.mdl"
tab.ent = "hp something"
blueprint_type_add(tab)