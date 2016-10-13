local categoryName = REAGENT_BANK -- "Reagent Bank"
local categoryIndex = 1002

local categoryFilter = function(bagID, slotID, itemID)
	if(IsReagentBankUnlocked()) then
		return bagID == -3
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)

local function ShowDepositReagentsTooltip(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	GameTooltip:SetText(REAGENTBANK_DEPOSIT)
	GameTooltip:Show()
end

Backpack:AddModule('DepositReagents', function()
	local Button = CreateFrame('Button', '$parentDepositReagents', BackpackBankContainerReagentBank)
	Button:SetPoint('TOPRIGHT', -8, -6)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', DepositReagentBank)
	Button:SetScript('OnEnter', ShowDepositReagentsTooltip)
	Button:SetScript('OnLeave', GameTooltip_Hide)

	local Texture = Button:CreateTexture('$parentTexture', 'ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
end)
