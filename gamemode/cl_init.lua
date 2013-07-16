--[[---------------------------------------------------------
cl_init.lua

 - Load Client Side Files
---------------------------------------------------------]]--

-- Load shared settings:
include("shared_settings.lua")

-- Load the shared content:
include("shared/_shared.lua")

-- Load the gamemode:
include("client/_client.lua")

if SERVER then return end
