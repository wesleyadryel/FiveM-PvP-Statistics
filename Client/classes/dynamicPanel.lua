local PANEL_POSITION_Y = 0.18
local EXTRA_MARGIN_TOP = 0.01
local DEFAULT_PLAYER_COLOR = {
    r = 163,
    g = 163,
    b = 163,
    a = 255
}
local DEFAULT_INFO_COLOR = {
    r = 0,
    g = 0,
    b = 0,
    a = 150
}
local DEFAULT_HEADER_COLOR = {
    r = 0,
    g = 0,
    b = 0,
    a = 255
}
local DEFAULT_TEXT_COLOR = {
    r = 255,
    g = 255,
    b = 255,
    a = 255
}
local ROW_HEIGHT = 0.03
local ROW_MARGIN = 0.00001
local ROW_VERTICAL_SPACE = ROW_HEIGHT + ROW_MARGIN

DynamicPanel = {}
DynamicPanel.__index = DynamicPanel

--- Creates a new DynamicPanel instance.
---@param title string The title of the dynamic panel.
---@param headerItems table The headers for the dynamic panel.
---@param players table The players data for the dynamic panel.
---@param colorTitle table<string, number> RGBA color.
---@return DynamicPanel
function DynamicPanel:new(title, headerItems, players, colorTitle)
    local instance = setmetatable({}, DynamicPanel)
    instance.title = title
    instance.headers = type(headerItems) == 'table' and headerItems or {}
    instance.players = type(players) == 'table' and players or {}
    instance.colorTitle = colorTitle
    return instance
end

--- Adds a header to the dynamic panel.
---@param index any The index of the header.
---@param name string The name of the header.
---@param width number The width of the header.
function DynamicPanel:AddHeader(index, name, width)
    table.insert(self.headers, {
        index = index,
        name = name,
        width = width
    })
end

--- Reset players to the dynamic panel.
---@param player table The player data to add.
function DynamicPanel:ResetPlayers()
    self.players = {}
end

--- Adds a player to the dynamic panel.
---@param player table The player data to add.
function DynamicPanel:AddPlayer(player)
    table.insert(self.players, player)
end

--- Sets the players for the dynamic panel.
---@param players table The table of players to set.
function DynamicPanel:setPlayers(players)
    self.players = type(players) == 'table' and players or {}
end


--- Creates text to display.
---@param text string The text to display.
---@param x number The x-coordinate.
---@param y number The y-coordinate.
---@param scaleH number The horizontal scale of the text.
---@param scaleW number The vertical scale of the text.
---@param r number The red color component.
---@param g number The green color component.
---@param b number The blue color component.
---@param a number The alpha color component.
---@param align number The alignment of the text.
---@param font number The font to use.
---@param minX number The minimum x-wrap.
---@param maxX number The maximum x-wrap.
---@param shadow number The shadow of the text.
function DynamicPanel:CreateText(text, x, y, scaleH, scaleW, r, g, b, a, align, font, minX, maxX, shadow)
    SetTextFont(font)
    SetTextColour(r, g, b, a)
    SetTextScale(scaleH, scaleW)
    SetTextJustification(align)
    SetTextWrap(minX, maxX)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetTextOutline()
    SetTextCentre(true)
    EndTextCommandDisplayText(x, y)
end

--- Draws the header on the dynamic panel.
---@param header table The header to draw.
---@param x number The x-coordinate.
---@param y number The y-coordinate.
---@param rowWidth number The width of the row.
function DynamicPanel:DrawHeader(header, x, y, rowWidth)
    DrawRect(x, y, header.width * rowWidth, ROW_HEIGHT, DEFAULT_HEADER_COLOR.r,
        DEFAULT_HEADER_COLOR.g, DEFAULT_HEADER_COLOR.b, DEFAULT_HEADER_COLOR.a)
    local textWidth = 0.1 
    local textX = x - (textWidth * 0.7) / 2
    local textY = y - ROW_MARGIN - 0.01
    local alignType = 0

    self:CreateText(header.name, textX, textY, 0.3, 0.3, 255, 255, 255, 255, alignType, 0, 0.0, 1.0, 0)
end

--- Draws a player row on the dynamic panel.
---@param player table The player data to draw.
--- The player table should have the following structure:
---@param rowY number The y-coordinate of the row.
---@param headerPositions table The positions of the headers.
function DynamicPanel:DrawPlayerRow(player, rowY, headerPositions)
    for j, headerPos in ipairs(headerPositions) do
        local columnX = headerPos.x
        local columnWidth = headerPos.width
        local text = player[self.headers[j].index] or ""
        local bgColor = player.backgroundColor or DEFAULT_INFO_COLOR 
        local textColor = player.textColor or DEFAULT_TEXT_COLOR
        
        DrawRect(columnX, rowY, columnWidth, ROW_HEIGHT, bgColor.r, bgColor.g,
            bgColor.b, bgColor.a  or 255 )
   
        local textWidth = 0.26 
        local textX = columnX - (textWidth * 0.28) / 2
        local textY = rowY - ROW_MARGIN - 0.01
        local font, minX, maxX, shadow = 0, 0.0, 1.0, 1
        local scaleH, scaleW = 0.34, 0.3
        local alignType = 0

        self:CreateText(text, textX, textY, scaleH, scaleW, textColor.r, textColor.g,
        textColor.b, textColor.a or 255, alignType, font, minX, maxX, shadow)
    end
end

--- Displays the dynamic panel.
---@param centerVerticallyAdjustment number The adjustment for vertical centering.
function DynamicPanel:Show(centerVerticallyAdjustment)
    local titleHeight = ROW_HEIGHT
    local totalHeight = titleHeight + (ROW_VERTICAL_SPACE * #self.players)
    local screenWidth = 1.0 
    local screenHeight = 1.0 
    local yCalc = PANEL_POSITION_Y --(screenHeight - totalHeight) / 2
    local yStartOffset = yCalc + EXTRA_MARGIN_TOP

    local totalWidth = 0
    for _, header in ipairs(self.headers) do
        totalWidth = totalWidth + header.width
    end
    totalWidth = totalWidth * 0.95 

    local xMin = (screenWidth - totalWidth) / (type(centerVerticallyAdjustment) == 'number' and centerVerticallyAdjustment or 1.2)
    local xMax = xMin + totalWidth
    local rowWidth = xMax - xMin

    local colorTitle = self.colorTitle or {r=255, g=255, b=255, a=255}

    local align, font, minX, maxX, shadow =  0, 1, 0.0, 1.0, 1
    self:CreateText(self.title or 'Panel Title', 0.508, (yCalc - 0.06), 0.7, 0.7, colorTitle.r, colorTitle.g, colorTitle.b, colorTitle.a, align, font, minX, maxX, shadow )

    local titleX = xMin + (rowWidth / 2)
    local titleY = yStartOffset + titleHeight / 2
    local headerPositions = {} 

    for i, header in ipairs(self.headers) do
        local headerX = xMin + (header.width * rowWidth) / 2
        self:DrawHeader(header, headerX, titleY, rowWidth)

        table.insert(headerPositions, {
            x = headerX,
            width = header.width * rowWidth
        })

        xMin = xMin + header.width * rowWidth
    end

    for i, player in ipairs(self.players) do
        local rowY = yStartOffset + titleHeight / 2 + ROW_VERTICAL_SPACE * i 

        self:DrawPlayerRow(player, rowY, headerPositions)
    end
end

-- local examplePlayers = {
--     { playerName = "Player1", kills = 15, deaths = 5, test = 8, backgroundColor = {r = 200, g = 0, b = 0, a = 100} , textColor = {r = 200, g = 0, b = 0, a = 255}},
--     { playerName = "Player2", kills = 20, deaths = 7, test = 4, backgroundColor = {r = 0, g = 200, b = 0, a = 100} },
--     { playerName = "Player3", kills = 8, deaths = 3, test = 6 },
--     { playerName = "Player4", kills = 12, deaths = 10, test = 9, backgroundColor = {r = 0, g = 0, b = 200, a = 100} },
--     { playerName = "Player5", kills = 5, deaths = 2, test = 3 },
--     { playerName = "Player6", kills = 18, deaths = 8, test = 7 },
--     { playerName = "Player7", kills = 25, deaths = 15, test = 2 },
--     { playerName = "Player8", kills = 10, deaths = 4, test = 5 },
--     { playerName = "Player9", kills = 22, deaths = 11, test = 1 },
--     { playerName = "Player10", kills = 14, deaths = 6, test = 4 }
-- }

-- RegisterCommand('testPanel', function()
--     local dynamicPanel = DynamicPanel:new('Players', {}, {})
--     dynamicPanel:AddHeader('playerName', "Player Name", 0.38)
--     dynamicPanel:AddHeader('kills', "Kills", 0.12)
--     dynamicPanel:AddHeader('deaths', "Deaths", 0.12)
--     dynamicPanel:AddHeader('test', "Test", 0.12)
--     for _, player in ipairs(examplePlayers) do
--         dynamicPanel:AddPlayer(player)
--     end
--     while true do
--         dynamicPanel:Show()
--         Citizen.Wait(0)
--     end
-- end)
