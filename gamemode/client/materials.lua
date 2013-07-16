if SERVER then return end

--[[matproxy.Add( {
	name = "PlayerColor", 
	init = function( self, mat, values )
		-- Store the name of the variable we want to set
		self.ResultTo = values.resultvar
	end,
	bind = function( self, mat, ent )
		-- If the target ent has a function called GetPlayerColor ) then use that
		-- The function SHOULD return a Vector with the chosen player's colour.

		-- In sandbox this function is created as a network function, 
		-- in player_sandbox.lua in SetupDataTables
		
		
		if ent:IsPlayer() then
			local col = team.GetColor(ent:Team())
			mat:SetVector( self.ResultTo, Vector(col.r/255, col.g/255, col.b/255))
		end
	end 
} )]]--
