SWEP.Author = "Ash47"
SWEP.Contact = "Dont"
SWEP.Purpose = "Base for all SWEPS on 2DM"
SWEP.Instructions = "None for shoe"

-- Set the hold type:
SWEP.ht = 1
SWEP.HoldType = _2dm.weapon.holdtypes[SWEP.ht]

SWEP.FiresUnderwater = true
SWEP.Weight = 1
SWEP.Category = "Ash47"

SWEP.Primary.Sound			= Sound ("NPC_Combine.GrenadeLaunch")
SWEP.Primary.Damage			= 0
SWEP.Primary.TakeAmmo		= 0
SWEP.Primary.ClipSize		= 100
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Delay			= 1
SWEP.Primary.Recoil			= 0
SWEP.Primary.Bursts			= 0

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/v_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

function SWEP:Initialize()
	-- Makes the RPG invisible:
	self:SetNoDraw(true)
end

function SWEP:Deploy()
	-- Makes the RPG invisible:
	self:SetNoDraw(true)
end

-- Checks if the gun needs to reloads, and reloads if so:
function SWEP:ReloadCheck()
	-- Do we have enough ammo for another shot:
	if self:Clip1() < self.Primary.TakeAmmo then
		-- Stop the burst:
		self.Primary.Bursts = 0
		
		-- Reload the gun:
		self:Reload()
		
		return true
	end
	
	return false
end

function SWEP:Think()
	if self.Primary.Bursts > 0 then
		-- Time to shoot?
		if CurTime() >= self.Primary.NextBurst then
			-- Check if there is enough ammo for this burst:
			if self:ReloadCheck() then return end
			
			-- Drop bursts by one:
			self.Primary.Bursts = self.Primary.Bursts - 1
			
			-- Set the next shot:
			self.Primary.NextBurst = CurTime() + self.Primary.BurstDelay
			
			-- Take a shot:
			self:FireProjectile()
			
			-- Take some ammo:
			self:TakePrimaryAmmo(self.Primary.TakeAmmo)
			
			-- Check for a reload:
			self:ReloadCheck()
		end
	end
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	-- A basic check:
	if self:ReloadCheck() then return end
	
	-- Fancy looking effects:
	self:ShootEffects() 
	
	-- Take ammo:
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	
	-- Automatic Gun:
	if self.Primary.Firemode == 0 then
		for i=1,self.Primary.NumberofShots do
			self:FireProjectile()
		end
		
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	-- Burst Fire:
	elseif self.Primary.Firemode == 1 then
		-- Set a delay for the next one:
		self.Primary.NextBurst = CurTime() + self.Primary.BurstDelay
		
		-- Make more bullets come out later:
		self.Primary.Bursts = self.Primary.NumberofShots - 1
		
		-- First the first projectile:
		self:FireProjectile()
		
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay + self.Primary.BurstDelay * self.Primary.NumberofShots )
		self:SetNextSecondaryFire( CurTime() + self.Primary.Delay + self.Primary.BurstDelay * self.Primary.NumberofShots )
	end
	
	-- Check for auto reload:
	self:ReloadCheck()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	if self.NextReload and CurTime() <= self.NextReload then return end
	
	if ((self:Clip1() < self.Primary.ClipSize) and (self.Owner:GetAmmoCount("Pistol") > 0)) then
		self:DefaultReload( ACT_VM_RELOAD )
		
		local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
		self.ReloadingTime = CurTime() + AnimationTime
		self:SetNextPrimaryFire(CurTime() + AnimationTime)
		self:SetNextSecondaryFire(CurTime() + AnimationTime)
	end
end
