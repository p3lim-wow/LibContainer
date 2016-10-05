local P = unpack(select(2, ...))

local FONT = [[Interface\AddOns\Backpack\assets\semplice.ttf]]

local function UpdateMoney()
	local money = GetMoney()
	local gold = math.floor(money / 1e4)
	local silver = math.floor((money / 1e2) % 1e2)
	local copper = math.floor(money % 1e2)

	local output = string.format('|cffffff66%d|r', gold)
	output = string.format('%s.|cffc0c0c0%d|r', output, silver)
	output = string.format('%s.|cffcc9900%d|r', output, copper)

	Backpack.Money:SetText(output)
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
end

local function Init(self)
	local Money = self:CreateFontString('$parentMoney', 'OVERLAY')
	Money:SetPoint('BOTTOMRIGHT', -8, 10)
	Money:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	Money:SetJustifyH('RIGHT')
	self.Money = Money

	local Currencies = self:CreateFontString('$parentCurrencies', 'OVERLAY')
	Currencies:SetPoint('BOTTOMLEFT', 5, 8)
	Currencies:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	self.Currencies = Currencies

	UpdateMoney()
	UpdateCurrencies()
end

local function Update(self, event)
	if(event == 'PLAYER_MONEY') then
		UpdateMoney()
	elseif(event == 'CURRENCY_DISPLAY_UPDATE') then
		UpdateCurrencies()
	end
end

P.AddModule(Init, Update, 'PLAYER_MONEY', 'CURRENCY_DISPLAY_UPDATE')
