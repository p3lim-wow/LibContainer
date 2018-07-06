local L = LibContainer.locale

local name = 'ReagentBank'
local localizedName = L['Reagent Bank']
local index = 999 -- as high as possible

local filter = function(Slot)
	-- default path for reagent bank items, not allowing custom items here
	local bagID = Slot:GetBagAndSlot()
	return IsReagentBankUnlocked() and bagID == REAGENTBANK_CONTAINER
end

LibContainer:AddCategory(index, name, localizedName, filter)
