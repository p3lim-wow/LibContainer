local P = unpack(select(2, ...))

local FONT = [[Interface\AddOns\Backpack\assets\semplice.ttf]]
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1}

local function OnEnter(self)
	self:SetAlpha(0.4)
end

local function OnLeave(self)
	self:SetAlpha(0)
end

local function OpenSearch(self)
	self:SetScript('OnEnter', nil)
	self:SetScript('OnLeave', nil)
	self:SetAlpha(1)

	local Editbox = self.Editbox
	Editbox:SetText('')
	Editbox:Show()
end

local function CloseSearch(self)
	self:Hide()

	SetItemSearch('')

	local Parent = self:GetParent()
	Parent:SetScript('OnEnter', OnEnter)
	Parent:SetScript('OnLeave', OnLeave)

	if(not MouseIsOver(Parent)) then
		Parent:SetAlpha(0)
	end
end

local function OnTextChanged(self)
	SetItemSearch(self:GetText())
end

local MIN_REPEAT_CHARACTERS = 4
local function OnChar(self)
	local text = self:GetText()
	if(string.len(text) > MIN_REPEAT_CHARACTERS) then
		local repeatChar = true
		for index = 1, MIN_REPEAT_CHARACTERS - 1, 1 do
			if(string.sub(text, (0 - index), (0 - index)) ~= string.sub(text, (-1 - index), (-1 - index))) then
				repeatChar = false
				break
			end
		end

		if(repeatChar) then
			-- break out of the search if the player is repeating chars (trying to move or something)
			self:GetScript('OnEscapePressed')(self)
		end
	end
end

local function Update()
	for bagID = REAGENTBANK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		for slotID = 0, Backpack:GetContainerNumSlots(bagID) do
			local exists, _, _, _, _, _, _, isFiltered = Backpack:GetContainerItemInfo(bagID, slotID)
			if(exists or slotID == 0) then
				local Slot = P.GetSlot(bagID, slotID)
				if(Slot and Slot:IsVisible()) then
					if(isFiltered) then
						Slot:SetAlpha(0.1)
					else
						Slot:SetAlpha(1)
					end
				end
			end
		end
	end
end

local function Init(self)
	local SearchBox = CreateFrame('Button', '$parentSearch', self)
	SearchBox:SetPoint('BOTTOMLEFT', 4, 4)
	SearchBox:SetPoint('BOTTOMRIGHT', -4, 4)
	SearchBox:SetHeight(20)
	SearchBox:SetAlpha(0)
	SearchBox:RegisterForClicks('AnyUp')
	SearchBox:SetScript('OnClick', OpenSearch)
	SearchBox:SetScript('OnEnter', OnEnter)
	SearchBox:SetScript('OnLeave', OnLeave)
	self.SearchBox = SearchBox

	local Editbox = CreateFrame('EditBox', '$parentEditBox', SearchBox)
	Editbox:SetPoint('TOPLEFT', 25, 0)
	Editbox:SetPoint('BOTTOMRIGHT', -5, 0)
	Editbox:SetFontObject(GameFontHighlightSmall)
	Editbox:SetScript('OnChar', OnChar)
	Editbox:SetScript('OnTextChanged', OnTextChanged)
	Editbox:SetScript('OnEscapePressed', CloseSearch)
	Editbox:SetAutoFocus(true)
	Editbox:Hide()
	SearchBox.Editbox = Editbox

	P.Fire('PostCreateSearch', self)
end

Backpack:AddModule('Search', Init, Update, false, 'INVENTORY_SEARCH_UPDATE')
