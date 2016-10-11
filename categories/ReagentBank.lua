local categoryName = REAGENT_BANK -- "Reagent Bank"
local categoryIndex = 1002

local categoryFilter = function(bagID, slotID, itemID)
	if(IsReagentBankUnlocked()) then
		return bagID == -3
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
