-- Thanks to @ls- for gathering the locale data

local MULTS_MILLION = {
	koKR = 1e4,
	zhCN = 1e4,
	zhTW = 1e4,
}

local MULTS_BILLION = {
	koKR = 1e8,
	zhCN = 1e8,
	zhTW = 1e8,
}

local PATTERN = '(%d+[%p%s]?%d*)%s-'
local WORDS_MILLION = {
	deDE = 'Million',
	enGB = 'million',
	enUS = 'million',
	esES = 'mill',
	esMX = 'mill',
	frFR = 'million',
	itIT = 'milion',
	koKR = '만',
	ptBR = 'milh',
	ruRU = 'млн',
	zhCN = '万',
	zhTW = '萬',
}

local WORDS_BILLION = {
	deDE = 'Milliarde',
	enGB = 'billion',
	enUS = 'billion',
	esES = 'mil millones',
	esMX = 'mil millones',
	frFR = 'milliard',
	itIT = 'mil[ai][ar][dr][di]',
	koKR = '억',
	ptBR = 'bilh',
	ruRU = 'млрд',
	zhCN = '亿',
	zhTW = '億',
}

local locale = GetLocale()
local WORD_MILLION = PATTERN .. WORDS_MILLION[locale]
local WORD_BILLION = PATTERN .. WORDS_BILLION[locale]
local MULT_MILLION = MULTS_MILLION[locale] or 1e6
local MULT_BILLION = MULTS_BILLION[locale] or 1e9

local SPACE = ' '
local PUNCT = '.'
local COMMA = ','
local EMPTY = ''
local COMBI = COMMA .. PUNCT .. EMPTY

local scanTipName = math.floor(GetTime())
local scanTip = CreateFrame('GameTooltip', scanTipName, nil, 'GameTooltipTemplate')
scanTip:SetOwner(WorldFrame, 'ANCHOR_NONE')

local text, value
local function ParseTip()
	scanTip:Show()

	for index = 3, scanTip:NumLines() do
		text = _G[scanTipName .. 'TextLeft' .. index]:GetText()
		if(text and text ~= '') then
			value = text:match(WORD_BILLION)
			if(value) then
				return tonumber(value:gsub(SPACE, EMPTY):gsub(COMMA, PUNCT), nil) * MULT_BILLION
			end

			value = text:match(WORD_MILLION)
			if(value) then
				return tonumber(value:gsub(SPACE, EMPTY):gsub(COMMA, PUNCT), nil) * MULT_MILLION
			end

			value = text:match(PATTERN)
			if(value) then
				return tonumber(value:gsub(COMBI, EMPTY), nil)
			end
		end
	end
end

function GetItemArtifactPower(item)
	if(not item or not IsArtifactPowerItem(item)) then
		return
	end

	if(type(item) == 'string') then
		-- BUG: 7.3.2, client fails to redraw tooltips set by SetHyperlink
		scanTip:ClearLines()
		scanTip:SetHyperlink(item)
	else
		scanTip:SetItemByID(item)
	end

	return ParseTip()
end

function GetContainerItemArtifactPower(bagID, slotID)
	local itemID = GetContainerItemID(bagID, slotID)
	if(not itemID or not IsArtifactPowerItem(itemID)) then
		return
	end

	scanTip:SetBagItem(bagID, slotID)

	return ParseTip()
end
