--[[---------------------------------------------------------
Server/weapons.lua

 - Weapon Networking Code
---------------------------------------------------------]]--

--[[
Server side weapon tracking
]]--

-- Ensure access to the global table:
_2dm = _2dm or {}

-- Create the store for weapons:
_2dm.Weapons = _2dm.Weapons or {}

function NewWeapon(data)
	-- Grab the default weapon:
	local tab = DefaultWeapon()
	
	if data then
		-- Merge in the new data:
		tab = tmerge(tab, data)
	end
	
	-- Store it:
	local num = table.insert(_2dm.Weapons, tab)
	
	-- Send this new gun to everyone:
	SendWeapon(num)
	
	-- Return it:
	return num
end

function UpdatedWeapon(num)
	-- Send the weapon:
	SendWeapon(num, -1)
end

--[[
General Functions
]]--

function SendWeapon(num, filter)
	net.Start("SendWeapon")
	net.WriteInt(num, 16)														-- The weapon
	net.WriteString(_2dm.Weapons[num].Title)									-- The name of the gun
	net.WriteInt(_2dm.Weapons[num].tier, 16)									-- The weapon's tier
	net.WriteInt(_2dm.Weapons[num].GunType, min_bits(#_2dm.weapon.guntypes))	-- Guntype
	net.WriteInt(_2dm.Weapons[num].ht, min_bits(#_2dm.weapon.holdtypes))		-- Holdtype
	net.WriteInt(_2dm.Weapons[num].modelnum, min_bits(#_2dm.weapon.models))		-- The Weapons Model NUMBER
	net.WriteInt(_2dm.Weapons[num].Primary.Damage, 16)							-- Damage
	net.WriteInt(math.Round(_2dm.Weapons[num].Primary.Accuracy*100), 16)		-- Accuracy
	net.WriteBit(_2dm.Weapons[num].Primary.Automatic)							-- Automatic
	net.WriteInt(_2dm.Weapons[num].Primary.Firemode, 4)							-- Firemode
	net.WriteInt(math.floor(_2dm.Weapons[num].Primary.BurstDelay*100), 8)		-- Fire Delay
	net.WriteInt(_2dm.Weapons[num].Primary.NumberofShots, 8)					-- Number of bullets / shot
	net.WriteInt(_2dm.Weapons[num].Primary.ClipSize, 9)							-- Size of the clip
	net.WriteInt(_2dm.Weapons[num].Primary.TakeAmmo, 8)							-- Ammo to take / burst|normal shot
	net.WriteInt(_2dm.Weapons[num].Primary.ScopeRange, 16)						-- How far a scope can zoom, 0 = disabled
	net.WriteInt(math.Round((1/_2dm.Weapons[num].Primary.Delay)*10), 16)		-- Shooting delay
	net.WriteInt(_2dm.Weapons[num].Primary.Force, 16)							-- Force
	
	if not filter or type(filter) == "number" then
		net.Broadcast()
	else
		net.Send(filter)
	end
end

function SendAllWeapons(filter)
	for k,v in pairs(_2dm.Weapons) do
		SendWeapon(k, filter)
	end
end

--[[
Player Related Functions
]]--

local meta = debug.getregistry().Player
function meta:SendWeapon(num)
	SendWeapon(num, self)
end

--[[
Weapon Related Functions
]]--

-- Generates a weapon out of the blue:
function GenerateWeapon()
	-- Stores our randomly generated values:
	local tab = {}
	tab.Title = ""
	tab.Primary = {}
	
	tab.Primary.Accuracy = NormalValue({absmin=0, avgmin=30, mean=60, avgmax=95, absmax=100, dec=2})
	tab.Primary.Damage = NormalValue({absmin=1, avgmin=10, mean=30, avgmax=60, absmax=100, dec=0})
	tab.Primary.ClipSize = NormalValue({absmin=1, avgmin=1, mean=4, avgmax=6, absmax=10, dec=0})
	tab.Primary.NumberofShots = NormalValue({absmin=1, avgmin=3, mean=6, avgmax=9, absmax=12, dec=0})
	tab.Primary.Delay = 1/NormalValue({absmin=1, avgmin=3, mean=6, avgmax=9, absmax=12, dec=1})
	
	if math.Rand(0, 1) > 0.8 then
		tab.Primary.Automatic = true
		tab.Title = tab.Title.."Auto "
	else
		tab.Primary.Automatic = false
	end
	
	if math.Rand(0, 1) > 0.9 then
		tab.Primary.FireDamage = NormalValue({absmin=1, avgmin=2, mean=5, avgmax=8, dec=0})
		tab.Primary.BurnTime = NormalValue({absmin=1, avgmin=1, mean=1.5, avgmax=2, dec=2})
		tab.Primary.BurnChance = math.Round(math.Rand(0, 1), 2)
		tab.Title = tab.Title.."Fire "
	else
		tab.Primary.FireDamage = 0
	end
	
	if math.Rand(0, 1) > 0.9 then
		tab.Primary.Explosive = true
		tab.Primary.ExplodeDamage = NormalValue({absmin=1, avgmin=15, mean=25, avgmax=40, dec=0})
		tab.Title = tab.Title.."Exploding "
	else
		tab.Primary.Explosive = false
	end
	
	tab.Primary.Force = NormalValue({absmin=1, avgmin=500, mean=750, avgmax=1500, dec=0})
	
	tab.Primary.TakeAmmo = 1
	
	tab.Primary.Firemode = 0
	tab.Primary.ScopeRange = 0
	
	return tab
	
	-- Make a new weapon:
	--local wep_primary = NewWeapon()
end

--[[local meta = debug.getregistry().Entity

function meta:Updated()
	SendWeapon(self, -1)
end]]--
