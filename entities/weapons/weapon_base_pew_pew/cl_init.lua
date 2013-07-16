if (SERVER) then return end

SWEP.PrintName = "Pew Pew"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

include("shared.lua")

-- Client version of fire weapon:
function SWEP:FireProjectile()
	self:EmitSound(self.Primary.Sound)
end

function SWEP:DrawWorldModel()
	if self.model then
		self.model:DrawModel()
	end
end

function SWEP:OnRemove()
	if self.model then
		self.model:Remove()
		self.model = nil
	end
end
