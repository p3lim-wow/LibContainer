local L = LibContainer.locale

local name = 'Events'
local localizedName = L['World Events']
local index = 70

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
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

LibContainer:AddCategory(index, name, localizedName, filter)
