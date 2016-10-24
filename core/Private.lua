local addonName, private = ...
private[1] = {name = addonName} -- P: private
private[2] = {} -- E: events
private[3] = {} -- L: localization

local P = private[1]
function P.print(...)
	print('|cff33ff99Backpack|r', ...)
end

function P.printf(message, ...)
	P.print(string.format(message, ...))
end

local lastMessage
function P.error(message, ...)
	if(message ~= lastMessage) then
		P.printf('|cffff0000Error:|r ' .. message, ...)
		lastMessage = message
	end
end

