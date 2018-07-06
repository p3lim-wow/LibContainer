local L = LibContainer.locale

local name = 'TradeGoods'
local localizedName = L['Trade Goods']
local index = 40

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
	else
		return Slot:GetItemClass() == LE_ITEM_CLASS_TRADEGOODS
	end
end

LibContainer:AddCategory(index, name, localizedName, filter)
