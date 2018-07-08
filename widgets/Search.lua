local L = LibContainer.locale

--[[ Search:header
Creates an editbox that will match the input against items in all [Parents](Parent)' [Bag](Bag) [Slots](Slot).  
This widget should only be created on one Parent, not all, and preverably on the Inventory [Container](Container)
as it's a persistent Container.

Valid data matching against:
- item ID
- item name
- item quality name (localized), e.g. "epic" for purple items
- item inventory type name (localized), e.g. "finger" for rings

It will match parts of names, which can be specified with multiple words.  
E.g. "fr bag" will match for "Frostweave Bag".

[Slots](Slot) not matched with the text will (by default) be dimmed by 90%, this behavior can be
altered with [Slot:OverrideSearch()](Slot#slotoverridesearchismatched).

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
    local Search = Container:AddWidget('Search')
    Search:SetPoint('BOTTOM')
    Search:SetSize(200, 20)
end)
```
--]]

local MIN_REPEAT_CHARACTERS = 4
local function OnChar(Widget)
	-- exit out of searching if the player is repeating keys (ie - trying to move)
	local text = Widget:GetText()
	if(text:len() >= MIN_REPEAT_CHARACTERS) then
		local repeatChar = true
		for i = 1, MIN_REPEAT_CHARACTERS - 1, 1 do
			if(text:sub((0 - i), (0 - i)) ~= text:sub((-1 - i), (-1 - i))) then
				repeatChar = false
				break
			end
		end

		if(repeatChar) then
			-- break out of the search if the player is repeating characters
			Widget:GetScript('OnEscapePressed')(Widget)
		end
	end
end

local function Find(word, ...)
	for index = 1, select('#', ...) do
		local str = tostring(select(index, ...))
		if(str and str:lower():find(word)) then
			return true
		end
	end
end

local function Search(Parent, text)
	for _, Bag in next, Parent:GetBags() do
		for slotIndex = 1, GetContainerNumSlots(Bag:GetID()) do
			local Slot = Bag:GetSlot(slotIndex)
			if(Slot and Slot:IsShown()) then
				local isMatched = true
				-- iterate every "word" of the text to find a match
				for word in text:gmatch('%S+') do
					-- if the previous word matched but the current one does not,
					-- flag as not matched
					if(isMatched and not Find(word,
							Slot:GetItemID(),
							Slot:GetItemQualityName(),
							Slot:GetItemName(),
							Slot:GetItemInventoryTypeName())) then
						isMatched = false
						-- no match thus far, won't match later either, bail out
						break
					end
				end

				if(Slot.OverrideSearch) then
					--[[ Slot:OverrideSearch(isMatched)
					This is an overridable function that will replace the default search widget
					filtering method, see [Search](Search).

					The `isMatched` parameter is a boolean flag if the Slot should be filtered
					or not.
					--]]
					Slot:OverrideSearch(isMatched)
				else
					if(isMatched) then
						Slot:SetAlpha(1)
					else
						Slot:SetAlpha(0.1)
					end
				end
			end
		end
	end
end

local function OnTextChanged(Widget)
	local Parent = Widget:GetParent():GetParent()
	local text = Widget:GetText():lower()

	local Bags = Parent:GetParentOfType('bags')
	if(Bags) then
		Search(Bags, text)
	end

	local Bank = Parent:GetParentOfType('bank')
	if(Bank) then
		Search(Bank, text)
	end
end

local function OnEscapePressed(Widget)
	Widget:ClearFocus()
	Widget:SetText('')

	OnTextChanged(Widget)
end

local function OnClick(Widget)
	Widget:SetFocus()
end

local function Create(Container)
	local Editbox = CreateFrame('EditBox', '$parentSearchWidget', Container)
	Editbox:SetFontObject('GameFontHighlightSmall')
	Editbox:SetScript('OnChar', OnChar)
	Editbox:SetScript('OnTextChanged', OnTextChanged)
	Editbox:SetScript('OnEscapePressed', OnEscapePressed)
	Editbox:SetAutoFocus(false)
	Editbox:SetAltArrowKeyMode(true)
	return Editbox
end

LibContainer:RegisterWidget('Search', nop, nil, nil, Create)
