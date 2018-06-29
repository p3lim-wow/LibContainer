local L = LibContainer.locale

local key = 'Consumables'
local name = L['Consumables']
local index = 41

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		local itemClass = Slot:GetItemClass()
		local itemSubClass = Slot:GetItemSubClass()
		if(itemClass == LE_ITEM_CLASS_CONSUMABLE and itemSubClass >= 1) then
			-- consumables other than engineering explosives and devices, they're considered profession related
			if(itemSubClass ~= 8) then
				-- but not consumables in the "other" subclass
				return true
			end
		elseif(itemClass == LE_ITEM_CLASS_ITEM_ENHANCEMENT) then
			-- enchants, armor kits etc
			return true
		end
	end
end

LibContainer:AddCategory(index, key, name, filter)
