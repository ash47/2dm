--[[---------------------------------------------------------
client/gadgets.lua

 - Gadgets
---------------------------------------------------------]]--
if SERVER then return end

-- Ensure _2dm exists:
_2dm = _2dm or {}

-- Store the gadget state:
net.Receive("GadgetState", function(len)
	_2dm.GadgetState = tobool(net.ReadBit())
end)


net.Receive("SendGadget", function(len)
	-- A local store:
	local tab = {}
	
	local num = net.ReadInt(16)								-- The gadget's ID
	local sort = net.ReadInt(min_bits(#_2dm.gadgets_ids))	-- The gadget's sort
	tab.name = net.ReadString()								-- The gadget's name
	
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
	_2dm.gadgets[num] = gadget_grab(sort, tab)
end)
