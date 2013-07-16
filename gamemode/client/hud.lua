--[[---------------------------------------------------------
Client/hud.lua

 - Hud related stuff
---------------------------------------------------------]]--
if SERVER then return end

-- Hud Colours:
local color_bg = Color(183, 183, 183, 255)			-- Back fo the hud
local color_bg2 = Color(67, 67, 67, 255)			-- Back of the inner section of the hud
local color_outline = Color(0, 0, 0, 255)			-- Outline Color
local color_text = Color(0, 0, 0, 255)				-- Color of text
local color_hptext = Color(255, 255, 255, 255)		-- Color of HP/Shield text
local color_ammo = Color(100, 100, 100, 255)		-- Color of the ammo bars
local color_hpb = Color(255, 255, 255, 255)			-- Color of the fading section of HP
local color_expb = Color(255, 255, 0, 255)			-- Color of the EXP bar
local color_rhs = Color(100, 100, 100, 255)			-- Color of the RHS things, unselected
local color_rhs_s = Color(0, 255, 0, 255)			-- Color of the RHS things, unselected
local color_rhstext = Color(0, 0, 0, 255)			-- Color of the RHS text

-- Health bar color (mixes between the two):
local color_hpna = Color(255, 128, 128, 255)
local color_hpnb = Color(255, 64, 64, 255)

-- Shield bar color (mixes between the two):
local color_shna = Color(128, 192, 255, 255)
local color_shnb = Color(0, 128, 255, 255)

-- EXP bar color (mixes between the two):
local color_exna = Color(255, 255, 128, 255)
local color_exnb = Color(200, 200, 0, 255)

-- Ammo bar color (mixes between the two):
local color_ammona = Color(160, 160, 160, 255)
local color_ammonb = Color(100, 100, 100, 255)


-- Real World HP/Shield Sizing:
local rw_hpw = 64	-- Width of the hpbar on people
local rw_hph = 8	-- Height of the hpbar on people
local rw_hpx = 0	-- Xoffset of hpbar
local rw_hpy = 120	-- Yosset of hpbar

-- Hud sizing:
local hud_tl_w = 256								-- (Top left Hud) Width
local hud_tl_h = 64									-- (Top left Hud) Height

local hud_tl_ammox = 4								-- Ammo xpos
local hud_tl_ammoy = 4								-- Ammo ypos

local hud_tl_ammow = hud_tl_w - hud_tl_ammox - 4		-- Width of HP Bar
local hud_tl_ammoh = 26								-- Height of a hp bar

--local hud_tl_sy = hud_tl_hpy + hud_tl_hph + 4		-- Shield Y pos

local hp_outline = 1								-- Size of outline on bars

local hud_r_w = 160

local hud_x = 4										-- Hud xpos offset
local hud_y = ScrH() - hud_tl_h*2 - 8				-- Hud ypos offset

--local hud_tl_lx = (hud_tl_w - hud_tl_hpw - 12)/2	-- Level X offset
local hud_tl_ly = 12								-- Level Y osset

local hud_tl_hpx = 24								-- HP X pos
local hud_tl_hpy = 40								-- HP Y pos

local hud_tl_hpw = 200								-- Width of HP Bar
local hud_tl_hph = 26								-- Height of a hp bar


-- EXP BAR:
local hud_expb_yo = 48
local hud_expb_h = 8

--[[
New Hud Settings:
]]--

local margin = 8							-- Space to the bottom left of bars

local hud_hpw = 200							-- Width of HP bar
local hud_hph = 26							-- Height of HP bar

local hud_hpx = margin						-- X pos of the HP
local hud_hpy = margin						-- Y pos of the HP

local hud_shx = hud_hpx						-- X pos of the shield
local hud_shy = hud_hpy + hud_hph + 4		-- Y pos of the shield

local hud_exw = hud_hpw						-- Width of EXP bar
local hud_exh = 12							-- Height of EXP bar

local hud_exx = hud_shx						-- X pos of exp bar
local hud_exy = hud_shy + 4 + hud_hph		-- Y pos of exp bar

local hud_ammow = hud_hpw					-- Width of the first ammo bar
local hud_ammoh = hud_hph					-- Height of the first ammo bar

local hud_ammo2y = margin							-- Y pos of second Ammo bar

local hud_ammox = ScrW() - hud_ammow - margin - 20	-- X pos of first Ammo bar
local hud_ammoy = hud_ammo2y + hud_ammoh + 4		-- Y pos of first Ammo bar

local hud_ammo2x = hud_ammox						-- X pos of second Ammo bar


-- Grab materials:
local mat_grad = Material("vgui/gradient-u")
local mat_heart = Material("icon16/heart.png")
local mat_shield = Material("icon16/shield.png")
local mat_gun = Material("icon16/gun.png")
local mat_nade = Material("icon16/bomb.png")

-- Disable HL2 Hud:
hook.Add("HUDShouldDraw", "HideShit", function(name)
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudCrosshair" or name == "CHudAmmo" or name == "CHudWeaponSelection" or name == "CHudWeapon" then
		return false
	end
end)

_max_hp = _max_hp or 0
_max_shield = _max_shield or 0

_s_display = _s_display or 0		-- Amount of HP to display in the bar
_hp_display = _hp_display or 0		-- Amount of Shield to display in the bar
_ex_display = _ex_display or 0		-- Amount of EXP out of 100 the player has
_ammo_display = _ammo_display or 0  -- Amount of AMMO to display
_nade_display = _nade_display or 0	-- Amunt of nades to display

-- Hud Rendering:
function GM:HUDPaint()
	-- Flashing Shield:
	local cf = math.abs(math.sin(CurTime() * 20) * 255)
	local color_flash = Color(cf, cf, cf, 255)
	
	local shoulddraw = false
	local tracedata = {}
	tracedata.start = LocalPlayer():EyePos()
	tracedata.mask = MASK_SOLID_BRUSHONLY
	
	local facing = (LocalPlayer():EyeAngles().y == 0)
	
	-- Other player shit:
	for k, v in pairs ( player.GetAll() ) do
		if v:Alive() then
			-- Test if they are on the same team:
			if LocalPlayer():Team() ~= v:Team() then
				-- Test facing dir:
				if((LocalPlayer():GetPos()[1] > v:GetPos()[1]) ~= facing) then
					tracedata.endpos = v:EyePos()
					trace = util.TraceLine(tracedata)
					shoulddraw = (not trace.Hit)
				else
					shoulddraw = false
				end
			else
				-- Same team, can always see:
				shoulddraw = true
			end
			
			if shoulddraw then
				-- Find the position:
				local pos = ( v:EyePos() + Vector(0,0,42)):ToScreen()
				
				-- Move it to the right spot:
				local x = math.Round(pos.x - rw_hpw/2 + rw_hpx)
				local y = math.Round(pos.y + rw_hpy)
				
				-- HP Bar:
				v._hpd = DuelBox(1, x, y, rw_hpw, rw_hph, color_outline, color_hpna, color_hpnb, color_hpb, v._hpd or v:Health(), v:Health(), 100)
				
				-- Stuff for flashing shield:
				local bg = color_outline
				if v:Armor() <= 0 then
					bg = color_flash
				end
				
				-- Shield Bar:
				v._sd = DuelBox(1, x, y + 4 + rw_hph, rw_hpw, rw_hph, bg, color_shna, color_shnb, color_hpb, v._sd or v:Armor(), v:Armor(), 200)
				
				-- The Player's Name:
				local txt = v:GetName()
				
				surface.SetFont("playername")
				local w, h = surface.GetTextSize(txt)
				
				surface.SetTextPos(pos.x - w/2, y - h)
				surface.SetTextColor(team.GetColor(v:Team()))
				surface.DrawText( txt )
			end
		end
	end
	
	-- If our local player is dead:
	if LocalPlayer():Health() <= 0 then
		-- Workout how long left:
		local timeleft = math.ceil(math.ceil(CurTime()/_RespawnDelay) * _RespawnDelay - CurTime())
		
		-- Draw how long left:
		local txt = "Respawning in "..timeleft.." second"..((timeleft>1 and "s") or "")
		surface.SetFont("RespawnTimer")
		local w, h = surface.GetTextSize(txt)
		surface.SetTextColor( Color(255, 0, 0, 255) )
		surface.SetTextPos( ScrW()/2 - w/2, ScrH()/2 - h/2)
		surface.DrawText(txt)
		
		return
	end
	
	-- The player's Armor:
	local a = math.max(LocalPlayer():Armor(), 0)
	local hp = math.max(LocalPlayer():Health(), 0)
	
	-- Render the icons:
	surface.SetDrawColor(color_hpb)
    surface.SetMaterial(mat_heart)
    surface.DrawTexturedRect(hud_hpx, hud_hpy + 6, 16, 16)
	surface.SetMaterial(mat_shield)
	surface.DrawTexturedRect(hud_shx, hud_shy + 6, 16, 16)
	surface.SetMaterial(mat_gun)
	surface.DrawTexturedRect(hud_ammox + hud_ammow + 4, hud_ammoy + 6, 16, 16)
	surface.SetMaterial(mat_nade)
	surface.DrawTexturedRect(hud_ammo2x + hud_ammow + 4, hud_ammo2y + 6, 16, 16)
	
	--[[
	Health:
	]]--
	
	-- Draw the bar:
	_hp_display = DuelBox(1, hud_hpx + 20, hud_hpy, hud_hpw, hud_hph, color_outline, color_hpna, color_hpnb, color_hpb, _hp_display, LocalPlayer():Health(), 100)
	
	-- Set the font:
	surface.SetFont("HudNewHP")
	
	-- HP Text:
	if hp > 0 then
		surface.SetTextColor(color_hptext)
		surface.SetTextPos(hud_hpx + 24, hud_hpy + 2) 
		surface.DrawText(math.ceil(LocalPlayer():Health()/100 * _max_hp))
	end
	
	--[[
	Shield:
	]]--
	
	-- Flashing Shield:
	local bg = color_outline
	if LocalPlayer():Armor() <= 0 then
		bg = color_flash
	end
	
	-- Draw the bar:
	_s_display = DuelBox(1, hud_shx + 20, hud_shy, hud_hpw, hud_hph, bg, color_shna, color_shnb, color_hpb, _s_display, LocalPlayer():Armor(), 200)
	
	-- Shield Text:
	if a > 0 then
		surface.SetTextPos(hud_shx + 24, hud_shy + 2) 
		surface.DrawText(math.ceil(LocalPlayer():Armor()/200 * _max_shield))
	end
	
	--[[
	EXP Bar:
	]]--
	
	_ex_display = DuelBox(1, hud_exx + 20, hud_exy, hud_exw, hud_exh, color_outline, color_exna, color_exnb, color_hpb, _ex_display, 25, 100)
	
	--[[
	Ammo:
	]]--
	
	-- REPLACE HARD VALUE OF 5000 HERE!
	
	-- Grab the player's weapon:
	local wep = LocalPlayer():GetActiveWeapon()
	local clip = 0
	local maxclip = 1
	
	if wep:IsValid() then
		clip = wep:Clip1()
		maxclip = wep.Primary.ClipSize
	end
	
	
	-- Draw the bar:
	RevDuelBox(1, hud_ammox, hud_ammoy, hud_ammow, hud_ammoh, color_outline, color_ammona, color_ammonb, color_hpb, clip, clip, maxclip)
	
	--LocalPlayer():GetAmmoCount("Pistol")
	
	-- Set the font:
	surface.SetFont("HudNewHP")
	
	local txt = clip.."/"..maxclip.." + "..LocalPlayer():GetAmmoCount("Pistol")
	
	surface.SetTextColor(color_hptext)
	surface.SetTextPos(hud_ammox + 4, hud_ammoy + 2) 
	surface.DrawText(txt)
	
	--[[
	Nades:
	]]--
	
	RevDuelBox(1, hud_ammo2x, hud_ammo2y, hud_ammow, hud_ammoh, color_outline, color_ammona, color_ammonb, color_hpb, 1, 1, 1)
	
	-- Move hp/shield display amount:
	--_hp_display = number_moveto(_hp_display, hp, 0.5)
	--_s_display = number_moveto(_s_display, a, 0.5)
	
	--[[-----------------
	Top Left Section
	-----------------]]--
	/*surface.SetDrawColor(color_bg)
	surface.DrawRect(hud_x , hud_y, hud_tl_w, hud_tl_h)
	
	-- Outline
	surface.SetDrawColor(color_outline)
	surface.DrawOutlinedRect(hud_x , hud_y, hud_tl_w, hud_tl_h)
	
	--[[
	EXP Bar:
	]]--
	surface.SetDrawColor(color_outline)
	surface.DrawRect(hud_x + 4 , hud_y + hud_expb_yo + 4, hud_tl_w - hud_tl_hpw - 12, hud_expb_h)	-- BG
	
	local exp_percent = 0.75	-- Set EXP to exp/exp_needed_to_next_level
	surface.SetDrawColor(color_expb)
	surface.DrawRect(hud_x + 5 , hud_y + hud_expb_yo + 5, (hud_tl_w - hud_tl_hpw - 14) * exp_percent, hud_expb_h-2)	-- Actual Bar
	
	--[[
	Player's level:
	]]--
	surface.SetFont("HudLevel")
	local level = "1"
	local w, h = surface.GetTextSize(level)
	
	surface.SetTextColor( color_text )
	surface.SetTextPos( hud_x + hud_tl_lx - w/2, hud_y + hud_tl_ly) 
	surface.DrawText( "1" )
	
	--[[
	Health:
	]]--
	
	surface.SetDrawColor(Color(255, 255, 255, 255))
    surface.SetMaterial(mat_heart)
    surface.DrawTexturedRect(hud_x + hud_tl_hpx - 20, hud_y + hud_tl_hpy + 4, 16, 16)
	surface.SetMaterial(mat_shield)
	surface.DrawTexturedRect(hud_x + hud_tl_hpx - 20, hud_y + hud_tl_sy + 4, 16, 16)
	
	-- Draw the bar:
	_hp_display = DuelBox(1, hud_x + hud_tl_hpx, hud_y + hud_tl_hpy, hud_tl_hpw, hud_tl_hph, color_outline, color_hpna, color_hpnb, color_hpb, _hp_display, LocalPlayer():Health(), 100)
	
	-- Set the font:
	surface.SetFont("HudHP")
	
	-- HP Text:
	if hp > 0 then
		surface.SetTextColor(color_hptext)
		surface.SetTextPos( hud_x + hud_tl_hpx + 4, hud_y + hud_tl_hpy + 2) 
		surface.DrawText(math.ceil(LocalPlayer():Health()/100 * _max_hp))
	end
	
	--[[
	Shield:
	]]--
	
	-- Flashing Shield:
	local bg = color_outline
	if LocalPlayer():Armor() <= 0 then
		bg = color_flash
	end
	
	-- Draw the bar:
	_s_display = DuelBox(1, hud_x + hud_tl_hpx, hud_y + hud_tl_sy, hud_tl_hpw, hud_tl_hph, bg, color_shna, color_shnb, color_hpb, _s_display, LocalPlayer():Armor(), 200)
	
	-- Shield Text:
	if a > 0 then
		surface.SetTextPos( hud_x + hud_tl_hpx + 4, hud_y + hud_tl_sy + 2) 
		surface.DrawText(math.ceil(LocalPlayer():Armor()/200 * _max_shield))
	end
	
	--[[-----------------
	Bottom Left Section
	-----------------]]--
	surface.SetDrawColor(color_bg)
	surface.DrawRect(hud_x , hud_y + hud_tl_h + 4, hud_tl_w, hud_tl_h)
	
	-- Outline
	surface.SetDrawColor(color_outline)
	surface.DrawOutlinedRect(hud_x , hud_y + hud_tl_h + 4, hud_tl_w, hud_tl_h)
	
	-- Grab the player's weapon:
	local wep = LocalPlayer():GetActiveWeapon()
	
	--print(wep.Primary.ClipSize)
	local pammo = 0
	local ammow = 0
	
	-- Top bar values:
	if wep:IsValid() and wep.Primary then
		pammo  = wep:Clip1()
		ammow = hud_tl_ammow  * math.min(pammo/wep.Primary.ClipSize, 1)
	end
	
	-- Bottom bar values:
	local pammo2 = LocalPlayer():GetAmmoCount("Pistol")
	local pammow2 = hud_tl_ammow * math.min(pammo2/5000, 1)									-- REPLACE HARD VALUE OF 5000 HERE!
	
	-- Top Ammo bar:
	surface.SetDrawColor(color_outline)
	surface.DrawRect(hud_x + hud_tl_ammox, hud_y + hud_tl_ammoy + hud_tl_h + 4, hud_tl_ammow, hud_tl_ammoh)
	surface.SetDrawColor(color_ammo)
	surface.DrawRect(hud_x + hud_tl_ammox + hp_outline, hud_y + hud_tl_ammoy + hud_tl_h + 4 + hp_outline, ammow - 2*hp_outline, hud_tl_ammoh - 2*hp_outline)
	
	-- Ammo Text:
	surface.SetTextPos( hud_x + hud_tl_ammox + 4, hud_y + hud_tl_ammoy + hud_tl_h + 6)
	surface.DrawText( pammo )
	
	-- Bottom Ammo bar:
	surface.SetDrawColor(color_outline)
	surface.DrawRect(hud_x + hud_tl_ammox, hud_y + hud_tl_ammoy + hud_tl_h + hud_tl_ammoh + 8, hud_tl_ammow, hud_tl_ammoh)
	surface.SetDrawColor(color_ammo)
	surface.DrawRect(hud_x + hud_tl_ammox + hp_outline, hud_y + hud_tl_ammoy + hud_tl_h + hud_tl_ammoh + 8 + hp_outline, pammow2 - 2*hp_outline, hud_tl_ammoh - 2*hp_outline)
	
	-- Ammo Text:
	surface.SetTextPos( hud_x + hud_tl_ammox + 4, hud_y + hud_tl_ammoy + hud_tl_h + hud_tl_ammoh + 10)
	surface.DrawText(pammo2)
	
	--[[-----------------
	Right Hand Section
	-----------------]]--
	surface.SetDrawColor(color_bg)
	surface.DrawRect(hud_x + hud_tl_w + 4 , hud_y, hud_r_w, hud_tl_h * 2 + 4)
	
	-- Outline
	surface.SetDrawColor(color_outline)
	surface.DrawOutlinedRect(hud_x + hud_tl_w + 4 , hud_y, hud_r_w, hud_tl_h * 2 + 4)
	
	-- Get ready to draw the bars:
	surface.SetFont("HudHP")
	surface.SetTextColor(color_rhstext)
	
	--[[
	First one:
	]]--
	if _2dm.SlotActive == 1 then
		surface.SetDrawColor(color_rhs_s)
	else
		surface.SetDrawColor(color_rhs)
	end
	surface.DrawRect(hud_x + hud_tl_w + 8, hud_y + hud_tl_hpy, hud_r_w - 8, hud_tl_hph)
	
	surface.SetDrawColor(color_outline)
	surface.DrawOutlinedRect(hud_x + hud_tl_w + 8, hud_y + hud_tl_hpy, hud_r_w - 8, hud_tl_hph)
	
	-- text:
	if _2dm.Weapons[_2dm.Slot[1]] then
		surface.SetTextPos( hud_x + hud_tl_w + 12, hud_y + hud_tl_hpy + 2) 
		surface.DrawText(_2dm.Weapons[_2dm.Slot[1]].Title)
	end
	
	--[[
	Second one:
	]]--
	if _2dm.SlotActive == 2 then
		surface.SetDrawColor(color_rhs_s)
	else
		surface.SetDrawColor(color_rhs)
	end
	surface.DrawRect(hud_x + hud_tl_w + 8, hud_y + hud_tl_hpy + hud_tl_hph +4, hud_r_w - 8, hud_tl_hph)
	
	surface.SetDrawColor(color_outline)
	surface.DrawOutlinedRect(hud_x + hud_tl_w + 8, hud_y + hud_tl_hpy + hud_tl_hph + 4, hud_r_w - 8, hud_tl_hph)
	
	-- text:
	if _2dm.Weapons[_2dm.Slot[2]] then
		surface.SetTextPos(hud_x + hud_tl_w + 12, hud_y + hud_tl_hpy + hud_tl_hph + 6) 
		surface.DrawText(_2dm.Weapons[_2dm.Slot[2]].Title)
	end
	
	--[[
	Third one:
	]]--
	surface.SetDrawColor(color_rhs)
	surface.DrawRect(hud_x + hud_tl_w + 8, hud_y + hud_tl_ammoy + hud_tl_h + 4, hud_r_w - 8, hud_tl_hph)
	
	surface.SetDrawColor(color_outline)
	surface.DrawOutlinedRect(hud_x + hud_tl_w + 8, hud_y + hud_tl_ammoy + hud_tl_h + 4, hud_r_w - 8, hud_tl_hph)
	
	--[[
	Fourth one:
	]]--
	if _2dm.GadgetState then
		surface.SetDrawColor(color_rhs_s)
	else
		surface.SetDrawColor(color_rhs)
	end
	
	surface.DrawRect(hud_x + hud_tl_w + 8, hud_y + hud_tl_ammoy + hud_tl_h + hud_tl_hph + 8, hud_r_w - 8, hud_tl_hph)
	
	surface.SetDrawColor(color_outline)
	surface.DrawOutlinedRect(hud_x + hud_tl_w + 8, hud_y + hud_tl_ammoy + hud_tl_h + hud_tl_hph + 8, hud_r_w - 8, hud_tl_hph)
	
	-- text:
	if _2dm.gadgets[_2dm.Slot[4]] then
		surface.SetTextPos(hud_x + hud_tl_w + 12, hud_y + hud_tl_ammoy + hud_tl_h + hud_tl_hph + 10) 
		surface.DrawText(_2dm.gadgets[_2dm.Slot[4]].name)
	end*/
	
	--[[-----------------
	Other rendering hooks:
	-----------------]]--
	
	-- Lane changing:
	HudLaneChanging()
	
	-- Render hud effects:
	HudEffects()
end

-- Draws a two colour sexy looking bar:
function DuelBox(border, x, y, width, height, bg, top, bottom, fade, display_value, actual_value, max_value)
	-- Calculate the new display value:
	display_value = math.min(number_moveto(display_value, actual_value, max_value/200), max_value)
	
	-- Workout drawing:
	local _width = (width - 2*border)*math.Clamp(display_value/max_value, 0, 1)
	local _width2 = (width - 2*border)*math.Clamp(actual_value/max_value, 0, 1)
	
	-- Draw the background:
	draw.RoundedBox(border, x, y, width, height, bg)
	
	if _width > _width2 then
		-- Draw the fading section:
		draw.RoundedBox(border, x+border, y+border, _width, height-2*border, fade)
	end
	
	if actual_value > 0 then
		-- Draw the coloured section:
		Gradient(x+border, y+border, math.min(_width, _width2), height - border*2, bottom, top)
		--draw.RoundedBoxEx(border, x+border, y+border, math.min(_width, _width2), height/2 - border, top, true, true, false, false)
		--draw.RoundedBoxEx(border, x+border, y + height/2, math.min(_width, _width2), height/2 - border, bottom, false, false, true, true)
	end
	
	-- Return the new display value:
	return display_value
end

-- Draws a two colour sexy looking bar REVERSED:
function RevDuelBox(border, x, y, width, height, bg, top, bottom, fade, display_value, actual_value, max_value)
	-- Calculate the new display value:
	display_value = math.min(number_moveto(display_value, actual_value, max_value/200), max_value)
	
	-- Workout drawing:
	local _width = (width - 2*border)*math.Clamp(display_value/max_value, 0, 1)
	local _width2 = (width - 2*border)*math.Clamp(actual_value/max_value, 0, 1)
	
	local dif  = width - _width - 2*border
	local dif2 = width - math.min(_width, _width2) - 2*border
	
	-- Draw the background:
	draw.RoundedBox(border, x, y, width, height, bg)
	
	if _width > _width2 then
		-- Draw the fading section:
		draw.RoundedBox(border, x+border+dif, y+border, _width, height-2*border, fade)
	end
	
	if actual_value > 0 then
		-- Draw the coloured section:
		Gradient(x+border+dif2, y+border, math.min(_width, _width2), height - border*2, bottom, top)
	end
	
	-- Return the new display value:
	return display_value
end

-- Draws a gradient:
function Gradient(x, y, w, h, col1, col2)
	-- Background segment:
	surface.SetDrawColor(col1)
	surface.DrawRect(x, y, w, h)
	
	-- Gradient segment:
	surface.SetDrawColor(col2)
    surface.SetMaterial(mat_grad)
    surface.DrawTexturedRect(x, y, w, h)
end

-- Store max hp /shield:
net.Receive("max_hp_shield", function(len)
	_max_hp = net.ReadInt(16)
	_max_shield = net.ReadInt(16)
end)
