local _G = getfenv(0)
-- Level Plan UI
NUM_LVLPLAN_TALENTSSHOWN = 6
TT_PresetLoaded = false
TT_StagedLevellingPlan = {}
TT_StagedLevellingPlanMinLevel = TT_MINLEVEL

TT_PlanOpts = {
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
            func=function()  TT_ProfileFrame_Show(TT_PROFILEMODES.ImportPlan) TT_LevellingPlans_DewDrop:Close() end,
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
            func=function()  TT_CatchUpPlan(true) TT_LevellingPlans_DewDrop:Close() end,
            value=""
        },
        {
            name="Save Plan",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            disabledTooltip="Start making a plan to save one\nPlans can only be made in Sim Mode",
            disabled = function() 
                if TT_SimMode and not TT_PresetLoaded then
                    for i=1, 3 do 
                        if TT_TalentPointsSpent[i] > 0 then
                            return false
                        end
                    end
                end
                return true
             end,
            editBoxText=function() return "" end,
            editBoxFunc=function(s) TT_NewPlan(s) end,
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
                    if TubTalent_Vars.AutoLearnPlans == TT_AUTOLEARN.Never then
                        return true
                    end
                end,
                func=function() 
                    TubTalent_Vars.AutoLearnPlans = TT_AUTOLEARN.Never
                end,
                value=""
            },
            {
                name="Prompt",
                tooltip="Displays a popup to learn latest talent in levelling plans on levelup",
                notCheckable=false,
                isRadio=true,
                checked=function() 
                    if TubTalent_Vars.AutoLearnPlans == TT_AUTOLEARN.Prompt then
                        return true
                    end
                end,
                func=function() 
                    TubTalent_Vars.AutoLearnPlans = TT_AUTOLEARN.Prompt
                    TT_CatchUpPlan(true)
                end,
                value=""
            },
            {
                name="Full Auto",
                tooltip="Auto learn new talents on levelup",
                notCheckable=false,
                isRadio=true,
                checked=function() 
                    if TubTalent_Vars.AutoLearnPlans == TT_AUTOLEARN.FullAuto then
                        return true
                    end
                end,
                func=function() 
                    TubTalent_Vars.AutoLearnPlans = TT_AUTOLEARN.FullAuto
                    TT_CatchUpPlan(true)
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
            disabled = function() return not TT_SimMode end,
            func=function(arg1)  TT_StagePlan(arg1) end,
            value=""
            },
            {
            name="Export Plan",
            tooltip="Exports the selected plan",
            notCheckable=true,
            func=function(arg1)  TT_ProfileFrame_Show(TT_PROFILEMODES.ExportPlan, arg1) TT_LevellingPlans_DewDrop:Close() end,
            value=""
            },
            {
            name="Delete Plan",
            tooltip="Deletes the selected plan",
            notCheckable=true,
            disabledTooltip="Can't delete the selected plan",
            disabled=function(arg1) 
                _, v = TT_FindPlan(arg1)
                if v ~=nil and TT_CurrentLevellingPlan ~= nil 
                and v.id == TT_CurrentLevellingPlan.id then
                    return true
                else 
                    return false
                end end,
            func=function(arg1)  TT_DeletePlan(arg1) end,
            value=""
            },
            {
            name="Rename Plan",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            editBoxText=function(arg1) 
                _, v =  TT_FindPlan(arg1) 
                return v.name 
            end,
            editBoxFunc=function(arg1,s) TT_RenamePlan(arg1,s) end,
            value=""
            },
        }
    },
}

function TT_FindPlan(planID)
    if TT_LevellingPlans == nil then
        return nil
    end
    for k, v in pairs(TT_LevellingPlans) do
        if v.id == tonumber(planID) then
            return k, v
        end
    end
    return nil
end


function TT_CheckPlan(plan)
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
    for i=1, 3 do
        for m=1, MAX_NUM_TALENTS do
            name, iconTexture, tier, column, rank, maxRank, 
            isExceptional, meetsPrereq = TT_OldGetTalentInfo(i,m);
            local found = 0 
            if rank ~= nil and rank > 0 then -- just check every learned rank...
                for k,v in plan do
                    if tonumber(k) <= estLevel and v.tab == i and v.btnID == m and v.rank == rank then
                        found = 1
                    end
                end
                if found ~= 1 then
                    TT_Out(TT_ERRLevelPlan)
                    return false
                end
            end
        end
    end
    return true
end

function TT_CatchUpLearnPlan()
    local cp1, cp2 = UnitCharacterPoints("player");
    local estLevel = max(UnitLevel("player") - cp1+1,10)
    while cp1 > 0 do
        if TT_CurrentLevellingPlan.plan[estLevel] ~= nil then
            btn = TT_CurrentLevellingPlan.plan[estLevel].btnID
            tab = TT_CurrentLevellingPlan.plan[estLevel].tab
            rank = TT_CurrentLevellingPlan.plan[estLevel].rank
            --TT_Out(format("Learning btn: %s tab: %s rank: %s", btn, tab, rank))
            LearnTalentRank(tab, btn, rank)
            cp1 = cp1 - 1
            estLevel = estLevel + 1
            TT_LearnedTalentsFlag = true
        else
            --TT_Out("End of leveling plan?") --TODO: Remove this after testing
            break
        end
    end
end

StaticPopupDialogs["TUBTALENTS_LVLPLAN_CATCHUP_PROMPT"] = {
    text = TT_CATCHUPPROMPT,
    button1 = "Yes",
    button2 = "No",
    OnAccept = TT_CatchUpLearnPlan,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}


function TT_CatchUpPlan(menu)
    local flag = menu or false
    if TubTalent_Vars.CurrentLevellingPlan ~= 0 then
    --Get unspent talent points (outside of modes)
        local cp1, cp2 = UnitCharacterPoints("player");
        --TT_Out(format("AutoLearn: %s", TubTalent_Vars.AutoLearnPlans))
        local estLevel = UnitLevel("player")
        estLevel = estLevel - cp1
        if estLevel >= TT_CurrentLevellingPlan.levellingPlanMaxLevel then
            return
        end
        if cp1 > 1 then -- many points to spend...
            if TubTalent_Vars.AutoLearnPlans == TT_AUTOLEARN.Prompt or flag then
                StaticPopup_Show("TUBTALENTS_LVLPLAN_CATCHUP_PROMPT")
            elseif TubTalent_Vars.AutoLearnPlans == TT_AUTOLEARN.FullAuto then
                TT_CatchUpLearnPlan()
            end
        elseif cp1 > 0 then 
            -- offer to learn the latest talent in the levelling plan...
            if TubTalent_Vars.AutoLearnPlans == TT_AUTOLEARN.Prompt or flag then
                TT_LearnTalentPopup:Show()
            elseif TubTalent_Vars.AutoLearnPlans == TT_AUTOLEARN.FullAuto then
                TT_CatchUpLearnPlan()
            end
        end
    end
end

function TT_SelectPlan(arg)
    _, v = TT_FindPlan(arg)
    if TT_CurrentLevellingPlan ~= nil and v.id == TT_CurrentLevellingPlan.id then -- deselect current one
        TubTalent_Vars.CurrentLevellingPlan = 0
        TT_CurrentLevellingPlan = nil
        TT_StagedTalentsFrame_Update()
        return
    end
    if TT_CheckPlan(v.plan) then 
        TubTalent_Vars.CurrentLevellingPlan = v.id
        TT_CurrentLevellingPlan = v
    end
    if (RQ_GetVersion and SUPERWOW_STRING) and not TT_FakeNoMods then
        --re-cache spellIDs if they're missing...
        TT_CheckSpellIds(v.plan)
    end
    --TT_LevellingPlans_DewDrop:Close()
    TT_CurrentTab=2
    TT_CatchUpPlan()
    TT_StagedTalentsFrame_SetTab()
    TT_StagedTalentsFrame_Update()
end

function TT_StagePlan(arg)
    k, v = TT_FindPlan(arg)
    --Empty currently staged levelling plan...
    TT_ResetButton_OnClick()
    --TT_StagedLevellingPlan = {}
    --Load this levelling plan...
    for i=1, 3 do -- re-add the points for comparison back
        TT_TalentPointsSpent[i] = v.points[i]
    end
    for k,x in pairs(v.plan) do
        TT_StagedLevellingPlan[k] = x
        if TT_StagedTalents[x.tab][x.btnID] == nil then
            TT_StagedTalents[x.tab][x.btnID] = 1
        else
            TT_StagedTalents[x.tab][x.btnID] = TT_StagedTalents[x.tab][x.btnID]+1
        end
    end
    TT_LevellingPlans_DewDrop:Close()
    TT_TalentFrame_Update()
    TT_TalentFrameButtons_OnUpdate()
    TT_StagedTalentsFrame_Update()
end

function TT_DeletePlan(arg)
    k, v = TT_FindPlan(arg)
    if v.id == TubTalent_Vars.CurrentLevellingPlan then
        TT_Out(TT_ERRDeleteSelctedPlan)
    else
        TT_LevellingPlans[k] = nil
    end
    TT_RegenPlansDropdown()
    TT_LevellingPlans_DewDrop:Close()
end

function TT_NewPlan(name) 
    local planMinLevel = TT_MINLEVEL + 1
    local planMaxLevel = planMinLevel
    local t = {}

    for k , v in pairs(TT_StagedLevellingPlan) do
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
        --TT_Out("Adding to new plan..." .. planMinLevel .. " " .. planMaxLevel)
        t[k] = n
    end
    TubTalent_Vars.LevellingPlanIDMax = TubTalent_Vars.LevellingPlanIDMax + 1
    local tp = {}
    for i=1, 3 do
        _, _, tp[i] = GetTalentTabInfo(i)
    end
    local newPlan = {
        class = UnitClass("player"),
        name = name,
        points = tp,
        id = TubTalent_Vars.LevellingPlanIDMax,
        levellingPlanMinLevel = planMinLevel, --Min level might get cut...
        levellingPlanMaxLevel = planMaxLevel,
        plan = t
    }
    table.insert(TT_LevellingPlans, newPlan)
    TT_RegenPlansDropdown()
    TT_LevellingPlans_DewDrop:Close()
end

function TT_RenamePlan(planID, name)
    _, v = TT_FindPlan(planID)
    v.name = name
    TT_RegenPlansDropdown()
end

-- Staged Talents Frame functions

function TT_StagedTalentsFrame_FrameSetup()
    TT_StagedTalentsFrame:SetParent(TalentFrame)
    TT_StagedTalentsFrame:ClearAllPoints()
    TT_StagedTalentsFrame:SetPoint("TOPLEFT", TalentFrame, "TOPRIGHT", -25, -20); -- Position it
    TT_StagedTalentsFrame:Show()
    -- Update widget framestrata to high or it'll draw under the levelling plan frame
    TT_StagedTalentsFrame_StagedPlanButton:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_CurrentPlanButton:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_LvlPlanSpec1:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_LvlPlanSpec2:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_LvlPlanSpec3:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_LvlPlanSpec4:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_LvlPlanSpec5:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_LvlPlanSpec6:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_PlanScrollFrame:SetFrameStrata("HIGH")
    TT_StagedTalentsFrame_PlansButton:SetFrameStrata("HIGH")
end

function TT_StagedTalentsFrame_PlansButton_OnClick()
    if TT_LevellingPlans_DewDrop:IsOpen() then
        TT_LevellingPlans_DewDrop:Close();
    else
        TT_LevellingPlans_DewDrop:Open(this);
    end
end

function TT_StagedTalentsFramePlans_DewdropRegister()
    TT_LevellingPlans_DewDrop:Register(TT_StagedTalentsFrame_PlansButton, --Bound Frame
        'point', function(parent) --Point
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value) TT_TalentPresets_DewdropGen(level, value, TT_PlanOpts) end,
        'dontHook', true
    )
end

function TT_StagedTalentsFrame_SetTab()
    if TT_CurrentTab == 1 then
        PanelTemplates_SelectTab(TT_StagedTalentsFrame_StagedPlanButton);
        PanelTemplates_DeselectTab(TT_StagedTalentsFrame_CurrentPlanButton);
    else
        PanelTemplates_SelectTab(TT_StagedTalentsFrame_CurrentPlanButton);
        PanelTemplates_DeselectTab(TT_StagedTalentsFrame_StagedPlanButton);
    end
    PanelTemplates_UpdateTabs(TT_StagedTalentsFrame)
    TT_StagedTalentsFrame_Update()
end

function TT_StagedTalentsFrame_SwitchTab()
    TT_CurrentTab = this:GetID()
    TT_StagedTalentsFrame_SetTab()
end

function TT_StagedTalentsFrame_Update()
    local numDisplay, plansToDisplay
    if TT_CurrentTab == 2 then
        if TubTalent_Vars.CurrentLevellingPlan ~= 0 then
            TT_StagedTalentsFrame_NoWorking:Hide()
            numDisplay = TT_CurrentLevellingPlan.levellingPlanMaxLevel - TT_MINLEVEL
            plansToDisplay = TT_CurrentLevellingPlan.plan
            if TT_CurrentLevellingPlan == nil then
                TT_Out("FAILED")
            end
        elseif TubTalent_Vars.CurrentLevellingPlan == 0 then
            numDisplay = 0 
            TT_StagedTalentsFrame_NoWorking:Show()
            TT_StagedTalentsFrame_NoWorking:SetText(TT_STAGEDTALENTS_NOPLANSELECTED)
            for i=1, NUM_LVLPLAN_TALENTSSHOWN do
                local lvlPlanFrame = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i]
                lvlPlanFrame:Hide()
            end
        end
    else
        if TT_SimMode and not TT_PresetLoaded then
            numDisplay = TT_StagedEstimatedLevel - TT_MINLEVEL
            plansToDisplay = TT_StagedLevellingPlan
            if numDisplay == 0 then -- how I can tell if it's empty
                TT_StagedTalentsFrame_NoWorking:Show()
                TT_StagedTalentsFrame_NoWorking:SetText(TT_STAGEDTALENTS_STARTPLAN)
            else
                TT_StagedTalentsFrame_NoWorking:Hide()
            end
        else
            numDisplay = 0 
            TT_StagedTalentsFrame_NoWorking:Show()
            if not TT_SimMode then
                TT_StagedTalentsFrame_NoWorking:SetText(TT_STAGEDTALENTSERR)
            elseif TT_SimMode and TT_PresetLoaded then
                TT_StagedTalentsFrame_NoWorking:SetText(TT_STAGEDTALENTSNOPRESETS)
            end
            for i=1, NUM_LVLPLAN_TALENTSSHOWN do
                local lvlPlanFrame = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i]
                lvlPlanFrame:Hide()
            end
        end
    end

	local scrollOffset = FauxScrollFrame_GetOffset(TT_StagedTalentsFrame_PlanScrollFrame);
	local index;
    local minIndex = TT_MINLEVEL
    GameTooltip:Hide()
	for i=1, NUM_LVLPLAN_TALENTSSHOWN do
        local lvlPlanFrame = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i]
		index = (scrollOffset) + i;
		if ( index <= numDisplay) then
            local lvlPlanLevel = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i.."Level"]
            local lvlPlanName = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i.."Name"]
            local lvlPlanRank = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i.."Rank"]
            local lvlPlanIcon = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i.."Icon"]
			lvlPlanFrame:Show()
            lvlPlanName:SetText(plansToDisplay[index+minIndex].name)
            lvlPlanRank:SetText("Rank: " .. plansToDisplay[index+minIndex].rank .. " Tab: " .. plansToDisplay[index+minIndex].tabName)
            lvlPlanLevel:SetText("Level: " .. index+minIndex)
            lvlPlanIcon:SetTexture(plansToDisplay[index+minIndex].icon)
		else
            lvlPlanFrame:Hide()
		end
        if MouseIsOver(lvlPlanFrame) and TT_StagedTalentsFrame:IsShown() then --Fixes jank when hiding the frame on show
            TT_LvlPlanTooltip(lvlPlanFrame:GetID())
        end
	end

	-- Scrollbar stuff
	FauxScrollFrame_Update(TT_StagedTalentsFrame_PlanScrollFrame, numDisplay , NUM_LVLPLAN_TALENTSSHOWN, 28);
end

--Shift click link for levelling plan
function TT_LvlPlan_OnClick()
    if IsShiftKeyDown() then
        local id = this:GetID()
        local scrollOffset = FauxScrollFrame_GetOffset(TT_StagedTalentsFrame_PlanScrollFrame);
        local index = id + scrollOffset + TT_MINLEVEL
        if TT_CurrentTab == 2 then
            plansToDisplay = TT_CurrentLevellingPlan.plan
        else
            plansToDisplay = TT_StagedLevellingPlan
        end
        local spellId = plansToDisplay[index].spellID
        local txt = DEFAULT_CHAT_FRAME.editBox:GetText()
        local link = format(TT_CHATLINKFORMAT,
        plansToDisplay[index].spellID, plansToDisplay[index].name, plansToDisplay[index].rank)
        txt = format("%s %s",txt, link)
        DEFAULT_CHAT_FRAME.editBox:SetText(txt)
    end
end

function TT_LvlPlanTooltip(cID)
    local scrollOffset = FauxScrollFrame_GetOffset(TT_StagedTalentsFrame_PlanScrollFrame);
    local id = this:GetID() -- Seems to get messy if I sent it object as paramater
    if this:GetID() == 0 then
        id = cID
        this = _G["TT_StagedTalentsFrame_LvlPlanSpec"..cID]
    end
    local index = id + scrollOffset + TT_MINLEVEL
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
    if TT_CurrentTab == 2 then
        if TT_CurrentLevellingPlan ~= nil then
            plansToDisplay = TT_CurrentLevellingPlan.plan
        end
    else
        plansToDisplay = TT_StagedLevellingPlan
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

function TT_CheckSpellIds(plan)
    for k,v in pairs(plan) do
        if v.spellID == 0 then
            v.spellID, _ = TT_GetTalentSpellID(v.tab, v.btnID, v.rank)
        else break -- break loop early if there's a non zero spellID
        end
    end
end

-- uses standard talent tooltip, plenty appropriate
function TT_LearnTalentPopup_TalentButtonOnEnter()
    local cp1, cp2 = UnitCharacterPoints("player");
    local estLevel = UnitLevel("player")
    --estlevel = estLevel - cp1    
    local btn = TT_CurrentLevellingPlan.plan[estLevel].btnID
    local tab = TT_CurrentLevellingPlan.plan[estLevel].tab
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
    GameTooltip:SetTalent(tab, btn)
end

function TT_LearnTalentPopup_TalentButtonLoad()
    local estLevel = UnitLevel("player")
    local texture = TT_CurrentLevellingPlan.plan[estLevel].icon
    local spellID = TT_CurrentLevellingPlan.plan[estLevel].spellID
    local rank = TT_CurrentLevellingPlan.plan[estLevel].rank
    local name = TT_CurrentLevellingPlan.plan[estLevel].name
    TT_LearnTalentPopup.spellID=spellID
    TT_Out(TT_LearnTalentPopup.spellID)
    TT_LearnTalentPopupTalentButtonIcon:SetTexture(texture)
    TT_LearnTalentPopupTalentButtonName:SetText(name)
    TT_LearnTalentPopupTalentButtonRank:SetText("Rank: " .. rank)
end

function TT_RegenPlansDropdown()
    TT_PlanOpts[2]["plans"] = {} -- clear it out first
    local count = 0 
    if TT_TalentPresets ~= nil then
        for k,v in pairs(TT_LevellingPlans) do
            local pDisplay = ""
            for i=1, 3 do
                name, _, _ = GetTalentTabInfo(i)
                pDisplay = format("%s%s in %s\n",pDisplay,v.points[i],name)
            end
            local t = {
                name=v.name,
                tooltipTitle=v.name,
                tooltip=format(TT_PLANDROPTOOLTIP,
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
                    TT_SelectPlan(id)
                    TT_RegenPlansDropdown()
                end,
                value="plansmenu:"..v.id
            }
            table.insert(TT_PlanOpts[2]["plans"],t)
            count = count + 1
        end
    end
    if count == 0 then
        table.insert(TT_PlanOpts[2]["plans"],TT_PLANDEFAULTDROP)
    end
end