local P = unpack(select(2, ...))

local function OnClick(self)
	local Container = P.GetCategoryContainer(self.parentContainer, 1001)
	for _, Slot in next, Container.slots do
		local itemID = Slot.itemID
		BackpackKnownItems[itemID] = true
		BackpackCustomCategory[itemID] = nil
	end

	P.UpdateAllSlots('ResetNew')
	P.PositionSlots()
end

local function Init(self)
	local Parent = _G[self:GetName() .. 'ContainerNewItems']

	local Button = CreateFrame('Button', '$parentResetNew', Parent)
	Button:SetPoint('TOPRIGHT', -8, -8)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', OnClick)
	Button.parentContainer = self
	self.ResetNew = Button

	local Texture = Button:CreateTexture('$parentTexture', 'ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexture([[Interface\Buttons\UI-RefreshButton]])
	Button.Texture = Texture

	P.Fire('PostCreateResetNew', self)
end

P.AddModule(Init, nil, true)
