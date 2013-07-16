--[[---------------------------------------------------------
server_settings.lua

 - Setup server side configuration
---------------------------------------------------------]]--

-- Setup key server variables:
RunConsoleCommand("hostname","Ash47's Dev Server")	-- Name of the server
RunConsoleCommand("sv_password","__protected_")		-- Server password
RunConsoleCommand("sv_region","5")					-- Set it to australian server

-- Stop annoying kicking:
RunConsoleCommand("sv_kickerrornum","0")

-- Server protection:
RunConsoleCommand("sv_lan","0")				-- Make it LAN only

-- Voice Stuff
RunConsoleCommand("sv_voiceenable","1")		-- Enable Voice
RunConsoleCommand("sv_alltalk","1")			-- Enable alltalk

-- Change gravity:
RunConsoleCommand("sv_gravity","450")

-- Ignore this line:
_2dm = _2dm or {}

-- Friendly fire:
_2dm.FF = false
