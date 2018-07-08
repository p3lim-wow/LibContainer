--[[ Currencies:header
Creates a group of buttons that display the tracked currencies.

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
    local Currencies = Container:AddWidget('Currencies')
    Currencies:SetPoint('BOTTOMLEFT')
    Currencies:SetSize(1, 20)
end)
```
--]]

local function OnClick(Currency)
	if(IsModifiedClick('CHATLINK')) then
		HandleModifiedItemClick(GetCurrencyLink(Currency:GetID(), 1))
	end
end

local function OnEnter(Currency)
	GameTooltip:SetOwner(Currency, 'TOPRIGHT')
	GameTooltip:SetCurrencyTokenByID(Currency:GetID())
	GameTooltip:Show()
end

local function Update(Widget)
	for index, Currency in next, Widget.buttons do
		local name, count, texture, currencyID = GetBackpackCurrencyInfo(index)
		if(name) then
			local Label = Currency.Label
			Label:SetText(count)

			Currency.Icon:SetTexture(texture)
			Currency:SetSize(Label:GetWidth() + Currency.Icon:GetWidth(), Label:GetHeight())
			Currency:SetID(currencyID)
			Currency:Show()
		else
			Currency:Hide()
		end
	end
end

local function Enable(Widget)
	if(not Widget.buttons) then
		local anchor = Widget:GetPoint()

		Widget.buttons = {}
		for index = 1, MAX_WATCHED_TOKENS do -- 3
			local Currency = CreateFrame('Button', nil, Widget)
			Currency:SetID(index)
			Currency:SetScript('OnClick', OnClick)
			Currency:SetScript('OnEnter', OnEnter)
			Currency:SetScript('OnLeave', GameTooltip_Hide)

			if(index == 1) then
				Currency:SetPoint('BOTTOMLEFT')
			else
				Currency:SetPoint('BOTTOMLEFT', Widget.buttons[index - 1], 'BOTTOMRIGHT', 2, 0)
			end

			local Icon = Currency:CreateTexture(nil, 'ARTWORK')
			Icon:SetPoint('LEFT')
			Icon:SetSize(10, 10)
			Currency.Icon = Icon

			local Label = Currency:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
			Label:SetPoint('LEFT', Icon, 'RIGHT', 2, 0)
			Currency.Label = Label

			Widget.buttons[index] = Currency
		end

		hooksecurefunc('SetCurrencyBackpack', function()
			Update(Widget)
		end)
	end


	Widget:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
end

local function Disable(Widget)
	Widget:UnregisterEvent('CURRENCY_DISPLAY_UPDATE')
end

LibContainer:RegisterWidget('Currencies', Enable, Disable, Update)
