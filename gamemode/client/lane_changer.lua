--[[---------------------------------------------------------
Client/Lane_Changer.lua

 - Lane Changing Code
---------------------------------------------------------]]--
if SERVER then return end

-- NOTE: Enforced server side too:
local cooldown = 1

local mat = Material("2dm/arrow_down.png")

local size = 64			-- Size LxW of arrow
local yoffset = 32		-- Arrow y pos offset

_lane_changes = _lane_changes or {}

-- Default to off:
_lane_changes.up = 0
_lane_changes.down = 0

-- Lane Changing Info:
net.Receive("LaneChanger", function(len)
	_lane_changes.up = net.ReadBit()
	_lane_changes.down = net.ReadBit()
end)

function HudLaneChanging()
	-- Grab the position:
	local pos = LocalPlayer():EyePos():ToScreen()
	
	pos.x = pos.x
	pos.y = pos.y - size - yoffset
	
	local rot = math.sin(CurTime()*5) * 8
	
	-- Reset the draw color:
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	-- Make them RED if you can't use them:
	if _lane_changes.LastPress then
		if _lane_changes.LastPress >= CurTime() then
			surface.SetDrawColor( 255, 0, 0, 255 )
		end
	end
	
	
	if _lane_changes.up == 1 and _lane_changes.down == 1 then
		-- Draw an up arrow:
		surface.SetMaterial(mat)
		surface.DrawTexturedRectRotated(pos.x + 4 + size/2, pos.y, size, size, rot)
		
		-- Draw an up arrow:
		surface.SetMaterial(mat)
		surface.DrawTexturedRectRotated(pos.x - 4 - size/2, pos.y, size, size, 180 + rot)
	elseif _lane_changes.up == 1 then
		-- Draw an up arrow:
		surface.SetMaterial(mat)
		surface.DrawTexturedRectRotated(pos.x, pos.y, size, size, 180 + rot)
	elseif _lane_changes.down == 1 then
		-- Draw an up arrow:
		surface.SetMaterial(mat)
		surface.DrawTexturedRectRotated(pos.x, pos.y, size, size, rot)
	end
	
	-- Stop spam:
	if _lane_changes.LastPress then
		if _lane_changes.LastPress >= CurTime() then
			return
		end
	end
	
	-- Check for up:
	if _lane_changes.up == 1 then
		if LocalPlayer():KeyDown(IN_FORWARD) then
			if not _lane_changes.pressed then
				_lane_changes.pressed = true
				
				net.Start("LaneChanger")
				net.WriteBit(true)
				net.SendToServer()
				
				_lane_changes.LastPress = CurTime() + cooldown
			end
		else
			_lane_changes.pressed = false
		end
	end
	
	-- check for down:
	if _lane_changes.down == 1 then
		if LocalPlayer():KeyDown(IN_BACK) then
			if not _lane_changes.pressed then
				_lane_changes.pressed = true
				
				net.Start("LaneChanger")
				net.WriteBit(false)
				net.SendToServer()
				
				_lane_changes.LastPress = CurTime() + cooldown
			end
		else
			_lane_changes.pressed = false
		end
	end
end