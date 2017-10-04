local P, E, L = unpack(select(2, ...))

local atBank
function P.PositionButtons()
	for parentContainer, containers in next, P.GetAllContainers() do
		for categoryIndex, Container in next, containers do
			if(Container.buttons) then
				local anchorPoint = Container.buttonAnchorPoint or 'TOPRIGHT'

				local sizeX = Container.buttonSizeX or Container.buttonSize or 16
				local sizeY = Container.buttonSizeY or Container.buttonSize or 16

				local spacingX = Container.buttonSpacingX or Container.buttonSpacing or 4
				local spacingY = Container.buttonSpacingY or Container.buttonSpacing or 4

				local paddingX = Container.buttonPaddingX or Container.buttonPadding or 8
				local paddingY = Container.buttonPaddingY or Container.buttonPadding or 6

				local growX = Container.buttonGrowX == 'RIGHT' and 1 or -1
				local growY = Container.buttonGrowY == 'UP' and 1 or -1

				local cols = Container.columns or 4

				local index = 1
				for _, Button in next, Container.buttons do
					local shouldShow
					if(Button.overrideShouldShow) then
						shouldShow = Button:overrideShouldShow(atBank)
					else
						shouldShow = not (Button.hideOfflineBank and not atBank)
					end

					Button:SetShown(shouldShow)

					if(Button:IsShown()) then
						local col = (index - 1) % cols
						local row = math.floor((index - 1) / cols)

						Button:ClearAllPoints()
						Button:SetPoint(anchorPoint, (paddingX + (sizeX + spacingX) * col) * growX, (paddingY + (sizeY + spacingY) * row) * growY)

						index = index + 1
					end
				end
			end
		end
	end
end

local function ShowTooltip(self)
	if(self.tooltipText) then
		GameTooltip:SetOwner(self, self.tooltipAnchor or 'ANCHOR_TOP')
		GameTooltip:SetText(self.tooltipText)
		GameTooltip:Show()
	end
end

function P.CreateContainerButton(name, categoryIndex, forBank)
	local parentContainer = forBank and BackpackBank or Backpack
	local Parent = P.GetCategoryContainer(parentContainer, categoryIndex)

	local sizeX = Parent.buttonSizeX or Parent.buttonSize or 16
	local sizeY = Parent.buttonSizeY or Parent.buttonSize or 16

	local Button = CreateFrame('Button', '$parent' .. name, Parent)
	Button:SetSize(sizeX, sizeY)
	Button:SetScript('OnEnter', ShowTooltip)
	Button:SetScript('OnLeave', GameTooltip_Hide)
	Button.hideOfflineBank = forBank

	local Texture = Button:CreateTexture('$parentTexture', 'ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
	Button.Texture = Texture

	P.Fire('PostCreateContainerButton', Button)

	Button.UpdateTooltip = ShowTooltip

	if(not Parent.buttons) then
		Parent.buttons = {}
	end

	table.insert(Parent.buttons, Button)
	P.PositionButtons()

	return Button
end

BackpackBank:HookScript('OnShow', P.PositionButtons)

function E:BANKFRAME_OPENED()
	atBank = true
	P.PositionButtons()
end

function E:BANKFRAME_CLOSED()
	atBank = false
	P.PositionButtons()
end

function E:REAGENTBANK_PURCHASED()
	P.PositionButtons()
end

-- @name Backpack:CreateContainerButton
-- @usage button = Backpack:CreateContainerButton(name, categoryIndex[, forBank])
-- @param name          - description
-- @param categoryIndex - description
-- @param forBank       - description (optional)
-- @return button       - Button
P.Expose('CreateContainerButton', function(_, name, categoryIndex, forBank)
	assert(name, 'Missing required parameter "name".')
	assert(type(name) == 'string', 'Parameter "name" must be a string.')
	assert(categoryIndex, 'Missing required parameter "categoryIndex".')
	assert(type(categoryIndex) == 'number', 'Parameter "categoryIndex" must be a number.')

	return P.CreateContainerButton(name, categoryIndex, forBank)
end)
