local P = unpack(select(2, ...))

local function Init(self)
	local Button = CreateFrame('Button', '$parentRestack', self)
	Button:SetPoint('TOPRIGHT', -8, -8)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', SortBags)
	self.Restack = Button

	local Texture = Button:CreateTexture('$parentTexture', 'ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
	Button.Texture = Texture

	P.Fire('PostCreateRestack', self)
end

P.AddModule(Init)
