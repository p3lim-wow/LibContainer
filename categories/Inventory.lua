local L = select(2, ...)[3]

local categoryName = L['Inventory']

local categoryFilter = function(bagID, slotID)
	return true -- default path
end

Backpack:AddCategory(1, categoryName, 'Inventory', categoryFilter)
