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

local function OnClick(self)
	if(IsModifiedClick('CHATLINK')) then
		HandleModifiedItemClick(GetCurrencyLink(self:GetID()))
	end
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:SetCurrencyTokenByID(self:GetID())
	GameTooltip:Show()
end

local function Update(self)
	for index, Button in next, self.buttons do
		local name, count, texture, currencyID = GetBackpackCurrencyInfo(index)
		if(name) then
			local Label = Button.Label
			Label:SetText(count)

			Button.Icon:SetTexture(texture)
			Button:SetSize(Label:GetWidth() + Button.Icon:GetWidth(), Label:GetHeight())
			Button:SetID(currencyID)
			Button:Show()
		else
			Button:Hide()
		end
	end
end

local function Enable(self)
	if(not self.buttons) then
		local anchor = self:GetPoint()

		self.buttons = {}
		for index = 1, MAX_WATCHED_TOKENS do -- 3
			local Button = CreateFrame('Button', nil, self)
			Button:SetID(index)
			Button:SetScript('OnClick', OnClick)
			Button:SetScript('OnEnter', OnEnter)
			Button:SetScript('OnLeave', GameTooltip_Hide)

			if(index == 1) then
				Button:SetPoint('BOTTOMLEFT')
			else
				Button:SetPoint('BOTTOMLEFT', self.buttons[index - 1], 'BOTTOMRIGHT', 2, 0)
			end

			local Icon = Button:CreateTexture(nil, 'ARTWORK')
			Icon:SetPoint('LEFT')
			Icon:SetSize(10, 10)
			Button.Icon = Icon

			local Label = Button:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
			Label:SetPoint('LEFT', Icon, 'RIGHT', 2, 0)
			Button.Label = Label

			self.buttons[index] = Button
		end

		hooksecurefunc('SetCurrencyBackpack', function()
			Update(self)
		end)
	end


	self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
end

local function Disable(self)
	self:UnregisterEvent('CURRENCY_DISPLAY_UPDATE')
end

LibContainer:RegisterWidget('Currencies', Enable, Disable, Update)
