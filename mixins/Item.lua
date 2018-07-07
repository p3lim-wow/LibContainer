local callbackMixin = LibContainer.mixins.callback

--[[ Item:header
The Item mixin is based off Blizzard's ItemMixin (see FrameXML/ObjectAPI/Item.lua), and serves the
purpose of easy access to item data.

The data is cached as much as possible to increase performance and reduce load times.

All of the methods of this mixin is inherited by the [Slot](Slot) objects.
--]]

-- based on ItemMixin, optimized for containers and caching
local itemMixin = {}
--[[ Item:SetItemLocation(itemLocation)
Sets the ItemLocation for the Item (see FrameXML/ObjectAPI/ItemLocation.lua)

* itemLocation - ItemLocation object (object)
--]]
function itemMixin:SetItemLocation(itemLocation) -- static
	assert(type(itemLocation) == 'table', 'itemLocation argument must be a itemLocation object.')
	assert(type(itemLocation.HasAnyLocation) == 'function', 'itemLocation argument must be a itemLocation object.')
	assert(itemLocation:HasAnyLocation(), 'itemLocation argument must be a valid itemLocation object.')

	self.itemLocation = itemLocation
end

--[[ Item:GetItemLocation()
Returns the ItemLocation object (see FrameXML/ObjectAPI/ItemLocation.lua)
--]]
function itemMixin:GetItemLocation() -- static
	return self.itemLocation
end

--[[ Item:GetBagAndSlot()
Returns the Bag identifier and the Slot index for the Item.
--]]
function itemMixin:GetBagAndSlot() -- static
	return self:GetItemLocation():GetBagAndSlot()
end

--[[ Item:IsItemEmpty()
Returns true/false if the Item is empty or not.
--]]
function itemMixin:IsItemEmpty() -- static
	return not C_Item.DoesItemExist(self:GetItemLocation())
end

--[[ Item:GetItemCooldown()
Returns the start, duration and enabled flag for the non-empty Item's cooldown status, if any.
--]]
function itemMixin:GetItemCooldown() -- variable, requires data load
	if(not self:IsItemEmpty()) then
		return GetContainerItemCooldown(self:GetBagAndSlot())
	end
end

--[[ Item:GetItemID()
Returns the non-empty Item's identifier.
--]]
function itemMixin:GetItemID() -- static
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
function itemMixin:GetItemLink() -- variable, requires data load
	if(not self:IsItemEmpty()) then
		if(not self.itemLink) then
			self.itemLink = C_Item.GetItemLink(self:GetItemLocation())
		end

		return self.itemLink
	end
end

--[[ Item:GetItemQuality()
Returns the non-empty Item's quality integer.
--]]
function itemMixin:GetItemQuality() -- variable, requires data load
	if(not self:IsItemEmpty()) then
		if(self.itemQuality == nil) then
			self.itemQuality = C_Item.GetItemQuality(self:GetItemLocation())
		end

		return self.itemQuality
	end
end

--[[ Item:GetItemQualityColor()
Returns a Color object for the non-empty Item.
--]]
function itemMixin:GetItemQualityColor() -- variable, requires data load
	if(not self:IsItemEmpty()) then
		if(self.itemQualityColor == nil) then
			local color = ITEM_QUALITY_COLORS[self:GetItemQuality()]
			self.itemQualityColor = color and color.color
		end

		return self.itemQualityColor
	end
end

--[[ Item:GetItemLevel()
Returns the non-empty Item's level.
--]]
function itemMixin:GetItemLevel() -- variable, requires data load
	if(not self:IsItemEmpty()) then
		if(self.itemLevel == nil) then
			self.itemLevel = C_Item.GetCurrentItemLevel(self:GetItemLocation())
		end

		return self.itemLevel
	end
end

--[[ Item:GetItemTexture()
Returns the non-empty Item's texture path.
--]]
function itemMixin:GetItemTexture() -- static, requires data load
	if(not self:IsItemEmpty()) then
		if(self.itemTexture == nil) then
			self.itemTexture = C_Item.GetItemIcon(self:GetItemLocation())
		end

		return self.itemTexture
	end
end

--[[ Item:GetItemCount()
Returns the number of items in the non-empty Item's location.
--]]
function itemMixin:GetItemCount() -- variable, requires data load
	if(not self:IsItemEmpty()) then
		if(self.itemCount == nil) then
			local _, itemCount = GetContainerItemInfo(self:GetBagAndSlot())
			self.itemCount = itemCount or 1
		end

		return self.itemCount
	end
end

--[[ Item:IsItemLocked()
Returns true/false if the the non-empty Item is locked or not.
--]]
function itemMixin:IsItemLocked() -- variable
	if(not self:IsItemEmpty()) then
		return C_Item.IsLocked(self:GetItemLocation())
	end
end

--[[ Item:GetItemValue()
Returns the merchant sell value of the non-empty Item.
--]]
function itemMixin:GetItemValue() -- variable, requires data load
	if(not self:IsItemEmpty()) then
		if(self.itemValue == nil) then
			local _, _, _, _, _, _, _, _, _, _, itemValue = GetItemInfo(self:GetItemID())
			self.itemValue = itemValue or 0
		end

		return self.itemValue
	end
end

--[[ Item:IsItemValuable()
Returns true/false if the non-empty Item is valuable or not.
--]]
function itemMixin:IsItemValuable() -- variable, requires data load
	return self:GetItemValue() > 0
end

--[[ Item:GetItemQuestID()
Returns the non-empty Item's quest identifier, if any.
--]]
function itemMixin:GetItemQuestID() -- static, requires data load
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
function itemMixin:IsItemQuestItem() -- static, requires data load
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
function itemMixin:IsItemQuestActive() -- variable, requires data load
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
function itemMixin:IsBattlePayItem() -- static, requires data load (?)
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
function itemMixin:IsNewItem() -- variable, requires data load
	if(not self:IsItemEmpty()) then
		return C_NewItems.IsNewItem(self:GetBagAndSlot())
	end
end

--[[ Item:GetItemClass()
Returns the non-empty Item's class identifier.
--]]
function itemMixin:GetItemClass() -- static
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
function itemMixin:GetItemSubClass() -- static
	if(not self:IsItemEmpty()) then
		if(self.itemSubClass == nil) then
			self:CacheItemInfoInstant()
		end

		return self.itemSubClass
	end
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
	-- cached info that is persistent
	self.itemID = nil
	self.itemQuestItem = nil
	self.itemQuestID = nil
	self.itemClass = nil
	self.itemSubClass = nil

	self:ClearCache()
end

--[[ Item:ClearCache()
Clears all variable item information.
--]]
function itemMixin:ClearCache()
	-- cached info that's not persistent
	self.itemLink = nil
	self.itemTexture = nil
	self.itemCount = nil
	self.itemQuality = nil
	self.itemQualityColor = nil
	self.itemValue = nil
	self.itemQuestActive = nil
	self.itemBattlePayItem = nil
	self.itemLevel = nil
end

--[[ Item:ContinueOnItemLoad(callback)
Executes the callback once the item has been loaded on the client (see FrameXML/ObjectAPI/Item.lua).

* callback - callback function (function)
--]]
itemMixin.ContinueOnItemLoad = ItemMixin.ContinueOnItemLoad

LibContainer.mixins.item = itemMixin
