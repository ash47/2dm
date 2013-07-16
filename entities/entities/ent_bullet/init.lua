AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("cl_init.lua")

function ENT:Initialize()
	
	--self.Entity:SetCollisionBounds(Vector(-1, -1, -1), Vector(1, 1, 1))
	
	self.Entity:SetModel( "models/Items/AR2_Grenade.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(0.7)
		phys:EnableGravity(true)
		phys:EnableDrag(true)
	end
end

function ENT:Stick(ent, pos)
	-- Only stick if we aren't already stuck:
	if self.Stuck then return end
	
	-- We are now stuck:
	self.Stuck = true
	
	-- Update our position:
	self:SetPos(pos)
	
	-- Check if we are sticking to world or ent:
	if not ent or not ent:IsValid() then
		-- Stick to a wall:
		self:SetMoveType(MOVETYPE_NONE)
		
		local phys = self.Entity:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	else
		self:SetParent(ent)
		self.parent = ent
	end
	
	-- Nocollide:
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end

function ENT:Unstick()
	-- We have to be stuck to do this:
	if not self.Stuck then return end
	
	-- We are now stuck:
	self.Stuck = false
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(true)
	end
	
	-- Enable collisions:
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	-- Remove parent:
	self:SetParent()
end

function ENT:remove(hp)
	if hp then
		self:SetPos(hp)
	end
	
	if self.Explosive then
		self:Explode()
	end
	
	-- Nocollide:
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	-- Freeze:
	self:SetMoveType(MOVETYPE_NONE)
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	-- Make invisible:
	self:SetColor(Color(255, 255, 255, 0))
	
	-- Remove it after the trail is gone:
	self.ExplodeTime = CurTime() + self.RemoveDelay
	self.removed = true
	
	-- Make it invisible:
	self:SetNoDraw(true)
	
	--self:Remove()
end

function ENT:Think()
	if CurTime()>self.ExplodeTime then
		if self.removed then
			-- Remove trail:
			self.trail:Remove()
			
			-- Remove self:
			self:Remove()
		else
			self:remove()
		end
	end
	
	if self.Stuck then
		if self.parent then
			if not (self.parent:IsValid() and self.parent:Health()>0) then
				self:Unstick()
			end
		end
	end
end

function ENT:PhysicsCollide(data, phys)
	-- Stick to anything
	if self.Sticky == 2 then
		self:Stick(data.HitEntity, data.HitPos)
	end
	
	if data.HitEntity:IsValid() then
		if data.HitEntity:IsPlayer() then
			-- Add the damage:
			data.HitEntity:TakeDamage(self.damage or 0, self.Owner, self.Owner:GetActiveWeapon())
			
			-- Enable fire damage:
			if self.FireDamage > 0 then
				-- Make sure this ent takes fire damage:
				if not data.HitEntity.FireProof then
					-- Allow for the burn chance:
					if math.Rand(0, 1) <= self.BurnChance then
						-- Burn baby burn:
						data.HitEntity:Ignite(self.BurnTime, 0)
						data.HitEntity.FireDamage = self.FireDamage
						data.HitEntity.FireOwner = self.Owner
					end
				end
			end
		end
		
		-- Bounce on entities:
		if self.Bouncy == 1 then
			self:remove(data.HitPos)
		end
		
		-- Stick to entities:
		if self.Sticky == 3 then
			self:Stick(data.HitEntity, data.HitPos)
		end
	else
		-- Stick to world only:
		if self.Sticky == 1 then
			self:Stick(data.HitEntity, data.HitPos)
		end
		
		-- Bounce on entities:
		if self.Bouncy == 3 then
			self:remove(data.HitPos)
		end
	end
	
	-- Explode on impact:
	if self.Bouncy == 0 then
		self:remove(data.HitPos)
	end
end

function ENT:Hit(ply)
	-- Add the damage:
	ply:TakeDamage(self.damage or 0, self.Owner, self.Owner:GetActiveWeapon())
	
	-- Enable fire damage:
	if self.FireDamage then
		if math.random(0, 1) > self.BurnChance then
			data.HitEntity:Ignite(self.BurnTime)
		end
	end
	
	-- Bounce on entities:
	if self.Bouncy == 1 then
		self:remove(self:GetPos())
	end
	
	-- Stick to entities:
	if self.Sticky == 3 then
		self:Stick(data.HitEntity, self:GetPos())
	end
	
	-- Explode on impact:
	if self.Bouncy == 0 then
		self:remove(self:GetPos())
	end
end

function ENT:Explode()
	local e = ents.Create("env_explosion")
		e:SetOwner(self.Owner)
		e:SetPos(self.Entity:GetPos())
		e:SetKeyValue("iMagnitude", self.ExplodeDamage)
		e:SetKeyValue("spawnflags", "56")
		e:Spawn()
		e:Activate()
		e:Fire("Explode", "", 0)
		
	local s = ents.Create("env_shake")
		s:SetOwner(self.Owner)
		s:SetPos(self.Entity:GetPos())
		s:SetKeyValue("amplitude", "200")	-- Power of the shake
		s:SetKeyValue("radius", "250")		-- Radius of the shake
		s:SetKeyValue("duration", "2.5")	-- Time of shake
		s:SetKeyValue("frequency", "255")	-- How har should the screenshake be
		s:SetKeyValue("spawnflags", "4")	-- Spawnflags(In Air)
		s:Spawn()
		s:Activate()
		s:Fire("StartShake", "", 0)
end