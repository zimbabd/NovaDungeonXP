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
        hide = false
    }
end


------------------------------------------------
-- Variables
------------------------------------------------

local running = false
local dungeonName = ""
local startTime = 0
local startXP = 0

local gainedXP = 0
local mobs = 0


------------------------------------------------
-- Helpers
------------------------------------------------

local function FormatXP(xp)

    if xp >= 1000000 then
        return string.format("%.1fm", xp / 1000000)

    elseif xp >= 1000 then
        return string.format("%.1fk", xp / 1000)

    else
        return xp
    end
end



local function SaveRun(runDate, entered, left, duration, xph)

    local minutes = duration / 60


    table.insert(
        NovaDungeonXPDB.history,
        1,
		{
			dungeon = dungeonName,

			date = runDate,

			entered = entered,
			left = left,

			time = minutes,

			xp = gainedXP,
			xph = xph,

			mobs = mobs
		}
    )


    while #NovaDungeonXPDB.history > 10 do
        table.remove(
            NovaDungeonXPDB.history
        )
    end

end


------------------------------------------------
-- Dungeon start/end
------------------------------------------------

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

    if not running then
        return
    end

    local endTime = time()
    local duration = endTime - startTime


    -- Игнорируем случайные заходы меньше минуты без опыта
    if duration < 60 and gainedXP == 0 then
        running = false
        return
    end


    local xph = 0

    if duration > 0 then
        xph = math.floor(gainedXP / duration * 3600)
    end


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

end

------------------------------------------------
-- Events
------------------------------------------------


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


    end


end)



------------------------------------------------
-- Window
------------------------------------------------


local frame = CreateFrame(
"Frame",
"NovaDungeonXPWindow",
UIParent
)


frame:SetWidth(750)
frame:SetHeight(400)
frame:SetPoint(
"CENTER"
)
frame:SetMovable(true)
frame:EnableMouse(true)

frame:RegisterForDrag("LeftButton")


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


local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)

table.insert(UISpecialFrames, "NovaDungeonXPWindow")

frame:SetBackdrop({
bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
tile=true,
tileSize=16,
edgeSize=16
})


frame:Hide()



local title = frame:CreateFontString(
nil,
"OVERLAY",
"GameFontNormalLarge"
)

title:SetPoint(
"TOP",
0,
-15
)

title:SetText(
"Nova Dungeon XP"
)



local rows = {}


local function CreateRow(index)

    local row = {}

    row.num = frame:CreateFontString(nil, "OVERLAY")
    row.name = frame:CreateFontString(nil, "OVERLAY")
    row.time = frame:CreateFontString(nil, "OVERLAY")
    row.xp = frame:CreateFontString(nil, "OVERLAY")
    row.xph = frame:CreateFontString(nil, "OVERLAY")


    local font = "Fonts\\ARIALN.TTF"

    row.num:SetFont(font, 16)
    row.name:SetFont(font, 16)
    row.time:SetFont(font, 16)
    row.xp:SetFont(font, 16)
    row.xph:SetFont(font, 16)


    local y = -70 - (index * 24)


    row.num:SetPoint("TOPLEFT", 20, y)
    row.name:SetPoint("TOPLEFT", 55, y)
    row.time:SetPoint("TOPLEFT", 300, y)
    row.xp:SetPoint("TOPLEFT", 400, y)
    row.xph:SetPoint("TOPLEFT", 520, y)


    return row

end

local header = CreateRow(0)

header.num:SetText("#")
header.name:SetText("Dungeon")
header.time:SetText("Time")
header.xp:SetText("XP")
header.xph:SetText("XP / Hour")


local function UpdateWindow()


    for _,row in ipairs(rows) do

        row.num:SetText("")
        row.name:SetText("")
        row.time:SetText("")
        row.xp:SetText("")
        row.xph:SetText("")

    end


    local bestXPH = 0


    for _,v in ipairs(NovaDungeonXPDB.history) do

        if (v.xph or 0) > bestXPH then
            bestXPH = v.xph
        end

    end



    for i,v in ipairs(NovaDungeonXPDB.history) do


        if not rows[i] then
            rows[i] = CreateRow(i + 1)
        end


        local color = ""

        if v.xph == bestXPH then
            color = "|cff00ff00"
        end


        local reset = "|r"


        rows[i].num:SetText(color..i..reset)

        rows[i].name:SetText(
            color..(v.dungeon or "Unknown")..reset
        )


        rows[i].time:SetText(
            color..
            string.format(
                "%dm",
                v.time or 0
            )
            ..
            reset
        )


        rows[i].xp:SetText(
            color..
            FormatXP(v.xp or 0)
            ..
            reset
        )


        rows[i].xph:SetText(
            color..
            FormatXP(v.xph or 0)
            ..
            reset
        )


    end

end

frame:SetScript(
    "OnShow",
    UpdateWindow
)

------------------------------------------------
-- Commands
------------------------------------------------


SLASH_NOVADXP1="/ndxp"


SlashCmdList["NOVADXP"]=function(msg)

    if msg=="reset" then

        NovaDungeonXPDB.history={}

        print("NovaDungeonXP history cleared")

    else

        if frame:IsShown() then
            frame:Hide()
        else
            UpdateWindow()
            frame:Show()
        end

    end

end



------------------------------------------------
-- Minimap button
------------------------------------------------
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

        tooltip:AddLine(
            "Nova Dungeon XP"
        )

        tooltip:AddLine(
            "/ndxp - open window"
        )

    end
}
)


if not NovaDungeonXPMinimapDB then

    NovaDungeonXPMinimapDB = {
        minimapPos = 225,
    }

end


DBIcon:Register(
"NovaDungeonXP",
minimapObject,
NovaDungeonXPMinimapDB
)