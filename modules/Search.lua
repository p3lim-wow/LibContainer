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
	self.Icon:Hide()

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
	Parent.Icon:Show()

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
			CloseSearch(self)
		end
	end
end

local function Update()
	for bagID = 0, NUM_BAG_FRAMES do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local exists, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(bagID, slotID)
			if(exists) then
				local Slot = P.GetSlot(bagID, slotID)
				if(isFiltered) then
					Slot:SetAlpha(0.1)
				else
					Slot:SetAlpha(1)
				end
			end
		end
	end
end

local function Init(self)
	local Frame = CreateFrame('Button', '$parentSearch', self)
	Frame:SetPoint('BOTTOMLEFT', 4, 4)
	Frame:SetPoint('BOTTOMRIGHT', -4, 4)
	Frame:SetHeight(20)
	Frame:SetAlpha(0)
	Frame:SetBackdrop(BACKDROP)
	Frame:SetBackdropColor(0, 0, 0, 0.9)
	Frame:SetBackdropBorderColor(0, 0, 0)
	Frame:RegisterForClicks('AnyUp')
	Frame:SetScript('OnClick', OpenSearch)
	Frame:SetScript('OnEnter', OnEnter)
	Frame:SetScript('OnLeave', OnLeave)

	local FrameIcon = Frame:CreateTexture('$parentIcon', 'OVERLAY')
	FrameIcon:SetPoint('CENTER')
	FrameIcon:SetSize(14, 14)
	FrameIcon:SetTexture([[Interface\Common\UI-Searchbox-Icon]])
	Frame.Icon = FrameIcon

	local Editbox = CreateFrame('EditBox', '$parentEditBox', Frame)
	Editbox:SetPoint('TOPLEFT', 25, 0)
	Editbox:SetPoint('BOTTOMRIGHT', -5, 0)
	Editbox:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	Editbox:SetScript('OnChar', OnChar)
	Editbox:SetScript('OnTextChanged', OnTextChanged)
	Editbox:SetScript('OnEscapePressed', CloseSearch)
	Editbox:SetAutoFocus(true)
	Editbox:Hide()
	Frame.Editbox = Editbox

	local EditboxIcon = Editbox:CreateTexture('$parentIcon', 'OVERLAY')
	EditboxIcon:SetPoint('RIGHT', Editbox, 'LEFT', -4, 0)
	EditboxIcon:SetSize(14, 14)
	EditboxIcon:SetTexture([[Interface\Common\UI-Searchbox-Icon]])
end

P.AddModule(Init, Update, 'INVENTORY_SEARCH_UPDATE')
