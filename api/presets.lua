local _G = getfenv(0)
--Preset dropdown menu
TubTalents_PresetOpts = {
    --levels...
    [1] = {
        {
            name="Presets",
            tooltip="",
            notCheckable=true,
            value="presets"
        },
        {
            name="Import Preset",
            tooltip="Opens a window to paste in a preset\nMust be for your class",
            notCheckable=true,
            func=function()  TubTalents_ProfileFrame_Show(TubTalents_PROFILEMODES.ImportPreset)  TubTalents_TalentPresets_Dewdrop:Close() end,
            value=""
        },
        {
            name="Stage Current Build",
            tooltip="Stages current learned talents\n Only needed in SimMode",
            notCheckable=true,
            disabledTooltip="Only useful in Sim Mode",
            disabled = function() return not TubTalents_SimMode end,
            func=function() TubTalents_StageCurrentSpec() end,
            value=""
        },
        {
            name="Save Preset",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            disabledTooltip="Start staging or spending points to save a preset",
            disabled = function() return TubTalents_SavePresetButton_OnUpdate() end,
            editBoxText=function() return "" end,
            editBoxFunc=function(s) TubTalents_NewPreset(s) end,
            value=""
        },
    },
    [2] = { --populate with presets...

    },
    [3] = { --arg1 is loaded from the previous dropdowns value
        ["presetmenu"] = {
            {
            name="Learn Preset",
            --tooltipTitle="Learn Preset",
            tooltip="Learns the selected preset over your current build\nNot available in Sim mode",
            notCheckable=true,
            disabled = function() return TubTalents_SimMode end,
            func=function(arg1)  TubTalents_TalentPresetLearn(arg1) end,
            value=""
            },
            {
            name="Stage Preset",
            tooltip="Stages the selected preset over your current build if possible\nEnable Sim mode if you don't want to reset your talents",
            notCheckable=true,
            func=function(arg1)  TubTalents_TalentPresetStage(arg1) end,
            value=""
            },
            {
            name="Export Preset",
            tooltip="Exports the selected preset",
            notCheckable=true,
            func=function(arg1)  TubTalents_ProfileFrame_Show(TubTalents_PROFILEMODES.ExportPreset, arg1) TubTalents_TalentPresets_Dewdrop:Close() end,
            value=""
            },
            {
            name="Delete Preset",
            tooltip="Deletes the selected preset",
            notCheckable=true,
            func=function(arg1)  TubTalents_TalentPresetDelete(arg1) end,
            value=""
            },
            {
            name="Share Preset",
            tooltip="Share the selected preset with party",
            notCheckable=true,
            func=function(arg1)  TubTalents_TalentPresetShare(arg1) end,
            value=""
            },
            {
            name="Rename Preset",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            editBoxText=function(arg1) 
                _, v =  TubTalents_FindTalentPreset(arg1) 
                return v.name 
            end,
            editBoxFunc=function(arg1,s) TubTalents_RenamePreset(arg1,s) end,
            value=""
            },
        }
    },
    [4] = {
        ["sharemenu"] = {
            {
            name="Party",
            tooltip="Shares the selected preset with Party",
            notCheckable=true,
            func=function()  
                TubTalents_TalentPresetShare(TT_CurrentSelectedDropID, TubTalents_AMCHANNELS.Party) 
            end,
            value=""
            },
            {
            name="Guild",
            tooltip="Shares the selected preset with Guild",
            notCheckable=true,
            func=function()  
                TubTalents_TalentPresetShare(TT_CurrentSelectedDropID, TubTalents_AMCHANNELS.Guild) 
            end,
            value=""
            },
            {
            name="Raid",
            tooltip="Shares the selected preset with Raid",
            notCheckable=true,
            func=function()  
                TubTalents_TalentPresetShare(TT_CurrentSelectedDropID, TubTalents_AMCHANNELS.Raid) 
            end,
            value=""
            },
            {
            name="Battleground",
            tooltip="Shares the selected preset with Battleground Group",
            notCheckable=true,
            func=function()  
                TubTalents_TalentPresetShare(TT_CurrentSelectedDropID, TubTalents_AMCHANNELS.BG) 
            end,
            value=""
            },
        },
    },
    --specials
    --close menu
    ["closemenu"] = {
        text = "Close Menu",
        textR = 0,
        textG = 1,
        textB = 1,
        func =  function() self:Close() end,
        notCheckable = true
    },
}
--Preset functions
function TubTalents_FindTalentPreset(presetID)
    if presetID == 0 then -- return current spec
        local t = {}
        local tp = {}
        for i=1, TubTalents_MAX_TALENTS do
            t[i] = {} -- initialize tab...
            _, _, tp[i] = TubTalents_OldGetTalentTabInfo(i)
            for m=1, MAX_NUM_TALENTS do
                local _, _, _, _, rank, 
                _, _, _ = TubTalents_OldGetTalentInfo(i, m);
                if rank ~=nil and rank ~= 0 then
                    t[i][m] = rank
                    --tp[i] = tp[i] + rank
                end
            end
        end

        --TubTalent_Vars.TalentPresetIDMax = TubTalent_Vars.TalentPresetIDMax+1
        local newPreset = {
            class = UnitClass("player"),
            name = "temp",
            id = 0,
            talents = t,
            points = tp,
        }
        --TubTalents_Out(format("c p1: %s p2: %s p3: %s", tp[1], tp[2], tp[3]))
        return 0, newPreset
    end
    for k, v in pairs(TubTalents_TalentPresets) do
        if v.id == tonumber(presetID) then
            return k, v
        end
    end
    return nil
end

function TubTalents_TalentPresetDelete(presetID)
    k, _ = TubTalents_FindTalentPreset(presetID) 
    TubTalents_TalentPresets[k] = nil
    TubTalents_RegenPresetDropdown()
    TubTalents_TalentPresets_Dewdrop:Close()
end

function TubTalents_StageCurrentSpec()
    TubTalents_TalentPresetStage(0)
end

function TubTalents_TalentPresetStage(presetID)
    _, t = TubTalents_FindTalentPreset(presetID)

    --checks
    local total = {} --stage points locally for comparison
    for i=1, TubTalents_MAX_TALENTS do
        total[i] = t.points[i]
    end

    -- Check already learned talents, and subtract points
    for i=1, TubTalents_MAX_TALENTS do
        for k, v in pairs(t.talents[i]) do
            local b = _G["TalentFrameTalent"..k];
            if b ~=nil then
                local btnID = b:GetID()
                local _, _, _, _, rank, 
                _, _, _ = GetTalentInfo(i, btnID);
                if rank ~= 0 then
                    total[i] = total[i] - rank
                end
                local _, _, _, _, learnedRank, _, _, _ = TubTalents_OldGetTalentInfo(i, k);
                local stagedRank = t.talents[i][k]
                --TubTalents_Out(format("rank: %s learnedRank: %s", rank, learnedRank))
                if stagedRank < learnedRank and not TubTalents_SimMode then --if ranks match its fine
                    TubTalents_Out(TubTalents_ERRStagedPresetsLearnedConflict)
                    TubTalents_TalentPresets_Dewdrop:Close()
                    return
                end
            end
        end
    end

    local totals = 0
    for i=1, TubTalents_MAX_TALENTS do
        totals = totals + total[i]
    end
    --if you don't have enough talent points to stage return error and stop
    if totals > TalentFrame.talentPoints then
        TubTalents_Out(TubTalents_ERRStagedPresetsPoints)
        TubTalents_TalentPresets_Dewdrop:Close()
        return
    end
    --staging...
    for i=1, TubTalents_MAX_TALENTS do -- re-add the points for comparison back
        TubTalents_TalentPointsSpent[i] = total[i] + TubTalents_TalentPointsSpent[i]
    end
    for i=1, getn(t.talents) do -- just copy them over to staging...
        for k, v in pairs (t.talents[i]) do --need to do pairs here i guess
            if TubTalents_SimMode then
                TubTalents_StagedTalents[i][k] = v
            else
                local _, _, _, _, learnedRank, _, _, _ = TubTalents_OldGetTalentInfo(i, k);
                TubTalents_StagedTalents[i][k] = v - learnedRank
            end
        end
    end
    TubTalents_PresetLoaded = true
    TubTalents_TalentFrame_Update()
    TubTalents_TalentFrameButtons_OnUpdate()
end

function TubTalents_TalentPresetLearn(presetID)
    --_, t = TubTalents_FindTalentPreset(presetID)
    --TubTalents_WipeCurrentSpec()
    --Checks and staging...
    TubTalents_TalentPresetStage(presetID)
    TubTalents_LearnButton_OnClick()
    TubTalents_TalentFrame_Update()
    TubTalents_TalentFrameButtons_OnUpdate()
end

function TubTalents_RegenPresetDropdown()
    TubTalents_PresetOpts[2]["presets"] = {} -- clear it out first
    local count = 0 
    if TubTalents_TalentPresets ~= nil then
        for k,v in pairs(TubTalents_TalentPresets) do
            local a = "ID: " .. v.id .. "\n"
            for i=1, TubTalents_MAX_TALENTS do
                name, _, _ = GetTalentTabInfo(i)
                a = format("%s%s in %s\n",a,v.points[i],name)
            end
            local t = {
                name=v.name,
                tooltipTitle=v.name,
                tooltip=a,
                notCheckable=true,
                value="presetmenu:"..v.id
            }
            table.insert(TubTalents_PresetOpts[2]["presets"],t)
            count = count + 1
        end
    end
    if count == 0 then
        table.insert(TubTalents_PresetOpts[2]["presets"],TubTalents_PRESETDEFAULTDROP)
    end
end

function TubTalents_NewPreset(name, preset)
    --Scan talents
    --Prepare package
    --Add it to the Presets table...
    local t = {}
    local tp = {}
    if preset == nil then
        for i=1, TubTalents_MAX_TALENTS do
            t[i] = {} -- initialize tab...
            _, _, tp[i] = GetTalentTabInfo(i)
            for m=1, MAX_NUM_TALENTS do
                local _, _, _, _, rank, 
                _, _, _ = TubTalents_GetTalentInfo(i, m);
                if rank ~=nil and rank ~= 0 then
                    t[i][m] = rank
                end
            end
        end
    else
        for i=1, TubTalents_MAX_TALENTS do
            tp[i] = preset.points[i]
            t[i] = {}
            for k, v in preset.talents[i] do
                t[i][k] = v
            end
        end
    end

    TubTalent_Vars.TalentPresetIDMax = TubTalent_Vars.TalentPresetIDMax+1
    local newPreset = {
        class = UnitClass("player"),
        name = name,
        id = TubTalent_Vars.TalentPresetIDMax,
        talents = t,
        points = tp,
    }
    table.insert(TubTalents_TalentPresets, newPreset)
    --TubTalents_Out("Adding new profile")
    TubTalents_RegenPresetDropdown()
end

function TubTalents_RenamePreset(presetID, name)
    _, v = TubTalents_FindTalentPreset(presetID)
    v.name = name
    TubTalents_RegenPresetDropdown()
    --TubTalents_TalentPresets_Dewdrop:Close()
end

-- Disables the dropdown button? if no points are staged or spent
function TubTalents_SavePresetButton_OnUpdate()
    for i=1, TubTalents_MAX_TALENTS do
        _, _, pointsSpent = GetTalentTabInfo(i);
        if pointsSpent > 0 then
            return false
        end
    end
    return true
end