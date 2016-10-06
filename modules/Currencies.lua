local P = unpack(select(2, ...))

local function UpdateMoney()
	local money = GetMoney()
	local gold = math.floor(money / 1e4)
	local silver = math.floor((money / 1e2) % 1e2)
	local copper = math.floor(money % 1e2)

	local output = string.format('|cffffff66%d|r', gold)
	output = string.format('%s.|cffc0c0c0%d|r', output, silver)
	output = string.format('%s.|cffcc9900%d|r', output, copper)

	Backpack.Money:SetText(output)

	P.Fire('UpdateMoney', Backpack, money)
end

local function UpdateCurrencies()
	local output = ''
	for index = 1, MAX_WATCHED_TOKENS do
		local name, count, texture, currencyID = GetBackpackCurrencyInfo(index)
		if(name) then
			output = string.format('%s |T%s:16:16:0:0|t %d', output, texture, count)
		end
	end

	Backpack.Currencies:SetText(output)

	P.Fire('UpdateCurrencies', Backpack)
end

local function Init(self)
	local Money = self:CreateFontString('$parentMoney', 'OVERLAY', 'GameFontHighlightSmall')
	Money:SetPoint('BOTTOMRIGHT', -8, 10)
	self.Money = Money

	local Currencies = self:CreateFontString('$parentCurrencies', 'OVERLAY', 'GameFontHighlightSmall')
	Currencies:SetPoint('BOTTOMLEFT', 5, 8)
	self.Currencies = Currencies

	P.Fire('PostCreateCurrencies', Backpack)

	if(not P.Override('UpdateMoney')) then
		UpdateMoney()
	end

	if(not P.Override('UpdateCurrencies')) then
		UpdateCurrencies()
	end
end

local function Update(self, event)
	if(event == 'PLAYER_MONEY') then
		if(not P.Override('UpdateMoney')) then
			UpdateMoney()
		end
	elseif(event == 'CURRENCY_DISPLAY_UPDATE') then
		if(not P.Override('UpdateCurrencies')) then
			UpdateCurrencies()
		end
	end
end

P.AddModule(Init, Update, 'PLAYER_MONEY', 'CURRENCY_DISPLAY_UPDATE')
