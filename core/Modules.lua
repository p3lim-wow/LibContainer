local P, E, L = unpack(select(2, ...))
local modules = {}

-- @name Backpack:AddModule
-- @usage Backpack:AddModule(name, initFunc, updateFunc[, includeBank][, events])
-- @param name        - Name of the module
-- @param initFunc    - Function that executes on initializing
-- @param updateFunc  - Function that executes on events (see last param)
-- @param includeBank - Boolean to also init for the bank (false by default)
-- @param events      - Events to listen to (add as many as you want)
P.Expose('AddModule', function(_, name, init, update, includeBank, ...)
	table.insert(modules, {
		name = name,
		init = init,
		update = update,
		includeBank = includeBank,
		events = {...}
	})
end)

function P.LoadModules()
	for _, moduleInfo in next, modules do
		for _, event in next, moduleInfo.events do
			E:RegisterEvent(event, moduleInfo.update)
		end

		if(moduleInfo.init) then
			moduleInfo.init(Backpack)

			if(moduleInfo.includeBank) then
				moduleInfo.init(BackpackBank, true)
			end
		end
	end
end
