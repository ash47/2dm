AddCSLuaFile ("shared.lua")
AddCSLuaFile ("cl_init.lua")

include("shared.lua")
include("cl_init.lua")

function SWEP:OnReloaded()
	-- TEMPORY:
	timer.Simple(3, function()
		-- Allow for client time lag:
		ApplyWeapon(self, self:GetOwner().Slot[1])
	end)
	
	-- Server side:
	ApplyWeapon(self, self:GetOwner().Slot[1])
end

function SWEP:FireProjectile()
	-- The sound:
	self:EmitSound(self.Primary.Sound)
	
	-- The angle this shot will fire at:
	local ang = self.Owner:GetAimVector():GetNormalized() + Vector( math.Rand(-self.Primary.Cone, self.Primary.Cone)*(100-self.Primary.Accuracy)/100, 0, math.Rand(-self.Primary.Cone, self.Primary.Cone)*(100-self.Primary.Accuracy)/100)
	ang[2] = 0
	
	-- Create a projectile:
	local ent = ents.Create (_2dm.weapon.projectiles[self.Primary.Projectile])
	
	-- Ensure it exists:
	if not ent:IsValid() then return end
	
	-- Make sure it collides properly:
	ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	-- Set key info:
	ent:SetPos (self.Owner:EyePos())
	ent:SetAngles (ang:Angle())
	ent:SetOwner(self.Owner)
	ent.Owner = self.Owner
	ent.damage = self.Primary.Damage
	ent:Spawn()
	
	-- Apply bullet specific traits:
	ent.FireDamage = self.Primary.FireDamage
	ent.BurnTime = self.Primary.BurnTime
	ent.BurnChance = self.Primary.BurnChance
	
	ent.Explosive = self.Primary.Explosive
	ent.ExplodeDamage = self.Primary.ExplodeDamage
	ent.Bouncy = self.Primary.Bouncy
	ent.Sticky = self.Primary.Sticky
	ent.ExplodeTime = CurTime() + self.Primary.ExplodeDelay
	ent.RemoveDelay = self.Primary.tracelength
	
	local col = team.GetColor(self.Owner:Team())
	
	-- Create a trail:
	ent.trail = util.SpriteTrail(ent, 0, col, false, 1, 1, self.Primary.tracelength, 0.5, "trails/plasma.vmt")
	
	-- Make the bullet go:
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:ApplyForceCenter (ang * self.Primary.Force)
	else
		ent:Remove()
	end
end
