--[[---------------------------------------------------------
Client/_Client.lua

 - Client Side part of the gamemode
---------------------------------------------------------]]--
--if SERVER then return end

-- Load files:
include("_settings.lua")		-- Contains settings that are needed
include("vgui/_vgui.lua")		-- Load custom VGUI elements
include("lane_changer.lua")		-- Lane changing code
include("view_controller.lua")	-- Controls our special view
include("fonts.lua")			-- All the fonts
include("hud.lua")				-- The Hud
include("weaponui.lua")			-- The weapon UI
include("scoreboard.lua")		-- The scoreboard
include("weapons.lua")			-- Weapon networking code
include("effects.lua")			-- Sexy looking effects
include("inventory.lua")		-- The inventory
include("bindings.lua")			-- Binds keys to shit
include("gadgets.lua")			-- Gadgets
include("blueprints.lua")		-- Blueprints
include("utilities.lua")		-- Utilities

-- Shit, possibly delete / finish:
include("materials.lua")
