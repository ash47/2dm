--[[---------------------------------------------------------
client/bindings.lua

 - Binds keys to shit
---------------------------------------------------------]]--

function GM:PlayerBindPress(ply, bind, pressed)
	if string.find(bind, "undo") then
		if pressed then
			net.Start("+undo")
		else
			net.Start("-undo")
		end
		net.SendToServer()
		return true
	end
end
