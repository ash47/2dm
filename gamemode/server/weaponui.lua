--[[---------------------------------------------------------
Server/weaponUI.lua

 - Weapon UI server side stuff
---------------------------------------------------------]]--

net.Receive("ApplyWeapon", function(len, ply)
	len = len - 16
	
	local num = ply.Slot[ply.SlotActive]
	
	if not _2dm.Weapons[num] then return end
	
	while len > 0 do
		len = len - 20
		
		local mode = net.ReadInt(16)
		local value = 0
		
		local t = net.ReadInt(4)
		
		if t == 1 then
			-- Standard decimal:
			value = net.ReadInt(16)
			len = len - 16
		elseif t == 2 then
			-- Check box:
			value = net.ReadInt(2)
			len = len - 2
		elseif t == 3 then
			-- String:
			value = net.ReadString()
			len = len - 8 * (string.len(value) + 1)
		else
			-- 2 decimal place number:
			value = net.ReadInt(16)/100
			len = len - 16
		end
		
		if mode == 1 then
			_2dm.Weapons[num].Primary.NumberofShots = value
		elseif mode == 2 then
			_2dm.Weapons[num].Primary.Force = math.abs(value)
		elseif mode == 3 then
			_2dm.Weapons[num].Primary.Cone = value
		elseif mode == 4 then
			_2dm.Weapons[num].Primary.Accuracy = value
		elseif mode == 5 then
			_2dm.Weapons[num].Primary.Delay = 1/value
		elseif mode == 6 then
			_2dm.Weapons[num].Primary.Damage = math.abs(value)
		elseif mode == 7 then
			if value == 1 then
				_2dm.Weapons[num].Primary.Automatic = true
			else
				_2dm.Weapons[num].Primary.Automatic = false
			end
		elseif mode == 8 then
			_2dm.Weapons[num].Primary.FireDamage = value
		elseif mode == 9 then
			_2dm.Weapons[num].Primary.BurnTime = value
		elseif mode == 10 then
			if value == 1 then
				_2dm.Weapons[num].Primary.Explosive = true
			else
				_2dm.Weapons[num].Primary.Explosive = false
			end
		elseif mode == 11 then
			_2dm.Weapons[num].Primary.Bouncy = value
		elseif mode == 12 then
			_2dm.Weapons[num].Primary.Sticky = value
		elseif mode == 13 then
			_2dm.Weapons[num].Primary.ExplodeDelay = value
		elseif mode == 14 then
			if value ~= -1 and _2dm.weapon.holdtypes[value] then
				_2dm.Weapons[num].ht = value
			end
		elseif mode == 15 then
			if value ~= -1 then
				_2dm.Weapons[num].modelnum = value
			end
		elseif mode == 16 then
			_2dm.Weapons[num].Primary.Firemode = value
		elseif mode == 17 then
			_2dm.Weapons[num].Primary.BurstDelay = value
		elseif mode == 18 then
			_2dm.Weapons[num].Primary.ClipSize = math.abs(value)
		elseif mode == 19 then
			_2dm.Weapons[num].Primary.TakeAmmo = value
		elseif mode == 20 then
			_2dm.Weapons[num].Primary.BurnChance = math.abs(value)
		elseif mode == 21 then
			_2dm.Weapons[num].Primary.ExplodeDamage = math.abs(value)
		elseif mode == 22 then
			_2dm.Weapons[num].Primary.ScopeRange = math.abs(value)
		end
	end
	
	-- We updated a weapon:
	UpdatedWeapon(num)
	
	-- Apply the update to the player's weapon:
	ApplyWeapon(ply:GetActiveWeapon(), num)
end)
