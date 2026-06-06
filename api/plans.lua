local _G = getfenv(0)
-- Level Plan UI
NUM_LVLPLAN_TALENTSSHOWN = 6
TubTalents_PresetLoaded = false
TubTalents_StagedLevellingPlan = {}
TubTalents_StagedLevellingPlanMinLevel = TubTalents_MINLEVEL

TubTalents_PlanOpts = {
    [1] = {
        {
            name="Plans",
            tooltip="",
            notCheckable=true,
            value="plans"
        },
        {
            name="Import Plan",
            tooltip="Opens a window to paste in a plan",
            notCheckable=true,
            func=function()  TubTalents_ProfileFrame_Show(TubTalents_PROFILEMODES.ImportPlan) TubTalents_LevellingPlans_DewDrop:Close() end,
            value=""
        },
        {
            name="Options",
            tooltip="",
            notCheckable=true,
            value="plansoptions"
        },
        {
            name="Catch Up On Plan",
            tooltip="Catch up on your selected levelling plan.",
            notCheckable=true,
            disabledTooltip="Only works if you have selected a plan\nAnd have points to spend",
            disabled = function() 
                if TubTalent_Vars.CurrentLevellingPlan ~= 0 -- need plan selected
                and TalentFrame.talentPoints > 0 then --need points to spend,
                    return false
                end
                return true
            end,
            func=function()  TubTalents_CatchUpPlan(true) TubTalents_LevellingPlans_DewDrop:Close() end,
            value=""
        },
        {
            name="Save Plan",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            disabledTooltip="Start making a plan to save one\nPlans can only be made in Sim Mode",
            disabled = function() 
                if TubTalents_SimMode and not TubTalents_PresetLoaded then
                    for i=1, TubTalents_MAX_TALENTS do 
                        if TubTalents_TalentPointsSpent[i] > 0 then
                            return false
                        end
                    end
                end
                return true
             end,
            editBoxText=function() return "" end,
            editBoxFunc=function(s) TubTalents_NewPlan(s) end,
            value=""
        },
    },
    [2] = { --populate with plans
        ["plans"]={

        },
        ["plansoptions"] = {
            {
                name="Auto Learn Talents",
                tooltipTitle="",
                tooltip="Auto learn talents as you level",
                notCheckable=true,
                value="plansoptionsautolearn"
            },
        },
    },
    [3] = { --arg1 is loaded from the previous dropdowns value
        ["plansoptionsautolearn"] = {
            {
                name="Never",
                tooltip="Never automatically learn talents\nLevelling plans are just for reference",
                notCheckable=false,
                isRadio=true,
                checked=function() 
                    if TubTalent_Vars.AutoLearnPlans == TubTalents_AUTOLEARN.Never then
                        return true
                    end
                end,
                func=function() 
                    TubTalent_Vars.AutoLearnPlans = TubTalents_AUTOLEARN.Never
                end,
                value=""
            },
            {
                name="Prompt",
                tooltip="Displays a popup to learn latest talent in levelling plans on levelup",
                notCheckable=false,
                isRadio=true,
                checked=function() 
                    if TubTalent_Vars.AutoLearnPlans == TubTalents_AUTOLEARN.Prompt then
                        return true
                    end
                end,
                func=function() 
                    TubTalent_Vars.AutoLearnPlans = TubTalents_AUTOLEARN.Prompt
                    TubTalents_CatchUpPlan()
                end,
                value=""
            },
            {
                name="Full Auto",
                tooltip="Auto learn new talents aggressively\n!!USE WITH CAUTION!!",
                notCheckable=false,
                isRadio=true,
                checked=function() 
                    if TubTalent_Vars.AutoLearnPlans == TubTalents_AUTOLEARN.FullAuto then
                        return true
                    end
                end,
                func=function() 
                    TubTalent_Vars.AutoLearnPlans = TubTalents_AUTOLEARN.FullAuto
                    TubTalents_CatchUpPlan()
                end,
                value=""
            },
        },
        ["plansmenu"] = {
            {
            name="Stage Plan",
            tooltip="Stages the selected plan over your current build if possible\nEnable Sim mode if you don't want to reset your talents",
            disabledTooltip="Must be in Sim Mode",
            notCheckable=true,
            disabled = function() return not TubTalents_SimMode end,
            func=function(arg1)  TubTalents_StagePlan(arg1) end,
            value=""
            },
            {
            name="Export Plan",
            tooltip="Exports the selected plan",
            notCheckable=true,
            func=function(arg1)  TubTalents_ProfileFrame_Show(TubTalents_PROFILEMODES.ExportPlan, arg1) TubTalents_LevellingPlans_DewDrop:Close() end,
            value=""
            },
            {
            name="Delete Plan",
            tooltip="Deletes the selected plan",
            notCheckable=true,
            disabledTooltip="Can't delete the selected plan",
            disabled=function(arg1) 
                _, v = TubTalents_FindPlan(arg1)
                if v ~=nil and TubTalents_CurrentLevellingPlan ~= nil 
                and v.id == TubTalents_CurrentLevellingPlan.id then
                    return true
                else 
                    return false
                end end,
            func=function(arg1)  
                _ , v = TubTalents_FindPlan(arg1)
                StaticPopupDialogs["TUBTALENTS_DELETEPLAN_POPUP"].text = 
                format(TubTalents_DELETEPLANPROMPT, v.name)
                StaticPopup_Show("TUBTALENTS_DELETEPLAN_POPUP")   
            end,
            value=""
            },
            {
            name="Share Plan",
            tooltip="Shares the selected plan",
            notCheckable=true,
            --func=function(arg1)  TubTalents_TalentPlanShare(arg1) end,
            value="sharemenu"
            },
            {
            name="Rename Plan",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            editBoxText=function(arg1) 
                _, v =  TubTalents_FindPlan(arg1) 
                return v.name 
            end,
            editBoxFunc=function(arg1,s) TubTalents_RenamePlan(arg1,s) end,
            value=""
            },
        }
    },
    [4] = {
        ["sharemenu"] = {
            {
            name="Party",
            tooltip="Shares the selected plan with Party",
            notCheckable=true,
            func=function()  
                TubTalents_TalentPlanShare(TT_CurrentSelectedDropID, TubTalents_AMCHANNELS.Party) 
            end,
            value=""
            },
            {
            name="Guild",
            tooltip="Shares the selected plan with Guild",
            notCheckable=true,
            func=function()  
                TubTalents_TalentPlanShare(TT_CurrentSelectedDropID, TubTalents_AMCHANNELS.Guild) 
            end,
            value=""
            },
            {
            name="Raid",
            tooltip="Shares the selected plan with Raid",
            notCheckable=true,
            func=function()  
                TubTalents_TalentPlanShare(TT_CurrentSelectedDropID, TubTalents_AMCHANNELS.Raid) 
            end,
            value=""
            },
            {
            name="Battleground",
            tooltip="Shares the selected plan with Battleground Group",
            notCheckable=true,
            func=function()  
                TubTalents_TalentPlanShare(TT_CurrentSelectedDropID, TubTalents_AMCHANNELS.BG) 
            end,
            value=""
            },
        },
    },
}

function TubTalents_FindPlan(planID)
    if TubTalents_LevellingPlans == nil then
        return nil
    end
    for k, v in pairs(TubTalents_LevellingPlans) do
        if v.id == tonumber(planID) then
            return k, v
        end
    end
    return nil
end


function TubTalents_CheckPlan(plan)
    --Check staged talents against currently learned talents
    --If there's something learned, but not staged then raise an error message
    -- and: Warn? Disable the current levelling plan?
    -- We'll just scan learned talents, and if anything isnt in the levelling plan
    -- raise an error.
    --- If you have something extra learned, its an issue as you'll be lacking points
    --- If you're missing something from the levelling plan, we'll get there
    ---- It'll fail to find something learned early though...? (Added key check)
    --local t = {}
    local estLevel = UnitLevel("player")
    for i=1, TubTalents_MAX_TALENTS do
        for m=1, MAX_NUM_TALENTS do
            name, iconTexture, tier, column, rank, maxRank, 
            isExceptional, meetsPrereq = TubTalents_OldGetTalentInfo(i,m);
            local found = 0 
            if rank ~= nil and rank > 0 then -- just check every learned rank...
                for k,v in plan do
                    if tonumber(k) <= estLevel and v.tab == i and v.btnID == m and v.rank == rank then
                        found = 1
                    end
                end
                if found ~= 1 then
                    TubTalents_Out(TubTalents_ERRLevelPlan)
                    return false
                end
            end
        end
    end
    return true
end

function TubTalents_CatchUpLearnPlan()
    local cp1, cp2 = UnitCharacterPoints("player");
    local estLevel = max(UnitLevel("player") - cp1+1,10)
    while cp1 > 0 do
        if TubTalents_CurrentLevellingPlan.plan[estLevel] ~= nil then
            btn = TubTalents_CurrentLevellingPlan.plan[estLevel].btnID
            tab = TubTalents_CurrentLevellingPlan.plan[estLevel].tab
            rank = TubTalents_CurrentLevellingPlan.plan[estLevel].rank
            --TubTalents_Out(format("Learning btn: %s tab: %s rank: %s", btn, tab, rank))
            LearnTalentRank(tab, btn, rank)
            cp1 = cp1 - 1
            estLevel = estLevel + 1
            TubTalents_LearnedTalentsFlag = true
        else
            --TubTalents_Out("End of leveling plan?") --TODO: Remove this after testing
            break
        end
    end
end

StaticPopupDialogs["TUBTALENTS_LVLPLAN_CATCHUP_PROMPT"] = {
    text = TubTalents_CATCHUPPROMPT,
    button1 = "Yes",
    button2 = "No",
    OnAccept = TubTalents_CatchUpLearnPlan,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}


function TubTalents_CatchUpPlan(menu)
    local flag = menu or false
    if TubTalent_Vars.CurrentLevellingPlan ~= 0 then
    --Get unspent talent points (outside of modes)
        local cp1, cp2 = UnitCharacterPoints("player");
        --TubTalents_Out(format("AutoLearn: %s", TubTalent_Vars.AutoLearnPlans))
        local estLevel = UnitLevel("player")
        estLevel = estLevel - cp1
        if estLevel >= TubTalents_CurrentLevellingPlan.levellingPlanMaxLevel then
            return
        end
        if cp1 > 1 then -- many points to spend...
            if TubTalent_Vars.AutoLearnPlans == TubTalents_AUTOLEARN.Prompt or flag then
                StaticPopup_Show("TUBTALENTS_LVLPLAN_CATCHUP_PROMPT")
            elseif TubTalent_Vars.AutoLearnPlans == TubTalents_AUTOLEARN.FullAuto then
                TubTalents_CatchUpLearnPlan()
            end
        elseif cp1 > 0 then 
            -- offer to learn the latest talent in the levelling plan...
            if TubTalent_Vars.AutoLearnPlans == TubTalents_AUTOLEARN.Prompt or flag then
                TubTalents_LearnTalentPopup:Show()
            elseif TubTalent_Vars.AutoLearnPlans == TubTalents_AUTOLEARN.FullAuto then
                TubTalents_CatchUpLearnPlan()
            end
        end
    end
end

function TubTalents_SelectPlan(arg)
    _, v = TubTalents_FindPlan(arg)
    if TubTalents_CurrentLevellingPlan ~= nil and v.id == TubTalents_CurrentLevellingPlan.id then -- deselect current one
        TubTalent_Vars.CurrentLevellingPlan = 0
        TubTalents_CurrentLevellingPlan = nil
        TubTalents_StagedTalentsFrame_Update()
        return
    end
    if TubTalents_CheckPlan(v.plan) then 
        TubTalent_Vars.CurrentLevellingPlan = v.id
        TubTalents_CurrentLevellingPlan = v
    end
    if (RQ_GetVersion and SUPERWOW_STRING) and not TubTalents_FakeNoMods then
        --re-cache spellIDs if they're missing...
        TubTalents_CheckSpellIds(v.plan)
    end
    --TubTalents_LevellingPlans_DewDrop:Close()
    TubTalents_StagedTalentFrame_CurrentTab=2
    TubTalents_CatchUpPlan()
    TubTalents_StagedTalentsFrame_SetTab()
    TubTalents_StagedTalentsFrame_Update()
end

function TubTalents_StagePlan(arg)
    k, v = TubTalents_FindPlan(arg)
    --Empty currently staged levelling plan...
    TubTalents_ResetButton_OnClick()
    --TubTalents_StagedLevellingPlan = {}
    --Load this levelling plan...
    for i=1, TubTalents_MAX_TALENTS do -- re-add the points for comparison back
        TubTalents_TalentPointsSpent[i] = v.points[i]
    end
    for k,x in pairs(v.plan) do
        TubTalents_StagedLevellingPlan[k] = x
        if TubTalents_StagedTalents[x.tab][x.btnID] == nil then
            TubTalents_StagedTalents[x.tab][x.btnID] = 1
        else
            TubTalents_StagedTalents[x.tab][x.btnID] = TubTalents_StagedTalents[x.tab][x.btnID]+1
        end
    end
    TubTalents_LevellingPlans_DewDrop:Close()
    TubTalents_TalentFrame_Update()
    TubTalents_TalentFrameButtons_OnUpdate()
    TubTalents_StagedTalentsFrame_Update()
end

function TubTalents_DeletePlan(arg)
    if arg == nil then arg = TT_CurrentSelectedDropID end
    k, v = TubTalents_FindPlan(arg)
    if v.id == TubTalent_Vars.CurrentLevellingPlan then
        TubTalents_Out(TubTalents_ERRDeleteSelctedPlan)
    else
        TubTalents_LevellingPlans[k] = nil
    end
    TubTalents_RegenPlansDropdown()
    TubTalents_LevellingPlans_DewDrop:Close()
end

StaticPopupDialogs["TUBTALENTS_DELETEPLAN_POPUP"] = {
    text = TubTalents_TEST,
    button1 = "Yes",
    button2 = "No",
    OnAccept = TubTalents_DeletePlan,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

function TubTalents_NewPlan(name,preset) 
    local planMinLevel = TubTalents_MINLEVEL + 1
    local planMaxLevel = planMinLevel
    local t = {}
    local tp = {}
    if preset == nil then
        for k , v in pairs(TubTalents_StagedLevellingPlan) do
            planMinLevel = min(planMinLevel, k)
            planMaxLevel = max(planMaxLevel, k)
            local n = {
                tab = v.tab,
                tabName = v.tabName,
                btnID = v.btnID,
                rank = v.rank,
                icon = v.icon,
                spellID = v.spellID,
                name = v.name,
            }
            --TubTalents_Out("Adding to new plan..." .. planMinLevel .. " " .. planMaxLevel)
            t[k] = n
        end
        for i=1, TubTalents_MAX_TALENTS do
            _, _, tp[i] = GetTalentTabInfo(i)
        end
    else
        planMinLevel = preset.levellingPlanMinLevel
        planMaxLevel = preset.levellingPlanMaxLevel
        name = preset.name
        for i=1, TubTalents_MAX_TALENTS do
            tp[i] = preset.points[i]
            for k, v in pairs(preset.plan) do
                local n = {
                    tab = v.tab,
                    tabName = v.tabName,
                    btnID = v.btnID,
                    rank = v.rank,
                    icon = v.icon,
                    spellID = v.spellID,
                    name = v.name,
                }
                t[k] = n
            end
        end
    end
    TubTalent_Vars.LevellingPlanIDMax = TubTalent_Vars.LevellingPlanIDMax + 1
    local newPlan = {
        class = UnitClass("player"),
        name = name,
        points = tp,
        id = TubTalent_Vars.LevellingPlanIDMax,
        levellingPlanMinLevel = planMinLevel, --Min level might get cut...
        levellingPlanMaxLevel = planMaxLevel,
        plan = t
    }
    table.insert(TubTalents_LevellingPlans, newPlan)
    TubTalents_RegenPlansDropdown()
    TubTalents_LevellingPlans_DewDrop:Close()
end

function TubTalents_RenamePlan(planID, name)
    _, v = TubTalents_FindPlan(planID)
    v.name = name
    TubTalents_RegenPlansDropdown()
end

-- Staged Talents Frame functions

function TubTalents_StagedTalentsFrame_FrameSetup()
    TubTalents_StagedTalentsFrame:SetParent(TalentFrame)
    TubTalents_StagedTalentsFrame:ClearAllPoints()
    TubTalents_StagedTalentsFrame:SetPoint("TOPLEFT", TalentFrame, "TOPRIGHT", -25, -20); -- Position it
    TubTalents_StagedTalentsFrame:Show()
    -- Update widget framestrata to high or it'll draw under the levelling plan frame
    TubTalents_StagedTalentsFrame_StagedPlanButton:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_CurrentPlanButton:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_LvlPlanSpec1:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_LvlPlanSpec2:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_LvlPlanSpec3:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_LvlPlanSpec4:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_LvlPlanSpec5:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_LvlPlanSpec6:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_PlanScrollFrame:SetFrameStrata("HIGH")
    TubTalents_StagedTalentsFrame_PlansButton:SetFrameStrata("HIGH")
end

function TubTalents_StagedTalentsFrame_PlansButton_OnClick()
    if TubTalents_LevellingPlans_DewDrop:IsOpen() then
        TubTalents_LevellingPlans_DewDrop:Close();
    else
        TubTalents_LevellingPlans_DewDrop:Open(this);
    end
end

function TubTalents_StagedTalentsFramePlans_DewdropRegister()
    TubTalents_LevellingPlans_DewDrop:Register(TubTalents_StagedTalentsFrame_PlansButton, --Bound Frame
        'point', function(parent) --Point
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value) TubTalents_TalentPresets_DewdropGen(level, value, TubTalents_PlanOpts) end,
        'dontHook', true
    )
end

function TubTalents_StagedTalentsFrame_SetTab()
    if TubTalents_StagedTalentFrame_CurrentTab == 1 then
        PanelTemplates_SelectTab(TubTalents_StagedTalentsFrame_StagedPlanButton);
        PanelTemplates_DeselectTab(TubTalents_StagedTalentsFrame_CurrentPlanButton);
    else
        PanelTemplates_SelectTab(TubTalents_StagedTalentsFrame_CurrentPlanButton);
        PanelTemplates_DeselectTab(TubTalents_StagedTalentsFrame_StagedPlanButton);
    end
    PanelTemplates_UpdateTabs(TubTalents_StagedTalentsFrame)
    TubTalents_StagedTalentsFrame_Update()
end

function TubTalents_StagedTalentsFrame_SwitchTab()
    TubTalents_StagedTalentFrame_CurrentTab = this:GetID()
    TubTalents_StagedTalentsFrame_SetTab()
end

function TubTalents_StagedTalentsFrame_Update()
    local numDisplay, plansToDisplay
    if TubTalents_StagedTalentFrame_CurrentTab == 2 then
        if TubTalent_Vars.CurrentLevellingPlan ~= 0 then
            TubTalents_StagedTalentsFrame_NoWorking:Hide()
            numDisplay = TubTalents_CurrentLevellingPlan.levellingPlanMaxLevel - TubTalents_MINLEVEL
            plansToDisplay = TubTalents_CurrentLevellingPlan.plan
            --if TubTalents_CurrentLevellingPlan == nil then
            --    TubTalents_Out("FAILED")
            --end
        elseif TubTalent_Vars.CurrentLevellingPlan == 0 then
            numDisplay = 0 
            TubTalents_StagedTalentsFrame_NoWorking:Show()
            TubTalents_StagedTalentsFrame_NoWorking:SetText(TubTalents_STAGEDTALENTS_NOPLANSELECTED)
            for i=1, NUM_LVLPLAN_TALENTSSHOWN do
                local lvlPlanFrame = _G["TubTalents_StagedTalentsFrame_LvlPlanSpec"..i]
                lvlPlanFrame:Hide()
            end
        end
    else
        if TubTalents_SimMode and not TubTalents_PresetLoaded then
            numDisplay = TubTalents_StagedEstimatedLevel - TubTalents_MINLEVEL
            plansToDisplay = TubTalents_StagedLevellingPlan
            if numDisplay == 0 then -- how I can tell if it's empty
                TubTalents_StagedTalentsFrame_NoWorking:Show()
                TubTalents_StagedTalentsFrame_NoWorking:SetText(TubTalents_STAGEDTALENTS_STARTPLAN)
            else
                TubTalents_StagedTalentsFrame_NoWorking:Hide()
            end
        else
            numDisplay = 0 
            TubTalents_StagedTalentsFrame_NoWorking:Show()
            if not TubTalents_SimMode then
                TubTalents_StagedTalentsFrame_NoWorking:SetText(TubTalents_STAGEDTALENTSERR)
            elseif TubTalents_SimMode and TubTalents_PresetLoaded then
                TubTalents_StagedTalentsFrame_NoWorking:SetText(TubTalents_STAGEDTALENTSNOPRESETS)
            end
            for i=1, NUM_LVLPLAN_TALENTSSHOWN do
                local lvlPlanFrame = _G["TubTalents_StagedTalentsFrame_LvlPlanSpec"..i]
                lvlPlanFrame:Hide()
            end
        end
    end

	local scrollOffset = FauxScrollFrame_GetOffset(TubTalents_StagedTalentsFrame_PlanScrollFrame);
	local index;
    local minIndex = TubTalents_MINLEVEL
    GameTooltip:Hide()
	for i=1, NUM_LVLPLAN_TALENTSSHOWN do
        local lvlPlanFrame = _G["TubTalents_StagedTalentsFrame_LvlPlanSpec"..i]
		index = (scrollOffset) + i;
		if ( index <= numDisplay) then
            local lvlPlanLevel = _G["TubTalents_StagedTalentsFrame_LvlPlanSpec"..i.."Level"]
            local lvlPlanName = _G["TubTalents_StagedTalentsFrame_LvlPlanSpec"..i.."Name"]
            local lvlPlanRank = _G["TubTalents_StagedTalentsFrame_LvlPlanSpec"..i.."Rank"]
            local lvlPlanIcon = _G["TubTalents_StagedTalentsFrame_LvlPlanSpec"..i.."Icon"]
			lvlPlanFrame:Show()
            lvlPlanName:SetText(plansToDisplay[index+minIndex].name)
            lvlPlanRank:SetText("Rank: " .. plansToDisplay[index+minIndex].rank .. " Tab: " .. plansToDisplay[index+minIndex].tabName)
            lvlPlanLevel:SetText("Level: " .. index+minIndex)
            lvlPlanIcon:SetTexture(plansToDisplay[index+minIndex].icon)
		else
            lvlPlanFrame:Hide()
		end
        if MouseIsOver(lvlPlanFrame) and TubTalents_StagedTalentsFrame:IsShown() then --Fixes jank when hiding the frame on show
            TubTalents_LvlPlanTooltip(lvlPlanFrame:GetID())
        end
	end

	-- Scrollbar stuff
	FauxScrollFrame_Update(TubTalents_StagedTalentsFrame_PlanScrollFrame, numDisplay , NUM_LVLPLAN_TALENTSSHOWN, 28);
end

--Shift click link for levelling plan
function TubTalents_LvlPlan_OnClick()
    if IsShiftKeyDown() then
        local id = this:GetID()
        local scrollOffset = FauxScrollFrame_GetOffset(TubTalents_StagedTalentsFrame_PlanScrollFrame);
        local index = id + scrollOffset + TubTalents_MINLEVEL
        if TubTalents_StagedTalentFrame_CurrentTab == 2 then
            plansToDisplay = TubTalents_CurrentLevellingPlan.plan
        else
            plansToDisplay = TubTalents_StagedLevellingPlan
        end
        local spellId = plansToDisplay[index].spellID
        local txt = DEFAULT_CHAT_FRAME.editBox:GetText()
        local link = format(TubTalents_CHATLINKFORMAT,
        plansToDisplay[index].spellID, plansToDisplay[index].name, plansToDisplay[index].rank)
        txt = format("%s %s",txt, link)
        DEFAULT_CHAT_FRAME.editBox:SetText(txt)
    end
end

function TubTalents_LvlPlanTooltip(cID)
    local scrollOffset = FauxScrollFrame_GetOffset(TubTalents_StagedTalentsFrame_PlanScrollFrame);
    local id = this:GetID() -- Seems to get messy if I sent it object as paramater
    if this:GetID() == 0 then
        id = cID
        this = _G["TubTalents_StagedTalentsFrame_LvlPlanSpec"..cID]
    end
    local index = id + scrollOffset + TubTalents_MINLEVEL
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
    if TubTalents_StagedTalentFrame_CurrentTab == 2 then
        if TubTalents_CurrentLevellingPlan ~= nil then
            plansToDisplay = TubTalents_CurrentLevellingPlan.plan
        end
    else
        plansToDisplay = TubTalents_StagedLevellingPlan
    end
    local sID
    if plansToDisplay ~= nil and plansToDisplay[index] ~= nil then --prevents an issue mousing over frame b4 being shown
        sID = plansToDisplay[index].spellID or 0 
    else
        return
    end
    if sID ~= 0 then
        GameTooltip:SetHyperlink(format("enchant:%s",sID))
    end
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPLEFT", this, "TOPRIGHT", 0, 0)
end

function TubTalents_CheckSpellIds(plan)
    for k,v in pairs(plan) do
        if v.spellID == 0 then
            v.spellID, _ = TubTalents_GetTalentSpellID(v.tab, v.btnID, v.rank)
        else break -- break loop early if there's a non zero spellID
        end
    end
end

-- uses standard talent tooltip, plenty appropriate
function TubTalents_LearnTalentPopup_TalentButtonOnEnter()
    local cp1, cp2 = UnitCharacterPoints("player");
    local estLevel = UnitLevel("player")
    --estlevel = estLevel - cp1    
    local btn = TubTalents_CurrentLevellingPlan.plan[estLevel].btnID
    local tab = TubTalents_CurrentLevellingPlan.plan[estLevel].tab
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
    GameTooltip:SetTalent(tab, btn)
end

function TubTalents_LearnTalentPopup_TalentButtonLoad()
    local estLevel = UnitLevel("player")
    local texture = TubTalents_CurrentLevellingPlan.plan[estLevel].icon
    local spellID = TubTalents_CurrentLevellingPlan.plan[estLevel].spellID
    local rank = TubTalents_CurrentLevellingPlan.plan[estLevel].rank
    local name = TubTalents_CurrentLevellingPlan.plan[estLevel].name
    TubTalents_LearnTalentPopup.spellID=spellID
    --TubTalents_Out(TubTalents_LearnTalentPopup.spellID)
    TubTalents_LearnTalentPopupTalentButtonIcon:SetTexture(texture)
    TubTalents_LearnTalentPopupTalentButtonName:SetText(name)
    TubTalents_LearnTalentPopupTalentButtonRank:SetText("Rank: " .. rank)
end

function TubTalents_RegenPlansDropdown()
    TubTalents_PlanOpts[2]["plans"] = {} -- clear it out first
    local count = 0 
    if TubTalents_TalentPresets ~= nil then
        for k,v in pairs(TubTalents_LevellingPlans) do
            local pDisplay = ""
            for i=1, TubTalents_MAX_TALENTS do
                name, _, _ = GetTalentTabInfo(i)
                pDisplay = format("%s%s in %s\n",pDisplay,v.points[i],name)
            end
            local t = {
                name=v.name,
                tooltipTitle=v.name,
                tooltip=format(TubTalents_PLANDROPTOOLTIP,
                v.id, pDisplay, v.levellingPlanMinLevel, v.levellingPlanMaxLevel),
                id=v.id,
                arg1=v.id,
                notCheckable=false,
                checked = function(id)
                    if TubTalent_Vars.CurrentLevellingPlan ~= nil then
                        if id == TubTalent_Vars.CurrentLevellingPlan then
                            return true
                        end
                    end return false  end,
                func=function(id)
                    TubTalents_SelectPlan(id)
                    TubTalents_RegenPlansDropdown()
                end,
                value="plansmenu:"..v.id
            }
            table.insert(TubTalents_PlanOpts[2]["plans"],t)
            count = count + 1
        end
    end
    if count == 0 then
        table.insert(TubTalents_PlanOpts[2]["plans"],TubTalents_PLANDEFAULTDROP)
    end
end