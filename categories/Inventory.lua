local P, E, L = unpack(select(2, ...))

local categoryName = L['Inventory']

local categoryFilter = function(bagID, slotID)
	return true -- default path
end

P.AddCategory(1, categoryName, 'Inventory', categoryFilter)
