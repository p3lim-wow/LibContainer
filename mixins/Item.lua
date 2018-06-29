local callbackMixin = LibContainer.mixins.callback

-- based on ItemMixin, optimized for containers
local itemMixin = {}
function itemMixin:SetItemLocation(location)
	self.itemLocation = location
end

function itemMixin:GetItemLocation()
	return self.itemLocation
end

function itemMixin:GetBagAndSlot()
	return self:GetItemLocation():GetBagAndSlot()
end

function itemMixin:IsItemEmpty()
	return not GetContainerItemID(self:GetBagAndSlot())
end

function itemMixin:GetItemCooldown()
	if(not self:IsItemEmpty()) then
		return GetContainerItemCooldown(self:GetBagAndSlot())
	end
end

function itemMixin:GetItemID()
	if(not self:IsItemEmpty()) then
		if(self.itemID == nil) then
			self:CacheItemInfo()
		end

		return self.itemID
	end
end

function itemMixin:GetItemLink()
	if(not self:IsItemEmpty()) then
		if(self.itemLink == nil) then
			self:CacheItemInfo()
		end

		return self.itemLink
	end
end

function itemMixin:GetItemQuality()
	if(not self:IsItemEmpty()) then
		if(self.itemQuality == nil) then
			self:CacheItemInfo()
		end

		return self.itemQuality
	end
end

function itemMixin:GetItemQualityColor()
	local itemQuality = self:GetItemQuality()
	local color = ITEM_QUALITY_COLORS[itemQuality]
	return color and color.color
end

function itemMixin:GetItemLevel()
	if(not self:IsItemEmpty()) then
		if(not self.itemLevel) then
			self.itemLevel = C_Item.GetCurrentItemLevel(self:GetItemLocation())
		end

		return self.itemLevel
	end
end

function itemMixin:GetItemTexture()
	if(not self:IsItemEmpty()) then
		if(self.itemTexture == nil) then
			self:CacheItemInfo()
		end

		return self.itemTexture
	end
end

function itemMixin:GetItemCount()
	if(not self:IsItemEmpty()) then
		if(self.itemCount == nil) then
			self:CacheItemInfo()
		end

		return self.itemCount or 0
	end
end

function itemMixin:IsItemLocked()
	if(not self:IsItemEmpty()) then
		if(self.itemLocked == nil) then
			self:CacheItemInfo()
		end

		return self.itemLocked
	end
end

function itemMixin:GetItemQuestID()
	if(not self:IsItemEmpty()) then
		if(self.itemQuestID == nil) then
			self:CacheItemQuestInfo()
		end

		return self.itemQuestID
	end
end

function itemMixin:IsItemQuestItem()
	if(not self:IsItemEmpty()) then
		if(self.itemQuestItem == nil) then
			self:CacheItemQuestInfo()
		end

		return self.itemQuestItem
	end
end

function itemMixin:IsItemQuestActive()
	if(not self:IsItemEmpty()) then
		if(self.itemQuestActive == nil) then
			self:CacheItemQuestInfo()
		end

		return self.itemQuestActive
	end
end

function itemMixin:IsBattlePayItem()
	if(not self:IsItemEmpty()) then
		if(self.itemBattlePayItem == nil) then
			self.itemBattlePayItem = IsBattlePayItem(self:GetBagAndSlot())
		end

		return self.itemBattlePayItem
	end
end

function itemMixin:IsNewItem()
	if(not self:IsItemEmpty()) then
		return C_NewItems.IsNewItem(self:GetBagAndSlot())
	end
end

function itemMixin:GetItemClass()
	if(not self:IsItemEmpty()) then
		if(self.itemClass == nil) then
			self:CacheItemInfoInstant()
		end

		return self.itemClass
	end
end

function itemMixin:GetItemSubClass()
	if(not self:IsItemEmpty()) then
		if(self.itemSubClass == nil) then
			self:CacheItemInfoInstant()
		end

		return self.itemSubClass
	end
end

function itemMixin:CacheItemInfo()
	local _
	self.itemTexture, self.itemCount, self.itemLocked, self.itemQuality, _, _, self.itemLink, _, self.itemWorthless, self.itemID = GetContainerItemInfo(self:GetBagAndSlot())
end

function itemMixin:CacheItemQuestInfo()
	self.itemQuestItem, self.itemQuestID, self.itemQuestActive = GetContainerItemQuestInfo(self:GetBagAndSlot())
end

function itemMixin:CacheItemInfoInstant()
	local _
	_, _, _, _, _, self.itemClass, self.itemSubClass = GetItemInfoInstant(self:GetItemID())
end

function itemMixin:Clear()
	self.itemTexture = nil
	self.itemCount = nil
	self.itemLocked = nil
	self.itemQuality = nil
	self.itemLink = nil
	self.itemWorthless = nil
	self.itemID = nil
	self.itemQuestItem = nil
	self.itemQuestID = nil
	self.itemQuestActive = nil
	self.itemBattlePayItem = nil
	self.itemClass = nil
	self.itemSubClass = nil
	self.itemLevel = nil
end

LibContainer.mixins.item = itemMixin
