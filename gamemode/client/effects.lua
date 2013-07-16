--[[---------------------------------------------------------
Client/Effects.lua

 - Sexy looking effects
---------------------------------------------------------]]--

_DamageDraw = {}

local effect_damage_color = Color(255, 0, 0, 255)

-- Applies a weapon:
net.Receive("DamageEffect", function(len)
	local pos = net.ReadVector()
	local amount = net.ReadInt(16)
	local mode = net.ReadInt(4)
	
	-- Adjust the color:
	local color = Color(255, 0, 0, 255)
	if mode == 1 then
		color = Color(74, 134, 232, 255)
	end
	
	-- Pick a dir:
	local dir = math.Rand(-1, 1)
	
	table.insert(_DamageDraw, {pos, amount, CurTime(), dir, color})
end)

-- Draws ontop of everything in the hud:
function HudEffects()
	-- Draw damage text:
	for k, v in pairs(_DamageDraw) do
		-- How long it's existed for:
		local t = (CurTime() - v[3])
		
		if t >= 2 then
			table.remove(_DamageDraw, k)
		end
		
		t = t - 0.3
		
		-- Workout the position:
		local pos = v[1]:ToScreen()
		pos.x = pos.x + (CurTime() - v[3]) * v[4] * 120
		
		t = t * 40
		
		pos.y = pos.y + (t*t) - 120*math.abs(v[4])
		
		-- Handle the text:
		local txt = v[2]
		local w, h = surface.GetTextSize(txt)
		
		surface.SetFont("effect_damage")
		surface.SetTextPos(pos.x - w/2, pos.y - h)
		surface.SetTextColor(v[5])
		surface.DrawText( txt )
	end
end
