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

local function Update(Widget)
	local money = GetMoney()
	local output = string.format('|cffffff66%d|r', math.floor(money / 1e4))
	output = string.format('%s.|cffc0c0c0%d|r', output, math.floor((money / 1e2) % 1e2))
	output = string.format('%s.|cffcc9900%d|r', output, math.floor(money % 1e2))

	local Label = Widget.Label
	Label:SetText(output)

	Widget:SetSize(Label:GetSize())
end

local function Enable(Widget)
	if(not Widget.Label) then
		local Label = Widget:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		Label:SetPoint('BOTTOMRIGHT')
		Widget.Label = Label
	end

	Widget:SetScript('OnClick', MoneyInputFrame_OpenPopup)
	Widget.info = MoneyTypeInfo.PLAYER

	Widget:RegisterEvent('PLAYER_MONEY')
	Widget:RegisterEvent('PLAYER_LOGIN')
end

local function Disable(Widget)
	Widget:UnregisterEvent('PLAYER_MONEY')
	Widget:UnregisterEvent('PLAYER_LOGIN')
end

LibContainer:RegisterWidget('Money', Enable, Disable, Update)
