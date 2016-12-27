local P, E, L = unpack(select(2, ...))

local defaults = {
	autoSellJunk = false,
	autoDepositReagents = false,
	bankmodifier = 0,
}

local Options = LibStub('Wasabi'):New(P.name, 'BackpackDB', defaults)
Options:AddSlash('/bp')
Options:AddSlash('/backpack')
Options:Initialize(function(self)
	local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 20, -16)
	Title:SetText(P.name)

	local BankModifier = self:CreateDropDown('bankmodifier')
	BankModifier:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 24, -10)
	BankModifier:SetText(L['Modifier to show bank when toggling Backpack'])
	BankModifier:SetValues({
		[0] = NONE,
		IsAltKeyDown = ALT_KEY,
		IsControlKeyDown = CTRL_KEY,
		IsShiftKeyDown = SHIFT_KEY,
	})
end)

local categories = {categories={}} -- Gets populated by the core on first load

local Categories = Options:CreateChild('Categories', 'BackpackCategoriesDB', categories)
Categories:Initialize(function(self)
	local Description = self:CreateDescription()
	Description:SetPoint('TOPLEFT', 20, -16)
	Description:SetFontObject('GameFontNormalMed1')
	Description:SetText(L['Here you can toggle categories or even create new ones!'])

	local Items = self:CreateObjectContainer('categories')
	Items:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', -20, -16)
	Items:SetSize(self:GetWidth(), 500)
	Items:SetObjectSize(self:GetWidth() - 20, 25)
	Items:SetObjectSpacing(2)

	local OnDeleteEnter = function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		GameTooltip:SetText(DELETE)
	end

	local OnDeleteClick = function(self)
		self:GetParent():Remove()
	end

	local OnToggleEnter = function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		GameTooltip:SetText(self:GetChecked() and DISABLE or ENABLE)
	end

	local OnToggleClick = function(self)
		local categoryIndex = self:GetParent().key
		BackpackCategoriesDB.categories[categoryIndex].enabled = not BackpackCategoriesDB.categories[categoryIndex].enabled

		-- Have to create containers if they don't exist
		if(not P.HasContainer(Backpack, categoryIndex)) then
			P.CreateContainer(P.categories[categoryIndex], Backpack)
		end

		if(not P.HasContainer(BackpackBank, categoryIndex)) then
			P.CreateContainer(P.categories[categoryIndex], BackpackBank)
		end

		P.UpdateAllSlots('CategoriesToggle')
		P.PositionSlots()

		OnToggleEnter(self) -- Update tooltip
	end

	Items:On('ObjectCreate', function(self, event, Object)
		Object:EnableMouse(false)

		local Background = Object:CreateTexture()
		Background:SetAllPoints()
		Background:SetColorTexture(1, 1, 1, 0.1)
		Object:SetNormalTexture(Background)

		local Name = Object:CreateFontString(nil, nil, 'GameFontHighlightSmallLeft')
		Name:SetPoint('LEFT', 5, 0)
		Object:SetFontString(Name)

		local Delete = CreateFrame('Button', nil, Object)
		Delete:SetPoint('RIGHT', -10, 0)
		Delete:SetSize(16, 16)
		Delete:EnableMouse(true)
		Delete:SetScript('OnClick', OnDeleteClick)
		Delete:SetScript('OnEnter', OnDeleteEnter)
		Delete:SetScript('OnLeave', GameTooltip_Hide)
		Object.Delete = Delete

		local DeleteDisabled = Delete:CreateTexture()
		DeleteDisabled:SetAllPoints()
		DeleteDisabled:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
		DeleteDisabled:SetDesaturated(true)

		Delete:SetNormalTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
		Delete:SetDisabledTexture(DeleteDisabled)
		Delete:SetPushedTexture([[Interface\Buttons\UI-GroupLoot-Pass-Down]])
		Delete:SetHighlightTexture([[Interface\Buttons\UI-GroupLoot-Pass-Highlight]], 'ADD')

		local Toggle = CreateFrame('CheckButton', nil, Object, 'InterfaceOptionsCheckButtonTemplate')
		Toggle:SetPoint('RIGHT', Delete, -25, 0)
		Toggle:SetSize(16, 16)
		Toggle:SetScript('OnClick', OnToggleClick)
		Toggle:SetScript('OnEnter', OnToggleEnter)
		Toggle:SetScript('OnLeave', GameTooltip_Hide)
		Object.Toggle = Toggle
	end)

	Items:On('ObjectUpdate', function(self, event, Object)
		Object:SetText(P.categories[Object.key].name)
		Object.Toggle:SetChecked(BackpackCategoriesDB.categories[Object.key].enabled)

		if(Object.key >= 1e2 and Object.key < 1000) then -- Any custom categories
			Object.Delete:Enable()
		else
			Object.Delete:Disable()
		end

		if(Object.key == 1 or Object.key == 1002) then -- Inventory and ReagentBank
			Object.Toggle:Disable()
		else
			Object.Toggle:Enable()
		end
	end)
end)
