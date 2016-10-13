local P, E, L = unpack(select(2, ...))

local categoryName = L['Erroneous']

local categoryFilter = function(bagID, slotID)
	-- This will hold any items that are not retrieving information
	local itemLink = Backpack:GetContainerItemLink(bagID, slotID)
	return not itemLink
end

Backpack:AddCategory(2, categoryName, categoryFilter)
