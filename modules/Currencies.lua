local P = unpack(select(2, ...))

local function Update()
	if(not P.Override('UpdateCurrencies')) then
		for index = 1, MAX_WATCHED_TOKENS do
			local Currency = Backpack.Currencies[index]

			local name, count, texture, currencyID = GetBackpackCurrencyInfo(index)
			if(name) then
				Currency:SetFormattedText('|T%s:16:16:0:0|t %d', texture, count)
				Currency.Button:SetID(currencyID)
			else
				Currency:SetText('')
				Currency.Button:SetID(0)
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
		local Currency = self:CreateFontString('$parentCurrency' .. index, 'OVERLAY', 'GameFontHighlightSmall')
		Currencies[index] = Currency

		if(index == 1) then
			Currency:SetPoint('BOTTOMLEFT', 10, 8)
		else
			Currency:SetPoint('LEFT', Currencies[index - 1], 'RIGHT')
		end

		local Button = CreateFrame('Button', '$parentButton', self)
		Button:SetAllPoints(Currency)
		Button:SetID(index)
		Button:SetScript('OnClick', OnClick)
		Button:SetScript('OnEnter', OnEnter)
		Button:SetScript('OnLeave', GameTooltip_Hide)
		Currency.Button = Button
	end
	self.Currencies = Currencies

	hooksecurefunc('SetCurrencyBackpack', Update)

	P.Fire('PostCreateCurrencies', self)
	Update()
end

P.AddModule(Init, Update, 'CURRENCY_DISPLAY_UPDATE')
