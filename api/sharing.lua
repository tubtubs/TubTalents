--import/export functionality for presets and levelling plans
-- Import Export Code --
TubTalents_ProfileFrameMode = TubTalents_PROFILEMODES.NONE

function TubTalents_SetupExportWindow()
    TubTalents_ProfileFrame_ScrollFrame_EditBox:SetScript("OnCursorChanged",
    function() this:HighlightText() end)
    TubTalents_ProfileFrame_ScrollFrame_EditBox:SetScript("OnShow",
    function() this:HighlightText() TubTalents_ProfileFrame_ScrollFrame_EditBox:SetFocus() end)
end

function TubTalents_SetupImportWindow()
    TubTalents_ProfileFrame_ScrollFrame_EditBox:SetScript("OnCursorChanged",nil)
    TubTalents_ProfileFrame_ScrollFrame_EditBox:SetScript("OnShow", function() 
    TubTalents_ProfileFrame_ScrollFrame_EditBox:SetFocus() end)
end

function TubTalents_ProfileFrame_Show(Mode,ID)
    TubTalents_ProfileFrameMode = Mode
    -- change titles and button prompts depending on the mode
    -- also fill in text field and auto select all text for exports
    if TubTalents_ProfileFrameMode == TubTalents_PROFILEMODES.ExportPreset then
        TubTalents_SetupExportWindow()
        TubTalents_ProfileFrame_ScrollFrame_EditBox:SetText(TubTalents_ExportPreset(ID))
        TubTalents_ProfileFrameTitleString:SetText(TubTalents_ExportPreset)
    elseif TubTalents_ProfileFrameMode == TubTalents_PROFILEMODES.ExportPlan then
        TubTalents_SetupExportWindow()
        TubTalents_ProfileFrame_ScrollFrame_EditBox:SetText(TubTalents_ExportPlan(ID))
        TubTalents_ProfileFrameTitleString:SetText(TubTalents_ExportPlan)
    elseif TubTalents_ProfileFrameMode == TubTalents_PROFILEMODES.ImportPreset then
        TubTalents_SetupImportWindow()
        TubTalents_ProfileFrame_ScrollFrame_EditBox:SetText("")
        TubTalents_ProfileFrameTitleString:SetText(TubTalents_ImportPreset)
    elseif TubTalents_ProfileFrameMode == TubTalents_PROFILEMODES.ImportPlan then
        TubTalents_SetupImportWindow()
        TubTalents_ProfileFrame_ScrollFrame_EditBox:SetText("")
        TubTalents_ProfileFrameTitleString:SetText(TubTalents_ImportPlan)
    end
    TubTalents_ProfileFrame:Show()
end

function TubTalents_RenamePlanPrompt()
    local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
    TubTalents_RenamePlan(TubTalent_Vars.LevellingPlanIDMax ,text)
    this:GetParent():Hide();
end

function TubTalents_RenamePresetPrompt()
    local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
    TubTalents_RenamePreset(TubTalent_Vars.TalentPresetIDMax ,text)
    this:GetParent():Hide();
end

StaticPopupDialogs["TUBTALENTS_RENAMEIMPORTEDPLAN"] = {
    text = TubTalents_ImportPlanSameName,
    button1 = "Yes",
    button2 = "No",
    hasEditBox = 1,
    OnAccept = TubTalents_RenamePlanPrompt,
    EditBoxOnEnterPressed=TubTalents_RenamePlanPrompt,
    OnHide = function()
        getglobal(this:GetName().."EditBox"):SetText("");
    end,
    OnShow = function()
        _, v = TubTalents_FindPlan(TubTalent_Vars.LevellingPlanIDMax)
        getglobal(this:GetName().."EditBox"):SetText(v.name)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["TUBTALENTS_RENAMEIMPORTEDPRESET"] = {
    text = TubTalents_ImportPresetSameName,
    button1 = "Yes",
    button2 = "No",
    hasEditBox = 1,
    OnAccept = TubTalents_RenamePresetPrompt,
    EditBoxOnEnterPressed=TubTalents_RenamePresetPrompt,
    OnHide = function()
        getglobal(this:GetName().."EditBox"):SetText("");
    end,
    OnShow = function()
        _, v = TubTalents_FindTalentPreset(TubTalent_Vars.TalentPresetIDMax)
        getglobal(this:GetName().."EditBox"):SetText(v.name)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

function TubTalents_CheckPresetName(a)
    for k, v in pairs(TubTalents_TalentPresets) do
        TubTalents_Out(format(TubTalents_CHECK,v.name))
        if v.name == a.name then
            return true
        end
    end
    return false
end

function TubTalents_CheckPlanName(a)
    for k, v in pairs(TubTalent_Vars.LevellingPlans) do
        TubTalents_Out(format(TubTalents_CHECK,v.name))
        if v.name == a.name then
            return true
        end
    end
    return false
end

function TubTalents_ProfileFrame_SubmitButton_OnClick()
    if TubTalents_ProfileFrameMode == TubTalents_PROFILEMODES.ImportPreset then 
        l = TubTalents_ProfileFrame_ScrollFrame_EditBox:GetText();
        f = loadstring(l);
        if f ~= nil then
            a = f()
            --for k,v in pairs(a) do
                --TubTalents_Out(k)
            --end 
        else
            TubTalents_Out(TubTalents_ERRBADCorrupPreset)
            return
        end

        -- validate it...
        if a.class == nil or a.name == nil or a.talents == nil or a.points == nil then
            TubTalents_Out(TubTalents_ERRCorruptPreset)
            return
        end
        if a.class ~= UnitClass("player") then
            TubTalents_Out(TubTalents_ERRPresetClass)
            return
        end
        --give it a new id and add it
        TubTalent_Vars.TalentPresetIDMax = TubTalent_Vars.TalentPresetIDMax+1
        a.id = TubTalent_Vars.TalentPresetIDMax
        table.insert(TubTalents_TalentPresets, a)
        if TubTalents_CheckPresetName(a) then            
            --offer to rename it if there's another named the same
            -- Doesn't matter if they have the same name, thought I'd offer though.
            StaticPopup_Show("TUBTALENTS_RENAMEIMPORTEDPRESET")
        end
        TubTalents_RegenPresetDropdown()
        TubTalents_Out(TubTalents_ACKPresetImport)
    elseif TubTalents_ProfileFrameMode == TubTalents_PROFILEMODES.ImportPlan then
        l = TubTalents_ProfileFrame_ScrollFrame_EditBox:GetText();
        f = loadstring(l);
        if f ~= nil then
            a = f() 
        else
            TubTalents_Out(TubTalents_ERRBADCorruptPlan)
            return
        end

        -- validate it...
        if a.class == nil or a.name == nil or a.plan == nil or a.points == nil
        or a.levellingPlanMinLevel== nil or a.levellingPlanMaxLevel==nil then
            TubTalents_Out(TubTalents_ERRCorruptPlan)
            return
        end
        if a.class ~= UnitClass("player") then
            TubTalents_Out(TubTalents_ERRPlanClass)
            return
        end
        --give it a new id and add it
        TubTalent_Vars.LevellingPlanIDMax = TubTalent_Vars.LevellingPlanIDMax + 1
        a.id = TubTalent_Vars.LevellingPlanIDMax
        if (RQ_GetVersion and SUPERWOW_STRING) and not TubTalents_FakeNoMods then
            --re-cache spellIDs if they're missing...
            TubTalents_CheckSpellIds(a.plan)
        end
        table.insert(TubTalents_LevellingPlans, a)
        if TubTalents_CheckPlanName(a) then            
            --offer to rename it if there's another named the same
            -- Doesn't matter if they have the same name, thought I'd offer though.
            StaticPopup_Show("TUBTALENTS_RENAMEIMPORTEDPLAN")
        end
        TubTalents_RegenPlansDropdown()
        TubTalents_Out(TubTalents_ACKPlanImport)
    end
    TubTalents_ProfileFrame:Hide();
end

TubTalents_ExportPresetTalentsButtonsTemplate = 
[[%s            [%s]=%s,
]]

TubTalents_ExportPresetTalentsTabsTemplate = 
[[%s        [%s] = {
]]

TubTalents_ExportPresetPointsTemplate = 
[[{
        [1] = %s,
        [2] = %s,
        [3] = %s,
    }]]

TubTalents_ExportPresetObjectTemplate =
[[return {
    class = "%s",
    name = "%s",
    id = 0,
    talents = %s,
    points = %s,
}]]
function TubTalents_ExportPreset(presetID)
    _, p = TubTalents_FindTalentPreset(presetID)
    local exportPresetPoints = format(TubTalents_ExportPresetPointsTemplate,
    p.points[1], p.points[2], p.points[3])
    local exportPresetTalents = "{\n"
    for k, v in p.talents do
        exportPresetTalents = format(TubTalents_ExportPresetTalentsTabsTemplate,
        exportPresetTalents, k)
        for m, b in p.talents[k] do
            exportPresetTalents = format(TubTalents_ExportPresetTalentsButtonsTemplate,
            exportPresetTalents, m, b)
        end
        exportPresetTalents = exportPresetTalents .. "    },\n"
    end
    exportPresetTalents = exportPresetTalents .. "  }"
    local exportPreset = format(TubTalents_ExportPresetObjectTemplate,
    p.class, p.name, exportPresetTalents, exportPresetPoints)
    return exportPreset
end

TubTalents_ExportPlanTemplate = 
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
TubTalents_ExportPlanPointsTemplate = 
[[{
    [1] = %s,
    [2] = %s,
    [3] = %s,
}]]
TubTalents_ExportPlanObjectTemplate = 
[[return {
    class = "%s",
    name = "%s",
    points = %s,
    id = 0,
    levellingPlanMinLevel = %s,
    levellingPlanMaxLevel = %s,
    plan = %s,
}]] -- leaving id at 0, gets re-assigned on import
function TubTalents_ExportPlan(planID)
    _, p = TubTalents_FindPlan(planID)
    local exportPlanPoints = format(TubTalents_ExportPlanPointsTemplate,
    p.points[1], p.points[2], p.points[3])
    local exportPlanLevels = "{\n"
    for k,v in p.plan do
        local t = string.gsub(v.icon,"\\","\\\\") --need to double up slashes or lose them on export
        exportPlanLevels = format(TubTalents_ExportPlanTemplate, exportPlanLevels,
        k, v.tab, v.tabName, v.btnID, v.rank, t, v.spellID, v.name)
    end
    exportPlanLevels = exportPlanLevels .. "}\n"
    local exportPlan = format(TubTalents_ExportPlanObjectTemplate,
    p.class, p.name, exportPlanPoints, p.levellingPlanMinLevel, 
    p.levellingPlanMaxLevel, exportPlanLevels)
    return exportPlan
end