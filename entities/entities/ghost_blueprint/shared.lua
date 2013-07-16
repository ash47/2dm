ENT.Type 		= "anim"
ENT.PrintName	= "Ghost Blueprint"
ENT.Author		= "Ash47"
ENT.Contact		= "dont"


function ENT:SetupDataTables()
	self:DTVar( "Int", 0, "Pos" );		-- How far away from the player to draw it
	self:DTVar( "Int", 1, "Rot" );		-- How much rotation
	self:DTVar( "Entity", 1, "Owner" );	-- The owner of it
end
