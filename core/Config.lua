local P, E, L = unpack(select(2, ...))

local defaults = {
	categories = {},
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
	Title:SetFontObject('GameFontNormalMed1')
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
