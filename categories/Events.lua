local L = select(2, ...)[3]

local categoryName = L['World Event']
local categoryIndex = 70

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local _, _, _, _, _, itemClass, itemSubClass = GetItemInfoInstant(itemID)
		if(itemClass == LE_ITEM_CLASS_QUESTITEM) then
			-- quest items that is not part of, or starts, a quest can be considered holiday related
			local isQuest, questID = Backpack:GetContainerItemQuestInfo(bagID, slotID)
			if(not questID and not isQuest) then
				return true
			end
		elseif(itemClass == LE_ITEM_CLASS_MISCELLANEOUS and itemSubClass == 3) then
			-- holiday crap
			return true
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, 'WorldEvents', categoryFilter)
