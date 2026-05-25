-- TODO: Add other markers for previewed talent points vs already spent points?
-- Add caching to tooltips? 
-- First test on Wallcraft found a weird quirk, will need to change my learning functions a bit
-- the button indexes are out of order on Wallcraft, so I'll need to order them based on tier
-- myself most likely

--*LEVELING PLAN TODO*--
--- Add it to presets
-- New functionality in LeftClick [CHECK]
-- New functionality in RightClick [CHECK]
-- Add frame to scroll through the staged presets levelling plan...
-- *Need to detect presets with no levelling plan
-- Store currently staged levelling plan locally [check]
-- Store currently selected levelling plan to saved variables
--
--- Dropdown Changes
-- Overwrite preset button...
-- Add checked state for staged presets?
-- Add current levelling plan to TubTalent_Vars
--
--- How to select learning plan?
-- Presets dropdown?
-- Levelling plan frame?
--
--- AutoLearn
-- Popup frame
-- Could just do it
-- Check if its possible too
-- OnLogin check for unspent points, OnLevelup check for unspent points
-- Test talent resets...
--
--- Baller tier:
-- Export preset
-- Share preset in party/guild?
-- Means I'll need to consider class for presets most likely...

--Functions to overwrite TalentFrame functionality
local _G = getfenv(0)
local libIcon = LibStub("LibDBIcon-1.0");
local libData = LibStub("LibDataBroker-1.1");
local TT_TalentPresets_Dewdrop = AceLibrary("Dewdrop-2.0");
local TT_LevellingPlans_DewDrop = AceLibrary("Dewdrop-2.0");
TT_MAX_TALENTS = 3
TT_MAX_TALENTPOINTS = 51
TT_SimMode = false
TT_AUTOLEARN = {
    Never=0,
    Prompt=1,
    FullAuto=2,
}
TT_TalentPointsSpent = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
} 
TT_StagedTalents = { --key: Tab
    [1] = {}, -- key: btnID val: rank
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {}
}
TT_StagedLevellingPlan = {
    --Example:
    --[10] = {tab=1, btnID=1, rank=1, icon="", spellID=1, name=""}
}
TT_MINLEVEL = 9
TT_StagedLevellingPlanMinLevel = TT_MINLEVEL
TT_StagedEstimatedLevel = TT_MINLEVEL

function TT_OutPutLevellingPlan()
    for k, v in TT_StagedLevellingPlan do
        TT_Out(format("level: %s tab: %s btn: %s rank: %s spellID: %s name: %s",
            k, v.tab, v.btnID, v.rank, v.spellID, v.name))
    end
end

local TT_DialogOpts = {
    --levels...
    [1] = {
        {
            name="Presets",
            tooltip="",
            notCheckable=true,
            value="presets"
        },
        {
            name="Save Build",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
            disabled = function() return TT_SavePresetButton_OnUpdate() end,
            editBoxText=function() return "" end,
            editBoxFunc=function(s) TT_NewPreset(s) end,
            value=""
        },
        {
            name="Import Preset",
            tooltip="Opens a window to paste in a plan",
            notCheckable=true,
            func=function()  TT_Out("TODO") end,
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
            func=function(arg1)  TT_Out("TODO") end,
            value=""
            },
            {
            name="Delete Preset",
            tooltip="Deletes the selected preset",
            notCheckable=true,
            func=function(arg1)  TT_TalentPresetDelete(arg1) end,
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

SlashCmdList['TUBTALENTS'] = TubTalents_TextCommands
SLASH_TUBTALENTS1 = "/tubtalents"

function TubTalents_TextCommands(arg)
    if arg == nil or arg == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00TubTalents commands:|r\n/tubtalents minimap \n/tubtalents toggle")
    elseif arg=="minimap" then
        if TubTalents_Icon.hide then
            TubTalents_ShowMinimap()
        else
            TubTalents_HideMinimap()
        end
    elseif arg=="toggle" then
        TalentFrame_LoadUI();
        TalentFrame_Toggle();
    end

end

function TubTalents_Init()
    if event=="PLAYER_LOGIN" then
        if TubTalent_Vars == nil then
            TubTalent_Vars = {
                Version = 1,
                MaxTalentPoints = TT_MAX_TALENTPOINTS,
                TalentPresets = {},
                LevellingPlans = {},
                CurrentLevellingPlan = 0,
                LevellingPlanIDMax = 0,
                TalentPresetIDMax = 0
            }
        elseif TubTalent_Vars.AutoLearnPlans == nil then
            TubTalent_Vars.AutoLearnPlans = 0
        elseif TubTalent_Vars.MaxTalentPoints == nil then
            TubTalent_Vars.MaxTalentPoints = TT_MAX_TALENTPOINTS
        end
        if TubTalent_Vars.CurrentLevellingPlan ~= 0 then
            _, TT_CurrentLevellingPlan = TT_FindPlan(TubTalent_Vars.CurrentLevellingPlan)
            if TT_CurrentLevellingPlan == nil then TT_Out(TubTalent_Vars.CurrentLevellingPlan) end
        end
        TubTalents_MinimapIconRegister()
        TT_StagedTalentsFramePlans_DewdropRegister()
        --Detecting client mods, and adjusting functionality...
        if RQ_GetVersion then
            --TT_Out("Reliquary detected")
        else
            TT_Out("Reliquary not found, falling back on old tooltips and disabling shift click links.")
            TT_TalentTooltip = TT_TalentTooltipNoMods
            TT_TalentFrameTalent_OnShiftClick = TT_TalentFrameTalent_OnShiftClickNoMods
        end

        if SUPERWOW_STRING then
            --TT_Out("SuperWoW detected")
        else
            TT_Out("SuperWoW not found, falling back on old tooltips and disabling shift click links.")
            TT_TalentTooltip = TT_TalentTooltipNoMods
            TT_TalentFrameTalent_OnShiftClick = TT_TalentFrameTalent_OnShiftClickNoMods
        end
    elseif event == "ADDON_LOADED" then
        if arg1=="Blizzard_TalentUI" then
            --If you wait for the addon to load hooking is fine, won't hook properly otherwise
            --Buttons
            local myButton = CreateFrame("Button", "TalentFrameLearnButton", TalentFrame, "UIPanelButtonTemplate")
            myButton:SetHeight(15)
            myButton:SetWidth(60)
            myButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 55, -421)
            myButton:SetText("Learn")
            myButton:SetScript("OnClick",TT_LearnButton_OnClick)
            myButton:SetScript("OnEnter",TT_TalentLearnButton_OnEnter)
            myButton:SetScript("OnLeave",function() GameTooltip:Hide() end)

            local myButton = CreateFrame("Button", "TalentFrameResetButton", TalentFrame, "UIPanelButtonTemplate")
            myButton:SetHeight(15)
            myButton:SetWidth(60)
            myButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 115, -421)
            myButton:SetText("Reset")
            myButton:SetScript("OnClick",TT_ResetButton_OnClick)

            local myButton = CreateFrame("Button", "TalentFramePresetsButton", TalentFrame, "UIPanelButtonTemplate")
            myButton:SetHeight(15)
            myButton:SetWidth(60)
            myButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 305, -42)
            myButton:SetText("Presets")

            --Checkboxes
            local myCheckButton = CreateFrame("CheckButton", "TalentFrameSimMode", TalentFrame, "UICheckButtonTemplate");
            myCheckButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 80, -42); -- Position it
            myCheckButton.tooltip = "Click to toggle this setting.";
            myCheckButton:SetHeight(15)
            myCheckButton:SetWidth(15)
            _G["TalentFrameSimModeText"]:SetText("Enable Sim Mode")
            myCheckButton:SetChecked(false); -- or false
            myCheckButton:SetScript("OnClick",TalentFrameSimMode_OnClick);

            --EditBoxes
            local myEditBox = CreateFrame("EditBox", "TalentFrameSimModePointsBox", TalentFrame,"InputBoxTemplate")
            myEditBox:SetHeight(80)
            myEditBox:SetWidth(20)
            myEditBox:SetPoint("CENTER", TalentFrame, "TOPLEFT", 265, -42); -- Position it
            myEditBox:SetFontObject(GameFontNormalSmall)
            myEditBox:SetAutoFocus(false)
            myEditBox:SetNumeric()
            myEditBox:SetMultiLine(false)
            myEditBox:SetMaxLetters(3)
            myEditBox:SetNumber(TubTalent_Vars.MaxTalentPoints)
            myEditBox:Hide()
            myEditBox:SetScript("OnEnterPressed", function(self)
                local t = this:GetNumber()
                if t~=0 then
                    TubTalent_Vars.MaxTalentPoints = t
                else 
                    myEditBox:SetNumber(TubTalent_Vars.MaxTalentPoints)
                end
                TT_TalentFrame_UpdateTalentPoints()
                this:ClearFocus()
            end)
            myEditBox:SetScript("OnEscapePressed", function(self)
                this:ClearFocus()
            end)
            myEditBox:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
			    GameTooltip:SetText("Enter to save");
			    GameTooltip:Show();
            end)
            myEditBox:SetScript("OnLeave", function(self)
                GameTooltip:Hide();
            end)
            
            --Text labels
            prompt = TalentFrame:CreateFontString("TalentFrameSimModePointsBoxPrompt", "OVERLAY", "GameFontNormalSmall")
            prompt:SetPoint("CENTER", TalentFrame, "TOPLEFT", 220, -42); -- Position it
            prompt:SetText("Max points:")
            prompt:Hide()

            prompt = TalentFrame:CreateFontString("TalentFrameEstimatedLevel", "OVERLAY", "GameFontNormalSmall")
            prompt:SetPoint("CENTER", TalentFrame, "TOP", 0, -68); -- Position it
            prompt:SetText("Level: 9")
            --Update buttons to initial state...

            TT_StagedTalentsFrame:SetParent(TalentFrame)
            TT_StagedTalentsFrame:ClearAllPoints()
            TT_StagedTalentsFrame:SetPoint("TOPLEFT", TalentFrame, "TOPRIGHT", -25, -20); -- Position it
            TT_StagedTalentsFrame:Show()
            TT_StagedTalentsFrame_StagedPlanButton:SetFrameStrata("HIGH")
            TT_StagedTalentsFrame_CurrentPlanButton:SetFrameStrata("HIGH")
            TT_StagedTalentsFrame_LvlPlanSpec1:SetFrameStrata("HIGH")
            TT_StagedTalentsFrame_LvlPlanSpec2:SetFrameStrata("HIGH")
            TT_StagedTalentsFrame_LvlPlanSpec3:SetFrameStrata("HIGH")
            TT_StagedTalentsFrame_LvlPlanSpec4:SetFrameStrata("HIGH")
            TT_StagedTalentsFrame_LvlPlanSpec5:SetFrameStrata("HIGH")
            TT_StagedTalentsFrame_PlanScrollFrame:SetFrameStrata("HIGH")
            TT_StagedTalentsFrame_PlansButton:SetFrameStrata("HIGH")
            --TT_StagedTalentsFrame_LvlPlanSpec6:SetFrameStrata("HIGH")
            PanelTemplates_UpdateTabs(TT_StagedTalentsFrame)
            --PanelTemplates_SetTab(TT_StagedTalentsFrame, 1);
            TT_TalentFrameButtons_OnUpdate()
            TT_StagedTalentsFrame_Update()

            --Function Overloads
            TalentFrameTalent_OnClick = TT_TalentFrameTalent_OnClick
            TalentFrame_Update = TT_TalentFrame_Update

            TT_OldGetTalentInfo = GetTalentInfo
            GetTalentInfo = TT_GetTalentInfo

            TT_OldGetTalentPrereqs = GetTalentPrereqs
            GetTalentPrereqs = TT_GetTalentPrereqs

            --TT_OldTalentFrame_UpdateTalentPoints = TalentFrame_UpdateTalentPoints
            TalentFrame_UpdateTalentPoints = TT_TalentFrame_UpdateTalentPoints
            
            TT_OldGetTalentTabInfo = GetTalentTabInfo
            GetTalentTabInfo = TT_GetTalentTabInfo
            TT_TalentFrame_Init()
            TT_TalentFramePreferences_DewdropRegister()
        end
    end

end

-- Need to move some function setups over to here...
function TT_TalentFrame_Init()
    TT_TalentPresets = TubTalent_Vars.TalentPresets
    TT_LevellingPlans = TubTalent_Vars.LevellingPlans
    --TT_TalentPresetIDMax = TubTalent_Vars.TalentPresetIDMax
    TT_RegenPresetDropdown()
    TT_RegenPlansDropdown()
    _G["TalentFramePresetsButton"]:SetScript("OnClick",function() 
        if TT_TalentPresets_Dewdrop:IsOpen() then
            TT_TalentPresets_Dewdrop:Close();
        else
            TT_TalentPresets_Dewdrop:Open(this);
        end
    end)
end

-- Minimap Setup
function TubTalents_HideMinimap()
	TubTalents_Icon.hide = true
	libIcon:Hide("TubTalents icon")
end

function TubTalents_ShowMinimap()
	TubTalents_Icon.hide = false
	if (libIcon:GetMinimapButton("TubTalents icon")) then
		libIcon:Show("TubTalents icon")
	else
		TubTalents_MinimapIconRegister()
	end
end

function TubTalents_MinimapIconRegister()
	if TubTalents_Icon == nil then
		TubTalents_Icon = {
			hide = false
		}
	end
	if not TubTalents_Icon.hide then
		local iconData = libData:NewDataObject("TubTalents icon data", {
			OnClick = function()
                TalentFrame_LoadUI();
                TalentFrame_Toggle();
			end,
			OnTooltipShow = function(tooltip)
				tooltip:SetText("TubTalents");
			end,
			icon = "Interface\\Icons\\Ability_Rogue_Disguise"
		});

		libIcon:Register("TubTalents icon", iconData, TubTalents_Icon);
	end
end

--Preset functions
function TT_FindTalentPreset(presetID)
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
            local _, _, _, _, learnedRank, _, _, _ = TT_OldGetTalentInfo(i, k);
            TT_StagedTalents[i][k] = v - learnedRank
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
        end
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
        name = name,
        id = TubTalent_Vars.TalentPresetIDMax,
        talents = t,
        points = tp,
    }
    table.insert(TT_TalentPresets, newPreset)
    TT_Out("Adding new profile")
    TT_RegenPresetDropdown()
end

--Dropdown Setup/Utilities
function TT_TalentFramePreferences_DewdropRegister()
    TT_TalentPresets_Dewdrop:Register(TalentFramePresetsButton, --Bound Frame
        'point', function(parent) --Point
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value) TT_TalentPresets_DewdropGen(level, value, TT_DialogOpts) end,
        'dontHook', true
    )
end

function TT_TalentPresets_DewdropGen(level, value, opts)
    if value ~= nil then
        if string.find(value,":") then --accepts values after colons as arguments. Used to pass arguments a level up
            local parsed_args = {}
            local a = string.gfind(value, ':([^:]+)')
            for i in a do --need to translate it to a table, a is a function
                table.insert(parsed_args,i)
            end 
            -- sub out the arguments for the real value
            value = string.gsub(value, ":.*", "")
            TT_TalentPresets_DewdropLevelGen(opts[level][value],parsed_args)
        else
            TT_TalentPresets_DewdropLevelGen(opts[level][value])
        end
    else
        TT_TalentPresets_DewdropLevelGen(opts[level])
    end
end

function TT_TalentPresets_DewdropLevelGen(opts,args)
    -- Process passed arguments...
    local args1, args2, args3, args4 = nil
    if args ~= nil then
        args1, args2, args3, args4 = args[1], args[2], args[3], args[4]
    end
    if opts == nil then
        return
    end
    for i,j in ipairs(opts) do
        if j.value ~= "" then -- next level
            if j.disabled and j.disabled() then
                TT_TalentPresets_Dewdrop:AddLine(
                    'text', j.name,
                    'tooltipTitle', j.tooltipTitle or nil,
                    'tooltipText', j.tooltip or nil,  
                    'textR', 0.4,
                    'textG', 0.4,
                    'textB', 0.4,
                    'disabled', j.disabled(),
                    --'value', j.value,
                    'hasArrow', false,
                    'notCheckable', true
                )
            elseif j.notCheckable then
                TT_TalentPresets_Dewdrop:AddLine(
                    'text', j.name,
                    'tooltipTitle', j.tooltipTitle or nil,
                    'tooltipText', j.tooltip or nil,  
                    'textR', 1,
                    'textG', 0.82,
                    'textB', 0,
                    'value', j.value,
                    'hasArrow', true,
                    'notCheckable', true
                )
            else
                TT_TalentPresets_Dewdrop:AddLine(
                    'text', j.name,
                    'tooltipTitle', j.tooltipTitle or nil,
                    'tooltipText', j.tooltip or nil,  
                    'textR', 1,
                    'textG', 0.82,
                    'textB', 0,
                    'func', j.func,
                    'value', j.value,
                    'hasArrow', true,
                    --'id',j.id or nil,
                    'checked', j.checked(j.id) or nil,
                    'notCheckable', false
                )
            end
        elseif j.disabled and j.disabled() then
            if j.checked ~= nil then
                TT_TalentPresets_Dewdrop:AddLine(
                    'text', j.name,
                    'tooltipTitle', j.tooltipTitle or nil,
                    'tooltipText', j.tooltip or nil,  
                    'textR', 0.4,
                    'textG', 0.4,
                    'textB', 0.4,
                    'func', j.func,
                    'value', j.value,
                    'hasArrow', false,
                    'disabled', j.disabled(),
                    --'id',j.id or nil,
                    'checked', j.checked(j.id) or nil,
                    'notCheckable', j.notCheckable
                )     
            else
                TT_TalentPresets_Dewdrop:AddLine(
                    'text', j.name,
                    'tooltipTitle', j.tooltipTitle or nil,
                    'tooltipText', j.tooltip or nil,  
                    'textR', 0.4,
                    'textG', 0.4,
                    'textB', 0.4,
                    'func', j.func,
                    'value', j.value,
                    'hasArrow', false,
                    'disabled', j.disabled(),
                    'notCheckable', j.notCheckable
                )    
            end
        elseif j.hasSlider then
            TT_TalentPresets_Dewdrop:AddLine(
                'text', j.name,
                'tooltipTitle', j.tooltipTitle or nil,
                'tooltipText', j.tooltip or nil,  
                'textR', 1,
                'textG', 0.82,
                'textB', 0,
                'value', j.value,
                'hasArrow', true,
                'notCheckable', j.notCheckable,
                'hasSlider', j.hasSlider,
                'sliderMin', j.sliderMin,
                'sliderMax', j.sliderMax,
                'sliderStep', j.sliderStep,
                'sliderValue', j.sliderValue(),
                'sliderFunc', j.sliderFunc
            )
        elseif j.hasEditBox then
            TT_TalentPresets_Dewdrop:AddLine(
                'text', j.name,
                'tooltipTitle', j.tooltipTitle or nil,
                'tooltipText', j.tooltip or nil,  
                'textR', 1,
                'textG', 0.82,
                'textB', 0,
                'value', j.value,
                'hasArrow', true,
                'notCheckable', j.notCheckable,
                'hasEditBox', j.hasEditBox,
                'editBoxText', j.editBoxText(),
                'editBoxFunc', j.editBoxFunc
            )
        elseif j.notCheckable and j.func == nil then -- titles
            TT_TalentPresets_Dewdrop:AddLine(
                'text', j.name,
                'tooltipTitle', j.tooltipTitle or nil,
                'tooltipText', j.tooltip or nil,  
                'textR', 0.4,
                'textG', 0.4,
                'textB', 0.4,
                'value', j.value,
                'hasArrow', false,
                'notCheckable', j.notCheckable
            )
        elseif j.notCheckable and j.func ~= nil then -- pure functions
            TT_TalentPresets_Dewdrop:AddLine(
                'text', j.name,
                'tooltipTitle', j.tooltipTitle or nil,
                'tooltipText', j.tooltip or nil,   
                'textR', 1,
                'textG', 0.82,
                'textB', 0,
                'func', j.func,
                'arg1', j.arg1 or args1 or nil,
                'arg2', j.arg2 or args2 or nil,
                'arg3', j.arg3 or args3 or nil,
                'arg4', j.arg4 or args4 or nil,
                'value', j.value,
                'hasArrow', false,
                'notCheckable', j.notCheckable
            )                    
        elseif j.isRadio then
            TT_TalentPresets_Dewdrop:AddLine(
                'text', j.name,
                'tooltipTitle', j.tooltipTitle or nil,
                'tooltipText', j.tooltip or nil,  
                'textR', 1,
                'textG', 0.82,
                'textB', 0,
                'isRadio', j.isRadio,
                'func', j.func,
                'value', j.value,
                'hasArrow', false,
                'checked', j.checked(),
                'notCheckable', j.notCheckable
            )
        end
    end

    --Close button
    TT_TalentPresets_Dewdrop:AddLine(
        'text', "Close Menu",
        'textR', 0,
        'textG', 1,
        'textB', 1,
        'func', function() TT_TalentPresets_Dewdrop:Close() end,
        'notCheckable', true
    )
end

--Update functions (Mostly original code)
function TT_TalentFrame_Update()
	-- Setup Tabs
	local tab, name, iconTexture, pointsSpent, button;
	local numTabs = GetNumTalentTabs();
	for i=1, MAX_TALENT_TABS do
		tab = _G["TalentFrameTab"..i];
		if ( i <= numTabs ) then
			name, iconTexture, pointsSpent = GetTalentTabInfo(i);
			if ( i == PanelTemplates_GetSelectedTab(TalentFrame) ) then
				-- If tab is the selected tab set the points spent info
                --pointsSpent = pointsSpent + TT_TalentPointsSpent[i];
				TalentFrameSpentPoints:SetText(format(MASTERY_POINTS_SPENT, name).." "..HIGHLIGHT_FONT_COLOR_CODE..pointsSpent..FONT_COLOR_CODE_CLOSE);
				TalentFrame.pointsSpent = pointsSpent;
			end
			tab:SetText(name);
			PanelTemplates_TabResize(10, tab);
			tab:Show();
		else
			tab:Hide();
		end
	end
	PanelTemplates_SetNumTabs(TalentFrame, numTabs);
	PanelTemplates_UpdateTabs(TalentFrame);

	-- Setup Frame
	SetPortraitTexture(TalentFramePortrait, "player");
	TalentFrame_UpdateTalentPoints(); --ADDED FUNCTION
	local talentTabName = GetTalentTabInfo(PanelTemplates_GetSelectedTab(TalentFrame));
	local base;
	local name, texture, points, fileName = GetTalentTabInfo(PanelTemplates_GetSelectedTab(TalentFrame)); -- Might need to override to keep track over simulated points spent
	if ( talentTabName ) then
		base = "Interface\\TalentFrame\\"..fileName.."-";
	else
		-- temporary default for classes without talents poor guys
		base = "Interface\\TalentFrame\\MageFire-";
	end
	
	TalentFrameBackgroundTopLeft:SetTexture(base.."TopLeft");
	TalentFrameBackgroundTopRight:SetTexture(base.."TopRight");
	TalentFrameBackgroundBottomLeft:SetTexture(base.."BottomLeft");
	TalentFrameBackgroundBottomRight:SetTexture(base.."BottomRight");
	
	local numTalents = GetNumTalents(PanelTemplates_GetSelectedTab(TalentFrame));
	-- Just a reminder error if there are more talents than available buttons
	if ( numTalents > MAX_NUM_TALENTS ) then
		message("Too many talents in talent frame!");
	end

	TalentFrame_ResetBranches();
	local tier, column, rank, maxRank, isExceptional, isLearnable;
	local forceDesaturated, tierUnlocked;
	for i=1, MAX_NUM_TALENTS do
		button = _G["TalentFrameTalent"..i];
		if ( i <= numTalents ) then
			-- Set the button info
			name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), i); -- Might need to override to do MeetsPrereq, and rank override
			_G["TalentFrameTalent"..i.."Rank"]:SetText(rank);
			SetTalentButtonLocation(button, tier, column);
			TALENT_BRANCH_ARRAY[tier][column].id = button:GetID();
			
			-- If player has no talent points then show only talents with points in them
			if ( (TalentFrame.talentPoints <= 0 and rank == 0)  ) then
				forceDesaturated = 1;
			else
				forceDesaturated = nil;
			end

			-- If the player has spent at least 5 talent points in the previous tier
			if ( ( (tier - 1) * 5 <= TalentFrame.pointsSpent ) ) then
				tierUnlocked = 1;
			else
				tierUnlocked = nil;
			end
			SetItemButtonTexture(button, iconTexture);
			
			-- Talent must meet prereqs or the player must have no points to spend
			if ( TalentFrame_SetPrereqs(tier, column, forceDesaturated, tierUnlocked, GetTalentPrereqs(PanelTemplates_GetSelectedTab(TalentFrame), i)) and meetsPrereq ) then
				SetItemButtonDesaturated(button, nil);
				
				if ( rank < maxRank ) then
					-- Rank is green if not maxed out
                    _G["TalentFrameTalent"..i]:SetScript("OnClick", nil)
                    _G["TalentFrameTalent"..i]:SetScript("OnMouseDown", TT_TalentFrameTalent_OnClick)
                    _G["TalentFrameTalent"..i]:SetScript("OnEnter",TT_TalentTooltip)
                    _G["TalentFrameTalent"..i]:SetScript("OnLeave",TT_TalentTooltip_OnLeave)
					_G["TalentFrameTalent"..i.."Slot"]:SetVertexColor(0.1, 1.0, 0.1);
					_G["TalentFrameTalent"..i.."Rank"]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
                    _G["TalentFrameTalent"..i]:SetScript("OnClick", nil)
                    _G["TalentFrameTalent"..i]:SetScript("OnMouseDown", TT_TalentFrameTalent_OnClick)                    
                    _G["TalentFrameTalent"..i]:SetScript("OnEnter",TT_TalentTooltip)
                    _G["TalentFrameTalent"..i]:SetScript("OnLeave",TT_TalentTooltip_OnLeave)
					_G["TalentFrameTalent"..i.."Slot"]:SetVertexColor(1.0, 0.82, 0);
					_G["TalentFrameTalent"..i.."Rank"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
				_G["TalentFrameTalent"..i.."RankBorder"]:Show();
				_G["TalentFrameTalent"..i.."Rank"]:Show();
			else
                _G["TalentFrameTalent"..i]:SetScript("OnClick", nil)
                _G["TalentFrameTalent"..i]:SetScript("OnMouseDown", TT_TalentFrameTalent_OnClick)                
                _G["TalentFrameTalent"..i]:SetScript("OnEnter",TT_TalentTooltip)
                _G["TalentFrameTalent"..i]:SetScript("OnLeave",TT_TalentTooltip_OnLeave)
				SetItemButtonDesaturated(button, 1, 0.65, 0.65, 0.65);
				_G["TalentFrameTalent"..i.."Slot"]:SetVertexColor(0.5, 0.5, 0.5);
				if ( rank == 0 ) then
					_G["TalentFrameTalent"..i.."RankBorder"]:Hide();
					_G["TalentFrameTalent"..i.."Rank"]:Hide();
				else
					_G["TalentFrameTalent"..i.."RankBorder"]:SetVertexColor(0.5, 0.5, 0.5);
					_G["TalentFrameTalent"..i.."Rank"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				end
			end
			
			button:Show();
		else	
			button:Hide();
		end
	end
	
	-- Draw the prereq branches
	local node;
	local textureIndex = 1;
	local xOffset, yOffset;
	local texCoords;
	-- Variable that decides whether or not to ignore drawing pieces
	local ignoreUp;
	local tempNode;
	TalentFrame_ResetBranchTextureCount();
	TalentFrame_ResetArrowTextureCount();
	for i=1, MAX_NUM_TALENT_TIERS do
		for j=1, NUM_TALENT_COLUMNS do
			node = TALENT_BRANCH_ARRAY[i][j];
			
			-- Setup offsets
			xOffset = ((j - 1) * 63) + INITIAL_TALENT_OFFSET_X + 2;
			yOffset = -((i - 1) * 63) - INITIAL_TALENT_OFFSET_Y - 2;
		
			if ( node.id ) then
				-- Has talent
				if ( node.up ~= 0 ) then
					if ( not ignoreUp ) then
						TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset, yOffset + TALENT_BUTTON_SIZE);
					else
						ignoreUp = nil;
					end
				end
				if ( node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - TALENT_BUTTON_SIZE + 1);
				end
				if ( node.left ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset - TALENT_BUTTON_SIZE, yOffset);
				end
				if ( node.right ~= 0 ) then
					-- See if any connecting branches are gray and if so color them gray
					tempNode = TALENT_BRANCH_ARRAY[i][j+1];	
					if ( tempNode.left ~= 0 and tempNode.down < 0 ) then
						TalentFrame_SetBranchTexture(i, j-1, TALENT_BRANCH_TEXTURECOORDS["right"][tempNode.down], xOffset + TALENT_BUTTON_SIZE, yOffset);
					else
						TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE + 1, yOffset);
					end
					
				end
				-- Draw arrows
				if ( node.rightArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["right"][node.rightArrow], xOffset + TALENT_BUTTON_SIZE/2 + 5, yOffset);
				end
				if ( node.leftArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["left"][node.leftArrow], xOffset - TALENT_BUTTON_SIZE/2 - 5, yOffset);
				end
				if ( node.topArrow ~= 0 ) then
					TalentFrame_SetArrowTexture(i, j, TALENT_ARROW_TEXTURECOORDS["top"][node.topArrow], xOffset, yOffset + TALENT_BUTTON_SIZE/2 + 5);
				end
			else
				-- Doesn't have a talent
				if ( node.up ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tup"][node.up], xOffset , yOffset);
				elseif ( node.down ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["tdown"][node.down], xOffset , yOffset);
				elseif ( node.left ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topright"][node.left], xOffset , yOffset);
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
				elseif ( node.left ~= 0 and node.up ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomright"][node.left], xOffset , yOffset);
				elseif ( node.left ~= 0 and node.right ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE, yOffset);
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset + 1, yOffset);
				elseif ( node.right ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["topleft"][node.right], xOffset , yOffset);
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
				elseif ( node.right ~= 0 and node.up ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["bottomleft"][node.right], xOffset , yOffset);
				elseif ( node.up ~= 0 and node.down ~= 0 ) then
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset , yOffset);
					TalentFrame_SetBranchTexture(i, j, TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
					ignoreUp = 1;
				end
			end
		end
		TalentFrameScrollFrame:UpdateScrollChildRect();
	end
	-- Hide any unused branch textures
	for i=TalentFrame_GetBranchTextureCount(), MAX_NUM_BRANCH_TEXTURES do
		_G["TalentFrameBranch"..i]:Hide();
	end
	-- Hide and unused arrowl textures
	for i=TalentFrame_GetArrowTextureCount(), MAX_NUM_ARROW_TEXTURES do
		_G["TalentFrameArrow"..i]:Hide();
	end
end

--Mostly overloaded for sim mode, and counting points for staged talents
function TT_TalentFrame_UpdateTalentPoints()
    local total = 0
    for i=1, TT_MAX_TALENTS do
        total = total + TT_TalentPointsSpent[i]
    end
    if total == 0 then
        TT_PresetLoaded = false
    end
    if TT_SimMode then
        TalentFrame.talentPoints = TubTalent_Vars.MaxTalentPoints - total
        TalentFrameTalentPointsText:SetText(TalentFrame.talentPoints);
    else
        local cp1, cp2 = UnitCharacterPoints("player");
        cp1 = cp1 - total
        TalentFrameTalentPointsText:SetText(cp1);
        TalentFrame.talentPoints = cp1;
    end
    TT_StagedTalentsFrame_Update()
    TT_UpdateEstimatedLevel()
end

function TT_UpdateEstimatedLevel()
    local total = 0
    for i=1, TT_MAX_TALENTS do
        local _, _, tabPoints = GetTalentTabInfo(i)
        total = total + tabPoints
    end
    TT_StagedEstimatedLevel = TT_MINLEVEL + total
    TalentFrameEstimatedLevel:SetText(format("Level: %s", TT_StagedEstimatedLevel))
end


--Mostly overloaded for sim mode
function TT_GetTalentTabInfo(tab)
    local name, iconTexture, pointsSpent, fileName = TT_OldGetTalentTabInfo(tab)
    --if TT_SimMode then
    --    pointsSpent = 0
    --end
    if TT_SimMode then
        pointsSpent=TT_TalentPointsSpent[tab];
    else
        pointsSpent = pointsSpent + TT_TalentPointsSpent[tab];
    end
    return name, iconTexture, pointsSpent, fileName
end

--Overloaded to return staged talents and sim mode
function TT_GetTalentInfo(tab, btn)
    local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = TT_OldGetTalentInfo(tab, btn);
    if TT_SimMode then
        if TT_StagedTalents[tab][btn] == nil then
            TT_StagedTalents[tab][btn] = 0
        end
        return name, iconTexture, tier, column, TT_StagedTalents[tab][btn], maxRank, isExceptional, meetsPrereq
    else
        if TT_StagedTalents[tab][btn]~=nil then
            rank = rank+TT_StagedTalents[tab][btn] 
        end
        return name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq
    end
end

--Utility function that returns a spellID for a talent given their tab/button id, and the next rank if available
-- TODO: Optimize, consider caching tab IDs for the played class for that session after first lookup
function TT_GetTalentSpellID(tab,btn)
    local tabName, texture, points, fileName = GetTalentTabInfo(tab);
    local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab,btnID);
    -- Named look ups are iffy... We could just try feeding a spellID into a tooltip and seeing what that does first, tbh.
    -- STEP: Get Spell ID for current rank
    -- Get which TalentTabID it is...
    local rows, err = RQ_GetRowCount("TalentTab")
    local currentTabID, spellId1, spellId2
    for i=1, rows do 
        local row, err = RQ_GetRowByIndex("TalentTab", i)
        -- id, name, Name_Mask, SpellIconID, RaceMask, ClassMask, orderIndex, BackgroundFile
        bgFile = row[8]
        if bgFile == fileName then
            currentTabID = row[1]
            break
        end
    end
    -- Get first SpellID
    local rows, err = RQ_GetRowCount("Talent")
    if err ~= nil then TT_Out(err) end
    for i=1, rows do 
        local row, err = RQ_GetRowByIndex("Talent", i)
        -- tID, tabid, tierid, columnindex, spellrank1, spellrank2, spellrank3, spellrank4, spellrank5
        -- spellrank6, spellrank7, spellrank8, spellrank9, prereqtalent1, prereqtalent2, prereqtalent3
        -- flags, requiredSpellID
        local tID, tabID, tierID, columnID = row[1], row[2], row[3], row[4]
        -- the column and tier IDs start at 0 in the DBC but 1 in lua
        columnID = columnID + 1
        tierID = tierID + 1
        --columnID = columnID - 1
        if tabID == currentTabID then
            if tierID==tier then 
                if column==columnID then --rank1 spell at index 5
                    --which rank to get?
                    if rank==0 then o=1 else o=rank end
                    spellId1 = row[4+o]
                    if rank ~= 0 and rank ~= maxRank then
                        spellId2 = row[4+o+1]
                    end
                end
            end
        end
    end
    return spellId1, spellId2
end

--Utility function that returns if a talent at a tab/button ID is a Pre-req
--Mostly used for right clicking buttons to remove points
function TT_IsTalentAPreReq(tab, btn)
    local numTalents = GetNumTalents(tab);
    local isPreReq, preReqColumn, preReqRow, preReqRank
    local found = 0 
    for i=1, MAX_NUM_TALENTS do
        local b = _G["TalentFrameTalent"..i]:GetID()
        local tier, column, isLearnable = GetTalentPrereqs(tab, b);
        if tier ~= nil  then -- only focus on whatever has pre-reqs
            local btnID = TALENT_BRANCH_ARRAY[tier][column].id
            if btn == btnID then
                isPreReq = true
                _, _, preReqRow, preReqColumn, preReqRank, 
                _, _, _ = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), b); 
                found = 1
                break
            end
        end
    end
    if found == 0 then
        isPreReq = false
    end
    return isPreReq, preReqColumn, preReqRow, preReqRank
end

--Utility function that finds the max tier in the current tab
function TT_GetMaxTier()
    for i=MAX_NUM_TALENT_TIERS, 1,-1 do
        for m=1, NUM_TALENT_COLUMNS do
            local b = TALENT_BRANCH_ARRAY[i][m].id
            if b ~=nil then
                local _, _, _, _, rank, 
                _, _, _ = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), b); 
                if rank ~= nil and rank ~= 0 then
                    return i
                end
            end
        end
    end
end

--Checks if the calling button can be left clicked to spend points given the talent status
function TT_TalentFrameTalentIsLeftClickable()
    local tab = PanelTemplates_GetSelectedTab(TalentFrame)
    local btn = this:GetID()
    local _, _, tier, column, rank, maxRank, 
    _, meetsPrereq = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), btn);
    -- If player has no talent points then no
    if ( (TalentFrame.talentPoints == 0)  ) then
        return false
    else
        forceDesaturated = nil;
    end

    -- If the player has spent at least 5 talent points in the previous tier
    if ( ( (tier - 1) * 5 <= TalentFrame.pointsSpent ) ) then
        tierUnlocked = 1;
    else
        return false
    end

    -- pre-req checks
    if ( TalentFrame_SetPrereqs(tier, column, forceDesaturated, tierUnlocked, GetTalentPrereqs(PanelTemplates_GetSelectedTab(TalentFrame), btn)) and meetsPrereq ) then
        if ( rank ~= maxRank ) then
            return true
        end
    end
    return false
end

--Checks if the calling button can be right clicked to remove points given the talent status
--Needs to be top level, or the tier must have at least 5 talent points after removal
--pre-req check as well
function TT_TalentFrameTalentIsRightClickable()
    local rightClickable = false
    local tab = PanelTemplates_GetSelectedTab(TalentFrame)
    local btn = this:GetID()
    --local p_check, t_check, rank_check, req_check
    if TT_StagedTalents[tab][btn] == nil then 
       return rightClickable
    end
    local _, _, tier, _, rank, _, 
    _, _ = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), btn);

    -- Needs to have points in it
    if rank ~= 0 then
        -- tier check maxtier, or 5 points in tier
        local maxTier = TT_GetMaxTier()
        local tierCheck = false
        -- if its the max tier, can likely remove points
        if maxTier == tier then
            tierCheck=true
        else
            if ( ( (maxTier - 1) * 5 < TalentFrame.pointsSpent-1 ) ) then
				tierCheck=true
			end
        end
        
        if tierCheck then 
            -- Can't be a pre-req of something underneath of it with points in it.
            -- Is it a pre-req?
            local isPreReq, _, _, preReqRank = TT_IsTalentAPreReq(tab,btn)
            if isPreReq then
                if preReqRank == 0 then -- Does the dependant child have points?
                    rightClickable = true
                end
            else
                rightClickable = true
            end
        end
    end
    return rightClickable
end

--Learns all staged talents
--Learns talents per tab, and then per 
function TT_LearnButton_OnClick()
    for i=1, TT_MAX_TALENTS do --iterate through tabs...
        local keys = {}
        local temp_tiers = {
        }
        for m=1, MAX_NUM_TALENT_TIERS do
            temp_tiers[m] = {}
        end
        for k,v in pairs (TT_StagedTalents[i]) do
            local name, _, tier, _, rank, _,
            _, _ = GetTalentInfo(i,k);
            temp_tiers[tier][k] = v
        end

        for m=1, MAX_NUM_TALENT_TIERS do --iterate through tiers...
            for k,v in pairs(temp_tiers[m]) do
                local name, _, _, _, rank, _,
                _, _ = GetTalentInfo(i,k);
                --TT_Out(format("Learning name: %s Rank: %s",name, rank))
                --Need to check whats learned first so it doesn't rank too high...
                local _, _, _, _, oldRank, _, _, _ = TT_OldGetTalentInfo(i, k);
                rank = rank - oldRank
                if rank > 0 then
                    LearnTalentRank(i, k, rank)
                end
            end
        end
    end
    TT_ResetButton_OnClick()
end

--Resets all staged clients
function TT_ResetButton_OnClick()
    TT_TalentPointsSpent = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    } 
    TT_StagedTalents = {
        [1] = {},
        [2] = {},
        [3] = {}
    }
    TT_StagedLevellingPlan = {}
    TT_StagedEstimatedLevel = TT_MINLEVEL
    TT_PresetLoaded = false
    TT_TalentFrame_Update()
    TT_TalentFrameButtons_OnUpdate()
end

--Overrides any currently learned specs, staging empty entries over them
--Might not be necessary with how SimMode now works?
function TT_WipeCurrentSpec()
    TT_PresetLoaded = false
    for i=1, TT_MAX_TALENTS do
        TT_TalentPointsSpent[i] = 0
        for m=1, MAX_NUM_TALENTS do
            local b = _G["TalentFrameTalent"..m]:GetID()
            if b ~= nil then
                --local _, _, _, _, rank, 
                --_, _, _ = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), b);
                TT_StagedTalents[i][b] = 0
            else break end
        end
    end
end

--Sets up sim mode
--Resets simulated specs
--Hides learned specs, gives full points
function TalentFrameSimMode_OnClick()
    TT_ResetButton_OnClick()
    TT_SimMode = not TT_SimMode
    TT_StagedLevellingPlan = {}
    if TT_SimMode then
        TT_WipeCurrentSpec()
        _G["TalentFrameSimModePointsBox"]:Show()
        _G["TalentFrameSimModePointsBoxPrompt"]:Show()
        TalentFrame.talentPoints = TubTalent_Vars.MaxTalentPoints
        TalentFrameTalentPointsText:SetText(TubTalent_Vars.MaxTalentPoints);
    else
        _G["TalentFrameSimModePointsBox"]:Hide()
        _G["TalentFrameSimModePointsBoxPrompt"]:Hide()
        TT_TalentFrame_UpdateTalentPoints()
    end
    TT_TalentFrame_Update()
    TT_TalentFrameButtons_OnUpdate()
    TT_StagedTalentsFrame_Update()
end

function TT_SavePresetButton_OnUpdate()
    for i=1, TT_MAX_TALENTS do
        if TT_TalentPointsSpent[i] > 0 then
            return false
        end
    end
    --check for spent talent points...?
    for i=1, 3 do
        _, _, pointsSpent = GetTalentTabInfo(i);
        if pointsSpent > 0 then
            return false
        end
    end
    return true
end

--If any simulated points have been spent offer learning
--otherwise, disable button functionality and gray out
function TT_TalentFrameButtons_OnUpdate()
    local found = 0 
    for i=1, TT_MAX_TALENTS do
        if TT_TalentPointsSpent[i] > 0 then
            found = 1
            break
        end
    end
    if found == 1 then
        if not TT_SimMode then
            TalentFrameLearnButton:SetScript("OnClick",TT_LearnButton_OnClick)
            TalentFrameLearnButton:GetNormalTexture():SetDesaturated(false)
            TalentFrameLearnButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
            TalentFrameLearnButtonText:SetTextColor(1, .8, 0)
        end
        TalentFrameResetButton:SetScript("OnClick",TT_ResetButton_OnClick)
        TalentFrameResetButton:GetNormalTexture():SetDesaturated(false)
        TalentFrameResetButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
        TalentFrameResetButtonText:SetTextColor(1, .8, 0)
    else
        TalentFrameLearnButton:SetScript("OnClick",nil)
        TalentFrameLearnButton:GetNormalTexture():SetDesaturated(true)
        TalentFrameLearnButton:SetHighlightTexture("")
        TalentFrameLearnButtonText:SetTextColor(0.5, 0.5, 0.5)
        TalentFrameResetButton:SetScript("OnClick",nil)
        TalentFrameResetButton:GetNormalTexture():SetDesaturated(true)
        TalentFrameResetButton:SetHighlightTexture("")
        TalentFrameResetButtonText:SetTextColor(0.5, 0.5, 0.5)
    end
    TT_TalentPresets_Dewdrop:Close()
end

--Left click function, stages specs and pretends to spend points
function TT_TalentFrameTalent_OnLeftClick()
    tab = PanelTemplates_GetSelectedTab(TalentFrame)
    btn = this:GetID()
    --Check for click validity...
    --Keep track of points
    TalentFrame.talentPoints = TalentFrame.talentPoints - 1
    --Keep track of which talent was clicked...
    -- Is it enabled? Yes, always
    TT_TalentPointsSpent[tab] = TT_TalentPointsSpent[tab] + 1
    if TT_SimMode then
        name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = TT_GetTalentInfo(tab,btn);
            if TT_StagedTalents[tab][btn] ~= nil then
            if TT_StagedTalents[tab][btn] + 1 <= maxRank then
                TT_StagedTalents[tab][btn] = TT_StagedTalents[tab][btn] + 1
            end
        elseif rank + 1 <= maxRank then
            TT_StagedTalents[tab][btn] = 1
        end
    else
        name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = TT_OldGetTalentInfo(tab,btn);
        if TT_StagedTalents[tab][btn] ~= nil then
            if TT_StagedTalents[tab][btn] + rank + 1 <= maxRank then
                TT_StagedTalents[tab][btn] = TT_StagedTalents[tab][btn] + 1
            end
        elseif rank + 1 <= maxRank then
            TT_StagedTalents[tab][btn] = 1
        end
    end
    --rank = rank + TT_StagedTalents[tab][btn]
    rank = rank  + 1

    --Add to levelling plan...
    TT_UpdateEstimatedLevel()
    if RQ_GetVersion and SUPERWOW_STRING then
        spellID, _ = TT_GetTalentSpellID(tab, btn)
    else
        spellID = 0 -- Disabled...
    end
    --TT_Out(format("Staging tab: %s btnID: %s rank: %s spellID: %s name: %s level: %s",
    --    tab, btn, rank, spellID, name, TT_StagedEstimatedLevel))
    if TT_SimMode then -- Only allow creating a levelling plan in sim mode
        TT_StagedLevellingPlan[TT_StagedEstimatedLevel] = {
            tab = tab,
            tabName = GetTalentTabInfo(tab),
            btnID = btn,
            rank = rank,
            icon = iconTexture,
            spellID = spellID,
            name = name,
        }
    end

    TT_TalentFrame_Update()
    TT_TalentTooltip()
    TT_TalentFrameButtons_OnUpdate()
end

--right click function, removes staged specs and pretends to refund points
function TT_TalentFrameTalent_OnRightClick()
    tab = PanelTemplates_GetSelectedTab(TalentFrame)
    btn = this:GetID()
    local _, _, _, _, rank, 
    _, _, _ = GetTalentInfo(tab, btn);
    -- probably redudant with prior safety check
    if TT_StagedTalents[tab][btn] ~= nil then 
        if TT_StagedTalents[tab][btn] - 1 >= 0 then
            TT_StagedTalents[tab][btn] = TT_StagedTalents[tab][btn] - 1
            TalentFrame.talentPoints = TalentFrame.talentPoints + 1
            TT_TalentPointsSpent[tab] = TT_TalentPointsSpent[tab] - 1
        end
    end
    -- remove from levelling plan...
    -- find a match on: tab, btn, rank, and remove it.
    local found = 0
    for k, v in pairs(TT_StagedLevellingPlan) do
        --Need to look for that button id... It will be in here.
        if v.btnID == btn and v.tab == tab and v.rank == rank then
            found = k 
            break
        end
    end
    --TT_Out("Before removing...")
    --TT_OutPutLevellingPlan()
    TT_StagedLevellingPlan[found] = nil -- removed it...
    local i = found
    -- Now need to re-do all the following levels...
    while TT_StagedLevellingPlan[i + 1] ~= nil do
        TT_StagedLevellingPlan[i] = TT_StagedLevellingPlan[i + 1]
        i = i+1
    end
    TT_UpdateEstimatedLevel()
    --TT_Out("After removing...")
    --TT_OutPutLevellingPlan()
    TT_TalentFrame_Update()
    TT_TalentTooltip()
    TT_TalentFrameButtons_OnUpdate()
end

--shift click, links the current rank of the spell in chat
--if it isn't learned yet links rank 1

function TT_TalentFrameTalent_OnShiftClickNoMods()
    TT_Out("Shift click links require SuperWoW+Reliquary client mods.")
end

function TT_TalentFrameTalent_OnShiftClick()
    tab = PanelTemplates_GetSelectedTab(TalentFrame)
    btn = this:GetID()
    local name, _, _, _, rank, _, 
    _, _ = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), btn)
    if rank == 0 then rank = 1 end
    local txt = DEFAULT_CHAT_FRAME.editBox:GetText()
    local spellId = TT_GetTalentSpellID(tab , btn)
    local link = format("\124ccfffffff\124Henchant:%s\124h[%s Rank %s]\124h\124r",spellId, name, rank)
    txt = format("%s %s",txt, link)
    DEFAULT_CHAT_FRAME.editBox:SetText(txt)
end

-- Handler for clicking talents
function TT_TalentFrameTalent_OnClick()
    if IsShiftKeyDown() then
        TT_TalentFrameTalent_OnShiftClick()
        return
    end
    if arg1 == "LeftButton" and TT_TalentFrameTalentIsLeftClickable() then
        TT_TalentFrameTalent_OnLeftClick()
        TT_StagedTalentsFrame_Update()
    elseif arg1 == "RightButton" and TT_TalentFrameTalentIsRightClickable() then
        TT_TalentFrameTalent_OnRightClick()
        TT_StagedTalentsFrame_Update()
    elseif arg1 == "RightButton" and not TT_TalentFrameTalentIsRightClickable() then
        TT_Out("Can't remove points from learned talents")
    end
    TT_TalentPresets_Dewdrop:Close()
end

--Overrides GetTalentPrereqs() returns:
--tier, column, isLearnable = GetTalentPrereqs( tabIndex , talentIndex[, inspect] );
function TT_GetTalentPrereqs(tab, btn)
    --Call the old one, and return a different isLearnable? I guess so.
    tier, column, isLearnable = TT_OldGetTalentPrereqs(tab, btn)
    if tier == nil then 
        return 
    end
    if isLearnable==nil then
        -- I need to translate the tier, column to tab, btn somehow?
        local i = TALENT_BRANCH_ARRAY[tier][column].id
        local preReq_btn = _G["TalentFrameTalent"..i]
        name, iconTexture, _, _, rank, maxRank, isExceptional, meetsPrereq = TT_OldGetTalentInfo(tab,i);
        local t=0
        if TT_StagedTalents[tab][i] ~= nil then
            t = rank + TT_StagedTalents[tab][i]
        end
        if t == maxRank then
            isLearnable=1 -- its expecting 1 instead of true by default here, may as well stick to it.
        else
            isLearnable=nil
        end
    end    return tier, column, isLearnable
end

--How in the world am I going to make tooltips work?
-- I'm afraid best bet is lookup...? Probably nampower fueled. Fuck it, let's try it...
-- SpellID lookup is clumsy and stupid, lets bust out the talent DBC lookup.
-- DBC: Talent.dbc Need: tierID, columnIndex which is returned by GetTalentInfo. But TalentTabID?
-- DBC: TalentTab.dbc Need: TalentTabID, using Name? 
-- TODO: Replace tooltip frame with your own frame. The newlines on rightext is janky

--Tooltips were a nightmare
--They're very close to the original
--Had to do unsavory things to have them look close
--Still a bit of a compromise
--They show weapon skill requirements, SuperWoW issue
--Link formatting options like :0:0 don't seem to help
--Wouldn't usually have anything like that on spell hyperlinks anyway
--Could make my own tooltip frame if I REALLY WANTED TO
function TT_TalentTooltipNoMods()
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
    GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(TalentFrame), this:GetID());
end

function TT_TalentTooltip()
    btnID = this:GetID()
    tab = TalentFrame.selectedTab
    local spellId1, spellId2 = TT_GetTalentSpellID(tab,btnID)
    local tabName, _, _, _ = GetTalentTabInfo(tab); -- Might need to override to keep track over simulated points spent
    local name, _, tier, _, rank, maxRank, _, _ = GetTalentInfo(tab,btnID);
    
    --Setup Tooltip
    -- adds to the first line
    -- adds a new line to the right text of the next line every time
    TT_TalentTooltip_OnLeave() -- hide first to clear, just in case
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    GameTooltip:SetHyperlink("enchant:"..spellId1.. ":0:0:0");
    local t = GameTooltipTextLeft2:GetText()
    local tt = GameTooltipTextRight2:GetText()
    local temp = "|cFFffffffRank ".. rank .. "/" .. maxRank .. "|r\n"
    if tt ~= nil then tt = "\n" .. tt end 
    --tier check
    local pointsReq = (tier-1)*5
    if ( ( pointsReq <= TalentFrame.pointsSpent ) ) then
        tierUnlocked = 1;
    else
        tierUnlocked = nil;
    end

    if tierUnlocked == nil then
        temp = temp .. format("|cFFBE1B20Requires %s points in %s Talents|r\n", pointsReq, tabName)
        if tt ~= nil then tt = "\n" .. tt end 
    end
    local preReqTier, preReqColumn, preReqIsLearnable = TT_GetTalentPrereqs(tab,btnID)
    --check pre-reqs
    --Requires %s points in %s Talents
    if preReqTier~=nil and preReqIsLearnable ~= 1 then
        -- Requires %s points in %s
        local i = TALENT_BRANCH_ARRAY[preReqTier][preReqColumn].id
        local preReqName, _, _, _, _, preReqMaxRank, _, _ = GetTalentInfo(tab,i)
        temp = temp .. format("|cFFBE1B20Requires %s points in %s|r\n",preReqMaxRank,preReqName)
        if tt ~= nil then tt = "\n" .. tt end 
    end
    -- add all the new data, and display it in the tooltip
    t = temp .. t
    if tt ~= nil then
        if GameToolTipTextRight3 ~= nil then
            tt = tt .. GameToolTipTextRigh3:GetText()
            GameTooltipTextRight2:SetText("")
        else
            GameTooltipTextRight2:SetText(tt)
        end
    end
    GameTooltipTextLeft2:SetText(t)
    if TT_TalentFrameTalentIsLeftClickable() then
        GameTooltip:AddLine("|cff00ff00Click to stage|r")
    end
    if TT_TalentFrameTalentIsRightClickable() then
        GameTooltip:AddLine("|cff00ff00Right click to remove staged points|r")
    end
    GameTooltip:Show()

    --Setup next rank tooltip (if relevant)
    if rank ~=0 and rank ~= maxRank then
        t=""
        TT_TalentTooltipFrame:SetOwner(GameTooltip, "ANCHOR_BOTTOM");
        TT_TalentTooltipFrame:SetHyperlink("enchant:"..spellId2);
        t = TT_TalentTooltipFrameTextLeft1:GetText()
        t = "Next Rank:\n" .. t
        TT_TalentTooltipFrameTextLeft1:SetText(t)
        TT_TalentTooltipFrame:Show()
        TT_TalentTooltipFrame:ClearAllPoints()
        TT_TalentTooltipFrame:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 0, 0)
    end
end

--Learn button tooltip
function TT_TalentLearnButton_OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    GameTooltip:ClearLines()
    if TT_SimMode then
        GameTooltip:AddLine("Not available in Sim Mode", 1, 1, 1) -- Title (White)
    end
    GameTooltip:Show()
end

--Overloaded Talent button tooltip
function TT_TalentTooltip_OnLeave()
    GameTooltip:Hide();
    TT_TalentTooltipFrame:Hide();
end

function TT_Out(msg)
    DEFAULT_CHAT_FRAME:AddMessage(format("%s: %s",
        "TT", msg))
end

-- Level Plan UI
NUM_LVLPLAN_TALENTSSHOWN = 5
TT_CurrentTab = 1
TT_PresetLoaded = false

local TT_PlanOpts = {
    [1] = {
        {
            name="Plans",
            tooltip="",
            notCheckable=true,
            value="plans"
        },
        {
            name="Save Plan",
            tooltip="Enter to save",
            notCheckable=true,
            hasEditBox=true,
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
        {
            name="Import Plan",
            tooltip="Opens a window to paste in a plan",
            notCheckable=true,
            func=function()  TT_Out("TODO") end,
            value=""
        },
        {
            name="Options",
            tooltip="",
            notCheckable=true,
            value="plansoptions"
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
                end,
                value=""
            },
        },
        ["plansmenu"] = {
            {
            name="Select Plan",
            --tooltipTitle="Learn Preset",
            tooltip="Learns the selected plan\nNot available in Sim mode",
            notCheckable=true,
            --disabled = function() return TT_SimMode end, --I'll let you select it twice, no harm lel
            func=function(arg1)  TT_SelectPlan(arg1) end,
            value=""
            },
            {
            name="Stage Plan",
            tooltip="Stages the selected plan over your current build if possible\nEnable Sim mode if you don't want to reset your talents",
            notCheckable=true,
            disabled = function() return not TT_SimMode end,
            func=function(arg1)  TT_StagePlan(arg1) end,
            value=""
            },
            {
            name="Export Plan",
            tooltip="Exports the selected plan",
            notCheckable=true,
            func=function(arg1)  TT_Out("TODO") end,
            value=""
            },
            {
            name="Delete Plan",
            tooltip="Deletes the selected plan",
            notCheckable=true,
            func=function(arg1)  TT_DeletePlan(arg1) end,
            value=""
            },
        }
    },
}

function TT_FindPlan(planID)
    if TubTalent_Vars.LevellingPlans == nil then
        return nil
    end
    for k, v in pairs(TubTalent_Vars.LevellingPlans) do
        if v.id == tonumber(planID) then
            return k, v
        end
    end
    return nil
end

function TT_SelectPlan(arg)
    _, v = TT_FindPlan(arg)
    TubTalent_Vars.CurrentLevellingPlan = v.id
    TT_CurrentLevellingPlan = v
    TT_LevellingPlans_DewDrop:Close()
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
        TT_Out(k)
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
        TT_Out("Can't delete currently selected levelling plan.")
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
        TT_Out("Adding to new plan..." .. planMinLevel .. " " .. planMaxLevel)
        t[k] = n
    end
    TubTalent_Vars.LevellingPlanIDMax = TubTalent_Vars.LevellingPlanIDMax + 1
    local tp = {}
    for i=1, 3 do
        _, _, tp[i] = GetTalentTabInfo(i)
    end
    local newPlan = {
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

function TT_RegenPlansDropdown()
    TT_PlanOpts[2]["plans"] = {} -- clear it out first
    if TT_TalentPresets ~= nil then
        for k,v in pairs(TT_LevellingPlans) do
            local a = "ID: " .. v.id .. "\n"
            for i=1, 3 do
                name, _, _ = GetTalentTabInfo(i)
                a = format("%s%s in %s\n",a,v.points[i],name)
            end
            a = a .. "Min Level: " .. v.levellingPlanMinLevel .. "\n"
            a = a .. "Max Level: " .. v.levellingPlanMaxLevel .. "\n"
            local t = {
                name=v.name,
                tooltipTitle=v.name,
                tooltip=a,
                id=v.id,
                notCheckable=false,
                checked = function(id)
                    if TubTalent_Vars.CurrentLevellingPlan ~= nil then
                        if id == TubTalent_Vars.CurrentLevellingPlan then
                            return true
                        end
                    end return false  end,
                value="plansmenu:"..v.id
            }
            table.insert(TT_PlanOpts[2]["plans"],t)
        end
    end
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

function TT_StagedTalentsFrame_SwitchTab()
    PanelTemplates_SelectTab(this);
    TT_CurrentTab = this:GetID()
    if TT_CurrentTab == 1 then
        PanelTemplates_DeselectTab(TT_StagedTalentsFrame_CurrentPlanButton);
    else
        PanelTemplates_DeselectTab(TT_StagedTalentsFrame_StagedPlanButton);
    end

    PanelTemplates_UpdateTabs(TT_StagedTalentsFrame)
    TT_StagedTalentsFrame_Update()
end

function TT_StagedTalentsFrame_Update()
    local numDisplay, plansToDisplay
    if TT_CurrentTab == 2 then
        if TubTalent_Vars.CurrentLevellingPlan ~= 0 then
            TT_StagedTalentsFrame_NoWorking:Hide()
            numDisplay = TT_CurrentLevellingPlan.levellingPlanMaxLevel - TT_MINLEVEL
            TT_Out("NUM DISPLAY" .. numDisplay)
            plansToDisplay = TT_CurrentLevellingPlan.plan
            if TT_CurrentLevellingPlan == nil then
                TT_Out("FAILED")
            end
        elseif TubTalent_Vars.CurrentLevellingPlan == 0 then
            numDisplay = 0 
            TT_StagedTalentsFrame_NoWorking:Show()
            TT_StagedTalentsFrame_NoWorking:SetText("No preset selected")
            for i=1, NUM_LVLPLAN_TALENTSSHOWN do
                local lvlPlanFrame = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i]
                lvlPlanFrame:Hide()
            end
            return
        end
    else
        if TT_SimMode and not TT_PresetLoaded then
            numDisplay = TT_StagedEstimatedLevel - TT_MINLEVEL
            plansToDisplay = TT_StagedLevellingPlan
            TT_StagedTalentsFrame_NoWorking:Hide()
        else
            numDisplay = 0 
            TT_StagedTalentsFrame_NoWorking:Show()
            TT_StagedTalentsFrame_NoWorking:SetText("Only enabled in Sim Mode.\nCannot be used with a loaded preset.")
            for i=1, NUM_LVLPLAN_TALENTSSHOWN do
                local lvlPlanFrame = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i]
                lvlPlanFrame:Hide()
            end
            return
        end
    end
	--local DeckBuilderFrame_DeckButtonText, DeckBuilderFrame_DeckButton;
	local scrollOffset = FauxScrollFrame_GetOffset(TT_StagedTalentsFrame_PlanScrollFrame);
	local index;
    local minIndex = TT_MINLEVEL
		-- Deck list
	for i=1, NUM_LVLPLAN_TALENTSSHOWN do
        local lvlPlanFrame = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i]

		index = (scrollOffset) + i;
        TT_Out(index)
        TT_Out(numDisplay)
		if ( index <= numDisplay) then
            local lvlPlanLevel = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i.."Level"]
            local lvlPlanName = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i.."Name"]
            local lvlPlanRank = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i.."Rank"]
            local lvlPlanIcon = _G["TT_StagedTalentsFrame_LvlPlanSpec"..i.."Icon"]
			lvlPlanFrame:Show()
            TT_Out("index:" .. index+minIndex)
            lvlPlanName:SetText(plansToDisplay[index+minIndex].name)
            lvlPlanRank:SetText("Rank: " .. plansToDisplay[index+minIndex].rank .. " Tab: " .. plansToDisplay[index+minIndex].tabName)
            lvlPlanLevel:SetText("Level: " .. index+minIndex)
            lvlPlanIcon:SetTexture(plansToDisplay[index+minIndex].icon)

			--DeckBuilderFrame_DeckButtonText:SetText(format("%s",EmoteButtons_DeckList[index]))
		else
            lvlPlanFrame:Hide()
			--DeckBuilderFrame_DeckButton:Hide();
		end
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(TT_StagedTalentsFrame_PlanScrollFrame, numDisplay , NUM_LVLPLAN_TALENTSSHOWN, 28);
	-- numEmotes is max entries, NUM_EMOTES_SHOWN is the number of lines, last one is supposed to be pixel size
	-- But it works best if I just shove number of elements in there. My scroll area isn't litterally moving,
	-- I'm merely switching out the elements every time a scroll event happens.
end