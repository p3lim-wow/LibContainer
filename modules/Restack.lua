local P, E, L = unpack(select(2, ...))

local function OnClick(self)
	if(self:GetParent() == Backpack) then
		SortBags()
	elseif(self:GetParent() == BackpackBank) then
		SortBankBags()
	else
		SortReagentBankBags()
	end
end

local function CreateButton(self, categoryIndex, isBank)
	local Button = P.CreateContainerButton('Restack', categoryIndex, isBank)
	Button:SetScript('OnClick', OnClick)
	self.Restack = Button

	if(self == Backpack) then
		Button.tooltipText = L['Restack']
	elseif(self == BackpackBank) then
		Button.tooltipText = L['Restack Bank']
	else
		Button.tooltipText = L['Restack Reagent Bank']
	end

	return Button
end

local function Init(self, isBank)
	local Button = CreateButton(self, 1, isBank)

	local ReagentBankButton
	if(isBank) then
		ReagentBankButton = CreateButton(BackpackBankContainerReagentBank, 1002, isBank)
	end

	P.Fire('PostCreateRestack', Button, ReagentBankButton)
end

Backpack:AddModule('Restack', Init, nil, true)
