assert(not LibContainer, 'Only one instance of LibContainer can exist.')

local parentAddOnName = ...

LibContainer = {}
LibContainer.mixins = {}
LibContainer.constants = {}
LibContainer.locale = {}

local defaults = {
	KnownItems = {}, -- key = itemID, value = categoryKey
}

local database_name = 'LibContainerDB'
--[[ LibContainer:SetDatabase(globalName)
Set the global name for the database.

* globalName - global savedvariable name (string)
--]]
function LibContainer:SetDatabase(db)
	-- TODO: consider using TOC metadata instead?
	database_name = db
end

--[[ LibContainer:ResetDatabase()
Resets the database back to the defaults.
--]]
function LibContainer:ResetDatabase()
	LibContainer.db = defaults
end

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('ADDON_LOADED')
Handler:SetScript('OnEvent', function(_, event, name)
	if(name ~= parentAddOnName) then
		return
	end

	local db = _G[database_name]
	if(not db) then
		db = defaults
	end

	LibContainer.db = db
	_G[database_name] = db
end)

local localizations = {}
local locale = GetLocale()
setmetatable(LibContainer.locale, {
	__call = function(_, newLocale)
		localizations[newLocale] = {}
		return localizations[newLocale]
	end,
	__index = function(_, key)
		local localeTable = localizations[locale]
		return localeTable and localeTable[key] or tostring(key)
	end
})
