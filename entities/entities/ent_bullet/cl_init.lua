include("shared.lua")

function ENT:Initialize()
	local mat = Matrix()
	mat:Scale( Vector( 0.5, 0.5, 0.5 ) ) 
	self.Entity:EnableMatrix("RenderMultiply", mat)
end

function ENT:Draw()
	self.Entity:DrawModel()
end

-- Client side hit:
function ENT:Hit()
end
