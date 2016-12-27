local P, E, L = unpack(select(2, ...))

local categoryName = L['Reagent Bank']
local categoryIndex = 1002

local categoryFilter = function(bagID, slotID, itemID)
	if(IsReagentBankUnlocked()) then
		return bagID == -3
	end
end

P.AddCategory(categoryIndex, categoryName, 'ReagentBank', categoryFilter)

local function ShouldShow(self, atBank)
	if(self.hideOfflineBank) then
		if(IsReagentBankUnlocked() and atBank) then
			return true
		end
	else
		return true
	end
end

Backpack:AddModule('DepositReagents', function(self)
	local Button = P.CreateContainerButton('DepositReagents', categoryIndex, true)
	Button:SetScript('OnClick', DepositReagentBank)
	Button.tooltipText = L['Deposit All Reagents']
	Button.overrideShouldShow = ShouldShow
	self.DepositReagents = Button

	P.Fire('PostCreateDepositReagents', Button)
end)

local function AutoDepositOnClick(self)
	BackpackDB.autoDepositReagents = not BackpackDB.autoDepositReagents
end

Backpack:AddModule('AutoDeposit', function(self)
	local Button = P.CreateContainerButton('AutoDeposit', categoryIndex, true)
	Button:SetScript('OnClick', AutoDepositOnClick)
	Button.tooltipText = L['Toggle auto-deposit']
	Button.overrideShouldShow = function()
		return true
	end
	BackpackBankContainerReagentBank.AutoDeposit = Button

	P.Fire('PostCreateAutoDeposit', Button)
end, function()
	if(BackpackDB.autoDepositReagents and not IsShiftKeyDown() and IsReagentBankUnlocked()) then
		DepositReagentBank()
	end
end, false, 'BANKFRAME_OPENED')

local function PurchaseReagentBankOnClick()
	StaticPopup_Show('CONFIRM_BUY_REAGENTBANK_TAB')
end

Backpack:AddModule('PurchaseReagentBank', function()
	local self = BackpackBankContainerReagentBank
	local Button = CreateFrame('Button', '$parentPurchaseReagentBank', self, 'UIPanelButtonTemplate')
	Button:SetPoint('CENTER')
	Button:SetText(L['Purchase'])
	Button:SetWidth(Button:GetTextWidth() + 40)
	Button:SetScript('OnClick', PurchaseReagentBankOnClick)
	self.PurchaseReagentBank = Button

	if(IsReagentBankUnlocked()) then
		Button:Hide()
	end
end, function()
	BackpackBankContainerReagentBank.PurchaseReagentBank:Hide()
end, false, 'REAGENTBANK_PURCHASED')
