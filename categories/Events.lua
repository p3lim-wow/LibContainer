local key = 'Events'
local name = BATTLE_PET_SOURCE_7 -- "World Events"
local index = 70

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot.itemID]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		local itemClass = Slot:GetItemClass()
		if(itemClass == LE_ITEM_CLASS_QUESTITEM) then
			-- quest items that is not part of, or starts, a quest can be considered holiday related
			return not Slot:GetItemQuestID() and not Slot:IsItemQuestItem()
		elseif(itemClass == LE_ITEM_CLASS_MISCELLANEOUS and Slot:GetItemSubClass() == 3) then
			-- holiday crap
			return true
		end
	end
end

LibContainer:AddCategory(index, key, name, filter)
