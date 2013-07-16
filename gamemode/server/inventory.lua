--[[---------------------------------------------------------
Server/inventory.lua

 - Inventory
---------------------------------------------------------]]--

-- Send the contents of a slot:
function SendSlotInfo(ply, slots)
	-- Ensure slots exists:
	if not slots then
		slots = {1, 2, 3, 4, 5}
	end
	
	-- Send over the player's slots:
	net.Start("SendSlots")
	for k,v in pairs(slots) do
		net.WriteInt(v, 4)				-- Which slot is being sent
		net.WriteInt(ply.Slot[v], 16)	-- The item ID
	end
	net.Send(ply)
end

function FillAmmo(num)
	/*if _2dm.Weapons[num] then
		_2dm.Weapons[num].ActiveClip = _2dm.Weapons[num].ClipSize
	end*/
end

-- Change the player's active slot:
function ChangeToSlot(ply, slot)
	-- Grab the player's active weapon:
	local wep = ply:GetActiveWeapon()
	
	-- Ensure it's a pew pew gun:
	if wep.num and _2dm.Weapons[wep.num] then
		-- Store how much ammo in it:
		_2dm.Weapons[wep.num].ActiveClip = wep:Clip1()
	end
	
	if type(wep) == "Weapon" then
		-- Strip it's ammo:
		if wep:IsValid() then
			wep:SetClip1(0)
		end
	end
	
	-- Set wep to nil:
	wep = nil
	
	-- Grab their ammo count:
	local ammo = ply:GetAmmoCount("pistol")
	
	-- Strip away all weapons:
	ply:StripWeapons()
	
	-- Set the player's active slot:
	ply.SlotActive = slot
	
	-- Check if there is a gun in the slot:
	if ply.Slot[slot] ~= 0 then
		-- Give the player a pew pew:
		ply:Give("weapon_base_pew_pew")
		
		-- Grab that weapon:
		wep = ply:GetWeapon("weapon_base_pew_pew")
		
		-- Apply the weapon's settings:
		ApplyWeapon(wep, ply.Slot[slot], -1)
	end
	
	-- Reset their ammo count:
	ply:SetAmmo(ammo, "Pistol")
	
	-- Tell the player which slot they're in:
	net.Start("ToggleSlot")
	net.WriteInt(slot, 4)
	
	if wep and wep:IsValid() then
		net.WriteInt(wep:Clip1(), 16)
	end
	
	-- Send the message:
	net.Send(ply)
end

-- Toggles a player's active slot:
function ToggleActiveSlot(ply)
	-- Change their active slot:
	if ply.SlotActive == 1 then
		ChangeToSlot(ply, 2)
	else
		ChangeToSlot(ply, 1)
	end
end

-- Adds an item to a backpack:
function Backpack_Add(ply, sort, num, pos)
	local r = nil
	
	if pos then
		r = table.insert(ply.Backpack, pos, {sort, num})
	else
		r = table.insert(ply.Backpack, {sort, num})
	end
	
	return r
end

-- Sends a backpack:
function Backpack_Send(ply)
	net.Start("Backpack")
	
	-- Send each item:
	for k,v in pairs(ply.Backpack) do
		net.WriteInt(v[1], 4)
		net.WriteInt(v[2], 16)
	end
	
	-- Send it to the player:
	net.Send(ply)
end

-- Loads a backpack:
function Backpack_Load(ply)
	-- Create an empty backpack:
	ply.Backpack = {}
	
	-- Here's where you would normally load it ---- implement me :D
	
	-- This is tempry shit, just make some new guns:
	
	-- Create some weapons:
	for i = 1,32 do
		local tab = GenerateWeapon()
		tab.Title = tab.Title.."Random #"..i
		local wep = NewWeapon(tab)
		Backpack_Add(ply, BP_WEP, wep)
	end
	
	-- Put it into the player's slots:
	ply.Slot[1] = 0
	ply.Slot[2] = 0
	
	-- Add a gadget to their pack:
	for k,v in pairs(_2dm.gadgets_ids) do
		local gad = gadget_add(k)
		Backpack_Add(ply, BP_GAD, gad)
	end
	
	-- Add a blueprint to their pack:
	for k,v in pairs(_2dm.blueprint_ids) do
		local bp = blueprint_add(k)
		Backpack_Add(ply, BP_BLU, bp)
	end
	
	-- Send the player some slot info:
	SendSlotInfo(ply)
	
	-- Send the backpack:
	Backpack_Send(ply)
end

-- A player wants to toggle their active slot:
net.Receive("ToggleSlot", function(len, ply)
	ToggleActiveSlot(ply)
end)

-- A player is swaping a backpacked item into a slot:
net.Receive("BackpackToSlot", function(len, ply)
	-- Grab what they sent:
	local bp = net.ReadInt(16)
	local slot = net.ReadInt(4)
	
	-- Validate what we just got:
	if slot < 1 or slot > 5 then return end		-- Invalid slot
	if (not ply.Backpack[bp]) and bp ~= 0 then return end		-- Item not found in backpack
	
	-- Check which slot it's being swapped into:
	if slot == 1 or slot == 2 then
		-- Deice what to do:
		if bp == 0 then
			-- Empty the slot:
			ply.Slot[slot] = 0
		else
			-- Check this item can go into this slot:
			if ply.Backpack[bp][1] == BP_WEP then
				-- Perform the swap:
				ply.Slot[slot] = ply.Backpack[bp][2]
			end
		end
	elseif slot == 4 then
		-- Disable their current gadget:
		gadget_off(ply, true)
		
		-- Deice what to do:
		if bp == 0 then
			-- Empty the slot:
			ply.Slot[slot] = 0
		else
			-- Check this item can go into this slot:
			if ply.Backpack[bp][1] == BP_GAD then
				-- Perform the swap:
				ply.Slot[slot] = ply.Backpack[bp][2]
			end
		end
	end
	
	-- Send the change to the player:
	SendSlotInfo(ply, {slot})
	
	-- Did we swap our active weapon?
	if slot == 1 or slot == 2 then
		if slot == ply.SlotActive then
			-- We need to load that weapon:
			ChangeToSlot(ply, slot)
		end
	end
	
	-- Tell them to open their inventory:
	net.Start("F2")
	net.Send(ply)
end)

-- Called when the player wants to swap out two slots:
net.Receive("SwapSlots",function(len,ply)
	-- Read in the data:
	local slota = net.ReadInt(4)
	local slotb = net.ReadInt(4)
	
	-- Validate the data:
	if slota <1 or slota >5 then return end
	if slotb <1 or slotb >5 then return end
	
	-- Ensure the slots are actually swapable:
	if slota + slotb ~= 3 then return end
	
	-- Perform the swap:
	local sa = ply.Slot[slota]
	ply.Slot[slota] = ply.Slot[slotb]
	ply.Slot[slotb] = sa
	
	-- Tell the player:
	SendSlotInfo(ply,{slota,slotb})
	
	-- Change weapons if we need to:
	if slota == ply.SlotActive or slotb == ply.SlotActive then
		ChangeToSlot(ply,ply.SlotActive)
	end
	
	-- Tell them to open their inventory:
	net.Start("F2")
	net.Send(ply)
end)