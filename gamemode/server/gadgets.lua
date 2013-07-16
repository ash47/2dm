--[[---------------------------------------------------------
server/gadgets.lua

 - Gadgets
 - Hooking into undo
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
GADGET Sending code
]]--

-- Send a single gadget:
function SendGadget(num, filter)
	if not _2dm.gadgets[num] then
		print("Tried to send gadget with unknown id: "..num)
		return false
	end
	
	net.Start("SendGadget")
	net.WriteInt(num, 16)												-- The Gadget's ID
	net.WriteInt(_2dm.gadgets[num].sort, min_bits(#_2dm.gadgets_ids))	-- The gadget's sort
	net.WriteString(_2dm.gadgets[num].name)								-- The name of the gadget
	
	-- Gadget mods:
	for k,v in pairs(_2dm.gadgets[num].mods) do
		net.WriteInt(v, 16)
	end
	
	if not filter or type(filter) == "number" then
		net.Broadcast()
	else
		net.Send(filter)
	end
	
	return true
end

-- Send every gadget over:
function SendAllGadgets(filter)
	for k,v in pairs(_2dm.gadgets) do
		SendGadget(k, filter)
	end
end

--[[
GADGET Adding code
]]--

-- Add a gun:
function gadget_add(sort, data)
	-- Grab the gadget:
	local tab = gadget_grab(sort, data)
	
	-- Store it:
	local num = table.insert(_2dm.gadgets, tab)
	
	-- Send it:
	SendGadget(num)
	
	--return it
	return num
end

--[[
GADGET Toggle Code
]]--

-- This function drains Shield / second
function GadgetDrain(ply, amount, delay, callback, loop)
	timer.Create(ply:SteamID().."drain", delay, 0, function()
		-- Take some shield:
		TakeShield(ply, amount)
		
		-- Run active code:
		if loop then
			loop(ply)
		end
		
		if ply.Shield <= 0 then
			timer.Remove(ply:SteamID().."drain")
			
			if callback then
				callback(ply)
			end
		end
	end)
end

-- Stops a gadget drain:
function GadgetDrainStop(ply)
	timer.Remove(ply:SteamID().."drain")
end

-- Update the state of a gadget:
function gadget_set_state(ply, state)
	-- Only update if different:
	if ply.gadgets.On ~= state then
		-- Store the change:
		ply.gadgets.On = state
		
		-- Send the change:
		net.Start("GadgetState")
		net.WriteBit(state)
		net.Send(ply)
	end
end

function gadget_on(ply)
	-- Grab their gadget sort:
	local g = ply.Slot[4]
	
	if not _2dm.gadgets[g] then return end
	local sortn = _2dm.gadgets[g].sortn
	if not _2dm.gadget_types[sortn] then return end
	
	if _2dm.gadget_types[sortn].toggle then
		if not ply.gadgets.On then
			_2dm.gadget_types[sortn].OnPress(ply)
			gadget_set_state(ply, true)
		else
			_2dm.gadget_types[sortn].OnRelease(ply)
			gadget_set_state(ply, false)
		end
	else
		_2dm.gadget_types[sortn].OnPress(ply)
		gadget_set_state(ply, true)
	end
end

function gadget_off(ply, force)
	-- Grab their gadget sort:
	local g = ply.Slot[4]
	
	if not _2dm.gadgets[g] then return end
	local sortn = _2dm.gadgets[g].sortn
	if not _2dm.gadget_types[sortn] then return end
	
	-- Check if we are allowed to turn it off:
	if (not _2dm.gadget_types[sortn].toggle) or force then
		-- If it's on:
		if ply.gadgets.On then
			-- Turn it off:
			_2dm.gadget_types[sortn].OnRelease(ply)
			gadget_set_state(ply, false)
		end
	end
end

--[[
GADGET Hooking Code
]]--

net.Receive("+undo", function(len, ply)
	gadget_on(ply)
end)

net.Receive("-undo", function(len, ply)
	gadget_off(ply)
end)
