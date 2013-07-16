--[[---------------------------------------------------------
Client/VGUI/d_invpanel.lua

 - The inventory model things
---------------------------------------------------------]]--
if SERVER then return end

-- Color Settings:
local color_bg = Color(183, 183, 183, 183)
local color_outline = Color(0, 0, 0, 255)
local color_text = Color(0, 0, 0, 255)

local color_outline_selected = Color(0, 255, 0, 255)

local pan_width = 256
local pan_height = _2dm.bp_height - 24

-- Settings:
model_w = 256							-- How big the model will be
model_xo = pan_width/2 - model_w/2		-- Ceneter the model
model_yo = pan_height - model_w		-- Move the model to the bottom, no idea why such a weird multipler

local PANEL = {}

function PANEL:Init()
	-- Set the default camera angle:
	self:SetCamPos(Vector(0, 30, 0))
	self:SetLookAt(Vector(0, 0, 0))
	
	self.width = pan_width
	self.height = pan_height
	
	-- Set the size:
	self:SetSize(pan_width, pan_height)
	
	-- Set the pos of our model:
	self.ypos = self.height - self.width
	
	-- Set our slot to default:
	self._item = 0
	self._item_old = 0
	
	-- Initial invisible:
	self:SetVisible(false)
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
	if self._item_old ~= self._item or self._sort_old ~= self._sort then
		if self._sort == BP_WEP then
			-- A weapon:
			if _2dm.Weapons[self._item] then
				-- Apply the weapon model:
				self:SetModel(_2dm.weapon.models[_2dm.Weapons[self._item].modelnum])
				
				-- Update the old to be the new:
				self._item_old = self._item
			end
		elseif self._sort == BP_GAD then
			-- A gadget:
			if _2dm.gadgets[self._item] then
				-- Apply the weapon model:
				self:SetModel(_2dm.gadgets[self._item].model)
				
				-- Update the old to be the new:
				self._sort_old = self._sort
			end
		end
	end
end

-- Change which slot to look at:
function PANEL:SetItem(item, sort)
	-- Store the old slot:
	self._item_old = self._item
	self._sort_old = self._sort
	
	-- Store the slot:
	self._item = item
	self._sort = sort
	
	-- Update ourself:
	self:Update()
	
	-- Make ourself visible:
	self:SetVisible(true)
end

-- Used to set the offset position of ourself:
function PANEL:SetPlace(x, y)
	-- Update offsets:
	self.xo = x
	self.yo = y
	
	-- Make visible:
	self:SetVisible(true)
end

-- Render the title:
function PANEL:DrawTitle()
	if self._sort == BP_WEP then
		-- A weapon:
		local w, h = surface.GetTextSize(_2dm.Weapons[self._item].Title)
		surface.SetTextPos(self.width/2 - w/2, 4)
		surface.DrawText(_2dm.Weapons[self._item].Title)
		
		-- Change the yoffset:
		self.line_yo = h + 16
	elseif self._sort == BP_GAD then
		-- A Gadget:
		local w, h = surface.GetTextSize(_2dm.gadgets[self._item].name)
		surface.SetTextPos(self.width/2 - w/2, 4)
		surface.DrawText(_2dm.gadgets[self._item].name)
		
		-- Change the yoffset:
		self.line_yo = h + 16
	end
end

function PANEL:DrawLine(ltxt, rtxt)
	-- Grab the size of the RHS text:
	local w, h = surface.GetTextSize(rtxt)
	
	-- Left text:
	surface.SetTextPos(16, self.line_yo)
	surface.DrawText(ltxt)
	
	-- Right text:
	surface.SetTextPos(self.width -w - 16, self.line_yo)
	surface.DrawText(rtxt)
	
	-- Move to the next line:
	self.line_yo = self.line_yo + h + 4
end

-- Make it look nice:
function PANEL:Paint()
	-- Check for visiblity:
	if not(self.par) or (not self.par:IsVisible()) then self:SetVisible(false) return end
	
	-- Workout where to snap to:
	local x, y = self.par:GetPos()
	x = x + self.xo
	y = y + self.yo
	
	-- Snap into place:
	self:SetPos(x, y)
	
	-- Only show if there is something to preview:
	if not _2dm.Weapons[self._item] then self:SetVisible(false) return end
	
	-- Draw the background:
	draw.RoundedBox( 4, 0, 0, self.width, self.height, color_outline)
	draw.RoundedBox( 4, 1, 1, self.width - 2, self.height - 2, color_bg)
	
	-- Setup text:
	surface.SetFont("inventory_text")
	surface.SetTextColor(color_text)
	
	-- Draw the model:
	self:DrawModel()
	
	if self._sort == BP_WEP then
		self:DrawTitle()
		self:DrawLine("Damage", _2dm.Weapons[self._item].Primary.Damage)
		self:DrawLine("Accuracy", _2dm.Weapons[self._item].Primary.Accuracy)
		self:DrawLine("Fire Rate", 1/_2dm.Weapons[self._item].Primary.Delay)
		self:DrawLine("Magazine Size", _2dm.Weapons[self._item].Primary.ClipSize)
		self:DrawLine("Power", _2dm.Weapons[self._item].Primary.Force)
		self:DrawLine("Bullets / Shot", _2dm.Weapons[self._item].Primary.NumberofShots)
	elseif self._sort == BP_GAD then
		self:DrawTitle()
	end
end

-- Stop entity rotation:
function PANEL:LayoutEntity(ent)
end

-- This is basically copy and paste from the base class, with some slight changes:
function PANEL:DrawModel()

if ( !IsValid( self.Entity ) ) then return end
	
	local x, y = self:LocalToScreen( model_xo, model_yo )
	
	self:LayoutEntity( self.Entity )
	
	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end
	
	local w, h = model_w, model_w
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

vgui.Register("D_inv_info", PANEL, "DModelPanel")
