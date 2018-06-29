assert(not LibContainer, 'Only one instance of LibContainer can exist.')

local parentAddOnName = ...

LibContainer = {}
LibContainer.mixins = {}
LibContainer.constants = {}

local defaults = {
	KnownItems = {}, -- key = itemID, value = categoryKey
}

local database_name = 'LibContainerDB'
function LibContainer:SetDatabase(db)
	-- TODO: consider using TOC metadata instead?
	database_name = db
end

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
