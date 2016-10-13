local P, E, L = unpack(select(2, ...))
P.modules = {}

-- @name Backpack:AddModule
-- @usage Backpack:AddModule(name, initFunc, updateFunc[, includeBank][, events])
-- @param name        - Name of the module
-- @param initFunc    - Function that executes on initializing
-- @param updateFunc  - Function that executes on events (see last param)
-- @param includeBank - Boolean to also init for the bank (false by default)
-- @param events      - Events to listen to (add as many as you want)
P.Expose('AddModule', function(_, name, init, update, includeBank, ...)
	table.insert(P.modules, {
		name = name,
		init = init,
		update = update,
		includeBank = includeBank,
		events = {...}
	})
end)
