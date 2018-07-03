--[[ Money:header
Creates a button that displays the amount of money the player has.

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
	local Money = Container:AddWidget('Money')
	Money:SetPoint('TOPRIGHT')
end)
```
--]]

local function Update(self)
	local money = GetMoney()
	local output = string.format('|cffffff66%d|r', math.floor(money / 1e4))
	output = string.format('%s.|cffc0c0c0%d|r', output, math.floor((money / 1e2) % 1e2))
	output = string.format('%s.|cffcc9900%d|r', output, math.floor(money % 1e2))

	local Label = self.Label
	Label:SetText(output)

	self:SetSize(Label:GetSize())
end

local function Enable(self)
	if(not self.Label) then
		local Label = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		Label:SetPoint('BOTTOMRIGHT')
		self.Label = Label
	end

	self:SetScript('OnClick', MoneyInputFrame_OpenPopup)
	self.info = MoneyTypeInfo.PLAYER

	self:RegisterEvent('PLAYER_MONEY')
	self:RegisterEvent('PLAYER_LOGIN')
end

local function Disable(self)
	self:UnregisterEvent('PLAYER_MONEY')
	self:UnregisterEvent('PLAYER_LOGIN')
end

LibContainer:RegisterWidget('Money', Enable, Disable, Update)
