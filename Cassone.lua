local addon = cargBags:NewImplementation(...)
local container = addon:GetContainerClass()
local button = addon:GetItemButtonClass()

local font = [=[Interface\AddOns\Cassone\semplice.ttf]=]
local texture = [=[Interface\ChatFrame\ChatFrameBackground]=]

local sorting = {
	content = function(a, b)
		if(a.bagID == b.bagID) then
			return a.slotID > b.slotID
		else
			return a.bagID > b.bagID
		end
	end,
	bags = function(item)
		return item.bagID >= 0 and item.bagID <= 4
	end,
	bank = function(item)
		return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11
	end
}

local function UpdateMoney(fontstring)
	local money = GetMoney()
	local gold = math.floor(money / 1e4)
	local silver = math.floor(mod(money / 1e2, 1e2))
	local copper = math.floor(money % 1e2)

	fontstring:SetText(gold > 0 and string.format('|cffffff66%d|r.|cffc0c0c0%d|r.|cffcc9900%d', gold, silver, copper) or
		silver > 0 and string.format('|cffc0c0c0%d|r.|cffcc9900%d|r', silver, copper) or
		copper > 0 and string.format('|cffcc9900%d|r', copper) or '')
end

function container:OnContentsChanged()
	local width, height = self:LayoutButtons('grid', self.bank and 11 or 8, 2, 6, -6)
	self:SetSize(width + 12, height + (self.bank and 12 or 20))
	self:SortButtons(sorting.content)
end

function container:OnCreate(name)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:CreateTitleRegion():SetAllPoints()

	self:SetBackdrop({bgFile = texture, edgeFile = texture, edgeSize = 1})
	self:SetBackdropColor(0, 0, 0, 0.5)
	self:SetBackdropBorderColor(0, 0, 0)

	self:SetFilter(sorting[name], true)
	self.bank = name == 'bank'

	if(self.bank) then
		self:Hide()
	else
		local money = self:CreateFontString(nil, 'ARTWORK')
		money:SetPoint('BOTTOMRIGHT', -4, 5)
		money:SetFont(font, 8, 'OUTLINE')
		money:SetJustifyH('RIGHT')

		UpdateMoney(money)
		addon:RegisterCallback('PLAYER_MONEY', money, UpdateMoney)
	end
end

function button:OnCreate()
	self:SetSize(26, 26)
	self:SetPushedTexture(nil)
	self:SetHighlightTexture(nil)

	self:SetBackdrop({bgFile = texture, edgeFile = texture, edgeSize = 1})
	self:SetBackdropColor(0, 0, 0, 0.5)
	self:SetBackdropBorderColor(0, 0, 0)

	self.Icon:ClearAllPoints()
	self.Icon:SetPoint('TOPRIGHT', -1, -1)
	self.Icon:SetPoint('BOTTOMLEFT', 1, 1)
	self.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	self.Count:SetFont(font, 8, 'OUTLINE')
	self.Count:SetPoint('BOTTOMRIGHT', 0, 2)

	self:HookScript('OnEnter', function()
		self.oldColor = {self:GetBackdropBorderColor()}
		self:SetBackdropBorderColor(0, 0.6, 1)
	end)

	self:HookScript('OnLeave', function()
		self:SetBackdropBorderColor(unpack(self.oldColor))
	end)

	_G[self:GetName()..'NormalTexture']:SetTexture(nil)
	_G[self:GetName()..'IconQuestTexture']:SetSize(0.01, 0.01)
end

function addon:OnInit()
	container:New('bags'):SetPoint('BOTTOMRIGHT', -50, 100)
	container:New('bank'):SetPoint('TOPLEFT', 50, -100)
end

function addon:OnBankOpened()
	self:GetContainer('bank'):Show()
end

function addon:OnBankClosed()
	self:GetContainer('bank'):Hide()
end

addon:RegisterBlizzard()
