--[[---------------------------------------------------------
sHared/wEapons.lua

 - Contains shared weapon shit
---------------------------------------------------------]]--

-- Ensure access to our global table:
/*_2dm = _2dm or {}

-- Access the weapon table:
_2dm.weapon = _2dm.weapon or {}

-- Add hold types:
_2dm.weapon.holdtypes = {"normal", "melee", "melee2", "fist", "knife", "smg", "ar2", "pistol", "rpg", "physgun", "grenade", "shotgun", "crossbow", "slam", "passive"}
_2dm.weapon.models = {	"models/weapons/w_357.mdl",
						"models/weapons/w_crossbow.mdl",
						"models/weapons/w_crowbar.mdl",
						"models/weapons/w_grenade.mdl",
						"models/weapons/w_IRifle.mdl",
						"models/weapons/w_Pistol.mdl",
						"models/weapons/w_rocket_launcher.mdl",
						"models/weapons/w_shotgun.mdl",
						"models/weapons/w_smg1.mdl",
						"models/weapons/w_stunbaton.mdl",
						"models/weapons/w_rif_m4a1.mdl",
						"models/weapons/w_rif_ak47.mdl"
}
_2dm.weapon.guntypes = {"Blade", "Handgun", "Revolver", "Uzi", "SMG", "Assult Rifle", "Bolt-Action Rifle", "Shotgun", "Minigun", "Rocket Launcher", "Sniper Rifle", "Shuriken", "Molotov", "Grenade"}
_2dm.weapon.projectiles = {"ent_bullet"}

_2dm.slot_labels = {"Primary", "Secondary", "Thrown", "Gadget", "Blueprint"}

-- This is the DEFAULT weapon:
function DefaultWeapon(data)
	-- Create a new weapon:
	local tab = {}
	
	-- Defining Attributes:
	tab.ht = 9						-- Hold Type ( _2dm.weapon.holdtypes )
	tab.GunType = 1					-- Gun Type  ( _2dm.weapon.guntypes )
	tab.tier = 1					-- Weapon's tier
	
	-- Main Gun Stuff:
	tab.Title = "Battle Riffle"		-- The gun's name
	tab.Weight = 1					-- How much does the gun weight?
	tab.FiresUnderwater = true		-- Can the gun be fired underwater
	tab.modelnum = 9				-- The model ID ( _2dm.weapon.models )
	
	-- Primary fire data:
	tab.Primary = {}
	tab.Primary.Damage			= 10		-- Damage per shot
	tab.Primary.TakeAmmo		= 0			-- Ammo taken per shot
	tab.Primary.ClipSize		= 100		-- Clip size
	tab.Primary.Accuracy		= 75		-- Accuracy of each shot
	tab.Primary.Cone			= 0.2		-- Cone size of each shot
	tab.Primary.NumberofShots	= 5			-- Number of bullets per shot
	tab.Primary.Automatic		= true		-- Is the gun automatic?
	tab.Primary.Recoil			= 10		-- Recoil, CURRENTLY NOTHING
	tab.Primary.Delay			= 1			-- FireDelay, 1/delay = shots per second
	tab.Primary.Force			= 750		-- The force of the bullet fired
	tab.Primary.Projectile		= 1			-- The projectile to fire ( _2dm.weapon.projectiles )
	tab.Primary.ExplodeDelay	= 2			-- How long before a bullet is removed / exploded
	tab.Primary.FireDamage		= 0			-- Does the bullet cause fire damage?
	tab.Primary.BurnTime		= 1			-- How long will it burn for?
	tab.Primary.BurnChance		= 0.5		-- What is the chance of catching someone on fire?
	tab.Primary.Explosive		= false		-- Does the bullet explode?
	tab.Primary.ExplodeDamage	= 10		-- Amount of damage caused by the explosion
	tab.Primary.Bouncy			= 0			-- Does the bullet bounce?
	tab.Primary.Sticky			= 0			-- Does the bullet stick?
	tab.Primary.tracelength		= 0.5		-- How long is the bullet's trail?
	tab.Primary.Recoil			= 0			-- RECOIL? Does NOTHING atm	
	tab.Primary.Firemode		= 1			-- Firemode | 0 = Automatic / Singleshot, 1 = Burstfire
	tab.Primary.BurstDelay		= 0.03		-- Delay after each SINGLE bullet
	tab.Primary.ScopeRange		= 500		-- How far a scope can zoom, 0 = disabled
	
	if data then
		tab = tmerge(tab, data)
	end
	
	return tab
end

-- Applies settings onto a given weapon:
function ApplyWeapon(wepent, num, filter, count)
	local wep = wepent
	
	if type(wepent) == "number" then
		wep = Entity(wepent)
	end
	
	-- Ensure valid objects are passed:
	if (not _2dm.Weapons[num]) or (not wep) or (not wep:IsValid()) or (not wep:IsWeapon()) then
		if CLIENT then
			-- Retry a few times:
			if (count or 0) < 50 then
				timer.Simple(0.1, function()ApplyWeapon(wepent, num, filter, (count or 0)+1)end)
			end
		end
		
		return
	end
	
	-- Ensure Primary exists:
	wep.Primary = wep.Primary or {}
	
	-- Store the number on it:
	wep.num = num
	
	-- We need to merge the data table into the weapon:
	for k,v in pairs(_2dm.Weapons[num]) do
		if type(v) == "table" then
			wep[k] = tmerge(wep[k], v)
		else
			wep[k] = v
		end
	end
	
	-- Apply the hold type:
	--wep:SetWeaponHoldType(_2dm.weapon.holdtypes[_2dm.Weapons[num].ht])
	
	-- Set the clip:
	wep:SetClip1(wep.ActiveClip or wep.Primary.ClipSize or 0)
	
	-- We also need to send this apply to the clients:
	if SERVER then
		-- Tell everyone:
		net.Start("ApplyWeapon")
		net.WriteInt(wep:EntIndex(), 16)
		net.WriteInt(num, 16)
		
		if not filter or type(filter) == "number" then
			net.Broadcast()
		else
			net.Send(filter)
		end
	else
		-- Apply the model:
		if wep.model then
			-- Remove old model:
			wep.model:Remove()
			wep.model = nil
		end
		
		-- If there's a model to add:
		if _2dm.Weapons[num].modelnum then
			-- Create it:
			wep.model = ClientsideModel(_2dm.weapon.models[_2dm.Weapons[num].modelnum], RENDER_GROUP_VIEW_MODEL_OPAQUE)
			wep.model:SetParent(wep)
			wep.model:AddEffects(EF_BONEMERGE)
		end
	end
end

--[[
args.mean		= The middle point where all data is centered

args.avgmin		= MOST (not all) values will fall ABOVE this point
args.absmin		= The cut off point for the lowest possible value generated.

args.avgmax		= MOST (not all) values will fall BELOW this point
args.absmax		= The cut off point for the lowest possible value generated.
]]--

function NormalValue(args)
	-- Scale the data properly:
	scaler = 3;
	
	-- Ensure we have values:
	args = args or {}
	args.mean = args.mean or 0
	args.avgmin = args.avgnmin or -1
	args.avgmax = args.avgmax or 1
	args.places = args.places or args.dec or 0
	
	-- Workout differences:
	difu = (args.avgmax - args.mean)/scaler;
	difd = (args.mean - args.avgmin)/scaler;
	
	-- Random numbers:
	u1 = math.Rand(0.01, 0.99)
	u2 = math.Rand(0.01, 0.99)
	
	-- Generate
	b = math.sqrt(-2 * math.log(u1))
	
	-- Round to correct number of places:
	v = b * math.sin(2 * math.pi * u2)
	
	-- Scale v:
	if v < 0 then
		v = v * difd
	else
		v = v * difu
	end
	
	-- Translate v:
    v = v + args.mean
	
	-- Limit the highest value:
	if args.absmax then
		if v > args.absmax then
			v = args.absmax
		end
	end
	
	-- Limit the lowest value:
	if args.absmin then
		if v < args.absmin then
			v = args.absmin
		end
	end
	
	-- Cut the decimal places:
	v = math.Round(v, args.places)
	
	-- Return it:
	return v
end
*/