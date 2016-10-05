-- custom list of any items that provide teleporting, because they deserve their own category

local teleporters = {
	129276, -- Beginner's Guide to Dimensional Rifting
	141605, -- Flight Master's Whistle
	140192, -- Dalaran Hearthstone
	110560, -- Garrison Hearthstone
	6948, -- Hearthstone
}

-- just so I can list them neater
local temp = {}
for _, itemID in next, teleporters do
	temp[itemID] = true
end
teleporters = temp

local categoryName = "Teleporters"
local categoryIndex = 60

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local itemID = GetContainerItemID(bagID, slotID)
		return teleporters[itemID]
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
