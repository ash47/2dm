--[[---------------------------------------------------------
Client/WeaponUI.lua

 - Weapon Creator UI
---------------------------------------------------------]]--
if SERVER then return end

_inputs = _inputs or {}

local function makeSlider(parent, x, y, width, min, max, text, dec, default)
	local s = vgui.Create( "DNumSlider", parent)
	s:SetPos(x, y)
	s:SetWide(width)
	s:SetText(text)
	s:SetMin(min)
	s:SetMax(max)
	s:SetDecimals(dec)
	s.Label = ""
	
	if dec == 0 then
		s.dec = 1
	else
		s.dec = 0
	end
	
	if default then
		s:SetValue(default)
	end
	
	return s
end

local function makeButton(parent, x, y, width, height, text)
	local s = vgui.Create( "DButton", parent)
	s:SetPos(x, y)
	s:SetSize(width, height)
	s:SetText(text)
	
	return s
end

local function makeCheck(parent, x, y, text, default)
	local s = vgui.Create( "DCheckBoxLabel", parent)
	s:SetPos(x, y)
	s:SetText(text)
	s:SizeToContents()
	
	s.dec = 2
	
	if default and default == true then
		s:SetChecked(true)
	end
	
	return s
end

local function makeCombo(parent, x, y, width, height, text, values, default)
	local s = vgui.Create( "DComboBox", parent)
	s:SetPos(x, y)
	s:SetSize(width, height)
	s:SetText(text)
	
	s._choice = {}
	
	for k,v in pairs(values) do
		s._choice[v] = k
		s:AddChoice(v)
	end
	
	s.dec = 4
	
	return s
end

-- A weapon creator UI:
function WeaponCreator()
	local d = vgui.Create("DFrame")
	d:SetPos(ScrW()/2-400, ScrH()/2-300)
	d:SetSize(800, 600)
	d:SetTitle("Weapon Creator")
	d:SetVisible(true)			// Visible
	d:SetDraggable(true)		// Dragable
	d:ShowCloseButton(true)		// Show Close Button
	d:SetSizable(false)			// No resizing
	d:SetDeleteOnClose(true)	// Remove when closed
	d:MakePopup()
	
	d.inputs = {}
	
	local wep = LocalPlayer():GetActiveWeapon()
	
	-- No weapon to leach off of:
	if not wep.Primary then return end
	
	d.inputs[1] = makeSlider(d,  16, 30,  250, 1, 10, "Bullets/Shot", 0, wep.Primary.NumberofShots)
	d.inputs[2] = makeSlider(d,  16, 60,  250, 1, 2000, "Fire Force", 0, wep.Primary.Force)
	d.inputs[3] = makeSlider(d,  16, 90,  250, 0, 1, "ConeSize", 2, wep.Primary.Cone)
	d.inputs[4] = makeSlider(d,  16, 120, 250, 0, 100, "Accuracy", 2, wep.Primary.Accuracy)
	d.inputs[5] = makeSlider(d,  16, 150, 250, 1, 15, "Shots / Second", 1, 1/wep.Primary.Delay)
	d.inputs[6] = makeSlider(d,  16, 180, 250, 1, 250, "Damage / Shot", 0, wep.Primary.Damage)
	d.inputs[7] = makeCheck(d,   16, 210, "Automatic?", wep.Primary.Automatic)
	d.inputs[8] = makeSlider(d,  16, 240, 250, 0, 20, "Fire Damage", 0, wep.Primary.FireDamage)
	d.inputs[9] = makeSlider(d,  16, 270, 250, 0, 10, "Burn Time (seconds)", 2, wep.Primary.BurnTime)
	d.inputs[10] = makeCheck(d,  16, 300, "Explosive?", wep.Primary.Explosive)
	d.inputs[11] = makeSlider(d, 16, 330, 250, 0, 3, "Explde on? A/P/N/W", 0, wep.Primary.Bouncy)
	-- 0 = none
	-- 1 = Bounce on walls
	-- 2 = Bounce on all
	-- 3 = Bounce on ents
	d.inputs[12] = makeSlider(d, 16, 360, 250, 0, 3, "Stick to? N/W/A/P", 0, wep.Primary.Sticky)
	-- 0 = none
	-- 1 = stick to walls
	-- 2 = stick to all
	-- 3 = stick to ents
	
	d.inputs[13] = makeSlider(d, 16, 390, 250, 0, 5, "Bullet Explode Delay", 2, wep.Primary.ExplodeDelay)

	d.inputs[14] = makeCombo(d, 260, 30, 250, 30, "Hold Type", _2dm.weapon.holdtypes)
	d.inputs[15] = makeCombo(d, 260, 60, 250, 30, "Weapon Model", _2dm.weapon.models)
	
	d.inputs[16] = makeSlider(d,  16, 420, 250, 0, 1, "Firemode A/B", 0, wep.Primary.Firemode)
	d.inputs[17] = makeSlider(d,  16, 450, 250, 0, 1, "Burst Delay", 2, wep.Primary.BurstDelay)
	
	d.inputs[18] = makeSlider(d,  16, 480, 250, 0, 250, "Clip Size", 0, wep.Primary.ClipSize)
	d.inputs[19] = makeSlider(d,  16, 510, 250, 0, 255, "Ammo / Shot", 0, wep.Primary.TakeAmmo)
	
	d.inputs[20] = makeSlider(d,  16, 540, 250, 0, 1, "Burn Chance", 2, wep.Primary.BurnChance)
	
	d.inputs[21] = makeSlider(d,  16, 570, 250, 0, 100, "Explosive Damage", 0, wep.Primary.ExplodeDamage)
	
	d.inputs[22] = makeSlider(d,  260, 90, 250, 0, 1000, "Scope Range", 0, wep.Primary.ScopeRange)
	
	-- Ensure we have a store:
	_inputs[wep.num] = _inputs[wep.num] or {}
	
	-- Load the store:
	for k,v in pairs(d.inputs) do
		if _inputs[wep.num][k] then
			d.inputs[k]:SetValue(_inputs[wep.num][k])
		end
	end
	
	local b = makeButton(d, 646, 546, 150, 50, "Apply")
	
	b.DoClick = function()
		net.Start("ApplyWeapon")
		for k,v in pairs(d.inputs) do
			local value = v:GetValue()
			net.WriteInt(k, 16)
			if v.dec == 1 then
				-- Standard Decimal
				net.WriteInt(1, 4)
				net.WriteInt(value, 16)
			elseif v.dec == 2 then
				-- Check Box
				if v:GetChecked() then
					value = 1
				else
					value = 0
				end
				
				net.WriteInt(2, 4)
				net.WriteInt(value, 2)
			elseif v.dec == 3 then
				-- String
				net.WriteInt(3, 4)
				net.WriteString(value or "")
			elseif v.dec == 4 then
				if v._choice[value] then
					net.WriteInt(1, 4)
					net.WriteInt(v._choice[value], 16)
				else
					net.WriteInt(1, 4)
					net.WriteInt(-1, 16)
				end
			else
				-- 2 decimal number:
				net.WriteInt(0, 4)
				net.WriteInt(math.floor(value*100), 16)
			end
			
			-- Store the value:
			_inputs[wep.num][k] = value
		end
		net.SendToServer()
	end
end

-- F4 has been pressed:
net.Receive("F4", function(len)
	WeaponCreator()
end)
