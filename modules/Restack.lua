local P = unpack(select(2, ...))

local function Restack(self)
	if(self:GetParent() == Backpack) then
		SortBags()
	elseif(self:GetParent() == BackpackBank) then
		SortBankBags()
	else
		SortReagentBankBags()
	end
end

local function CreateButton(self)
	local Button = CreateFrame('Button', '$parentRestack', self)
	Button:SetPoint('TOPRIGHT', -9, -6)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', Restack)
	self.Restack = Button

	local NormalTexture = Button:CreateTexture('$parentNormal', 'ARTWORK')
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
end

local function Init(self)
	CreateButton(self)

	if(self == BackpackBank) then
		CreateButton(BackpackBankContainerReagentBank)
	end

	P.Fire('PostCreateRestack', self)
end

P.AddModule(Init, nil, true)
