--[[---------------------------------------------------------
Client/Fonts.lua

 - Contains all fonts
---------------------------------------------------------]]--
if SERVER then return end

-- HP Hud Text
surface.CreateFont("HudHP", {
	size = 24,
	weight = 0,
	antialias = true,
	shadow = false,
	font = "arial"
})

-- New HP Text
surface.CreateFont("HudNewHP", {
	size = 24,
	weight = 0,
	antialias = true,
	shadow = t,
	font = "arial",
	outline = true
})

-- Hud Level Font
surface.CreateFont("HudLevel", {
	size = 36,
	weight = 0,
	antialias = true,
	shadow = false,
	font = "arial"
})

-- Playername text above/below player ingame
surface.CreateFont("playername", {
	size = 24,
	weight = 0,
	antialias = true,
	shadow = true,
	font = "coolvetica"
})

-- Floating damage effect
surface.CreateFont("effect_damage", {
	size = 24,
	weight = 0,
	antialias = true,
	shadow = false,
	font = "arial"
})

-- Text on inventory items:
surface.CreateFont("inventory_text", {
	size = 16,
	weight = 0,
	antialias = true,
	shadow = false,
	font = "arial"
})

-- Text for repspawn timer:
surface.CreateFont("RespawnTimer", {
	size = 32,
	weight = 40,
	antialias = true,
	shadow = true,
	font = "arial"
})

-- Text for bitching messages on teh screen:
surface.CreateFont("BitchPlease", {
	size = 120,
	weight = 20,
	antialias = true,
	shadow = true,
	font = "arial"
})
