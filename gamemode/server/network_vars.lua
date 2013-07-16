--[[---------------------------------------------------------
Server/network_vars.lua

 - All network variables
 - What each var does
---------------------------------------------------------]]--

-- Server ==> Client || Client ==> Server

-- Usermessages:
util.AddNetworkString("F4")				-- F4 has been pressed						|| N/A
util.AddNetworkString("F2")				-- F2 has been pressed						|| N/A

util.AddNetworkString("ApplyWeapon")	-- Apply weapon settings to a weapon		|| Apply a weapon
util.AddNetworkString("SendWeapon")		-- Sending a weapons						|| N/A
util.AddNetworkString("DamageEffect")	-- Sending a damage effect					|| N/A

util.AddNetworkString("LaneChanger")	-- Sending lane changing info				|| N/A

util.AddNetworkString("SendSlots")		-- Sending the contents of a slot			|| N/A

util.AddNetworkString("ToggleSlot")		-- Sending the active slot					|| Toggle active slot plux

util.AddNetworkString("Backpack")		-- Sending an entire backpack				|| N/A
util.AddNetworkString("BackpackToSlot")	-- N/A										|| Backpack item goes into a slot
util.AddNetworkString("SwapSlots")		-- N/A										|| Change the contents of two slots


-- Shit for bindings:
util.AddNetworkString("+undo")			-- N/A										|| Client presses undo
util.AddNetworkString("-undo")			-- N/A										|| Client releases undo

-- Gadget Shit:
util.AddNetworkString("GadgetState")	-- Sending gadget on/off					|| N/A
util.AddNetworkString("SendGadget")		-- Sending a gadget							|| N/A

-- Blueprint Shit:
util.AddNetworkString("SendBluePrint")	-- Sendinga blueprint						|| N/A
util.AddNetworkString("bp_place")		-- N/A										|| Dragging out a blueprint...
util.AddNetworkString("bp_cancel")		-- N/A										|| Cancel the creation of a blueprint
util.AddNetworkString("bp_pos")			-- N/A										|| Updating the position of the spawned object
util.AddNetworkString("bp_rot")			-- N/A										|| Rotating a blueprint


util.AddNetworkString("max_hp_shield")	-- Sending max hp/shield					|| N/A

