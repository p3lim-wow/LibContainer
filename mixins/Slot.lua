local callbackMixin = LibContainer.mixins.callback
local bagMixin = LibContainer.mixins.bag

local slotMixin = {}
function slotMixin:UpdateVisibility()
	self:Fire('PreUpdateVisibility', self)

	if(self:IsItemEmpty()) then
		self:Hide()
	else
		self:ContinueOnItemLoad(function()
			-- cache variables typically used for sorting
			self.itemQuality = self:GetItemQuality()
			self.itemLevel = self:GetCurrentItemLevel()
			self.itemID = self:GetItemID()
			self.itemCount = self:GetItemCount()

			self:Update()
			self:UpdateCategory()
			self:UpdateContainer()
			self:Show()
		end)
	end

	self:Fire('PostUpdateVisibility', self)
end

function slotMixin:Update()
	if(self:IsItemEmpty()) then
		return
	end

	self:Fire('PreUpdate', self)

	local itemQuality = self:GetItemQuality()
	SetItemButtonTexture(self, self:GetItemIcon())
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

function slotMixin:SetCategory(category)
	if(category.index ~= self:GetCategory()) then
		self.prevCategory = self:GetCategory()
		self.currentCategory = category.index
	end
end

function slotMixin:GetPrevCategory()
	return self.prevCategory
end

function slotMixin:GetCategory()
	return self.currentCategory
end

local disabled = {} -- TEMP
local reverse = {}
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
			self:SetCategory(category)
			break
		end
	end
end

function slotMixin:UpdateContainer()
	local Parent = self.parent

	local old = self:GetPrevCategory()
	if(old) then
		Parent:GetContainer(old):RemoveSlot()
	end

	Parent:GetContainer(self:GetCategory()):AddSlot(self)
end

function slotMixin:UpdateCooldown()
	self:Fire('PreUpdateCooldown', self)

	if(self:IsShown()) then
		local start, duration, enabled = self:GetItemCooldown()
		CooldownFrame_Set(self.Cooldown, start, duration, enabled)
	end

	self:Fire('PostUpdateCooldown', self)
end

-- additions to ItemMixin
function slotMixin:GetBagAndSlot()
	return self:GetItemLocation():GetBagAndSlot()
end

function slotMixin:GetItemCount()
	if(not self:IsItemEmpty()) then
		local _, count = GetContainerItemInfo(self:GetBagAndSlot())
		return count and count > 0 and count or 0
	end
end

function slotMixin:IsItemQuestItem()
	if(not self:IsItemEmpty()) then
		return (GetContainerItemQuestInfo(self:GetBagAndSlot()))
	end
end

function slotMixin:IsItemQuestActive()
	if(not self:IsItemEmpty()) then
		local _, _, isActive = GetContainerItemQuestInfo(self:GetBagAndSlot())
		return isActive
	end
end

function slotMixin:GetItemQuestID()
	if(not self:IsItemEmpty()) then
		local _, questID = GetContainerItemQuestInfo(self:GetBagAndSlot())
		return questID
	end
end

function slotMixin:IsBattlePayItem()
	if(not self:IsItemEmpty()) then
		return IsBattlePayItem(self:GetBagAndSlot())
	end
end

function slotMixin:IsNewItem()
	if(not self:IsItemEmpty()) then
		return C_NewItems.IsNewItem(self:GetBagAndSlot())
	end
end

function slotMixin:GetItemCooldown()
	if(not self:IsItemEmpty()) then
		return GetContainerItemCooldown(self:GetBagAndSlot())
	end
end

function slotMixin:GetItemClass()
	if(not self:IsItemEmpty()) then
		return select(6, GetItemInfoInstant(self:GetItemID()))
	end
end

function slotMixin:GetItemSubClass()
	if(not self:IsItemEmpty()) then
		return select(7, GetItemInfoInstant(self:GetItemID()))
	end
end

function bagMixin:CreateSlot(slotIndex)
	local template
	if(self:GetID() == BANK_CONTAINER) then
		template = 'BankItemButtonGenericTemplate'
	elseif(self:GetID() == REAGENTBANK_CONTAINER) then
		template = 'ReagentBankItemButtonGenericTemplate'
	else
		template = 'ContainerFrameItemButtonTemplate'
	end

	local Slot = Mixin(CreateFrame('Button', '$parentSlot' .. slotIndex, self, template), slotMixin, ItemMixin, callbackMixin)
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
