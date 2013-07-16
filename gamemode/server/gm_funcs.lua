--[[---------------------------------------------------------
Server/gm_funcs.lua

 - Contains all non-specific GM functions
---------------------------------------------------------]]--

-- When the game first starts:
function GM:Initialize()
	-- Reset next wave:
	self.NextWave = -100
end

-- This runs once all map entities have been made:
function GM:InitPostEntity()
end

--[[---------------------------------------------------------
F1 - F4 buttons
---------------------------------------------------------]]--

function GM:ShowHelp(ply)
	if ply:Team() == TEAM_RED then
		ply:SetTeam(TEAM_BLU)
	else
		ply:SetTeam(TEAM_RED)
	end
end

function GM:ShowTeam(ply)
	net.Start("F2")
	net.Send(ply)
end

function GM:ShowSpare1(ply)
end

function GM:ShowSpare2(ply)
	net.Start("F4")
	net.Send(ply)
end

--[[---------------------------------------------------------
Spawn handling functions
---------------------------------------------------------]]--

-- When the first joins the server:
function GM:PlayerInitialSpawn(ply)
	-- Create a store for weapons:
	ply.Slot = {}
	
	-- Put 0 (nothing) into all the slots:
	for i=1,5 do
		ply.Slot[i] = 0
	end
	
	-- Set the player's active slot:
	ply.SlotActive = 1
	
	-- Send everything they will need:
	//SendAllWeapons(ply)
	//SendAllGadgets(ply)
	
	-- Load out the player's weapon:
	//Backpack_Load(ply)
	
	-- Default them to red:
	ply:SetTeam(TEAM_RED)
	
	-- The ammo the player spawns with:
	ply.AmmoStart = 5000
	
	-- Send everyone's active weapons to the new guy:
	/*for k,v in pairs(player.GetAll()) do
		ApplyWeapon(v:GetActiveWeapon(), v.Slot[v.SlotActive], ply)
	end*/
end

-- When the player spawns / respawns:
function GM:PlayerSpawn(ply)
	-- Ensure they have no weapons:
	ply:StripWeapons()
	
	-- Set the player's model:
	ply:SetModel("models/player/group01/male_01.mdl")
	
	-- Set up their jumping power:
	ply:SetJumpPower(250)
	
	-- Reset their speed:
	ply:SetWalkSpeed(260)
	ply:SetRunSpeed(320)
	
	-- Enable custom collisions:
	ply:SetCustomCollisionCheck(true)
	
	-- Shield info:
	ply.ShieldMax = 2000
	ply.Shield = ply.ShieldMax
	ply.ShieldDelay = 3
	ply.ShieldRecharge = 100
	
	-- Send max shield + max hp to player:
	net.Start("max_hp_shield")
	net.WriteInt(100, 16)
	net.WriteInt(ply.ShieldMax, 16)
	net.Send(ply)
	
	-- Set Health and armour:
	ply:SetHealth(100)
	ply:SetArmor(math.floor(ply.Shield/ply.ShieldMax * 200))
	
	-- Disable suit zoom:
	ply:SetCanZoom(false)
	
	-- Fill both player's guns:
	FillAmmo(ply.Slot[1])
	FillAmmo(ply.Slot[2])
	
	-- Change to the player's Active slot:
	ChangeToSlot(ply, ply.SlotActive)
	
	-- Give spawn ammo:
	ply:SetAmmo(ply.AmmoStart, "Pistol")
	
	-- Reset Gadgets:
	ply.gadgets = {}
	
	-- Turn gadgets off:
	gadget_set_state(ply, false)
	_2dm.gadget_types["Glide Boots"].OnRelease(ply)
end

function GM:PlayerSelectSpawn(ply)
    local spawns = ents.FindByClass("_2dm_spawn")
	local oldspawns = ents.FindByClass("info_player_start")
	
	-- No 2DM spawns found:
	if #spawns == 0 then
		if # oldspawns > 0 then
			return oldspawns[math.random(#oldspawns)]
		else
			return
		end
	end
    
	local newspawns = {}
	
	-- Lets only grab our teams spawns:
	for k, v in pairs(spawns) do
		if v.TeamNumber == ply:Team() then
			table.insert(newspawns, v)
		end
	end
	
	if #newspawns > 0 then
		return newspawns[math.random(#newspawns)] 
	else
		if # oldspawns > 0 then
			return oldspawns[math.random(#oldspawns)]
		else
			return
		end
	end
end

--[[---------------------------------------------------------
Death Stuff:
---------------------------------------------------------]]--

-- What happens when they die:
function GM:DoPlayerDeath(ply, attacker, dmginfo)
	-- Create a ragdoll:
	ply:CreateRagdoll()
	
	-- Update the respawn timer:
	while self.NextWave <= CurTime() do
		self.NextWave = self.NextWave + _RespawnDelay
	end
	
	local m = _2dm.language.kill[math.random(1, #_2dm.language.kill)]
	
	-- Print it out:
	for k,v in pairs(player.GetAll()) do
		v:PrintMessage(HUD_PRINTTALK, string.format(m, attacker:Name(), ply:Name()))
	end
end

-- Stop death noises:
function GM:PlayerDeathSound()
	return true
end

-- Respawn on waves:
function GM:PlayerDeathThink(ply)
	if self.NextWave <= CurTime() then
		ply:Spawn()
	end
end

--[[---------------------------------------------------------
Player Disconnect
---------------------------------------------------------]]--

-- When a player disconnects:
function GM:PlayerDisconnected(ply)
end

--[[---------------------------------------------------------
Damage handle:
---------------------------------------------------------]]--

-- Recharges the player's shield:
function RechargeShield(ply, s)
	if not ply:IsValid() then
		timer.Remove(s.."shield2")
		timer.Remove(s.."shield2")
		return
	end
	
	-- Stop dead people from recharging:
	if ply:Health() <= 0 then
		ply.Shield = 0
		timer.Remove(s.."shield2")
		return
	end
	
	-- Add to the shield:
	ply.Shield = ply.Shield + ply.ShieldRecharge
	
	-- Is it fully recharged?
	if ply.Shield >= ply.ShieldMax then
		-- Cap it:
		ply.Shield = ply.ShieldMax
		
		-- Remove the recharger:
		timer.Remove(s.."shield2")
	end
	
	-- Set Armour:
	ply:SetArmor(math.floor(ply.Shield/ply.ShieldMax * 200))
end

function TakeShield(ply, amount)
	-- Remove their shield:
	ply.Shield = math.max(ply.Shield - amount, 0)
	
	-- Send special effects:
	if amount > 0 then
		DamageEffect(ply:EyePos() + Vector(math.random(-5,5), 0, -10), amount, 1)
	end
	
	ply:SetArmor(math.floor(ply.Shield/ply.ShieldMax * 200))
	
	-- Grab their steamid:
	local s = ply:SteamID()
	
	-- Stop HP recharging:
	timer.Remove(s.."shield2")
	
	-- Apply the recharge delay:
	timer.Create(s.."shield1", ply.ShieldDelay, 1, function() timer.Create(ply:SteamID().."shield2", 0.1, 0, function() RechargeShield(ply, s) end) end)
end

function GM:EntityTakeDamage(ply, dmginfo)
	-- Player handling:
	if ply:IsPlayer() then
		-- Disable Friendly fire:
		if (not _2dm.FF) then
			if dmginfo:GetAttacker():IsPlayer() then
				if dmginfo:GetAttacker():Team() == ply:Team() then
					dmginfo:SetDamage(0)
				end
			end
		end
		
		-- Class based filter:
		local c = dmginfo:GetAttacker():GetClass()
		
		if c == "entityflame" then
			if dmginfo:IsDamageType(DMG_DIRECT) then
				if not dmginfo:GetAttacker().FireTarget then
					if ply.FireOwner then
						dmginfo:GetAttacker().FireTarget = ply
						dmginfo:GetAttacker().BurnDamage = ply.BurnDamage
						dmginfo:SetAttacker(ply.FireOwner)
					end
				else
					if dmginfo:GetAttacker().FireTarget ~= ply then
						-- Shouldn't be burning us:
						dmginfo:SetDamage(0)
					else
						dmginfo:SetAttacker(ply.FireOwner)
						
					end
				end
			end
		elseif c == "env_fire" then
			-- Environment Fire:
			dmginfo:SetDamage(0)
		end
		
		-- Change based on type:
		if dmginfo:IsDamageType(DMG_DIRECT) then
			-- The entity has caught fire:
			dmginfo:SetDamage(ply.FireDamage or 0)
		elseif dmginfo:IsDamageType(DMG_BURN) then
			dmginfo:SetDamage(dmginfo:GetAttacker().BurnDamage or 0)
		end
		
		-- Grab the amount of damage:
		local amount = dmginfo:GetDamage()
		
		-- Send special effects:
		if amount > 0 then
			local mode = 0
			
			if ply.Shield > 0 then
				mode = 1
			end
			
			DamageEffect(ply:EyePos() + Vector(math.random(-5,5), 0, -10), amount, mode)
		end
		
		-- Grab the player's shield:
		local hp = ply:Health()
		
		-- Grab their steamid:
		local s = ply:SteamID()
		
		-- Stop HP recharging:
		timer.Remove(s.."shield2")
		
		-- Proccess Shield:
		if ply.Shield >= 0 then
			-- No HP Damage:
			dmginfo:ScaleDamage(0)
			
			-- Remove some shield:
			ply.Shield = ply.Shield - amount
			
			if ply.Shield < 0 then
				hp = hp + ply.Shield
				ply.Shield = 0
			end
			
			-- Update HP and Shield:
			ply:SetHealth(hp)
			ply:SetArmor(math.floor(ply.Shield/ply.ShieldMax * 200))
		end
		
		-- Apply the recharge delay:
		timer.Create(s.."shield1", ply.ShieldDelay, 1, function() timer.Create(ply:SteamID().."shield2", 0.1, 0, function() RechargeShield(ply, s) end) end)
	end
end

--function GM:PlayerShouldTakeDamage( victim, pl )
--end

-- Disable fall damage (and the sound):
function GM:GetFallDamage(ply, speed)
    return false
end

--[[---------------------------------------------------------
Collision Handling Stuff
---------------------------------------------------------]]--

--[[---------------------------------------------------------
Foot Steps
---------------------------------------------------------]]--

--function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf ) 
--	return true
--end
