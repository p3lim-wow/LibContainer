local callbackMixin = LibContainer.mixins.callback
local itemMixin = LibContainer.mixins.item
local bagMixin = LibContainer.mixins.bag

local slotMixin = {}
--[[ Slot:UpdateVisibility()
Updates the visibility and hides/shows and updates the Slot.  
If the Slot is updated, its Category will be updated as well.
--]]
function slotMixin:UpdateVisibility()
	self:Fire('PreUpdateVisibility', self)

	if(self:IsItemEmpty()) then
		self:Hide()
		self:Clear()
		self:RemoveCategory()
	else
		if(self:GetItemID() ~= GetContainerItemID(self:GetBagAndSlot())) then
			-- temp solution
			self:Clear()
		end

		self:Show()
		self:Update()
		self:UpdateCategory()
	end

	self:Fire('PostUpdateVisibility', self)
end

--[[ Slot:Update()
Updates a Slot.  
This is intended for updating its children's parameters.
--]]
function slotMixin:Update()
	self:Fire('PreUpdate', self)

	local itemQuality = self:GetItemQuality()
	SetItemButtonTexture(self, self:GetItemTexture())
	SetItemButtonQuality(self, itemQuality, self:GetItemID())
	SetItemButtonCount(self, self:GetItemCount())
	SetItemButtonDesaturated(self, self:IsItemLocked())

	local QuestIcon = self.QuestIcon
	local questID = self:GetItemQuestID()
	if(questID and not self:IsItemQuestActive()) then
		QuestIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG)
		QuestIcon:Show()
	elseif(questID or self:IsItemQuestItem()) then
		QuestIcon:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
		QuestIcon:Show()
	else
		QuestIcon:Hide()
	end

	local BattlePay = self.BattlePay
	if(BattlePay) then
		BattlePay:SetShown(self:IsBattlePayItem())
	end

	local JunkIcon = self.JunkIcon
	if(JunkIcon) then
		JunkIcon:SetShown(itemQuality == LE_ITEM_QUALITY_POOR)
	end

	local NewItem = self.NewItem
	if(NewItem) then
		if(itemQuality > LE_ITEM_QUALITY_POOR and self:IsNewItem()) then
			NewItem:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[itemQuality])
			NewItem:Show()
			self.NewItemAnim:Play()
		else
			NewItem:Hide()
			self.NewItemAnim:Stop()
		end
	end

	self:Fire('PostUpdate', self)
end

--[[ Slot:UpdateLock()
Updates the locked status of the Slot.
--]]
function slotMixin:UpdateLock()
	SetItemButtonDesaturated(self, self:IsItemLocked())
end

--[[ Slot:SetCategory(categoryIndex)
Adds the Slot to the given Container.

* categoryIndex - category index the Slot should be attached to a Container for (integer)
--]]
function slotMixin:SetCategory(categoryIndex)
	self.parent:GetContainer(categoryIndex):AddSlot(self)
	self.categoryIndex = categoryIndex
end

--[[ Slot:GetCategory()
Returns the category index the Slot is attached to a Container for.
--]]
function slotMixin:GetCategory()
	return self.categoryIndex
end

local disabled = {} -- TEMP
local reverse = {}
--[[ Slot:UpdateCategory()
Iterates through the available Categories, removes the Slot from the previous Container and adds it
to the new one.  
Any categories disabled on the Parent will not be traversed.
--]]
function slotMixin:UpdateCategory()
	local categories = self.parent:GetCategories()

	table.wipe(reverse)
	for categoryIndex, info in next, categories do
		if(not disabled[info.name]) then
			table.insert(reverse, categoryIndex)
		end
	end

	table.sort(reverse)

	for index = #reverse, 1, -1 do
		local category = categories[reverse[index]]
		if(category.filterFunc(self)) then
			self:RemoveCategory()
			self:SetCategory(category.index)
			break
		end
	end
end

--[[ Slot:RemoveCategory()
Removes the Slot from the current Container it is attached to.
--]]
function slotMixin:RemoveCategory()
	local categoryIndex = self:GetCategory()
	if(categoryIndex) then
		self.parent:GetContainer(categoryIndex):RemoveSlot(self)
		self.categoryIndex = nil
	end
end

--[[ Slot:UpdateCooldown()
Updates the cooldown for the Slot.
--]]
function slotMixin:UpdateCooldown()
	self:Fire('PreUpdateCooldown', self)

	if(self:IsShown()) then
		local start, duration, enabled = self:GetItemCooldown()
		CooldownFrame_Set(self.Cooldown, start, duration, enabled)
	end

	self:Fire('PostUpdateCooldown', self)
end

--[[ Bag:CreateSlot(slotIndex)
Creates and returns a Slot with the given index.  
The Slot object is templated based on the Bag identifier, and is assigned a location from the
ItemLocation ObjectAPI, and mixed in with the Item mixin. It is also assigned with predictable keys
that represents its child frames, textures and fontstrings.

* slotIndex - slot index (integer)
--]]
function bagMixin:CreateSlot(slotIndex)
	local template
	if(self:GetID() == BANK_CONTAINER) then
		template = 'BankItemButtonGenericTemplate'
	elseif(self:GetID() == REAGENTBANK_CONTAINER) then
		template = 'ReagentBankItemButtonGenericTemplate'
	else
		template = 'ContainerFrameItemButtonTemplate'
	end

	local Slot = Mixin(CreateFrame('Button', '$parentSlot' .. slotIndex, self, template), slotMixin, itemMixin, callbackMixin)
	Slot:Hide()
	Slot.parent = self:GetParent()
	Slot:Show()
	Slot:SetID(slotIndex)
	Slot:SetItemLocation(ItemLocation:CreateFromBagAndSlot(self:GetID(), slotIndex))

	-- assign predictable keys for children
	local slotName = Slot:GetName()
	Slot.Icon = Slot.icon
	-- Slot.Count = Slot.Count
	Slot.Stock = _G[slotName .. 'Stock']
	Slot.SearchOverlay = Slot.searchOverlay
	Slot.IconBorder = Slot.IconBorder
	Slot.IconOverlay = Slot.IconOverlay
	Slot.NormalTexture = Slot:GetNormalTexture()
	Slot.PushedTexture = Slot:GetPushedTexture()
	Slot.HighlightTexture = Slot:GetHighlightTexture()

	Slot.QuestIcon = Slot.IconQuestTexture or _G[slotName .. 'IconQuestTexture']
	Slot.Cooldown = Slot.Cooldown or _G[slotName .. 'Cooldown']
	-- Slot.JunkIcon = Slot.JunkIcon
	-- Slot.UpgradeIcon = Slot.UpgradeIcon
	Slot.Flash = Slot.flash
	Slot.FlashAnim = Slot.flashAnim
	Slot.NewItem = Slot.NewItemTexture
	Slot.NewItemAnim = Slot.newitemglowAnim
	Slot.BattlePay = Slot.BattlepayItemTexture

	self:GetParent():Fire('PostCreateSlot', Slot)

	self.slots[slotIndex] = Slot
	return Slot
end

LibContainer.mixins.slot = slotMixin