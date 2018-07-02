local callbackMixin = LibContainer.mixins.callback

-- based on ItemMixin, optimized for containers
local itemMixin = {}
--[[ Item:SetItemLocation(itemLocation)
Sets the ItemLocation for the Item (see FrameXML/ObjectAPI/ItemLocation.lua)

* itemLocation - ItemLocation object (object)
--]]
function itemMixin:SetItemLocation(itemLocation)
	self.itemLocation = itemLocation
end

--[[ Item:GetItemLocation()
Returns the ItemLocation object (see FrameXML/ObjectAPI/ItemLocation.lua)
--]]
function itemMixin:GetItemLocation()
	return self.itemLocation
end

--[[ Item:GetBagAndSlot()
Returns the Bag identifier and the Slot index for the Item.
--]]
function itemMixin:GetBagAndSlot()
	return self:GetItemLocation():GetBagAndSlot()
end

--[[ Item:IsItemEmpty()
Returns true/false if the Item is empty or not.
--]]
function itemMixin:IsItemEmpty()
	return not GetContainerItemID(self:GetBagAndSlot())
end

--[[ Item:GetItemCooldown()
Returns the start, duration and enabled flag for the non-empty Item's cooldown status, if any.
--]]
function itemMixin:GetItemCooldown()
	if(not self:IsItemEmpty()) then
		return GetContainerItemCooldown(self:GetBagAndSlot())
	end
end

--[[ Item:GetItemID()
Returns the non-empty Item's identifier.
--]]
function itemMixin:GetItemID()
	if(not self:IsItemEmpty()) then
		if(not self.itemID) then
			self.itemID = C_Item.GetItemID(self:GetItemLocation())
		end

		return self.itemID
	end
end

--[[ Item:GetItemLink()
Returns the non-empty Item's hyperlink.
--]]
function itemMixin:GetItemLink()
	if(not self:IsItemEmpty()) then
		if(self.itemLink == nil) then
			self:CacheItemInfo()
		end

		return self.itemLink
	end
end

--[[ Item:GetItemQuality()
Returns the non-empty Item's quality integer.
--]]
function itemMixin:GetItemQuality()
	if(not self:IsItemEmpty()) then
		if(self.itemQuality == nil) then
			self:CacheItemInfo()
		end

		return self.itemQuality
	end
end

--[[ Item:GetItemQualityColor()
Returns a Color object for the non-empty Item.
--]]
function itemMixin:GetItemQualityColor()
	local itemQuality = self:GetItemQuality()
	local color = ITEM_QUALITY_COLORS[itemQuality]
	return color and color.color
end

--[[ Item:GetItemLevel()
Returns the non-empty Item's level.
--]]
function itemMixin:GetItemLevel()
	if(not self:IsItemEmpty()) then
		if(not self.itemLevel) then
			self.itemLevel = C_Item.GetCurrentItemLevel(self:GetItemLocation())
		end

		return self.itemLevel
	end
end

--[[ Item:GetItemTexture()
Returns the non-empty Item's texture path.
--]]
function itemMixin:GetItemTexture()
	if(not self:IsItemEmpty()) then
		if(self.itemTexture == nil) then
			self:CacheItemInfo()
		end

		return self.itemTexture
	end
end

--[[ Item:GetItemCount()
Returns the number of items in the non-empty Item's location.
--]]
function itemMixin:GetItemCount()
	if(not self:IsItemEmpty()) then
		if(self.itemCount == nil) then
			self:CacheItemInfo()
		end

		return self.itemCount or 0
	end
end

--[[ Item:IsItemLocked()
Returns true/false if the the non-empty Item is locked or not.
--]]
function itemMixin:IsItemLocked()
	if(not self:IsItemEmpty()) then
		if(self.itemLocked == nil) then
			self:CacheItemInfo()
		end

		return self.itemLocked
	end
end

--[[ Item:GetItemQuestID()
Returns the non-empty Item's quest identifier, if any.
--]]
function itemMixin:GetItemQuestID()
	if(not self:IsItemEmpty()) then
		if(self.itemQuestID == nil) then
			self:CacheItemQuestInfo()
		end

		return self.itemQuestID
	end
end

--[[ Item:IsItemQuestItem()
Returns true/false if the non-empty Item is a quest item or not.
--]]
function itemMixin:IsItemQuestItem()
	if(not self:IsItemEmpty()) then
		if(self.itemQuestItem == nil) then
			self:CacheItemQuestInfo()
		end

		return self.itemQuestItem
	end
end

--[[ Item:IsItemQuestActive()
Returns true/false if the non-empty Item's quest is active or not.
--]]
function itemMixin:IsItemQuestActive()
	if(not self:IsItemEmpty()) then
		if(self.itemQuestActive == nil) then
			self:CacheItemQuestInfo()
		end

		return self.itemQuestActive
	end
end

--[[ Item:IsBattlePayItem()
Returns true/false if the non-empty Item is a "Battle Pay" item or not.
--]]
function itemMixin:IsBattlePayItem()
	if(not self:IsItemEmpty()) then
		if(self.itemBattlePayItem == nil) then
			self.itemBattlePayItem = IsBattlePayItem(self:GetBagAndSlot())
		end

		return self.itemBattlePayItem
	end
end

--[[ Item:IsNewItem()
Returns true/false if the non-empty Item is a "new" item or not.
--]]
function itemMixin:IsNewItem()
	if(not self:IsItemEmpty()) then
		return C_NewItems.IsNewItem(self:GetBagAndSlot())
	end
end

--[[ Item:GetItemClass()
Returns the non-empty Item's class identifier.
--]]
function itemMixin:GetItemClass()
	if(not self:IsItemEmpty()) then
		if(self.itemClass == nil) then
			self:CacheItemInfoInstant()
		end

		return self.itemClass
	end
end

--[[ Item:GetItemSubClass()
Returns the non-empty Item's sub-class identifier.
--]]
function itemMixin:GetItemSubClass()
	if(not self:IsItemEmpty()) then
		if(self.itemSubClass == nil) then
			self:CacheItemInfoInstant()
		end

		return self.itemSubClass
	end
end

--[[ Item:CacheItemInfo()
Caches generic item information.
--]]
function itemMixin:CacheItemInfo()
	local _
	self.itemTexture, self.itemCount, self.itemLocked, self.itemQuality, _, _, self.itemLink, _, self.itemWorthless, self.itemID = GetContainerItemInfo(self:GetBagAndSlot())
end

--[[ Item:CacheItemQuestInfo()
Caches quest-related item information.
--]]
function itemMixin:CacheItemQuestInfo()
	self.itemQuestItem, self.itemQuestID, self.itemQuestActive = GetContainerItemQuestInfo(self:GetBagAndSlot())
end

--[[ Item:CacheItemInfoInstant()
Caches intantly available item information.
--]]
function itemMixin:CacheItemInfoInstant()
	local _
	_, _, _, _, _, self.itemClass, self.itemSubClass = GetItemInfoInstant(self:GetItemID())
end

--[[ Item:Clear()
Clears all cached item information.
--]]
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
