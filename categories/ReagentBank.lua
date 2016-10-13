local P, E, L = unpack(select(2, ...))

local categoryName = REAGENT_BANK -- "Reagent Bank"
local categoryIndex = 1002

local categoryFilter = function(bagID, slotID, itemID)
	if(IsReagentBankUnlocked()) then
		return bagID == -3
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)


Backpack:AddModule('DepositReagents', function(self)
	local Button = P.CreateContainerButton('DepositReagents', categoryIndex, true)
	Button:SetScript('OnClick', DepositReagentBank)
	Button.tooltipText = REAGENTBANK_DEPOSIT

	Button.Texture:SetDesaturated(not BackpackDB.autoDepositReagents)
	self.DepositReagents = Button

	P.Fire('PostCreateAutoDeposit', Button)
end)

local function OnClick(self)
	BackpackDB.autoDepositReagents = not BackpackDB.autoDepositReagents
	BackpackBankContainerReagentBank.AutoDeposit.Texture:SetDesaturated(not BackpackDB.autoDepositReagents)
end

Backpack:AddModule('AutoDeposit', function(self)
	local Button = P.CreateContainerButton('AutoDeposit', categoryIndex, true)
	Button:SetScript('OnClick', OnClick)
	Button.tooltipText = L['Toggle auto-deposit']

	Button.Texture:SetDesaturated(not BackpackDB.autoDepositReagents)
	BackpackBankContainerReagentBank.AutoDeposit = Button

	P.Fire('PostCreateAutoDeposit', Button)
end, function()
	if(BackpackDB.autoDepositReagents and not IsShiftKeyDown() and IsReagentBankUnlocked()) then
		DepositReagentBank()
	end
end)
