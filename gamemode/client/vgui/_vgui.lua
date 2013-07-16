--[[---------------------------------------------------------
Client/VGUI/_VGUI.lua

 - Load all custom VGUIs
---------------------------------------------------------]]--
--if SERVER then return end

include("d_invpanel.lua")		-- Inventory model panels
include("d_invpanel_drag.lua")	-- A dragging special inventory panel
include("d_inv_info.lua")		-- The thingo that shows info about guns
include("d_blueprint_bot.lua")	-- The blueprints down the bottom of the screen
