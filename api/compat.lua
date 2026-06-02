--Disables client mod functionality
--Mostly improved tooltips, and shift click links in chat
function TT_NoClientMods()
    TT_TalentTooltip = TT_TalentTooltipNoMods
    TT_TalentFrameTalent_OnShiftClick = TT_TalentFrameTalent_OnShiftClickNoMods
    TT_LvlPlan_OnClick = TT_TalentFrameTalent_OnShiftClickNoMods
    TT_StagedTalentsFrame_LvlPlanSpec6:SetScript("OnEnter",nil)
    TT_StagedTalentsFrame_LvlPlanSpec5:SetScript("OnEnter",nil)
    TT_StagedTalentsFrame_LvlPlanSpec4:SetScript("OnEnter",nil)
    TT_StagedTalentsFrame_LvlPlanSpec3:SetScript("OnEnter",nil)
    TT_StagedTalentsFrame_LvlPlanSpec2:SetScript("OnEnter",nil)
    TT_StagedTalentsFrame_LvlPlanSpec1:SetScript("OnEnter",nil)
end

function TT_TalentFrameTalent_OnShiftClickNoMods()
    if IsShiftKeyDown() then
        TT_Out("Shift click links require SuperWoW+Reliquary client mods.")
    end
end

function TT_TalentTooltipNoMods()
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
    GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(TalentFrame), this:GetID());
end