local addonName, DTKC = ...

-- ===============================
-- TOTAL KILLS FRAME
-- ===============================

local frame = CreateFrame("Frame", "DromsTrashKillCountFrame", UIParent)
frame:SetSize(80, 30)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
frame:SetFrameStrata("HIGH")
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    tile = true,
    tileSize = 16
})
frame:SetBackdropColor(0, 0, 0, 0.6)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:Show()

frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetPoint("BOTTOM", frame, "TOP", 0, 6)
label:SetText("Kills")

local totalText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
totalText:SetPoint("CENTER", frame, "CENTER", 0, 2)
totalText:SetText("0")

-- ===============================
-- MULTI-KILL FRAME (SETUP MODE)
-- ===============================

local multiFrame = CreateFrame("Frame", "DromsMultiKillFrame", UIParent)
multiFrame:SetSize(250, 110)
multiFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
multiFrame:SetFrameStrata("DIALOG")
multiFrame:SetMovable(true)
multiFrame:EnableMouse(true)
multiFrame:RegisterForDrag("LeftButton")

multiFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16
})
multiFrame:SetBackdropColor(0, 0, 0, 0.8)

multiFrame:SetScript("OnDragStart", multiFrame.StartMoving)
multiFrame:SetScript("OnDragStop", multiFrame.StopMovingOrSizing)

-- Big number
local multiText = multiFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
multiText:SetFont("Fonts\\FRIZQT__.TTF", 72, "OUTLINE")
multiText:SetPoint("CENTER", multiFrame, "CENTER", 0, 18)
multiText:SetText("Drag and press ready\nthen type /dtkc help to\nsee all your options")
multiText:SetTextColor(1, 1, 1)

-- Kill name text
local multiLabel = multiFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
multiLabel:SetFont("Fonts\\FRIZQT__.TTF", 28, "OUTLINE")
multiLabel:SetPoint("TOP", multiText, "BOTTOM", 0, -4)
multiLabel:SetText("")
multiLabel:SetTextColor(1, 1, 1)

-- Ready button
local readyButton = CreateFrame("Button", nil, multiFrame, "UIPanelButtonTemplate")
readyButton:SetSize(80, 22)
readyButton:SetPoint("BOTTOM", multiFrame, "BOTTOM", 0, 10)
readyButton:SetText("Ready")

multiFrame:Show()

-- ===============================
-- STATE
-- ===============================

local trashCount = 0
local windowKills = 0
local firstKillTime = 0
local lastKillTime = 0

local MULTI_WINDOW = 0.15
local MULTI_MODE = "burst"    -- "burst" or "streak"
local multiCount = 0
local MULTI_DISPLAY_TIME = 2    
local multiTimer = 0
local setupMode = true

-- ===============================
-- COLOR + TITLE + FONT TIERS
-- ===============================

local function GetMultiInfo(kills)
    if kills < 3 then
        return 0.4, 1.0, 0.4, "Multi Kill", "GameFontNormalLarge"

    elseif kills < 5 then
        return 0.6, 1.0, 0.2, "Mega Kill", "GameFontHighlightLarge"

    elseif kills < 7 then
        return 1.0, 1.0, 0.2, "Ultra Kill", "GameFontNormalHuge"

    elseif kills < 10 then
        return 1.0, 0.75, 0.25, "Rampage", "QuestTitleFont"

    elseif kills < 20 then
        return 1.0, 0.55, 0.15, "Annihilation", "QuestTitleFont"

    elseif kills < 50 then
        return 1.0, 0.35, 0.15, "Mythic Slaughter", "QuestTitleFont"

    elseif kills < 100 then
        return 0.95, 0.15, 0.15, "City Buster", "QuestTitleFont"

    elseif kills < 150 then
        return 0.85, 0.15, 0.6, "Continent Buster", "QuestTitleFont"

    elseif kills < 200 then
        return 0.9, 0.4, 0.9, "Planet Buster", "QuestTitleFont"

    elseif kills < 300 then
        return 0.95, 0.65, 0.95, "Galaxy Buster", "QuestTitleFont"

    elseif kills < 400 then
        return 1.0, 0.85, 0.85, "Ascendant", "QuestTitleFont"

    elseif kills <= 499 then
        return 1.0, 0.95, 0.95, "Transcendent", "QuestTitleFont"
    else
        return 1.0, 1.0, 1.0, "Godlike", "QuestTitleFont"
    end
end


-- ===============================
-- TIMER (ONLY AFTER READY)
-- ===============================

multiFrame:SetScript("OnUpdate", function(self, elapsed)
    if setupMode then return end
    if not self:IsShown() then return end

    multiTimer = multiTimer + elapsed
    if multiTimer >= MULTI_DISPLAY_TIME then
        self:Hide()
        multiTimer = 0
    end
end)

-- ===============================
-- READY BUTTON LOGIC
-- ===============================

readyButton:SetScript("OnClick", function()
    setupMode = false

    -- Hide setup visuals
    multiFrame:SetBackdrop(nil)
    readyButton:Hide()
    multiText:SetText("")
    multiLabel:SetText("")
    multiFrame:Hide()
end)

-- ===============================
-- EVENTS
-- ===============================

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if setupMode then return end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent = ...

        if subevent == "UNIT_DIED" then
            local now = GetTime()

            -- total kills (unchanged)
            trashCount = trashCount + 1
            totalText:SetText(trashCount)

            -- =========================
            -- MULTIKILL LOGIC
            -- =========================

            if windowKills == 0 then
                -- first kill in a sequence
                windowKills = 1
                firstKillTime = now
                lastKillTime = now
            else
                if MULTI_MODE == "streak" then
                    -- Killstreak: reset window on each kill
                    if now - lastKillTime <= MULTI_WINDOW then
                        windowKills = windowKills + 1
                        lastKillTime = now
                    else
                        windowKills = 1
                        firstKillTime = now
                        lastKillTime = now
                    end
                else
                    -- Burst: fixed window from first kill
                    if now - firstKillTime <= MULTI_WINDOW then
                        windowKills = windowKills + 1
                    else
                        windowKills = 1
                        firstKillTime = now
                        lastKillTime = now
                    end
                end
            end

            -- =========================
            -- DISPLAY (unchanged)
            -- =========================

            if windowKills >= 2 then
                local r, g, b, title, font = GetMultiInfo(windowKills)

                multiText:SetFontObject(font)
                multiText:SetText(windowKills)
                multiText:SetTextColor(r, g, b)

                multiLabel:SetFontObject(font)
                multiLabel:SetText(title)
                multiLabel:SetTextColor(r, g, b)

                multiTimer = 0
                multiFrame:Show()
            end
        end

    elseif event == "ZONE_CHANGED_NEW_AREA"
        or event == "PLAYER_ENTERING_WORLD" then

        trashCount = 0
        windowKills = 0
        firstKillTime = 0
        lastKillTime = 0
        multiTimer = 0

        totalText:SetText("0")
        multiFrame:Hide()
    end
end)
local function ShowTotalCounter(show)
    if show then
        frame:Show()
    else
        frame:Hide()
    end
end

local function ShowMultiCounter(show)
    if show then
        multiFrame:Show()
    else
        multiFrame:Hide()
    end
end



SLASH_DTKC1 = "/dtkc"
SlashCmdList["DTKC"] = function(msg)
    local a, b = msg:match("^(%S+)%s*(%S*)$")
    if not a then return end

    a = a:lower()
    b = b:lower()

    local num = tonumber(b)

    -- numeric settings
    if a == "window" and num then
        MULTI_WINDOW = num
        print("DTKC: MULTI_WINDOW set to", num)

    elseif a == "display" and num then
        MULTI_DISPLAY_TIME = num
        print("DTKC: MULTI_DISPLAY_TIME set to", num)

    -- mode
    elseif a == "mode" then
        if b == "burst" or b == "b" then
            MULTI_MODE = "burst"
            print("DTKC: Multikill mode set to BURST")
        elseif b == "streak" or b == "s" then
            MULTI_MODE = "streak"
            print("DTKC: Multikill mode set to KILLSTREAK")
        else
            print("DTKC: usage /dtkc mode burst|streak")
        end

    -- total counter visibility
    elseif a == "total" then
        if b == "show" then
            ShowTotalCounter(true)
            print("DTKC: Total counter shown")
        elseif b == "hide" then
            ShowTotalCounter(false)
            print("DTKC: Total counter hidden")
        end

    -- multikill counter visibility
    elseif a == "multi" then
        if b == "show" then
            ShowMultiCounter(true)
            print("DTKC: Multikill counter shown")
        elseif b == "hide" then
            ShowMultiCounter(false)
            print("DTKC: Multikill counter hidden")
        end

    else
        print("DTKC commands:")
        print("/dtkc window <seconds>  - sets the time window for counting kills")
        print("/dtkc display <seconds> - sets how long the counter stays visible")
        print("/dtkc mode <burst> | <streak>")

        print("> STREAK: Every kill resets the time window. The count continues as long as you keep killing.")
        print("> BURST: Fixed time window. Only counts kills that happen within the window (recommended: 0.15).")

        print("/dtkc total <show> | <hide>  - total kills counter")
        print("/dtkc multi <show> | <hide>  - multikill counter")

    end
end


