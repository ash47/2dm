--[[---------------------------------------------------------
server/effects.lua

 - Sexy looking effects
---------------------------------------------------------]]--

function DamageEffect(pos, amount, mode, filter)
	net.Start("DamageEffect")
	net.WriteVector(pos)
	net.WriteInt(amount, 16)
	net.WriteInt(mode, 4)
	
	if not filter or type(filter) == "number" then
		net.Broadcast()
	else
		net.Send(filter)
	end
end
