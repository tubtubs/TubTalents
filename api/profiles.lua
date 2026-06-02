--import/export functionality for presets and levelling plans
function TT_ProfileFrame_SubmitButton_OnClick()
    if TT_ProfileFrameMode == TT_PROFILEMODES.ImportPreset then 
        l = TT_ProfileFrame_ScrollFrame_EditBox:GetText();
        f = loadstring(l);
        if f ~= nil then
            a = f()
            for k,v in pairs(a) do
                TT_Out(k)
            end 
        else
            TT_Out("Imported preset is really corrupt, try re-exporting")
            return
        end

        -- validate it...
        if a.class == nil or a.name == nil or a.talents == nil or a.points == nil then
            TT_Out("Imported preset is corrupt, try re-exporting")
            return
        end
        if a.class ~= UnitClass("player") then
            TT_Out("Imported preset doesn't match your class")
            return
        end
        --give it a new id and add it
        TubTalent_Vars.TalentPresetIDMax = TubTalent_Vars.TalentPresetIDMax+1
        a.id = TubTalent_Vars.TalentPresetIDMax
        table.insert(TT_TalentPresets, a)
        if TT_CheckPresetName(a) then            
            --offer to rename it if there's another named the same
            -- Doesn't matter if they have the same name, thought I'd offer though.
            StaticPopup_Show("TUBTALENTS_RENAMEIMPORTEDPRESET")
        end
        TT_RegenPresetDropdown()
        TT_Out("Successfully imported preset")
    elseif TT_ProfileFrameMode == TT_PROFILEMODES.ImportPlan then
        l = TT_ProfileFrame_ScrollFrame_EditBox:GetText();
        f = loadstring(l);
        if f ~= nil then
            a = f() 
        else
            TT_Out("Imported plan is really corrupt, try re-exporting")
            return
        end

        -- validate it...
        if a.class == nil or a.name == nil or a.plan == nil or a.points == nil
        or a.levellingPlanMinLevel== nil or a.levellingPlanMaxLevel==nil then
            TT_Out("Imported plan is corrupt, try re-exporting")
            return
        end
        if a.class ~= UnitClass("player") then
            TT_Out("Imported plan doesn't match your class")
            return
        end
        --give it a new id and add it
        TubTalent_Vars.LevellingPlanIDMax = TubTalent_Vars.LevellingPlanIDMax + 1
        a.id = TubTalent_Vars.LevellingPlanIDMax
        if (RQ_GetVersion and SUPERWOW_STRING) and not TT_FakeNoMods then
            --re-cache spellIDs if they're missing...
            TT_CheckSpellIds(a.plan)
        end
        table.insert(TT_LevellingPlans, a)
        if TT_CheckPlanName(a) then            
            --offer to rename it if there's another named the same
            -- Doesn't matter if they have the same name, thought I'd offer though.
            StaticPopup_Show("TUBTALENTS_RENAMEIMPORTEDPLAN")
        end
        TT_RegenPlansDropdown()
        TT_Out("Successfully imported plan")
    end
    TT_ProfileFrame:Hide();
end

TT_ExportPresetTalentsButtonsTemplate = 
[[%s            [%s]=%s,
]]

TT_ExportPresetTalentsTabsTemplate = 
[[%s        [%s] = {
]]

TT_ExportPresetPointsTemplate = 
[[{
        [1] = %s,
        [2] = %s,
        [3] = %s,
    }]]

TT_ExportPresetObjectTemplate =
[[return {
    class = "%s",
    name = "%s",
    id = 0,
    talents = %s,
    points = %s,
}]]
function TT_ExportPreset(presetID)
    _, p = TT_FindTalentPreset(presetID)
    local exportPresetPoints = format(TT_ExportPresetPointsTemplate,
    p.points[1], p.points[2], p.points[3])
    local exportPresetTalents = "{\n"
    for k, v in p.talents do
        exportPresetTalents = format(TT_ExportPresetTalentsTabsTemplate,
        exportPresetTalents, k)
        for m, b in p.talents[k] do
            exportPresetTalents = format(TT_ExportPresetTalentsButtonsTemplate,
            exportPresetTalents, m, b)
        end
        exportPresetTalents = exportPresetTalents .. "    },\n"
    end
    exportPresetTalents = exportPresetTalents .. "  }"
    local exportPreset = format(TT_ExportPresetObjectTemplate,
    p.class, p.name, exportPresetTalents, exportPresetPoints)
    return exportPreset
end

TT_ExportPlanTemplate = 
[[%s[%s] = {
    tab = %s,
    tabName = "%s",
    btnID = %s,
    rank = %s,
    icon = "%s",
    spellID = %s,
    name = "%s",
},
]]
TT_ExportPlanPointsTemplate = 
[[{
    [1] = %s,
    [2] = %s,
    [3] = %s,
}]]
TT_ExportPlanObjectTemplate = 
[[return {
    class = "%s",
    name = "%s",
    points = %s,
    id = 0,
    levellingPlanMinLevel = %s,
    levellingPlanMaxLevel = %s,
    plan = %s,
}]] -- leaving id at 0, gets re-assigned on import
function TT_ExportPlan(planID)
    _, p = TT_FindPlan(planID)
    local exportPlanPoints = format(TT_ExportPlanPointsTemplate,
    p.points[1], p.points[2], p.points[3])
    local exportPlanLevels = "{\n"
    for k,v in p.plan do
        local t = string.gsub(v.icon,"\\","\\\\") --need to double up slashes or lose them on export
        exportPlanLevels = format(TT_ExportPlanTemplate, exportPlanLevels,
        k, v.tab, v.tabName, v.btnID, v.rank, t, v.spellID, v.name)
    end
    exportPlanLevels = exportPlanLevels .. "}\n"
    local exportPlan = format(TT_ExportPlanObjectTemplate,
    p.class, p.name, exportPlanPoints, p.levellingPlanMinLevel, 
    p.levellingPlanMaxLevel, exportPlanLevels)
    return exportPlan
end