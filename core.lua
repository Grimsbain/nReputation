
local gsub = string.gsub
local find = string.find

-- Used to set session variables.
local RegisterDefaultSetting = function(key,value)
    if ( nReputationDB == nil ) then
        nReputationDB = {}
    end
    if ( nReputationDB[key] == nil ) then
        nReputationDB[key] = value
    end
end

RegisterDefaultSetting("Toggle",true)


-- UI Code
local nReputationToggle = CreateFrame("CheckButton", "nReputationToggle", ReputationFrame, "InterfaceOptionsCheckButtonTemplate")
nReputationToggle:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -5, -25)
nReputationToggle.Text:SetText("Auto")
nReputationToggle.Text:SetPoint("RIGHT",nReputationToggle,"LEFT",-nReputationToggle.Text:GetWidth()+1,0)
nReputationToggle:SetScale(.9)
nReputationToggle:SetScript("OnClick", function(this)
    local checked = not not this:GetChecked()
    PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
    nReputationDB.Toggle = checked
end)


nReputationToggle:SetScript("OnShow", function(self)
    function UpdateToggle()
        nReputationToggle:SetChecked(nReputationDB.Toggle)
    end
    UpdateToggle()
    nReputationToggle:SetScript("OnShow", nil)
end)

-- Proccess tracking changes. Will ignore guild and anything set to inactive.
local SetWatched = function(newFaction)
    if running then
        return
    end
    running = true
    local i = 1
    local wasCollapsed = {}
    local watchedFaction = select(1,GetWatchedFactionInfo())
    while i <= GetNumFactions() do
        local name, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _, _, _, _ = GetFactionInfo(i)
        if isHeader then
            if name == FACTION_INACTIVE then
                break
            end
            if isCollapsed then
                ExpandFactionHeader(i)
                wasCollapsed[name] = true
            end
        end
        if (name == newFaction) then
            if (watchedFaction ~= newFaction) then
                SetWatchedFactionIndex(i)
            end
            break
        end
        i = i + 1
    end
    i = 1
    while i <= GetNumFactions() do
        local name, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _, _, _, _ = GetFactionInfo(i)
        if isHeader and not isCollapsed and wasCollapsed[name] then
            CollapseFactionHeader(i)
            wasCollapsed[name] = nil
        end
        i = i + 1
    end
    running = nil
end

-- Reads faction change line and sets watched reputation.
local listener = CreateFrame("Frame")
listener:SetScript("OnEvent", function(self, event, ...)
    if ( not nReputationDB.Toggle ) then return end

    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = ...

    local pattern_standing_inc = gsub(gsub(FACTION_STANDING_INCREASED, "(%%s)", "(.+)"), "(%%d)", "(%%d+)")

    if ( event == "CHAT_MSG_COMBAT_FACTION_CHANGE" ) then

        local s1, e1, faction, amount = find(arg1, pattern_standing_inc)

        if ( s1 ~= nil and amount ~= nil ) then
            if ( faction ~= GUILD ) then
                SetWatched(faction)
            end
        end
    end
end)

-- Listen for faction change events.
listener:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")