local L = LibContainer.locale

local key = 'New'
local name = L['New Items']
local index = 997 -- as high as possible

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		-- don't mark junk as new
		return Slot:GetItemQuality() > LE_ITEM_QUALITY_POOR
	end
end

LibContainer:AddCategory(index, key, name, filter)
