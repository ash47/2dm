--[[---------------------------------------------------------
Client/VGUI/d_blueprint_bot.lua

 - The blueprint things on the bottom of the screen
---------------------------------------------------------]]--
if SERVER then return end

-- Color Settings:
local color_bg = Color(183, 183, 183, 183)
local color_outline = Color(0, 0, 0, 255)
local color_text = Color(0, 0, 0, 255)

local color_outline_draggable = Color(0, 0, 255, 255)
local color_outline_selected = Color(0, 255, 0, 255)

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
	
	-- Change the cursor:
	--self:SetCursor("hand");
	
	-- Set our slot to default:
	self._slot = 0
	self._slot_old = 0
	self._slottxt = "0"
	self._bp_pos = -1
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
function PANEL:Update()
	-- Only update if we need to:
	if self._slot_old ~= self._slot then
		if _2dm.BluePrints[self._slot] then
			-- Apply the weapon model:
			self:SetModel(_2dm.BluePrints[self._slot].model)
			
			-- Update the old to be the new:
			self._slot_old = self._slot
			self._sort_old = self._sort
		end
	end
end

-- Change which slot to look at:
function PANEL:SetSlot(slot, backpack_pos)
	-- Store the old slot:
	self._slot_old = self._slot
	
	-- Store the slot:
	self._slot = slot
	
	-- Store the backpack pos:
	self._bp_pos = backpack_pos
	
	-- Apply slot title:
	--self._slottxt = _2dm.slot_labels[slot]
	
	-- Update ourself:
	self:Update()
end

-- When the panel is hovered:
function PANEL:OnCursorEntered()
	-- Update weapon viewer:
	--_2dm.Inventory.inl:SetItem(_2dm.Slot[self._slot], self._sort)
end

-- When the panel stops being hovered:
function PANEL:OnCursorExited()
	-- Check if we are allowed to remove weapon viewer:
	--if _2dm.Slot[self._slot] == _2dm.Inventory.inl._item then
		-- Remove weapon viewer:
	--	_2dm.Inventory.inl:SetItem(0)
	--end
end

-- When the panel is pressed:
function PANEL:OnMousePressed(btn)
	if btn == MOUSE_LEFT then
		net.Start("bp_place")
		net.WriteInt(self._bp_pos, 16)
		net.SendToServer()
	end
	
	--[[local par = self:GetParent()
	
	if btn == MOUSE_LEFT then
		if par.dragging == 0 then
			-- Start dragging:
			par.dx, par.dy = gui.MousePos()
			par.dragging = 1
			
			par.drag = function()
				-- Create a drag:
				local a = vgui.Create("D_invpanel_drag")
				a.invpanel = self:GetParent()
				
				-- Stop from selecting self:
				a.fail = self
				
				-- Update it:
				a:Update(_2dm.Slot[self._slot], self._slot, self._sort, 1)
				
				-- Make it visible:
				a:MakePopup()
			end
			
			par.dragfail = function()
				_2dm.Inventory.inr:SetItem(_2dm.Slot[self._slot], self._sort)
			end
		end
	end]]--
	
end

-- Make it look nice:
function PANEL:Paint()
	-- Outline color:
	local c_outline = color_outline
	
	-- Grab our parent:
	local par = self:GetParent()
	
	-- If we are allowed to drag to:
	--[[if par.drag_sort == self._sort then
		c_outline = color_outline_draggable
	end]]--
	
	-- Drag and drop glow:
	--[[if par.DragTo and par.DragTo == self then
		c_outline = color_outline_selected
	end]]--
	
	-- Draw the background:
	draw.RoundedBox( 4, 0, 0, self.width, self.width, c_outline)
	draw.RoundedBox( 4, 1, 1, self.width - 2, self.width - 2, color_bg)
	
	-- Setup text:
	surface.SetFont("inventory_text")
	surface.SetTextColor(color_text)
	
	-- Draw slot number:
	--surface.SetTextPos(4, 4)
	--surface.DrawText(self._slottxt)
	
	if _2dm.BluePrints[self._slot] then	
		-- Draw the model:
		self:DrawModel()
		
		-- Name of the blueprint:
		local txt = _2dm.BluePrints[self._slot].name or ""
		local w, h = surface.GetTextSize(txt)
		surface.SetTextPos(self.width/2 - w/2, self.width - h - 4)
		surface.DrawText(txt)

	end
end


-- This is basically copy and paste from the base class, with some slight changes:
function PANEL:DrawModel()

if ( !IsValid( self.Entity ) ) then return end
	local x, y = self:LocalToScreen( 0, -self.ypos )
	
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

vgui.Register("D_blueprint_bot", PANEL, "DModelPanel")
