local addonName = ...
local events = CreateFrame("Frame")
local activePlates, icons = {}, {}
local elapsed = 0

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffShowMe:|r " .. message)
end

local function InitializeSettings()
    if type(ShowMeDB) ~= "table" then ShowMeDB = {} end
    ShowMeDB.nameplateQuestIcon = ShowMeDB.nameplateQuestIcon == true
end

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

-- Inspect structured objective lines, without English-only kill/loot keywords.
-- nil means unavailable or restricted data; false means no unfinished objective.
local function TooltipQuestObjective(unit)
    if not (C_TooltipInfo and C_TooltipInfo.GetUnit and Enum
        and Enum.TooltipDataLineType and Enum.TooltipDataLineType.QuestObjective) then
        return nil
    end
    local data = C_TooltipInfo.GetUnit(unit)
    if not data then return nil end
    if TooltipUtil and TooltipUtil.SurfaceArgs then TooltipUtil.SurfaceArgs(data) end
    if IsSecret(data.lines) or type(data.lines) ~= "table" then return nil end
    local restricted, foundObjective = false, false
    for _, line in ipairs(data.lines) do
        if TooltipUtil and TooltipUtil.SurfaceArgs then TooltipUtil.SurfaceArgs(line) end
        if IsSecret(line.type) then
            restricted = true
        elseif line.type == Enum.TooltipDataLineType.QuestObjective then
            foundObjective = true
            if IsSecret(line.leftText) then
                restricted = true
            elseif type(line.leftText) == "string" then
                -- The counter can precede or follow a localized objective label.
                local have, need = line.leftText:match("(%d+)%s*/%s*(%d+)")
                if have and need then
                    if tonumber(have) < tonumber(need) then return true end
                else
                    -- Objectives without counters use the client's relation API.
                    restricted = true
                end
            else
                restricted = true
            end
        end
    end
    if restricted or not foundObjective then return nil end
    return false
end

local function QuestRelation(unit)
    if C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest then
        local ok, related = pcall(C_QuestLog.UnitIsRelatedToActiveQuest, unit)
        if ok then return related end
    end
end

local function GetIcon(plate)
    local icon = icons[plate]
    if not icon then
        -- Own unprotected overlay; never change Blizzard's nameplate visibility.
        icon = CreateFrame("Frame", nil, plate)
        icon:SetSize(20, 20)
        icon:EnableMouse(false)
        local texture = icon:CreateTexture(nil, "OVERLAY")
        texture:SetAllPoints()
        texture:SetAtlas("QuestNormal")
        icon:Hide()
        icons[plate] = icon
    end
    local unitFrame = plate.UnitFrame
    local anchor = unitFrame and (unitFrame.HealthBarsContainer or unitFrame.healthBar)
        or plate
    icon:ClearAllPoints()
    icon:SetPoint("RIGHT", anchor, "LEFT", -6, 0)
    return icon
end

local function UpdatePlate(unit, plate)
    local icon = icons[plate]
    if not (ShowMeDB and ShowMeDB.nameplateQuestIcon) then
        if icon then icon:Hide() end
        return
    end
    icon = GetIcon(plate)
    icon:Hide()
    local ok, isPlayer = pcall(UnitIsPlayer, unit)
    if not ok or IsSecret(isPlayer) or isPlayer then return end
    local deadOK, dead = pcall(UnitIsDeadOrGhost, unit)
    if deadOK and not IsSecret(dead) and dead then return end

    local related = QuestRelation(unit)
    if not IsSecret(related) and related == false then return end
    local tooltipOK, objective = pcall(TooltipQuestObjective, unit)
    if tooltipOK and objective ~= nil then
        icon:SetShown(objective)
    elseif IsSecret(related) then
        -- A secret boolean may only be passed to the engine, never inspected.
        if not pcall(icon.SetShown, icon, related) then icon:Hide() end
    else
        icon:SetShown(related == true)
    end
end

local function UpdateAll()
    for unit, plate in pairs(activePlates) do UpdatePlate(unit, plate) end
end

local function DiscoverPlates()
    for _, icon in pairs(icons) do icon:Hide() end
    wipe(activePlates)
    if C_NamePlate and C_NamePlate.GetNamePlates then
        for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
            local unit = plate.namePlateUnitToken
            if unit then activePlates[unit] = plate end
        end
    end
    UpdateAll()
end

local function PrintHelp()
    Print("Available commands (on: enable icons, off: disable icons):")
    Print("/showme nameplate-quest-icon on - Show a yellow exclamation mark left of quest mob nameplates.")
    Print("/showme nameplate-quest-icon off - Hide ShowMe's quest icons.")
    Print("/showme status - Show the saved setting.")
    Print("/showme help - Show this help.")
end

for _, event in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD",
    "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "QUEST_LOG_UPDATE",
    "UNIT_QUEST_LOG_CHANGED", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED" }) do
    events:RegisterEvent(event)
end

events:SetScript("OnEvent", function(_, event, unit)
    if event == "ADDON_LOADED" then
        if unit == addonName then InitializeSettings() end
        return
    end
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        InitializeSettings()
        DiscoverPlates()
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
        if plate then
            -- Clear a recycled plate's old marker before evaluating its new mob.
            if icons[plate] then icons[plate]:Hide() end
            activePlates[unit] = plate
            UpdatePlate(unit, plate)
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local plate = activePlates[unit]
        if plate and icons[plate] then icons[plate]:Hide() end
        activePlates[unit] = nil
    elseif event ~= "UNIT_QUEST_LOG_CHANGED" or unit == "player" then
        UpdateAll()
    end
end)

-- Retry delayed tooltip data and keep anchors current when plate layouts change.
-- Only visible plates are inspected, and only while the feature is enabled.
events:SetScript("OnUpdate", function(_, delta)
    if not (ShowMeDB and ShowMeDB.nameplateQuestIcon) or not next(activePlates) then
        elapsed = 0
        return
    end
    elapsed = elapsed + delta
    if elapsed >= 0.5 then
        elapsed = 0
        UpdateAll()
    end
end)

SLASH_SHOWME1 = "/showme"
SlashCmdList.SHOWME = function(message)
    message = message:lower():match("^%s*(.-)%s*$")
    if message == "help" or message == "" then PrintHelp(); return end
    InitializeSettings()
    if message == "status" then
        Print("nameplate-quest-icon - Quest mob icons: "
            .. (ShowMeDB.nameplateQuestIcon and "on" or "off"))
        return
    end
    local name, mode = message:match("^(%S+)%s+(%S+)$")
    if name ~= "nameplate-quest-icon" or (mode ~= "on" and mode ~= "off") then
        Print("Invalid command. For usage and available parameters, type /showme help")
        return
    end
    ShowMeDB.nameplateQuestIcon = mode == "on"
    DiscoverPlates()
    Print("Quest mob nameplate icons are " .. (mode == "on" and "enabled." or "disabled."))
end
