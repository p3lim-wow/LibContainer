local setCategoryName = strsplit(':', EQUIPMENT_SETS) -- "Equipment Sets"
local setCategoryIndex = 31

local function setCategoryFilter(bagID, slotID, itemID)
	local isInSet = GetContainerItemEquipmentSetInfo(bagID, slotID)
	return isInSet
end

Backpack:AddCategory(setCategoryIndex, setCategoryName, setCategoryFilter)



local gearCategoryName = BAG_FILTER_EQUIPMENT -- "Equipment"
local gearCategoryIndex = 30

local gearCategoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == gearCategoryIndex) then
		return true
	elseif(not custom) then
		if(itemID) then
			local itemName, _, itemQuality, _, _, _, _, _, _, _, _, itemClass = GetItemInfo(itemID)
			if(itemName and itemQuality >= LE_ITEM_QUALITY_UNCOMMON) then
				return itemClass == 2 or itemClass == 4
			end
		end
	end
end

Backpack:AddCategory(gearCategoryIndex, gearCategoryName, gearCategoryFilter)
