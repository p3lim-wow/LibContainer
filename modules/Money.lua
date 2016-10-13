local P = unpack(select(2, ...))

local function Update()
	if(not P.Layout('UpdateMoney')) then
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
end

local function Init(self)
	local Money = self:CreateFontString('$parentMoney', 'OVERLAY', 'GameFontHighlightSmall')
	Money:SetPoint('BOTTOMRIGHT', -8, 10)
	self.Money = Money

	local Button = CreateFrame('Button', '$parentButton', self)
	Button:SetAllPoints(Money)
	Button:SetScript('OnClick', MoneyInputFrame_OpenPopup)
	Button.info = MoneyTypeInfo.PLAYER
	Money.Button = Button

	P.Fire('PostCreateMoney', self)
	Update()
end

Backpack:AddModule('Money', Init, Update, false, 'PLAYER_MONEY', 'PLAYER_LOGIN')
