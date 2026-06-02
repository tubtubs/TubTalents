--import/export functionality for presets and levelling plans
-- Import Export Code --
TT_ProfileFrameMode = 0

function TT_SetupExportWindow()
    TT_ProfileFrame_ScrollFrame_EditBox:SetScript("OnCursorChanged",
    function() this:HighlightText() end)
    TT_ProfileFrame_ScrollFrame_EditBox:SetScript("OnShow",
    function() this:HighlightText() TT_ProfileFrame_ScrollFrame_EditBox:SetFocus() end)
end

function TT_SetupImportWindow()
    TT_ProfileFrame_ScrollFrame_EditBox:SetScript("OnCursorChanged",nil)
    TT_ProfileFrame_ScrollFrame_EditBox:SetScript("OnShow", function() 
    TT_ProfileFrame_ScrollFrame_EditBox:SetFocus() end)
end

function TT_ProfileFrame_Show(Mode,ID)
    TT_ProfileFrameMode = Mode
    -- change titles and button prompts depending on the mode
    -- also fill in text field and auto select all text for exports
    if TT_ProfileFrameMode == TT_PROFILEMODES.ExportPreset then
        TT_SetupExportWindow()
        TT_ProfileFrame_ScrollFrame_EditBox:SetText(TT_ExportPreset(ID))
        TT_ProfileFrameTitleString:SetText(TT_ExportPreset)
    elseif TT_ProfileFrameMode == TT_PROFILEMODES.ExportPlan then
        TT_SetupExportWindow()
        TT_ProfileFrame_ScrollFrame_EditBox:SetText(TT_ExportPlan(ID))
        TT_ProfileFrameTitleString:SetText(TT_ExportPlan)
    elseif TT_ProfileFrameMode == TT_PROFILEMODES.ImportPreset then
        TT_SetupImportWindow()
        TT_ProfileFrame_ScrollFrame_EditBox:SetText("")
        TT_ProfileFrameTitleString:SetText(TT_ImportPreset)
    elseif TT_ProfileFrameMode == TT_PROFILEMODES.ImportPlan then
        TT_SetupImportWindow()
        TT_ProfileFrame_ScrollFrame_EditBox:SetText("")
        TT_ProfileFrameTitleString:SetText(TT_ImportPlan)
    end
    TT_ProfileFrame:Show()
end

StaticPopupDialogs["TUBTALENTS_RENAMEIMPORTEDPLAN"] = {
    text = TT_ImportPlanSameName,
    button1 = "Yes",
    button2 = "No",
    hasEditBox = 1,
    OnAccept = TT_RenamePlanPrompt,
    EditBoxOnEnterPressed=TT_RenamePlanPrompt,
    OnHide = function()
        getglobal(this:GetName().."EditBox"):SetText("");
    end,
    OnShow = function()
        _, v = TT_FindPlan(TubTalent_Vars.LevellingPlanIDMax)
        getglobal(this:GetName().."EditBox"):SetText(v.name)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["TUBTALENTS_RENAMEIMPORTEDPRESET"] = {
    text = TT_ImportPresetSameName,
    button1 = "Yes",
    button2 = "No",
    hasEditBox = 1,
    OnAccept = TT_RenamePresetPrompt,
    EditBoxOnEnterPressed=TT_RenamePresetPrompt,
    OnHide = function()
        getglobal(this:GetName().."EditBox"):SetText("");
    end,
    OnShow = function()
        _, v = TT_FindTalentPreset(TubTalent_Vars.TalentPresetIDMax)
        getglobal(this:GetName().."EditBox"):SetText(v.name)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}
function TT_RenamePlanPrompt()
    local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
    TT_RenamePlan(TubTalent_Vars.LevellingPlanIDMax ,text)
    this:GetParent():Hide();
end

function TT_RenamePresetPrompt()
    local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
    TT_RenamePreset(TubTalent_Vars.TalentPresetIDMax ,text)
    this:GetParent():Hide();
end

function TT_CheckPresetName(a)
    for k, v in pairs(TT_TalentPresets) do
        TT_Out(v.name)
        if v.name == a.name then
            return true
        end
    end
    return false
end

function TT_CheckPlanName(a)
    for k, v in pairs(TubTalent_Vars.LevellingPlans) do
        TT_Out(v.name)
        if v.name == a.name then
            return true
        end
    end
    return false
end

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