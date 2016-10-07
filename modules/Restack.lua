local P = unpack(select(2, ...))

local function Init(self)
	local Button = CreateFrame('Button', '$parentRestack', self)
	Button:SetPoint('TOPRIGHT', -9, -6)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', SortBags)
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

	P.Fire('PostCreateRestack', self)
end

P.AddModule(Init)
