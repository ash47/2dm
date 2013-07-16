ENT.Base = "base_point"
ENT.Type = "point"

function ENT:KeyValue( key, value )
	key = string.lower(key)
	if (key == "targetname") then
		self.Entity:SetName(value)
	end
end
