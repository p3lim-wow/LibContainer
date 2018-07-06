local L = LibContainer.locale

local name = 'Equipment'
local localizedName = L['Equipment']
local index = 30

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
	else
		if(Slot:GetItemQuality() >= LE_ITEM_QUALITY_UNCOMMON) then
			local itemClass = Slot:GetItemClass()
			if(itemClass == LE_ITEM_CLASS_WEAPON or itemClass == LE_ITEM_CLASS_ARMOR) then
				return true
			elseif(itemClass == LE_ITEM_CLASS_GEM and Slot:GetItemSubClass() == 11) then
				return true
			end
		end
	end
end

LibContainer:AddCategory(index, name, localizedName, filter)
