--[[---------------------------------------------------------
server/lane_changer.lua

 - Lane Changing Code
---------------------------------------------------------]]--

-- How long before they can lane change again:
local cooldown = 1

-- Grab the player table:
local meta = debug.getregistry().Player

function meta:lane_changer(up, down)
	-- Store the changes:
	self.lane_up = up
	self.lane_down = down
	
	-- Tell the player:
	net.Start("LaneChanger")
	net.WriteBit((up and true) or false)
	net.WriteBit((down and true) or false)
	net.Send(self)
end

net.Receive("LaneChanger", function(len, ply)
	-- Ensure no spam:
	if ply.lane_last then
		if ply.lane_last > CurTime() then
			return
		end
	end
	
	-- 3 Second protection:
	ply.lane_last = CurTime() + cooldown
	
	-- Read the info:
	local up = net.ReadBit()
	local pos = ply:GetPos()
	
	-- Move the player:
	if up == 1 then
		if ply.lane_up then
			pos[2] = ply.lane_up
			ply:SetPos(pos)
		end
	else
		if ply.lane_down then
			pos[2] = ply.lane_down
			ply:SetPos(pos)
		end
	end
end)
