local L = LibContainer.locale

local key = 'Junk'
local name = L['Junk']
local index = 998 -- as high as possible

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		if(IsArtifactPowerItem(Slot:GetItemID())) then
			-- Crucible's Promise makes AP items useless
			return (select(13, GetAchievementInfo(12071)))
		else
			return Slot:GetItemQuality() == LE_ITEM_QUALITY_POOR
		end
	end
end

local sort = function(slotA, slotB)
	return (slotA:GetItemValue() * slotA:GetItemCount()) > (slotB:GetItemValue() * slotB:GetItemCount())
end

LibContainer:AddCategory(index, key, name, filter, sort)
