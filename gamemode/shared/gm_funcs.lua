--[[---------------------------------------------------------
sHared/gM_funcs.lua

 - Contains all non-specific GM functions
---------------------------------------------------------]]--

-- Side scrolling movement:
function GM:SetupMove(ply, data)
	local eye = ply:EyeAngles()
	
	if eye.y == 180 then
		-- Walk:
		data:SetForwardSpeed(-data:GetSideSpeed())
	else
		-- Walk:
		data:SetForwardSpeed(data:GetSideSpeed())
		
		-- Enfoce side moving:
		eye.y = 0
		ply:SetEyeAngles(eye)
	end
	
	-- Stop side moving:
	data:SetSideSpeed(0)
end

function GM:PlayerNoClip(ply)
	return true
end

hook.Add("ShouldCollide", "PlayerCollision",function(ent1, ent2)
	if ent1:IsPlayer() then
		if ent2:IsPlayer() then
			return false
		elseif ent2:GetClass() == "ent_bullet" then
			if _2dm.FF or ent2:GetOwner():Team() ~= ent1:Team() then
				--ent2:Hit(ent1)
				return true
			end
			
			return false
		end
	elseif ent2:IsPlayer() then
		if ent1:IsPlayer() then
			return false
		elseif ent1:GetClass() == "ent_bullet" then
			if _2dm.FF or ent1:GetOwner():Team() ~= ent2:Team() then
				--ent1:Hit(ent2)
				return true
			end
			
			return false
		end
	end
end)
