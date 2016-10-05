local categoryName = ITEM_QUALITY6_DESC -- "Artifact"
local categoryIndex = 10

local scanTipName = (...) .. 'ScanTip' .. math.floor(GetTime())
local scanTip = CreateFrame('GameTooltip', scanTipName)
scanTip:SetOwner(WorldFrame, 'ANCHOR_NONE')

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	else
		scanTip:SetBagItem(bagID, slotID)
		scanTip:Show()

		local line = _G[scanTipName .. 'TextLeft2']
		return line and line:GetText() == ARTIFACT_POWER -- "Artifact Power"
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
