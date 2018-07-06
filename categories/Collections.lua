local L = LibContainer.locale

local name = 'Collections'
local localizedName = L['Collections']
local index = 80

local scanTip = CreateFrame('GameTooltip', 'LibContainerScanTip' .. math.floor(GetTime()), nil, 'GameTooltipTemplate')
scanTip:SetOwner(WorldFrame, 'ANCHOR_NONE')
local scanTipName = scanTip:GetName()

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
	else
		local itemClass = Slot:GetItemClass()
		if(itemClass == LE_ITEM_CLASS_BATTLEPET) then
			-- caged battlepets
			return true
		elseif(itemClass == LE_ITEM_CLASS_MISCELLANEOUS) then
			local itemSubClass = Slot:GetItemSubClass()
			if(itemSubClass == 2 or itemSubClass == 5) then
				-- uncaged battlepets and mounts
				return true
			elseif(itemSubClass == 4) then
				-- toys
				-- return not not (C_ToyBox.GetToyInfo(Slot:GetItemID())) -- returns data for non-toys, confirmed will be fixed soon™
				scanTip:SetBagItem(Slot:GetBagAndSlot())
				scanTip:Show()

				for index = 1, scanTip:NumLines() do
					local line = _G[scanTipName .. 'TextLeft' .. index]
					if(line and line:GetText() == TOY) then -- "Toy"
						return true
					end
				end
			end
		end
	end
end

LibContainer:AddCategory(index, name, localizedName, filter)
