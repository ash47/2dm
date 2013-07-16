--[[---------------------------------------------------------
client/blueprints.lua

 - Blueprints
---------------------------------------------------------]]--
if SERVER then return end

-- Ensure _2dm exists:
_2dm = _2dm or {}

--[[ The players mode ]]--
_2dm.PlayerMode = _2dm.PlayerMode or 0
-- 0 Gameplay
-- 1 Building

-- This is where we keep the blueprints:
_2dm.BluePrints = _2dm.BluePrints or {}

-- A store for blueprints:
local vgui_BluePrints = vgui_BluePrints or {}

net.Receive("SendBluePrint", function(len)
	-- A local store:
	local tab = {}
	
	local num = net.ReadInt(16)								-- The blueprint's ID
	local sort = net.ReadInt(min_bits(#_2dm.blueprint_ids))	-- The blueprint's sort
	tab.name = net.ReadString()								-- The blueprint's name
	
	-- Lower the length:
	len = len - 16 - (string.len(tab.name)+1) * 8
	
	-- Read in the mods:
	tab.mods = {}
	
	local i = 0
	
	while(len > 0) do
		-- Move to the next mod:
		i = i + 1
		
		-- Store:
		tab.mods[i] = net.ReadInt(16)
		
		-- Remove some length:
		len = len - 16
	end
	
	-- Store the weapon:
	_2dm.BluePrints[num] = blueprint_grab(sort, tab)
end)

-- Stores the vgui of a blueprint:
function vgui_blueprint_store(blueprint)
	-- Insert it:
	return table.insert(vgui_BluePrints, blueprint)
end

-- Cleans up vgui blueprints:
function vgui_blueprint_cleanup()
	for k,v in pairs(vgui_BluePrints) do
		-- Ensure the model is removed:
		if v.Entity and v.Entity:IsValid() then
			v.Entity:Remove()
		end
		
		-- Remove the actual blueprint:
		v:Remove()
	end
end

-- A list of elements yet to be built:
local vgui_to_build = {}

-- Queues a VGUI blueprint to be built:
function vgui_blueprint_queue(bp, slotnum)
	table.insert(vgui_to_build, {bp, slotnum})
end

-- Builds the queue:
function vgui_create_queue()
	-- Reset the build queue:
	vgui_to_build = {}
	
	-- Sort through inventory:
	for k,v in pairs(_2dm.Backpack) do
		local sort = v[1]
		local v = v[2]
		
		-- Check if it's a blueprint:
		if sort == BP_BLU then
			-- Check if we have details on it:
			if _2dm.BluePrints[v] then
				-- Queue it to be built:
				vgui_blueprint_queue(v, k)
			end
		end
	end
end

-- Builds a queue:
function vgui_build_queue()
	-- Space between blueprints:
	local spacer = 8
	
	-- Midpoint of the screen:
	local mid = ScrW()/2
	
	-- Where to put the blueprints:
	local xx = mid - (#vgui_to_build * (_2dm.model_width + spacer) - spacer)/2
	local yy = ScrH() - _2dm.model_width - 4
	
	-- Build each vgui element:
	for k,v in pairs(vgui_to_build) do
		-- Build the element:
		vgui_blueprint_build(xx, yy, v)
		
		-- Move to the next spot:
		xx = xx + _2dm.model_width + spacer
	end
end

-- Adds the vgui blueprint:
function vgui_blueprint_build(x, y, slot)
	-- Create a blueprint:
	local m = vgui.Create("D_blueprint_bot")
	
	-- Set it up:
	m:SetPos(x, y)
	m:SetSlot(slot[1], slot[2])
	
	-- Store it:
	return vgui_blueprint_store(m)
end

-- Cancels the creation of a blueprint:
function cancel_blueprint()
	net.Start("bp_cancel")
	net.SendToServer()
end

-- When the context menu is opened:
function GM:OnContextMenuOpen()
	-- Enable Building mode:
	_2dm.PlayerMode = 1
	
	-- Create the queue:
	vgui_create_queue()
	
	-- Build the queue:
	vgui_build_queue()
end

-- When the context menu is closed:
function GM:OnContextMenuClose()
	-- Reset to gameplay mode:
	_2dm.PlayerMode = 0
	
	-- Remove blueprints:
	vgui_blueprint_cleanup()
	
	-- Cancel the blueprint:
	cancel_blueprint()
end
