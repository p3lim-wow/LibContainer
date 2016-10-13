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

local function UpdateVisibility(_, visiting)
	BackpackBank.Restack:SetShown(P.atBank or visiting)
	BackpackBankContainerReagentBank.Restack:SetShown(P.atBank or visiting)
end

local function Update()
	UpdateVisibility(nil, true)
end

local function ShowTooltip(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	GameTooltip:SetText(self.tooltipText)
	GameTooltip:Show()
end

local function CreateButton(self)
	local Button = CreateFrame('Button', '$parentRestack', self)
	Button:SetPoint('TOPRIGHT', -9, -6)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', Restack)
	Button:SetScript('OnEnter', ShowTooltip)
	Button:SetScript('OnLeave', GameTooltip_Hide)
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

	if(self == Backpack) then
		Button.tooltipText = BAG_CLEANUP_BAGS
	elseif(self == BackpackBank) then
		Button.tooltipText = BAG_CLEANUP_BANK
	else
		Button.tooltipText = BAG_CLEANUP_REAGENT_BANK
	end
end

local function Init(self)
	CreateButton(self)

	if(self == BackpackBank) then
		CreateButton(BackpackBankContainerReagentBank)

		self:HookScript('OnShow', UpdateVisibility)
	end

	P.Fire('PostCreateRestack', self)
end

Backpack:AddModule('Restack', Init, Update, true, 'BANKFRAME_OPENED')
