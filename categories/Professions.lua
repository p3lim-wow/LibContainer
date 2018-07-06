local L = LibContainer.locale

local name = 'Professions'
local localizedName = L['Professions']
local index = 50

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
	else
		local itemClass = Slot:GetItemClass()
		local itemSubClass = Slot:GetItemSubClass()
		if(itemClass == LE_ITEM_CLASS_CONSUMABLE and itemSubClass == 0) then
			-- engineering explosives and devices
			return true
		elseif(itemClass == LE_ITEM_CLASS_RECIPE) then
			return true
		elseif(itemClass == LE_ITEM_CLASS_CONTAINER and itemSubClass ~= 1) then
			-- profession bags
			return true
		end
	end
end

LibContainer:AddCategory(index, name, localizedName, filter)
