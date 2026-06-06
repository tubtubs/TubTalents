--Disables client mod functionality
--Mostly improved tooltips, and shift click links in chat
function TubTalents_NoClientMods()
    TubTalents_TalentTooltip = TubTalents_TalentTooltipNoMods
    TubTalents_TalentFrameTalent_OnShiftClick = TubTalents_TalentFrameTalent_OnShiftClickNoMods
    TubTalents_LvlPlan_OnClick = TubTalents_TalentFrameTalent_OnShiftClickNoMods
    TubTalents_StagedTalentsFrame_LvlPlanSpec6:SetScript("OnEnter",nil)
    TubTalents_StagedTalentsFrame_LvlPlanSpec5:SetScript("OnEnter",nil)
    TubTalents_StagedTalentsFrame_LvlPlanSpec4:SetScript("OnEnter",nil)
    TubTalents_StagedTalentsFrame_LvlPlanSpec3:SetScript("OnEnter",nil)
    TubTalents_StagedTalentsFrame_LvlPlanSpec2:SetScript("OnEnter",nil)
    TubTalents_StagedTalentsFrame_LvlPlanSpec1:SetScript("OnEnter",nil)
end

function TubTalents_TalentFrameTalent_OnShiftClickNoMods()
    if IsShiftKeyDown() then
        TubTalents_Out(TubTalents_COMPATSHIFTCLICK)
    end
end

function TubTalents_TalentTooltipNoMods()
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
    GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(TalentFrame), this:GetID());
end