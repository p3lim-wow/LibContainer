local P = unpack(select(2, ...))

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

	local NormalTexture = Button.Texture
	NormalTexture:SetAllPoints()
	NormalTexture:SetAtlas('bags-button-autosort-up')

	local PushedTexture = Button:CreateTexture('$parentPushed', 'ARTWORK')
	PushedTexture:SetAllPoints()
	PushedTexture:SetAtlas('bags-button-autosort-down')

	local HighlightTexture = Button:CreateTexture('$parentPushed', 'ARTWORK')
	HighlightTexture:SetAllPoints()
	HighlightTexture:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
	HighlightTexture:SetBlendMode('ADD')

	Button:SetNormalTexture(NormalTexture)
	Button:SetPushedTexture(PushedTexture)
	Button:SetHighlightTexture(HighlightTexture)

	if(self == Backpack) then
		Button.tooltipText = L['Restack']
	elseif(self == BackpackBank) then
		Button.tooltipText = L['Restack Bank']
	else
		Button.tooltipText = L['Restack Reagent Bank']
	end
end

local function Init(self, isBank)
	CreateButton(self, 1, isBank)

	if(isBank) then
		CreateButton(BackpackBankContainerReagentBank, 1002, isBank)
	end

	P.Fire('PostCreateRestack', self)
end

Backpack:AddModule('Restack', Init, nil, true)
