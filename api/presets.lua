--Preset dropdown menu
TT_DialogOpts = {
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
            func=function()  TT_ProfileFrame_Show(TT_PROFILEMODES.ImportPreset)  TT_TalentPresets_Dewdrop:Close() end,
            value=""
        },
        {
            name="Stage Current Build",
            tooltip="Stages current learned talents\n Only needed in SimMode",
            notCheckable=true,
            disabledTooltip="Only useful in Sim Mode",
            disabled = function() return not TT_SimMode end,
            func=TT_StageCurrentSpec,
            value=""
        },
        {
            name="Save Preset",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            disabledTooltip="Start staging or spending points to save a preset",
            disabled = function() return TT_SavePresetButton_OnUpdate() end,
            editBoxText=function() return "" end,
            editBoxFunc=function(s) TT_NewPreset(s) end,
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
            disabled = function() return TT_SimMode end,
            func=function(arg1)  TT_TalentPresetLearn(arg1) end,
            value=""
            },
            {
            name="Stage Preset",
            tooltip="Stages the selected preset over your current build if possible\nEnable Sim mode if you don't want to reset your talents",
            notCheckable=true,
            func=function(arg1)  TT_TalentPresetStage(arg1) end,
            value=""
            },
            {
            name="Export Preset",
            tooltip="Exports the selected preset",
            notCheckable=true,
            func=function(arg1)  TT_ProfileFrame_Show(TT_PROFILEMODES.ExportPreset, arg1) TT_TalentPresets_Dewdrop:Close() end,
            value=""
            },
            {
            name="Delete Preset",
            tooltip="Deletes the selected preset",
            notCheckable=true,
            func=function(arg1)  TT_TalentPresetDelete(arg1) end,
            value=""
            },
            {
            name="Rename Preset",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            editBoxText=function(arg1) 
                _, v =  TT_FindTalentPreset(arg1) 
                return v.name 
            end,
            editBoxFunc=function(arg1,s) TT_RenamePreset(arg1,s) end,
            value=""
            },
        }
    },
    [4] = {

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
function TT_FindTalentPreset(presetID)
    if presetID == 0 then -- return current spec
        local t = {}
        local tp = {}
        for i=1, 3 do
            t[i] = {} -- initialize tab...
            _, _, tp[i] = TT_OldGetTalentTabInfo(i)
            for m=1, MAX_NUM_TALENTS do
                local _, _, _, _, rank, 
                _, _, _ = TT_OldGetTalentInfo(i, m);
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
        --TT_Out(format("c p1: %s p2: %s p3: %s", tp[1], tp[2], tp[3]))
        return 0, newPreset
    end
    for k, v in pairs(TT_TalentPresets) do
        if v.id == tonumber(presetID) then
            return k, v
        end
    end
    return nil
end

function TT_TalentPresetDelete(presetID)
    k, _ = TT_FindTalentPreset(presetID) 
    TT_TalentPresets[k] = nil
    TT_RegenPresetDropdown()
    TT_TalentPresets_Dewdrop:Close()
end

function TT_StageCurrentSpec()
    TT_TalentPresetStage(0)
end

function TT_TalentPresetStage(presetID)
    _, t = TT_FindTalentPreset(presetID)

    --checks
    local total = {} --stage points locally for comparison
    for i=1, 3 do
        total[i] = t.points[i]
    end

    -- Check already learned talents, and subtract points
    for i=1, 3 do
        for k, v in pairs(t.talents[i]) do
            local b = _G["TalentFrameTalent"..k];
            if b ~=nil then
                local btnID = b:GetID()
                local _, _, _, _, rank, 
                _, _, _ = GetTalentInfo(i, btnID);
                if rank ~= 0 then
                    total[i] = total[i] - rank
                end
                local _, _, _, _, learnedRank, _, _, _ = TT_OldGetTalentInfo(i, k);
                local stagedRank = t.talents[i][k]
                --TT_Out(format("rank: %s learnedRank: %s", rank, learnedRank))
                if stagedRank < learnedRank and not TT_SimMode then --if ranks match its fine
                    TT_Out("Learned ranks conflict, can't stage preset. Reset, or enable Sim mode.")
                    TT_TalentPresets_Dewdrop:Close()
                    return
                end
            end
        end
    end

    local totals = 0
    for i=1, 3 do
        totals = totals + total[i]
    end
    --if you don't have enough talent points to stage return error and stop
    if totals > TalentFrame.talentPoints then
        TT_Out("Not enough points, can't stage preset. Reset, or enable Sim mode.")
        TT_TalentPresets_Dewdrop:Close()
        return
    end
    --staging...
    for i=1, 3 do -- re-add the points for comparison back
        TT_TalentPointsSpent[i] = total[i] + TT_TalentPointsSpent[i]
    end
    for i=1, getn(t.talents) do -- just copy them over to staging...
        for k, v in pairs (t.talents[i]) do --need to do pairs here i guess
            if TT_SimMode then
                TT_StagedTalents[i][k] = v
            else
                local _, _, _, _, learnedRank, _, _, _ = TT_OldGetTalentInfo(i, k);
                TT_StagedTalents[i][k] = v - learnedRank
            end
        end
    end
    TT_PresetLoaded = true
    TT_TalentFrame_Update()
    TT_TalentFrameButtons_OnUpdate()
end

function TT_TalentPresetLearn(presetID)
    --_, t = TT_FindTalentPreset(presetID)
    TT_WipeCurrentSpec()
    --Checks and staging...
    TT_TalentPresetStage(presetID)
    TT_LearnButton_OnClick()
    TT_TalentFrame_Update()
    TT_TalentFrameButtons_OnUpdate()
end

function TT_RegenPresetDropdown()
    TT_DialogOpts[2]["presets"] = {} -- clear it out first
    local count = 0 
    if TT_TalentPresets ~= nil then
        for k,v in pairs(TT_TalentPresets) do
            local a = "ID: " .. v.id .. "\n"
            for i=1, 3 do
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
            table.insert(TT_DialogOpts[2]["presets"],t)
            count = count + 1
        end
    end
    if count == 0 then
        local t = {
            name="Create or import a preset",
            tooltip="Go ahead, stage or spend some points and then save it.",
            notCheckable=true,
            value=""
        }
        table.insert(TT_DialogOpts[2]["presets"],t)
    end
end

function TT_NewPreset(name)
    --Scan talents
    --Prepare package
    --Add it to the Presets table...
    local t = {}
    local tp = {}
    for i=1, 3 do
        t[i] = {} -- initialize tab...
        _, _, tp[i] = GetTalentTabInfo(i)
        for m=1, MAX_NUM_TALENTS do
            local _, _, _, _, rank, 
            _, _, _ = TT_GetTalentInfo(i, m);
            if rank ~=nil and rank ~= 0 then
                t[i][m] = rank
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
    table.insert(TT_TalentPresets, newPreset)
    TT_Out("Adding new profile")
    TT_RegenPresetDropdown()
end

function TT_RenamePreset(presetID, name)
    _, v = TT_FindTalentPreset(presetID)
    v.name = name
    TT_RegenPresetDropdown()
    --TT_TalentPresets_Dewdrop:Close()
end

-- Disables the dropdown button? if no points are staged or spent
function TT_SavePresetButton_OnUpdate()
    for i=1, TT_MAX_TALENTS do
        _, _, pointsSpent = GetTalentTabInfo(i);
        if pointsSpent > 0 then
            return false
        end
    end
    return true
end