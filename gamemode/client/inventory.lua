--[[---------------------------------------------------------
Client/Inventory.lua

 - The inventory
---------------------------------------------------------]]--
if SERVER then return end

-- Ensure 2dm exists:
_2dm = _2dm or {}

-- A store for the backpack:
_2dm.Backpack = _2dm.Backpack or {}

-- Setup inventory slots:
_2dm.Slot = _2dm.Slot or {}

-- Change the active slot:
_2dm.SlotActive = _2dm.SlotActive or 1

-- Assign nothing into them by default:
for i = 1, 5 do
	_2dm.Slot[i] = _2dm.Slot[i] or 0
end

net.Receive("SendSlots", function(len)
	-- Remove the initial len:
	len = len - 16
	
	while len > 0 do
		-- Remove the bytes we are about to read:
		len = len - 20
		
		local slotn = net.ReadInt(4)	-- The slot to inject into
		local cont = net.ReadInt(16)	-- The contents to inject
		
		-- Read and store the bytes:
		_2dm.Slot[slotn] = cont
	end
end)

net.Receive("Backpack", function(len)
	-- Reset backpack:
	_2dm.Backpack = {}
	
	while len > 0 do
		-- Remove the bytes we are about to read:
		len = len - 20
		
		Backpack_Add(net.ReadInt(4), net.ReadInt(16))
	end
end)

-- Inserts into a backpack:
function Backpack_Add(sort, num, pos)
	local r = nil
	if pos then
		r = table.insert(_2dm.Backpack, pos, {sort, num})
	else
		r = table.insert(_2dm.Backpack, {sort, num})
	end
	
	return r
end

-- Swap a backpack item to an inventory slot:
function BackpackToSlot(bp, slot)
	net.Start("BackpackToSlot")
	net.WriteInt(bp, 16)
	net.WriteInt(slot, 4)
	net.SendToServer()
end

-- Swap out two slots:
function SloToSlot(slota, slotb)
	net.Start("SwapSlots")
	net.WriteInt(slota, 4)
	net.WriteInt(slotb, 4)
	net.SendToServer()
end

function Inventory()
	local sx, sy = nil, nil
	
	-- Check if one already exists:
	if _2dm.Inventory then
		if _2dm.Inventory:IsValid() then
			-- Remove left side pain:
			if _2dm.Inventory.inl and _2dm.Inventory.inl:IsValid() then
				_2dm.Inventory.inl:Remove()
			end
			
			-- Remove right side pain:
			if _2dm.Inventory.inr and _2dm.Inventory.inr:IsValid() then
				_2dm.Inventory.inr:Remove()
			end
			
			-- Remove the inventory pain:
			sx, sy = _2dm.Inventory:GetPos()
			_2dm.Inventory:Remove()
		end
	end
	
	-- Frame to hold the backpack:
	local d = vgui.Create("DFrame")
	d:SetPos(ScrW()/2-400, ScrH()/2-300)
	d:SetSize(_2dm.inv_width, _2dm.bp_height)
	d:SetTitle("Back Pack")
	d:SetVisible(true)			// Visible
	d:SetDraggable(true)		// Dragable
	d:ShowCloseButton(true)		// Show Close Button
	d:SetSizable(false)			// No resizing
	d:SetDeleteOnClose(false)	// Don't remove when closed
	d:MakePopup()
	d.think = d.Think
	d.Think = function(self)
		if self.dragging == 1 then
			-- Check if still dragging:
			if input.IsMouseDown(MOUSE_LEFT) then
				local _x, _y = gui.MousePos()
				if self.dx ~= _x or self.dy ~= _y then
					-- Drag something:
					self.drag()
					
					-- Disable dragging:
					self.dragging = 0
				end
			else
				-- Disable dragging:
				self.dragging = 0
				
				-- Run the other caller:
				self.dragfail()
			end
		end
		
		-- Run normal thinking shit:
		self.think(self)
	end
	
	-- Old Adjusting:
	if sx then
		d:SetPos(sx, sy)
	end
	
	-- Storage for each slot:
	d.slot = {}
	
	-- Disable dragging:
	d.dragging = 0
	
	-- The backpack itself:
	local lst = vgui.Create("DListView", d)
	lst:SetPos(4, 28)
	lst:SetSize(_2dm.bp_width, _2dm.bp_height - 32)
	lst:SetMultiSelect(false)
	lst:AddColumn("Tier"):SetFixedWidth(30);
	lst:AddColumn("Item"):SetFixedWidth(200);
	lst:AddColumn("Type")
	
	-- When a line is pressed:
	lst.OnClickLine = function(self, line, selected)
		if d.dragging == 0 then
			-- Start dragging:
			d.dx, d.dy = gui.MousePos()
			d.dragging = 1
			
			-- If we drag:
			d.drag = function()
				-- Create a drag:
				local a = vgui.Create("D_invpanel_drag")
				a.invpanel = d
				
				-- Stop from selecting self:
				a.fail = lst
				
				-- Update it:
				a:Update(line.num, line._id, line._sort)
				
				a:MakePopup()
			end
			
			-- If we fail:
			d.dragfail = function()
				-- Unselect last guy:
				if lst.selected then
					lst.selected:SetSelected(false)
				end
				
				-- Select self:
				lst.selected = line
				line:SetSelected(true)
				
				-- Update the right hand previewer:
				_2dm.Inventory.inr:SetItem(line.num, line._sort)
			end
		end
	end
	
	-- When a line is hovered over:
	local function LineEnter(self)
		-- Update weapon viewer:
		_2dm.Inventory.inl:SetItem(self.num, self._sort)
	end
	
	-- When a line stops being hovered:
	local function LineExit(self)
		-- Check if we are allowed to remove weapon viewer:
		if self.num == _2dm.Inventory.inl._item then
			-- Remove weapon viewer:
			_2dm.Inventory.inl:SetItem(0)
		end
	end
	
	-- Store it:
	d.lst = lst
	
	-- Build a reverse index:
	local r1 = {}
	r1[_2dm.Slot[1]] = true
	r1[_2dm.Slot[2]] = true
	
	-- Add all the backpack items:
	for k,v in pairs(_2dm.Backpack) do
		local sort = v[1]
		local v = v[2]
		
		if sort == BP_WEP then
			if _2dm.Weapons[v] then
				-- Ensure it's not already equiped:
				if not r1[v] then
					-- Add it to our list:
					local item = lst:AddLine(_2dm.Weapons[v].tier, _2dm.Weapons[v].Title, _2dm.weapon.guntypes[_2dm.Weapons[v].GunType])
					
					item.num = v		-- The items's ID
					item._id = k		-- Thr backpack's position in the table
					item._sort = sort	-- The item's sort
					
					item.OnCursorEntered = LineEnter
					item.OnCursorExited = LineExit
				end
			end
		elseif sort == BP_GAD then
			if _2dm.gadgets[v] then
				-- Ensure it's not already equiped:
				if _2dm.Slot[4] ~= v then
					-- Add it to our list:
					local item = lst:AddLine("?", _2dm.gadgets[v].name, "Gadget")
					
					item.num = v		-- The items's ID
					item._id = k		-- Thr backpack's position in the table
					item._sort = sort	-- The item's sort
					
					item.OnCursorEntered = LineEnter
					item.OnCursorExited = LineExit
				end
			end
		end
	end
	
	local xx = _2dm.bp_width + 8
	local yy = 28
	
	-- Slot 1:
	local m = vgui.Create("D_invpanel", d)
	m:SetPos(xx, yy)
	m:SetSlot(1, BP_WEP)
	d.slot[1] = m
	
	yy = yy + _2dm.model_width + 8
	
	-- Slot 2:
	local m = vgui.Create("D_invpanel", d)
	m:SetSlot(2, BP_WEP)
	m:SetPos(xx, yy)
	d.slot[2] = m
	
	yy = yy + _2dm.model_width + 8
	
	-- Slot 3:
	local m = vgui.Create("D_invpanel", d)
	m:SetSlot(3, BP_NAD)
	m:SetPos(xx, yy)
	d.slot[3] = m
	
	yy = yy + _2dm.model_width + 8
	
	-- Slot 4:
	local m = vgui.Create("D_invpanel", d)
	m:SetSlot(4, BP_GAD)
	m:SetPos(xx, yy)
	d.slot[4] = m
	
	-- Create the left hand inv viewer:
	local m = vgui.Create("D_inv_info")
	m.par = d					-- This is what to attach to
	m:SetItem(0)				-- Set it to show noting initially
	m:SetPlace(-m.width-4, 24)	-- Set it's offset position
	d.inl = m					-- Store it
	
	-- Create the left hand inv viewer:
	local m = vgui.Create("D_inv_info")
	m.par = d					-- This is what to attach to
	m:SetItem(0)				-- Set it to show noting initially
	m:SetPlace(_2dm.inv_width + 4, 24)	-- Set it's offset position
	d.inr = m					-- Store it
	
	-- Store the main frame:
	_2dm.Inventory = d
end

-- F2 has been pressed:
net.Receive("F2", function(len)
	Inventory()
end)

-- The player pressed Q:
function GM:OnSpawnMenuOpen()
	-- Lets tell the server to switch slots:
	net.Start("ToggleSlot")
	net.SendToServer()
end

-- Slot has been changed:
net.Receive("ToggleSlot", function(len)
	-- Set the active slot:
	_2dm.SlotActive = net.ReadInt(4)
	
	if len > 4 then
		-- Read the ammo count:
		local count = net.ReadInt(16)
		local wep = nil
		
		if LocalPlayer():IsValid() then
			wep = LocalPlayer():GetActiveWeapon()
		end
		
		if wep and wep:IsValid() then
			-- Apply Straight away:
			wep:SetClip1(count)
		else
			timer.Simple(1, function()
				local wep = LocalPlayer():GetActiveWeapon()
				
				if wep:IsValid() then
					-- Apply after a second:
					wep:SetClip1(count)
				end
			end)
		end
	end
end)