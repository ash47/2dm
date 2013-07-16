--[[---------------------------------------------------------
Shared/sHared.lua

 - All the shared stuff
 - Team info
---------------------------------------------------------]]--

-- General information
GM.Version = "WiP"
GM.Name = "2D Madness "..GM.Version
GM.Author = "Ash47 (STEAM_0:0:14045128)"

-- Load Shared files:
include("items/_itemloader.lua")	-- Item loading system
include("teams.lua")				-- Teams
include("gm_funcs.lua")				-- Gamemode functions
include("weapons.lua")				-- Weapon related poo
include("utilities.lua")			-- Useful functions
include("inventory.lua")			-- Inventory shit
include("gadgets.lua")				-- Gadgets
include("blueprints.lua")			-- Blueprints
