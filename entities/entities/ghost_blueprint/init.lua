AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("cl_init.lua")

function ENT:Initialize()
	self:SetModel(_2dm.blueprint[self.Sort].model)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	-- Network the Owner:
	self.dt.Owner = self.Owner
	
	-- More networking:
	self.dt.Rot = 0
	self.dt.Pos = 0
end

function ENT:Think()
	if self.owner and self.owner:IsValid() then
		--self:SetPos(self.owner:GetEyeTrace().HitPos)
	end
end
