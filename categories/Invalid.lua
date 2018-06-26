local key = 'Invalid'
local name = 'Erroneous'
local index = 2

local locale = GetLocale()
if(locale == 'deDE') then
	name = 'Ungültig'
elseif(locale == 'esES') then
	-- MISSING TRANSLATION
elseif(locale == 'esMX') then
	-- MISSING TRANSLATION
elseif(locale == 'frFR') then
	-- MISSING TRANSLATION
elseif(locale == 'itIT') then
	-- MISSING TRANSLATION
elseif(locale == 'koKR') then
	name = '잘못된'
elseif(locale == 'ptBR') then
	name = 'Errôneo'
elseif(locale == 'ruRU') then
	name = 'Ошибочные'
elseif(locale == 'zhCN') then
	name = '错误'
elseif(locale == 'zhTW') then
	name = '錯誤'
end

local filter = function(Slot)
	-- any item that is not retrieving information
	return not GetContainerItemLink(Slot:GetBagAndSlot())
end

LibContainer:AddCategory(index, key, name, filter)
