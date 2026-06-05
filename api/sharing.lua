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

-- ADDON MESSAGE SHARING
-- Always broadcast, but attempt to send to a specific user?
-- If your name is mentioned, just start staging it?
-- When complete, ask if you'd like to save it. If not, discard it.
TubTalents_AMPRESET1 = 
[[
]]
TubTalents_AMPMODES = {
    Preset=1,
    Plan=2,
}
TubTalents_AMPTYPES = {
    [TubTalents_AMPMODES.Preset] = {
        Class=1,
        Name=2,
        Points=3,
        Talent=4,
        EOL = 5,
    }
}
-- MESSAGE FORMAT: 
-- mode:type:info[...]:info
-- ex: 1:1:mage
TubTalents_AMPFormat2= "%s:%s" -- mostly EOL
TubTalents_AMPFormat3= "%s:%s:%s"
TubTalents_AMPFormat4 = "%s:%s:%s:%s" --only safe for numeric data
TubTalents_AMPFormat5 = "%s:%s:%s:%s:%s" --only safe for numeric data
function TubTalents_TalentPresetShare(arg1)
    _, p = TubTalents_FindTalentPreset(arg1)
    local CHANNEL = "PARTY"
    local PREFIX = TubTalents_AMPREFIX
    local MESSAGE = ""
    local MODE = TubTalents_AMPMODES.Preset

    -- Send packet with class, and name first...
    -- 1:1:class
    MESSAGE = format(TubTalents_AMPFormat3,
    MODE, TubTalents_AMPTYPES[MODE].Class, UnitClass("player"))
    SendAddonMessage(PREFIX,MESSAGE,CHANNEL)
    -- Send name
    -- 1:2:name
    MESSAGE = format(TubTalents_AMPFormat3,
    MODE, TubTalents_AMPTYPES[MODE].Name, p.name)
    SendAddonMessage(PREFIX,MESSAGE,CHANNEL)
    -- Send points
    -- 1:3:tabindex:points
    for i=1, TubTalents_MAX_TALENTS do
        MESSAGE = format(TubTalents_AMPFormat4,
        MODE, TubTalents_AMPTYPES[MODE].Points, i, p.points[i])
        SendAddonMessage(PREFIX,MESSAGE,CHANNEL)
    end
    -- Finally send talents
    -- 1:4:tabindex:btnindex:rank
    for i=1, TubTalents_MAX_TALENTS do
        for k,v in pairs(p.talents[i]) do
        MESSAGE = format(TubTalents_AMPFormat5,
        MODE, TubTalents_AMPTYPES[MODE].Talent, i, k, v)
        SendAddonMessage(PREFIX,MESSAGE,CHANNEL)
        end
    end
    MESSAGE = format(TubTalents_AMPFormat2,
    MODE, TubTalents_AMPTYPES[MODE].EOL)
    SendAddonMessage(PREFIX,MESSAGE,CHANNEL)
end

TubTalents_AMP_preset = {
    class="",
    name="",
    talents = {
        [1] = {},
        [2] = {},
        [3] = {},
    },
    points = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
}

TubTalents_AMP_plan = {

}

TubTalents_AMPError = false

TubTalents_AMPLastPlayer = ""

StaticPopupDialogs["TUBTALENTS_AMIMPORTPRESET"] = {
    text = "",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        TubTalents_NewPreset(TubTalents_AMP_preset.name, TubTalents_AMP_preset)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

function TubTalents_AMHANDLER(arg2,arg3,arg4) 
    --TubTalents_Out(format("arg2: %s", arg2))
    -- parse the args...
    local parsed_args = {}
    local a = string.gfind(arg2, '([^:]+)') --parses info after :
    for i in a do --need to translate it to a table, a is a function
        table.insert(parsed_args,i)
        --TubTalents_Out(i)
    end 
    local len = getn(parsed_args)
    if len <= 1 then -- error expecting at least 2 arguments
        TubTalents_Out("Addon Message Error1")
        TubTalents_AMPError = true
    elseif len == 2 then -- EOL
        local MODE = tonumber(parsed_args[1])
        local TYPE = tonumber(parsed_args[2])
        if MODE == TubTalents_AMPMODES.Preset then
            if TYPE == TubTalents_AMPTYPES[MODE].EOL then
                if not TubTalents_AMPError then
                    if TubTalents_AMP_preset.class == UnitClass("player") then
                        --Offer to save it...
                        local MESSAGE = format("%s has shared the preset %s with you. Would you like to import?",
                            arg4, TubTalents_AMP_preset.name)
                        StaticPopupDialogs["TUBTALENTS_AMIMPORTPRESET"].text = MESSAGE
                        StaticPopup_Show("TUBTALENTS_AMIMPORTPRESET")
                    else
                        TubTalents_Out("Shared preset isn't for your class")
                    end
                else
                    TubTalents_Out("Addon Message Error4")
                end
            end
        elseif MODE == TubTalents_AMPMODES.Plan then
            if TYPE == TubTalents_AMPTYPES[MODE].EOL then

            end
        end

        TubTalents_AMPLastPlayer = ""
        TubTalents_AMPError = false
    else -- data packet...
        TubTalents_AMPLastPlayer = arg4
        -- Which mode...?
        local MODE = tonumber(parsed_args[1])
        if MODE == TubTalents_AMPMODES.Preset then
            local TYPE = tonumber(parsed_args[2])
            if len == 3 and TYPE == TubTalents_AMPTYPES[MODE].Class then
                TubTalents_Out(format("Class: %s", parsed_args[3]))
                TubTalents_AMP_preset.class = parsed_args[3]
            elseif len == 3 and TYPE == TubTalents_AMPTYPES[MODE].Name then
                TubTalents_Out(format("Name: %s", parsed_args[3]))
                TubTalents_AMP_preset.name = parsed_args[3]
            elseif len == 4 and TYPE == TubTalents_AMPTYPES[MODE].Points then
                TubTalents_Out(format("Tab: %s Points:%s", parsed_args[3], parsed_args[4]))
                TubTalents_AMP_preset.points[tonumber(parsed_args[3])] = tonumber(parsed_args[4])
            elseif len == 5 and TYPE == TubTalents_AMPTYPES[MODE].Talent then
                TubTalents_Out(format("Tab: %s Btn:%s Rank: %s", parsed_args[3], parsed_args[4], parsed_args[5]))
                TubTalents_AMP_preset.talents[tonumber(parsed_args[3])][tonumber(parsed_args[4])] = tonumber(parsed_args[5])
            else
                TubTalents_Out("Addon Message Error2")
                TubTalents_AMPError = true
            end
        elseif MODE == TubTalents_AMPMODES.Plan then
        else
            TubTalents_Out("Addon Message Error3")
            TubTalents_AMPError = true
        end
    end

    --TubTalents_Out(format("arg3: %s", arg3))
    --TubTalents_Out(format("arg4: %s", arg4))
end


--/run SendAddonMessage("TTA","TEST","PARTY")

--PROTOCOL: 