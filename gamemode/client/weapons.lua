--[[---------------------------------------------------------
Client/Weapons.lua

 - Weapon networking code
---------------------------------------------------------]]--

-- Ensure access to the global table:
_2dm = _2dm or {}

-- Create the store for weapons:
_2dm.Weapons = _2dm.Weapons or {}

net.Receive("SendWeapon", function(len)
	-- A local store:
	local tab = {}
	
	-- Primary shit:
	tab.Primary = {}
	
	local num = net.ReadInt(16)									-- The gun
	tab.Title = net.ReadString()								-- The Title of the gun
	tab.tier = net.ReadInt(16)									-- The weapon's tier
	tab.GunType = net.ReadInt(min_bits(#_2dm.weapon.guntypes))	-- Guntype:
	tab.ht = net.ReadInt(min_bits(#_2dm.weapon.holdtypes))		-- Weapon Holdtype:
	tab.modelnum = net.ReadInt(min_bits(#_2dm.weapon.models))	-- The Weapons Model NUMBER
	tab.Primary.Damage = net.ReadInt(16)						-- Damage
	tab.Primary.Accuracy = net.ReadInt(16)/100					-- Accuracy
	tab.Primary.Automatic = tobool(net.ReadBit())				-- Automatic
	tab.Primary.Firemode = net.ReadInt(4)						-- Firemode
	tab.Primary.BurstDelay = net.ReadInt(8) / 100				-- Burst
	tab.Primary.NumberofShots = net.ReadInt(8)					-- Number of bullets / shot
	tab.Primary.ClipSize = net.ReadInt(9)						-- Clip size
	tab.Primary.TakeAmmo = net.ReadInt(8)						-- Ammo to take / burst|normal shot
	tab.Primary.ScopeRange = net.ReadInt(16)					-- How far a scope can zoom, 0 = disabled
	tab.Primary.Delay = 1/(net.ReadInt(16)/10)					-- Shooting delay
	tab.Primary.Force = net.ReadInt(16)							-- Force
	
	-- Store the weapon:
	_2dm.Weapons[num] = DefaultWeapon(tab)
end)

-- Applies a weapon:
net.Receive("ApplyWeapon", function(len)
	local ent = net.ReadInt(16)
	local num = net.ReadInt(16)
	ApplyWeapon(ent, num)
end)
