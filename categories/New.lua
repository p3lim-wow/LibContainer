local L = LibContainer.locale

local name = 'New'
local localizedName = L['New Items']
local index = 997 -- as high as possible

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
	else
		-- don't mark junk as new
		return Slot:GetItemQuality() > LE_ITEM_QUALITY_POOR
	end
end

LibContainer:AddCategory(index, name, localizedName, filter)
