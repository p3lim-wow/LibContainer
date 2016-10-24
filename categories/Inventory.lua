local categoryName = INVENTORY_TOOLTIP -- "Inventory"

local categoryFilter = function(bagID, slotID)
	return true -- default path
end

Backpack:AddCategory(1, categoryName, 'Inventory', categoryFilter)
