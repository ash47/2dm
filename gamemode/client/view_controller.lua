--[[---------------------------------------------------------
Client/View_Controller.lua

 - Client Side part of the gamemode
---------------------------------------------------------]]--
if SERVER then return end

-- Camera Settings:
ViewShift = Vector(0, -320, 0)		-- Right/Left, In/Out, Up/Down

local sniper_movespeed = 2

sniper_shiftx = 0
sniper_shifty = 0

-- Workout where the camera should go:
function GM:CalcView(ply, pos, angles, fov)
	local sniper_x = 0
	local sniper_y = 0
	
	local wep = LocalPlayer():GetActiveWeapon()
	
	if wep:IsValid() and wep.Primary then
		if (wep.Primary.ScopeRange or 0) > 0 then
			sniper_x = wep.Primary.ScopeRange
			sniper_y = -wep.Primary.ScopeRange * (ScrH()/ScrW()) / 2
		end
	end
	
	-- Grab the cursor pos:
	local x, y = gui.MousePos()
	
	local sniper_shiftx_target = 0
	local sniper_shifty_target = 0
	
	if input.IsMouseDown(MOUSE_RIGHT) then
		sniper_shiftx_target = math.Clamp(x/ScrW() - 0.5, -0.5, 0.5) * sniper_x
		sniper_shifty_target = (y/ScrH() - 0.5) * sniper_y
	end
	
	-- Move the sniper view towards the target:
	sniper_shiftx = number_moveto(sniper_shiftx, sniper_shiftx_target, sniper_movespeed)
	sniper_shifty = number_moveto(sniper_shifty, sniper_shifty_target, sniper_movespeed)
	
	-- Find the player's position relative to our view:
	local scrpos = LocalPlayer():EyePos():ToScreen()
	
	
	-- Find the new x and y position:
	x = math.Clamp(x, 0, ScrW()) - scrpos.x
	y = math.Clamp(y, 0, ScrH()) - scrpos.y
	
	-- Adjust dir:
	local dir = 0
	if x < 0 then
		dir = 180
	end
	
	-- Aim up / down:
	local ang = math.deg(math.atan(y/math.abs(x)))
	
	if LocalPlayer():Health() > 0 then
		-- Aim towards cursor:
		LocalPlayer():SetEyeAngles(Angle(ang, dir, 0))
	end
	
	-- Workout sniper zoom:
	local SniperZoom = Vector(sniper_shiftx, 0, sniper_shifty)
	
	-- Work out where to view from:
    local view = {}
    view.origin = pos + ViewShift + SniperZoom
    view.angles = (pos - view.origin + SniperZoom):Angle()
    view.fov = fov
	
	LastCamPos = view.origin
	LastCamAng = view.angles
	
    return view
end

-- Always draw the local character:
function GM:ShouldDrawLocalPlayer(ply)
	return true
end

-- Allow shooting to start:
function GM:GUIMousePressed(mc)
	-- Ensure we are in gameplay mode:
	if _2dm.PlayerMode == 0 then
		if mc == MOUSE_LEFT then RunConsoleCommand("+attack")
		elseif mc == MOUSE_RIGHT then RunConsoleCommand("+attack2")
		end
	elseif _2dm.PlayerMode == 1 then
		if mc == MOUSE_RIGHT then
			net.Start("bp_rot")
			net.SendToServer()
		end
	end
end

-- Allow shooting to stop:
function GM:GUIMouseReleased(mc)
    if mc == MOUSE_LEFT then RunConsoleCommand("-attack")
    elseif mc == MOUSE_RIGHT then RunConsoleCommand("-attack2")
    end
end

-- Enable the cursor:
gui.EnableScreenClicker(true)
