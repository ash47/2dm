--[[---------------------------------------------------------
shared/items/_itemloader.lua

 - Loads items
 - Loads weapons
---------------------------------------------------------]]--

-- Ensure our global exists:
_2dm = _2dm or {}

-- Store the slot names:
_2dm.slot_labels = {"Primary", "Secondary", "Thrown", "Gadget", "Blueprint"}

-- Weapons table:
_2dm.Weapons = _2dm.Weapons or {}

-- Item table:
_2dm.Items = _2dm.Items or {}

-- Location to the items folder:
local item_path = "shared/items/"

-- We are not loading by default:
local loading = false

-- Stores the shit we are currently editing:
local editing_slot = {}

-- Returns weather or not we are loading weapons, this is used for live reload shit:
function item_loading()
	return loading
end

local function get_id(name)
	local a = string.Explode("_", name)[1]
	
	-- Return error for invalid shit:
	if(a == "") then
		a = -1
	end
	
	return tonumber(a)
end

-- Loads a file:
local function load_file(fname)
	-- Create new table:
	local store = {}
	
	-- Reset the editing slot:
	editing_slot = store
	
	-- Include the file:
	include(fname)
	
	-- Return the editing slot:
	return store
end

-- Loads a directory:
local function load_dir(path, local_path)
	local store = {}
	
	-- Check for a settings file:
	if(file.Exists(path.."_settings.lua", "LUA")) then
		store = load_file(local_path.."_settings.lua")
	end
	
	-- Find shit:
	local files, directories = file.Find( path.."*", "LUA" )
	
	-- Load directories:
	for k,v in pairs(directories) do
		local a = get_id(v)
		
		-- Make sure we have a proper thing:
		if(a > 0) then
			-- Load this directory:
			store[a] = load_dir(path..v.."/", local_path..v.."/")
		end
	end
	
	-- Load Files:
	for k,v in pairs(files) do
		local a = get_id(v)
		
		-- Make sure we have a proper thing:
		if(a > 0) then
			-- Load this directory:
			store[a] = load_file(local_path..v)
		end
	end
	
	return store
end

-- Reload shit:
function item_reload()
	-- We are loading:
	loading = true
	
	-- Create the items table:
	_2dm.Items = load_dir(PATH..item_path, "/")
	
	PrintTable(_2dm.Items)
	
	-- We are done loading:
	loading = false
end

-- Sets the type of item this is:
function item_set_type(s)
	editing_slot.item_type = s
end

-- Ask for an item reload:
item_reload()
