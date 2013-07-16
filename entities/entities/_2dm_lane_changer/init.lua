ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	self.Entity.lane_up = self.Entity.lane_up or nil
	self.Entity.lane_down = self.Entity.lane_down or nil
	
	-- The transistions:
	self.Entity.Up = false
	self.Entity.Down = false
	
	timer.Simple(1, function()
		-- Find positions:
		if self.Entity.lane_up then
			local e = ents.FindByName(self.Entity.lane_up)
			if #e > 0 then
				self.Entity.Up = true
				self.Entity.UpPos = e[1]:GetPos()[2]
			end
		end
		
		if self.Entity.lane_down then
			local e = ents.FindByName(self.Entity.lane_down)
			if #e > 0 then
				self.Entity.Down = true
				self.Entity.DownPos = e[1]:GetPos()[2]
			end
		end
	end)
	
end

--[[function ENT:AcceptInput( name, activator, caller, data )
	if ( string.lower(name) == "lane_up" ) then
		if data == "!activator" then
			activator:SetGravity(self.Entity.gravity )
		end
	end
	if ( string.lower(name) == "end" ) then
		if data == "!activator" then
			activator:SetGravity(1)
		end
	end
	return false
end]]--


function ENT:KeyValue( key, value )
	key = string.lower(key)
	if ( key == "lane_up" ) then
		self.Entity.lane_up = value
	end
	if ( key == "lane_down" ) then
		self.Entity.lane_down = value
	end
end

function ENT:StartTouch( ent )
	if ent:IsValid() and ent:IsPlayer() then
		ent:lane_changer(self.Entity.UpPos, self.Entity.DownPos)
	end
end

function ENT:EndTouch( ent )
	if ent:IsValid() and ent:IsPlayer() then
		if ent.lane_up == self.Entity.UpPos and ent.lane_down == self.Entity.DownPos then
			ent:lane_changer(nil, nil)
		end
	end
end
