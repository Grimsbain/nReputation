local addon, nRep = ...

local nReputationToggle = CreateFrame("CheckButton", "nReputationToggle", ReputationFrame, "InterfaceOptionsCheckButtonTemplate")
nReputationToggle:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -5, -25)
nReputationToggle.Text:SetText(TRACK_QUEST_ABBREV)
nReputationToggle.Text:SetPoint("RIGHT", nReputationToggle, "LEFT", -nReputationToggle.Text:GetWidth()-2, 0)
nReputationToggle:SetScale(.9)
nReputationToggle:SetScript("OnClick", function(self)
    local checked = not not self:GetChecked()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    nReputationDB.Toggle = checked
end)

nReputationToggle:SetScript("OnShow", function(self)
    function UpdateToggle()
        nReputationToggle:SetChecked(nReputationDB.Toggle)
    end
    UpdateToggle()
    nReputationToggle:SetScript("OnShow", nil)
end)
