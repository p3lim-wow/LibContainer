local P, E, L = unpack(select(2, ...))

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

local function ShowAutoDepositTooltip(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	GameTooltip:SetText(L['Toggle auto-deposit'])
	GameTooltip:Show()
end

local function ToggleAutoDeposit(self)
	BackpackDB.autodeposit = not BackpackDB.autodeposit
	BackpackBankContainerReagentBank.AutoDeposit:GetNormalTexture():SetDesaturated(not BackpackDB.autodeposit)
end

local function AutoDepositUpdate()
	if(BackpackDB.autodeposit and not IsShiftKeyDown()) then
		DepositReagentBank()
	end
end

local function AutoDepositInit()
	local self = BackpackBankContainerReagentBank
	local Button = CreateFrame('Button', '$parentAutoDeposit', self)
	Button:SetPoint('TOPRIGHT', -30, -6)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', ToggleAutoDeposit)
	Button:SetScript('OnEnter', ShowAutoDepositTooltip)
	Button:SetScript('OnLeave', GameTooltip_Hide)

	local Texture = Button:CreateTexture('$parentTexture', 'ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
	Texture:SetDesaturated(not BackpackDB.autodeposit)
	Button:SetNormalTexture(Texture)

	self.AutoDeposit = Button
end

Backpack:AddModule('AutoDeposit', AutoDepositInit, AutoDepositUpdate, false, 'BANKFRAME_OPENED')
