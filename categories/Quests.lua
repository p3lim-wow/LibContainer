local key = 'Quests'
local name = AUCTION_CATEGORY_QUEST_ITEMS -- "Quest Items"
local index = 20

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot.itemID]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		-- any item that is part of, or starts, a quest
		return Slot:GetItemQuestID() or Slot:IsItemQuestItem()
	end
end

LibContainer:AddCategory(index, key, name, filter)
