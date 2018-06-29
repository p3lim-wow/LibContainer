local key = 'New'
local name = 'New Items'
local index = 997 -- as high as possible

local locale = GetLocale()
if(locale == 'deDE') then
	name = 'Neue Gegenstände'
elseif(locale == 'esES') then
	-- MISSING TRANSLATION
elseif(locale == 'esMX') then
	-- MISSING TRANSLATION
elseif(locale == 'frFR') then
	-- MISSING TRANSLATION
elseif(locale == 'itIT') then
	-- MISSING TRANSLATION
elseif(locale == 'koKR') then
	name = '새로운 아이템'
elseif(locale == 'ptBR') then
	name = 'Novos Itens'
elseif(locale == 'ruRU') then
	name = 'Новые предметы'
elseif(locale == 'zhCN') then
	name = '新物品'
elseif(locale == 'zhTW') then
	name = '新物品'
end

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		-- don't mark junk as new
		return Slot:GetItemQuality() > LE_ITEM_QUALITY_POOR
	end
end

LibContainer:AddCategory(index, key, name, filter)
