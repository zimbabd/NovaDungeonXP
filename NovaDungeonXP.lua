local addon = CreateFrame("Frame", "NovaDungeonXP")

------------------------------------------------
-- Saved Variables
------------------------------------------------

NovaDungeonXPDB = NovaDungeonXPDB or {}

if not NovaDungeonXPDB.history then
    NovaDungeonXPDB.history = {}
end

if not NovaDungeonXPDB.minimap then
    NovaDungeonXPDB.minimap = {
        angle = 180,
<<<<<<< HEAD
        hide  = false
    }
end

-- Persistent active run state (survives /reload)
if NovaDungeonXPDB.activeRun == nil then
    NovaDungeonXPDB.activeRun = false
end
=======
        hide = false
    }
end

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce

------------------------------------------------
-- ALL Variables (declared first!)
------------------------------------------------

<<<<<<< HEAD
local running     = false
local dungeonName = ""
local startTime   = 0
local startXP     = 0
local startXPMax  = 0   -- UnitXPMax at run start, used for levelup detection

local gainedXP = 0
local mobs     = 0

local sortKey = nil
local sortAsc = true
local rows    = {}
=======
local running = false
local dungeonName = ""
local startTime = 0
local startXP = 0

local gainedXP = 0
local mobs = 0

local sortKey = nil
local sortAsc = true
local rows = {}
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce

local frame
local title
local close
local scrollFrame
local scrollChild
local headerButtons
local clearBtn
local DeleteRun

<<<<<<< HEAD
-- Flag: waiting for GetInstanceInfo to return a valid name
local pendingStart        = false
local pendingStartElapsed = 0
=======
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce

------------------------------------------------
-- Helpers
------------------------------------------------

local function FormatXP(xp)
<<<<<<< HEAD
    if xp >= 1000000 then
        return string.format("%.1fm", xp / 1000000)
    elseif xp >= 1000 then
        return string.format("%.1fk", xp / 1000)
=======

    if xp >= 1000000 then
        return string.format("%.1fm", xp / 1000000)

    elseif xp >= 1000 then
        return string.format("%.1fk", xp / 1000)

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    else
        return xp
    end
end

<<<<<<< HEAD
-- Format raw seconds -> "Xm Ys"
local function FormatDuration(seconds)
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    if m > 0 then
        return string.format("%dm %02ds", m, s)
    else
        return string.format("%ds", s)
    end
end

local function SaveRun(runDate, entered, left, duration, xph)
=======
local function SaveRun(runDate, entered, left, duration, xph)

    local minutes = duration / 60

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    table.insert(
        NovaDungeonXPDB.history,
        1,
        {
<<<<<<< HEAD
            dungeon  = dungeonName,
            date     = runDate,
            entered  = entered,
            left     = left,
            duration = duration,   -- raw seconds (replaces old float "time")
            xp       = gainedXP,
            xph      = xph,
            mobs     = mobs
=======
            dungeon = dungeonName,

            date = runDate,

            entered = entered,
            left = left,

            time = minutes,

            xp = gainedXP,
            xph = xph,

            mobs = mobs
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
        }
    )

    while #NovaDungeonXPDB.history > 100 do
<<<<<<< HEAD
        table.remove(NovaDungeonXPDB.history)
    end
end

-- Persist active run to SavedVariables so /reload does not lose progress
local function PersistActiveRun()
    NovaDungeonXPDB.activeRun = {
        running     = running,
        dungeonName = dungeonName,
        startTime   = startTime,
        startXP     = startXP,
        startXPMax  = startXPMax,
        gainedXP    = gainedXP,
        mobs        = mobs
    }
end

local function ClearActiveRun()
    NovaDungeonXPDB.activeRun = false
end

-- Restore active run state after /reload inside a dungeon
local function RestoreActiveRun()
    local ar = NovaDungeonXPDB.activeRun
    if ar and ar.running then
        running      = true
        dungeonName  = ar.dungeonName or ""
        startTime    = ar.startTime   or time()
        startXP      = ar.startXP     or UnitXP("player")
        startXPMax   = ar.startXPMax  or UnitXPMax("player")
        gainedXP     = ar.gainedXP    or 0
        mobs         = ar.mobs        or 0
        print("|cff00ff00Nova Dungeon XP:|r Resumed " .. dungeonName)
    end
end

------------------------------------------------
-- Instance type check (only party/raid = dungeon)
------------------------------------------------

local VALID_INSTANCE_TYPES = {
    party = true,
    raid  = true,
}

local function IsInDungeon()
    local inInstance, instanceType = IsInInstance()
    return inInstance and VALID_INSTANCE_TYPES[instanceType]
=======
        table.remove(
            NovaDungeonXPDB.history
        )
    end

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
end


------------------------------------------------
-- Dungeon start/end
------------------------------------------------

<<<<<<< HEAD
local function TryStartDungeon()
    local name = GetInstanceInfo()

    -- GetInstanceInfo can return empty string right after loading screen;
    -- return false so the caller retries via OnUpdate
    if not name or name == "" then
        return false
    end

    dungeonName  = name
    startTime    = time()
    startXP      = UnitXP("player")
    startXPMax   = UnitXPMax("player")
    gainedXP     = 0
    mobs         = 0
    running      = true
    pendingStart = false

    PersistActiveRun()

    print("|cff00ff00Nova Dungeon XP:|r " .. name .. " started")
    return true
end

local function StartDungeon()
    -- First attempt immediately; if name is empty, schedule retries via OnUpdate
    if not TryStartDungeon() then
        pendingStart        = true
        pendingStartElapsed = 0
    end
end

local function FinishDungeon()
=======
local function StartDungeon()

    local name = GetInstanceInfo()

    dungeonName = name

    startTime = time()
    startXP = UnitXP("player")

    gainedXP = 0
    mobs = 0

    running = true

    print("|cff00ff00Nova Dungeon XP:|r "..name.." started")

end

local function FinishDungeon()

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    if not running then
        return
    end

<<<<<<< HEAD
    local endTime  = time()
    local duration = endTime - startTime

    -- Ignore accidental entries under 60 s with zero XP
    if duration < 60 and gainedXP == 0 then
        running = false
        ClearActiveRun()
=======
    local endTime = time()
    local duration = endTime - startTime

    -- Игнорируем случайные заходы меньше минуты без опыта
    if duration < 60 and gainedXP == 0 then
        running = false
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
        return
    end

    local xph = 0
<<<<<<< HEAD
=======

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    if duration > 0 then
        xph = math.floor(gainedXP / duration * 3600)
    end

    local runDate = date("%d.%m.%Y", startTime)
<<<<<<< HEAD
    local entered = date("%a %b %d %H:%M", startTime)
    local left    = date("%a %b %d %H:%M", endTime)

    SaveRun(runDate, entered, left, duration, xph)

    -- Chat summary
    print("|cff00ff00Nova Dungeon XP|r")
    print("|cff00ff00------------------------------------------------|r")
    print("Dungeon      : " .. dungeonName)
    print(string.format("Duration     : %s", FormatDuration(duration)))
    print("XP Gained    : " .. FormatXP(gainedXP))
    print("XP / Hour    : " .. FormatXP(xph))
    print("Mobs Killed  : " .. mobs)
    print("|cff00ff00------------------------------------------------|r")

    running = false
    ClearActiveRun()
=======

    local entered = date("%a %b %d %H:%M", startTime)
    local left = date("%a %b %d %H:%M", endTime)

    local minutes = math.floor(duration / 60)
    local seconds = duration % 60

    -- Сохраняем результат
    SaveRun(
        runDate,
        entered,
        left,
        duration,
        xph
    )

    -- Вывод в чат
    print("|cff00ff00Nova Dungeon XP|r")
    print("|cff00ff00------------------------------------------------|r")

    print("Dungeon      : "..dungeonName)

    print(
        string.format(
            "Duration     : %dm %02ds",
            minutes,
            seconds
        )
    )

    print(
        "XP Gained    : "
        ..
        FormatXP(gainedXP)
    )

    print(
        "XP / Hour    : "
        ..
        FormatXP(xph)
    )

    print(
        "Mobs Killed  : "
        ..
        mobs
    )

    print("|cff00ff00------------------------------------------------|r")

    running = false

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
end

------------------------------------------------
-- Events
------------------------------------------------

<<<<<<< HEAD
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_XP_UPDATE")
addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

addon:SetScript("OnEvent", function(self, event, ...)

    -- PLAYER_LOGIN: restore persisted run state (fired once, UI is fully ready)
    if event == "PLAYER_LOGIN" then
        RestoreActiveRun()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        local inDungeon = IsInDungeon()

        if inDungeon and not running then
            StartDungeon()
        elseif not inDungeon and running then
            FinishDungeon()
        end

        return
    end

    -- XP update: correctly handle levelup
    if event == "PLAYER_XP_UPDATE" then
        if not running then return end

        local currentXP    = UnitXP("player")
        local currentXPMax = UnitXPMax("player")

        if currentXP >= startXP then
            -- Normal gain within the same level
            local diff = currentXP - startXP
            if diff > 0 then
                gainedXP = gainedXP + diff
            end
        else
            -- Levelup: player crossed a level boundary
            -- Gain = (startXPMax - startXP) to ding + currentXP on new level
            local toNextLevel = startXPMax - startXP
            if toNextLevel < 0 then toNextLevel = 0 end
            gainedXP = gainedXP + toNextLevel + currentXP
        end

        startXP    = currentXP
        startXPMax = currentXPMax
        PersistActiveRun()
        return
    end

    -- Count mob kills via combat log
    -- CHAT_MSG_COMBAT_XP_GAIN does not exist in 3.3.5 WotLK clients
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not running then return end

        local timestamp, subevent, hideCaster,
              sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
              destGUID, destName, destFlags = ...

        if subevent == "UNIT_DIED" then
            -- COMBATLOG_OBJECT_TYPE_NPC         = 0x0800
            -- COMBATLOG_OBJECT_REACTION_HOSTILE = 0x0040
            local isNPC     = bit.band(destFlags or 0, 0x0800) ~= 0
            local isHostile = bit.band(destFlags or 0, 0x0040) ~= 0
            if isNPC and isHostile then
                mobs = mobs + 1
                PersistActiveRun()
            end
        end

        return
=======
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_XP_UPDATE")
addon:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

addon:SetScript(
"OnEvent",
function(self,event,...)

    if event=="PLAYER_ENTERING_WORLD" then

        local inInstance = IsInInstance()

        if inInstance and not running then

            StartDungeon()

        elseif not inInstance and running then

            FinishDungeon()

        end

    elseif event=="PLAYER_XP_UPDATE" then

        if running then

            local xp = UnitXP("player")

            local diff = xp - startXP

            if diff > 0 then

                gainedXP = gainedXP + diff
                startXP = xp

            end

        end

    elseif event=="CHAT_MSG_COMBAT_XP_GAIN" then

        if running then

            mobs = mobs + 1

        end

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    end

end)

<<<<<<< HEAD
-- OnUpdate: retry TryStartDungeon while pendingStart == true
-- Gives up after 3 seconds and falls back to "Unknown Dungeon"
addon:SetScript("OnUpdate", function(self, elapsed)
    if not pendingStart then return end

    pendingStartElapsed = pendingStartElapsed + elapsed

    if pendingStartElapsed >= 3 then
        -- Final attempt; fall back to "Unknown Dungeon" if still empty
        pendingStart = false
        local name = GetInstanceInfo()
        dungeonName  = (name and name ~= "") and name or "Unknown Dungeon"
        startTime    = time()
        startXP      = UnitXP("player")
        startXPMax   = UnitXPMax("player")
        gainedXP     = 0
        mobs         = 0
        running      = true
        PersistActiveRun()
        print("|cff00ff00Nova Dungeon XP:|r " .. dungeonName .. " started")
        return
    end

    -- Retry approximately every 0.5 seconds
    if pendingStartElapsed >= 0.5 then
        TryStartDungeon()
    end
end)

=======
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
------------------------------------------------
-- UI Elements (create frame first, then all child elements)
------------------------------------------------

frame = CreateFrame(
"Frame",
"NovaDungeonXPWindow",
UIParent
)

frame:SetWidth(750)
frame:SetHeight(400)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

<<<<<<< HEAD
frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
=======
frame:SetScript(
"OnDragStart",
function(self)
    self:StartMoving()
end
)

frame:SetScript(
"OnDragStop",
function(self)
    self:StopMovingOrSizing()
end
)
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce

close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)
table.insert(UISpecialFrames, "NovaDungeonXPWindow")

frame:SetBackdrop({
<<<<<<< HEAD
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 16
=======
bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
tile=true,
tileSize=16,
edgeSize=16
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
})

frame:Hide()

title = frame:CreateFontString(nil, "OVERLAY")
title:SetPoint("TOP", 0, -15)
title:SetFont("Fonts\\ARIALN.TTF", 20)
title:SetText("Nova Dungeon XP")

------------------------------------------------
<<<<<<< HEAD
-- Scroll Frame & Child
=======
-- Scroll Frame & Child (created before UpdateWindow!)
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
------------------------------------------------

scrollFrame = CreateFrame("ScrollFrame", "NovaDungeonXPScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 20, -85)
scrollFrame:SetPoint("BOTTOMRIGHT", -32, 10)

scrollChild = CreateFrame("Frame", "NovaDungeonXPScrollChild", scrollFrame)
scrollChild:SetWidth(700)
scrollChild:SetHeight(1)
scrollFrame:SetScrollChild(scrollChild)

------------------------------------------------
<<<<<<< HEAD
-- Row factory and table functions
=======
-- Functions that use UI elements (defined AFTER UI elements exist!)
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
------------------------------------------------

local function CreateRow(index)
    local row = {}
<<<<<<< HEAD

    row.frame = CreateFrame("Frame", nil, scrollChild)
    row.frame:SetWidth(700)
    row.frame:SetHeight(24)
    local y = -((index - 1) * 24)
    row.frame:SetPoint("TOPLEFT", 0, y)
    row.frame:EnableMouse(true)

    row.bg = row.frame:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row.frame)
    row.bg:SetTexture(0, 0, 0, 0)

    row.frame:SetScript("OnEnter", function()
        row.bg:SetTexture(0.3, 0.3, 0.3, 0.5)
    end)
    row.frame:SetScript("OnLeave", function()
        row.bg:SetTexture(0, 0, 0, 0)
    end)

    row.num  = row.frame:CreateFontString(nil, "OVERLAY")
    row.name = row.frame:CreateFontString(nil, "OVERLAY")
    row.time = row.frame:CreateFontString(nil, "OVERLAY")
    row.xp   = row.frame:CreateFontString(nil, "OVERLAY")
    row.xph  = row.frame:CreateFontString(nil, "OVERLAY")

=======
    
    -- Create a frame for the row to handle mouse events and background
    row.frame = CreateFrame("Frame", nil, scrollChild)
    row.frame:SetWidth(700)
    row.frame:SetHeight(24)
    local y = - ((index - 1) * 24)
    row.frame:SetPoint("TOPLEFT", 0, y)
    row.frame:EnableMouse(true)
    
    -- Background texture for highlighting
    row.bg = row.frame:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row.frame)
    row.bg:SetTexture(0, 0, 0, 0) -- Fully transparent by default
    
    -- OnEnter/OnLeave for hover highlight
    row.frame:SetScript("OnEnter", function()
        row.bg:SetTexture(0.3, 0.3, 0.3, 0.5) -- Semi-transparent gray
    end)
    row.frame:SetScript("OnLeave", function()
        row.bg:SetTexture(0, 0, 0, 0) -- Back to transparent
    end)
    
    -- Font strings parented to the row frame
    row.num = row.frame:CreateFontString(nil, "OVERLAY")
    row.name = row.frame:CreateFontString(nil, "OVERLAY")
    row.time = row.frame:CreateFontString(nil, "OVERLAY")
    row.xp = row.frame:CreateFontString(nil, "OVERLAY")
    row.xph = row.frame:CreateFontString(nil, "OVERLAY")
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    local font = "Fonts\\ARIALN.TTF"
    row.num:SetFont(font, 16)
    row.name:SetFont(font, 16)
    row.time:SetFont(font, 16)
    row.xp:SetFont(font, 16)
    row.xph:SetFont(font, 16)
<<<<<<< HEAD

    row.num:SetPoint("TOPLEFT",   0, 0)
    row.name:SetPoint("TOPLEFT",  35, 0)
    row.time:SetPoint("TOPLEFT", 280, 0)
    row.xp:SetPoint("TOPLEFT",   380, 0)
    row.xph:SetPoint("TOPLEFT",  500, 0)

=======
    
    -- Position font strings relative to the row frame
    row.num:SetPoint("TOPLEFT", 0, 0)
    row.name:SetPoint("TOPLEFT", 35, 0)
    row.time:SetPoint("TOPLEFT", 280, 0)
    row.xp:SetPoint("TOPLEFT", 380, 0)
    row.xph:SetPoint("TOPLEFT", 500, 0)
    
    -- Delete "X" button
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    row.deleteBtn = CreateFrame("Button", nil, row.frame, "UIPanelCloseButton")
    row.deleteBtn:SetWidth(20)
    row.deleteBtn:SetHeight(20)
    row.deleteBtn:SetPoint("TOPRIGHT", 0, 0)
<<<<<<< HEAD

=======
    
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    return row
end

local function SortRuns(a, b)
    if not sortKey then return false end
    local valA = a[sortKey] or 0
    local valB = b[sortKey] or 0
    if type(valA) == "string" then
        valA = valA:lower()
        valB = valB:lower()
    end
    if sortAsc then
        return valA < valB
    else
        return valA > valB
    end
end

local function UpdateWindow()
<<<<<<< HEAD
=======

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    for _, row in ipairs(rows) do
        row.num:SetText("")
        row.name:SetText("")
        row.time:SetText("")
        row.xp:SetText("")
        row.xph:SetText("")
<<<<<<< HEAD
        row.deleteBtn:Hide()
=======
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    end

    local bestXPH = 0
    for _, v in ipairs(NovaDungeonXPDB.history) do
        if (v.xph or 0) > bestXPH then
            bestXPH = v.xph
        end
    end

    local display = {}
    for i, v in ipairs(NovaDungeonXPDB.history) do
        display[i] = v
    end

    if sortKey then
        table.sort(display, SortRuns)
    end

    for i, v in ipairs(display) do
        if not rows[i] then
            rows[i] = CreateRow(i)
        end

        local color = ""
<<<<<<< HEAD
        if bestXPH > 0 and (v.xph or 0) == bestXPH then
            color = "|cff00ff00"
        end
        local reset = "|r"

        -- Support both new (duration = integer seconds) and
        -- old (time = float minutes) saved variable formats
        local timeStr
        if v.duration then
            timeStr = FormatDuration(v.duration)
        else
            timeStr = string.format("%dm", math.floor(v.time or 0))
        end

        rows[i].num:SetText(color .. i .. reset)
        rows[i].name:SetText(color .. (v.dungeon or "Unknown") .. reset)
        rows[i].time:SetText(color .. timeStr .. reset)
        rows[i].xp:SetText(color .. FormatXP(v.xp or 0) .. reset)
        rows[i].xph:SetText(color .. FormatXP(v.xph or 0) .. reset)
        rows[i].deleteBtn:Show()

        -- Capture entry in local scope so the closure is correct
        local entry = v
        rows[i].deleteBtn:SetScript("OnClick", function()
            DeleteRun(entry)
        end)
    end

    scrollChild:SetHeight(math.max(1, #display * 24))
end

function DeleteRun(runToDelete)
=======
        if (v.xph or 0) == bestXPH then
            color = "|cff00ff00"
        end
        local reset = "|r"
        rows[i].num:SetText(color..i..reset)
        rows[i].name:SetText(color..(v.dungeon or "Unknown")..reset)
        rows[i].time:SetText(color..string.format("%dm", v.time or 0)..reset)
        rows[i].xp:SetText(color..FormatXP(v.xp or 0)..reset)
        rows[i].xph:SetText(color..FormatXP(v.xph or 0)..reset)
        
        -- Set up delete button for this row
        rows[i].deleteBtn:SetScript("OnClick", function()
            DeleteRun(v)
        end)
    end

    local numRows = #display
    scrollChild:SetHeight(numRows * 24)
end

function DeleteRun(runToDelete)
    -- Find and remove the run from history
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    for i, run in ipairs(NovaDungeonXPDB.history) do
        if run == runToDelete then
            table.remove(NovaDungeonXPDB.history, i)
            break
        end
    end
<<<<<<< HEAD
=======
    -- Refresh the display
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
    UpdateWindow()
end

-- Clear History Button
clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
clearBtn:SetWidth(100)
clearBtn:SetHeight(24)
clearBtn:SetPoint("TOPRIGHT", -10, -30)
clearBtn:SetText("Clear History")

<<<<<<< HEAD
=======
-- Function to clear history with confirmation
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
local function ClearHistory()
    StaticPopupDialogs["NOVADUNGEONXP_CLEAR_HISTORY"] = {
        text = "Are you sure you want to clear all dungeon history?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            NovaDungeonXPDB.history = {}
            UpdateWindow()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("NOVADUNGEONXP_CLEAR_HISTORY")
end

clearBtn:SetScript("OnClick", ClearHistory)

frame:SetScript("OnShow", UpdateWindow)

------------------------------------------------
<<<<<<< HEAD
-- Header Buttons
=======
-- Header Buttons (defined after UpdateWindow!)
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
------------------------------------------------

headerButtons = {}

local function CreateHeaderButton(text, key, x)
    local btn = CreateFrame("Button", nil, frame)
    btn:SetWidth(150)
    btn:SetHeight(24)
    btn:SetPoint("TOPLEFT", x, -48)

    local fs = btn:CreateFontString(nil, "OVERLAY")
    fs:SetPoint("LEFT", 0, 0)
    fs:SetFont("Fonts\\ARIALN.TTF", 16)
    fs:SetText(text)
    btn.text = fs

    if key then
        btn:SetScript("OnClick", function()
            if sortKey == key then
                sortAsc = not sortAsc
            else
                sortKey = key
                sortAsc = true
            end
            UpdateWindow()
        end)
    end

    return btn
end

<<<<<<< HEAD
headerButtons.num  = CreateHeaderButton("#",         nil,        20)
headerButtons.name = CreateHeaderButton("Dungeon",   "dungeon",  55)
headerButtons.time = CreateHeaderButton("Time",      "duration", 300)
headerButtons.xp   = CreateHeaderButton("XP",        "xp",       400)
headerButtons.xph  = CreateHeaderButton("XP / Hour", "xph",      520)
=======
headerButtons.num = CreateHeaderButton("#", nil, 20)
headerButtons.name = CreateHeaderButton("Dungeon", "dungeon", 55)
headerButtons.time = CreateHeaderButton("Time", "time", 300)
headerButtons.xp = CreateHeaderButton("XP", "xp", 400)
headerButtons.xph = CreateHeaderButton("XP / Hour", "xph", 520)
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce

------------------------------------------------
-- Slash Commands
------------------------------------------------

<<<<<<< HEAD
SLASH_NOVADXP1 = "/ndxp"

SlashCmdList["NOVADXP"] = function(msg)
    if msg == "reset" then
        NovaDungeonXPDB.history = {}
        print("|cff00ff00Nova Dungeon XP:|r history cleared")
    else
=======
SLASH_NOVADXP1="/ndxp"

SlashCmdList["NOVADXP"]=function(msg)

    if msg=="reset" then

        NovaDungeonXPDB.history={}
        print("NovaDungeonXP history cleared")

    else

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
        if frame:IsShown() then
            frame:Hide()
        else
            UpdateWindow()
            frame:Show()
        end
<<<<<<< HEAD
    end
=======

    end

>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
end

------------------------------------------------
-- Minimap Button
------------------------------------------------

<<<<<<< HEAD
local LDB    = LibStub("LibDataBroker-1.1")
local DBIcon = LibStub("LibDBIcon-1.0")

local minimapObject = LDB:NewDataObject(
    "NovaDungeonXP",
    {
        type  = "launcher",
        text  = "Nova Dungeon XP",
        icon  = "Interface\\AddOns\\NovaDungeonXP\\ndxp",
        OnClick = function(self, button)
            if frame:IsShown() then
                frame:Hide()
            else
                UpdateWindow()
                frame:Show()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Nova Dungeon XP")
            tooltip:AddLine("/ndxp - open window")
        end
    }
=======
local LDB = LibStub("LibDataBroker-1.1")
local DBIcon = LibStub("LibDBIcon-1.0")

local minimapObject = LDB:NewDataObject(
"NovaDungeonXP",
{
    type = "launcher",
    text = "Nova Dungeon XP",
    icon = "Interface\\AddOns\\NovaDungeonXP\\ndxp",
    OnClick = function(self, button)
        if frame:IsShown() then
            frame:Hide()
        else
            UpdateWindow()
            frame:Show()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Nova Dungeon XP")
        tooltip:AddLine("/ndxp - open window")
    end
}
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
)

if not NovaDungeonXPMinimapDB then
    NovaDungeonXPMinimapDB = {
        minimapPos = 225,
    }
end

DBIcon:Register(
<<<<<<< HEAD
    "NovaDungeonXP",
    minimapObject,
    NovaDungeonXPMinimapDB
=======
"NovaDungeonXP",
minimapObject,
NovaDungeonXPMinimapDB
>>>>>>> 84e4139800a1b333367c7459f47e00d6044064ce
)
