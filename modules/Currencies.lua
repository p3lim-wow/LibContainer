local P = unpack(select(2, ...))

local function Update()
	if(not P.Override('UpdateCurrencies')) then
		for index = 1, MAX_WATCHED_TOKENS do
			local Button = Backpack.Currencies[index]

			local name, count, texture, currencyID = GetBackpackCurrencyInfo(index)
			if(name) then
				local Label = Button.Label
				Label:SetText(count)

				Button:SetSize(Label:GetWidth() + Button.Icon:GetWidth(), Label:GetHeight())
				Button.Icon:SetTexture(texture)
				Button:SetID(currencyID)
				Button:Show()
			else
				Button:Hide()
			end
		end

		P.Fire('UpdateCurrencies', Backpack)
	end
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetCurrencyTokenByID(self:GetID())
	GameTooltip:Show()
end

local function OnClick(self)
	if(IsModifiedClick('CHATLINK')) then
		HandleModifiedItemClick(GetCurrencyLink(self:GetID()))
	end
end

local function Init(self)
	local Currencies = {}
	for index = 1, MAX_WATCHED_TOKENS do
		local Button = CreateFrame('Button', '$parentCurrency' .. index, self)
		Button:SetID(index)
		Button:SetScript('OnClick', OnClick)
		Button:SetScript('OnEnter', OnEnter)
		Button:SetScript('OnLeave', GameTooltip_Hide)

		if(index == 1) then
			Button:SetPoint('BOTTOMLEFT')
		else
			Button:SetPoint('LEFT', Currencies[index - 1], 'RIGHT', 5, 0)
		end

		local Icon = Button:CreateTexture('$parentIcon', 'ARTWORK')
		Icon:SetPoint('LEFT')
		Icon:SetSize(10, 10)
		Button.Icon = Icon

		local Label = Button:CreateFontString('$parentLabel', 'OVERLAY', 'GameFontHighlightSmall')
		Label:SetPoint('LEFT', Icon, 'RIGHT', 2, 0)
		Button.Label = Label

		Currencies[index] = Button
	end
	self.Currencies = Currencies

	hooksecurefunc('SetCurrencyBackpack', Update)

	P.Fire('PostCreateCurrencies', Currencies)
	Update()
end

Backpack:AddModule('Currencies', Init, Update, false, 'CURRENCY_DISPLAY_UPDATE')
