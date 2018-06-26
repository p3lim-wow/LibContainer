local key = 'Inventory'
local name = INVENTORY_TOOLTIP -- "Inventory"
local index = 1 -- as low as possible

local filter = function(Slot)
	-- default path
	return true
end

LibContainer:AddCategory(index, key, name, filter)
