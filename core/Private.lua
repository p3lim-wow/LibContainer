local addonName, private = ...
private[2] = newproxy(true) -- E: events
private[1] = {name = addonName} -- P: private

local P = private[1]
function P.print(...)
	print('|cff33ff99Backpack|r', ...)
end

local lastMessage
function P.error(message, ...)
	if(message ~= lastMessage) then
		P.print('|cffff0000Error:|r ' .. string.format(message, ...))
		lastMessage = message
	end
end

