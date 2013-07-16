--[[---------------------------------------------------------
Client/VGUI/d_invpanel.lua

 - The inventory model things
---------------------------------------------------------]]--
if SERVER then return end

-- Color Settings:
local color_bg = Color(200, 200, 200, 150)
local color_outline = Color(0, 0, 0, 255)
local color_text = Color(0, 0, 0, 255)

local color_outline_selected = Color(0, 255, 0, 255)	-- The color when you drop an item into a slot
color_outline_drop = Color(255, 0, 0, 255)				-- The color when you drop an item back into the backpack

local PANEL = {}

function PANEL:Init()
	-- Set the default camera angle:
	self:SetCamPos(Vector(0, 30, 0))
	self:SetLookAt(Vector(0, 0, 0))
	
	self.width = _2dm.model_width
	self.height = _2dm.model_width
	
	-- Set the size:
	self:SetSize(self.width, self.height)
	
	-- Set the pos of our model:
	self.ypos = self.height - self.width
	
	-- Set our slot to default:
	self._slot = 0
	self._slot_old = 0
	self._slottxt = ""
	
	-- Grab cursor pos:
	local _x, _y = gui.MousePos()
	
	-- Update our pos:
	self:SetPos(_x - self.width/2, _y - self.height/2)
end

function PANEL:SetModel(model)
	-- Remove the old entity:
	if self.Entity and self.Entity:IsValid() then
		self.Entity:Remove()
		self.Entity = nil		
	end
	
	if not ClientsideModel then return end
	
	-- Create a new model:
	self.Entity = ClientsideModel(model, RENDER_GROUP_OPAQUE_ENTITY)
	if not self.Entity:IsValid() then return end
	
	self.Entity:SetNoDraw(true)
	
	-- Make it look good:
	local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
	self:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.75, 0.75, 0.5))
	self:SetLookAt((PrevMaxs + PrevMins) / 2)
	
	--self.Entity:SetNoDraw(true)
end

-- Update the panel:
function PANEL:Update(item, pos, sort, mode)
	-- Adjust for different shit:
	if mode then
		-- Store the mode:
		self.mode = mode
	else
		-- The default mode:
		self.mode = 0
	end
	
	-- Store the item:
	self._item = item
	self._pos = pos
	self._sort = sort
	
	-- Set the drag sort in the parent:
	self.invpanel.drag_sort = sort
	
	-- Fix glitchyness:
	self:SetPos(gui.MousePos())
	
	if sort == BP_WEP then
		-- A Weapon:
		if _2dm.Weapons[item] then
			self:SetModel(_2dm.weapon.models[_2dm.Weapons[item].modelnum])
		end
	elseif sort == BP_GAD then
		-- A gadget:
		if _2dm.gadgets[item] then
			self:SetModel(_2dm.gadgets[item].model)
		end
	end
end

local function Check(_x, _y, pan)
	local w, h = pan:GetSize()
	local difx, dify = pan:GetPos()
	
	difx = math.abs(_x - difx - w/2)
	dify = math.abs(_y - dify - h/2)
	
	if difx <= w/2 and dify <= h/2 then
		return true
	end
	
	return false
end

-- Make it look nice:
function PANEL:Paint()
	-- Setup colors:
	local c_outline = color_outline
	
	-- Grab cursor pos:
	local _x, _y = gui.MousePos()
	
	-- Update our pos:
	self:SetPos(_x - self.width/2, _y - self.height/2)
	
	local ox, oy = self.invpanel:GetPos()
	
	_x = _x - ox
	_y = _y - oy
	
	-- Reset who we are inside:
	self.invpanel.DragTo = nil
	
	-- Try each pan:
	for k,v in pairs(self.invpanel.slot) do
		if self.fail ~= v then
			if self._sort == v._sort then
				if Check(_x, _y, v) then
					self.invpanel.DragTo = v
					c_outline = color_outline_selected
					break
				end
			end
		end
	end
	
	-- Check for drop back into inventory:
	if self.mode == 1 then
		if Check(_x, _y, self.invpanel.lst) then
			self.invpanel.DragTo = -1
			c_outline = color_outline_drop
		end
	end
	
	-- Draw the background:
	draw.RoundedBox( 4, 0, 0, self.width, self.width, c_outline)
	draw.RoundedBox( 4, 1, 1, self.width - 2, self.width - 2, color_bg)
	
	-- Setup text:
	surface.SetFont("inventory_text")
	surface.SetTextColor(color_text)
	
	-- Draw slot number:
	surface.SetTextPos(4, 4)
	surface.DrawText(self._slottxt)
	
	if self._sort == BP_WEP then
		if _2dm.Weapons[self._item] then	
			-- Draw the model:
			self:DrawModel()
			
			-- Name of the weapon:
			local txt = _2dm.Weapons[self._item].Title
			local w, h = surface.GetTextSize(txt)
			surface.SetTextPos(self.width/2 - w/2, self.width - h - 4)
			surface.DrawText(txt)

		end
	elseif self._sort == BP_GAD then
		if _2dm.gadgets[self._item] then	
			-- Draw the model:
			self:DrawModel()
			
			-- Name of the weapon:
			local txt = _2dm.gadgets[self._item].name
			local w, h = surface.GetTextSize(txt)
			surface.SetTextPos(self.width/2 - w/2, self.width - h - 4)
			surface.DrawText(txt)
		end
	end
	
	-- Check if we need to remove ourself:
	if not input.IsMouseDown(MOUSE_LEFT) then
		if self.invpanel.DragTo then
			-- Perform the swap:
			if self.mode == 1 then
				if self.invpanel.DragTo == -1 then
					-- Return to backpack:
					BackpackToSlot(0, self._pos)
				else
					SloToSlot(self._pos, self.invpanel.DragTo._slot)
				end
			else
				BackpackToSlot(self._pos, self.invpanel.DragTo._slot)
			end
			
			-- Reset dragging parent:
			self.invpanel.DragTo = nil
		end
		
		-- Remove highlighting:
		self.invpanel.drag_sort = -1
		
		-- Remvoe ourself:
		self:Remove()
	end
end

-- Stop entity rotation:
function PANEL:LayoutEntity(ent)
end

-- This is basically copy and paste from the base class, with some slight changes:
function PANEL:DrawModel()

if ( !IsValid( self.Entity ) ) then return end
	
	local x, y = self:LocalToScreen( 0, -self.ypos )
	
	self:LayoutEntity( self.Entity )
	
	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end
	
	local w, h = _2dm.model_width, _2dm.model_width
	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, 4096 )
	cam.IgnoreZ( true )
	
	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( self.colColor.a/255 )
	
	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end
		
	self.Entity:DrawModel()
	
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
	
	self.LastPaint = RealTime()
end

vgui.Register("D_invpanel_drag", PANEL, "DModelPanel")
