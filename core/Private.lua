local addonName, private = ...
private[2] = newproxy(true) -- E: events
private[1] = {name = addonName} -- P: private

local P = private[1]
function P.error(...)
	print(...)
end

function P.print(...)
	print(...)
end
