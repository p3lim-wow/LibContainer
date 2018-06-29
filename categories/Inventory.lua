local L = LibContainer.locale

local key = 'Inventory'
local name = L['Inventory']
local index = 1 -- as low as possible

local filter = function(Slot)
	-- default path
	return true
end

LibContainer:AddCategory(index, key, name, filter)
