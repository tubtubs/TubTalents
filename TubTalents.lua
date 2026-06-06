-- TODO: Add other markers for previewed talent points vs already spent points?
-- TODO: Add caching to tooltips? 

-- TODO: Cleanup
-- Localisation.lua -> Pull a lot of strings and constants out [CHECK]
-- More lua files to split up functionality if possible [CHECK]
-- Remove test prints/functions
---- I'm okay with leaving some commented out
-- Check variable names
---- Replace TubTalents_ with TubTalents_, gaudy maybe but I need it.


-- TODO: Polish
-- Refine Chat commands
-- AddonMessages
---- Need to be able to select channel
---- Need to be able to disable/enable it

-- TODO: Bugs
-- Stage current build is broken


--Functions to overwrite TalentFrame functionality
local _G = getfenv(0)
local libIcon = LibStub("LibDBIcon-1.0");
local libData = LibStub("LibDataBroker-1.1");
TubTalents_TalentPresets_Dewdrop = AceLibrary("Dewdrop-2.0");
TubTalents_LevellingPlans_DewDrop = AceLibrary("Dewdrop-2.0");
TubTalents_Settings_DewDrop = AceLibrary("Dewdrop-2.0");
--Testing
TubTalents_DebugMode = false -- actually un-used, only used when debugging during dev
TubTalents_FakeNoMods = false --quicker than disabling mods, but client mod functionality will still work ofc

TubTalents_StagedTalentFrame_CurrentTab = TubTalents_STAGEDTALENTTABS.StagedPlan
TubTalents_LearnedTalentsFlag = true
TubTalents_SimMode = false

TubTalents_TalentPointsSpent = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
} 
TubTalents_StagedTalents = { --key: Tab
    [1] = {}, -- key: btnID val: rank
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {}
}

TubTalents_StagedEstimatedLevel = TubTalents_MINLEVEL

SlashCmdList['TUBTALENTS'] = TubTalents_TextCommands
SLASH_TUBTALENTS1 = "/"..TubTalents_ADDONAME

function TubTalents_TextCommands(arg)
    if arg == nil or arg == "" then
        TubTalents_PrintEachLine(TubTalents_CHATHELP)
    elseif arg==TubTalents_CHATABOUT then
        TubTalents_PrintEachLine(TubTalents_ABOUT)
    elseif arg==TubTalents_CHATRESET then
        StaticPopup_Show("TUBTALENTS_RESETSETTINGS_POPUP")
    elseif arg==TubTalents_CHATCATCHUP then
        TubTalents_CatchUpPlan(true)
    elseif arg==TubTalents_CHATMINIMAP then
        TubTalents_MinimapIconToggle()
    elseif arg==TubTalents_CHATTOGGLE then
        TalentFrame_Toggle();
    end
end

function TubTalents_Init()
    if event=="CHARACTER_POINTS_CHANGED" then
        -- check plan viability... But only if points have been spent, not gained.
        -- Unless spent by the addon
        if (arg1 < 0) then --indicates learned talents...
            if TubTalent_Vars.CurrentLevellingPlan ~= 0  and not TubTalents_LearnedTalentsFlag then -- indicates if learned by this addon...
                if TubTalents_CheckPlan(TubTalents_CurrentLevellingPlan.plan) then
                    TubTalents_CatchUpPlan()
                else
                    TubTalent_Vars.CurrentLevellingPlan = 0 
                    TubTalents_CurrentLevellingPlan = nil
                end
            else
                TubTalents_LearnedTalentsFlag = false
            end
        elseif (arg1 > 0) then --DING!
            if TubTalents_CurrentLevellingPlan ~= nil then
                if TubTalents_CheckPlan(TubTalents_CurrentLevellingPlan.plan) then
                    TubTalents_CatchUpPlan()
                else
                    TubTalent_Vars.CurrentLevellingPlan = 0 
                    TubTalents_CurrentLevellingPlan = nil
                end
            end
        end 
    elseif event=="PLAYER_LOGIN" then --INIT
        if TubTalent_Vars == nil or TubTalents_DebugMode then
            TubTalent_Vars = {
                Version = 1,
                TalentPresets = {},
                LevellingPlans = {},
                CurrentLevellingPlan = 0,
                LevellingPlanIDMax = 0,
                TalentPresetIDMax = 0
            }
        end
        if TubTalent_Vars.Version < 2 or TubTalents_DebugMode then --Upgrading Saved variables
            for k,v in pairs(TubTalent_Vars.TalentPresets) do
                v.class = UnitClass("player")
            end
            for k,v in pairs(TubTalent_Vars.LevellingPlans) do
                v.class = UnitClass("player")
            end
            TubTalent_Vars.ShowSpellIDs = false
            TubTalent_Vars.MaxTalentPoints = TubTalents_MAX_TALENTPOINTS
            TubTalent_Vars.ShowLevellingPlanFrame = true
            TubTalent_Vars.AddonSharing = true
            TubTalent_Vars.AutoLearnPlans = TubTalents_AUTOLEARN.Prompt
            TubTalent_Vars.Version = 2
        end
        --Convenient shorthand names for the saved variable lists
        TubTalents_TalentPresets = TubTalent_Vars.TalentPresets
        TubTalents_LevellingPlans = TubTalent_Vars.LevellingPlans
        TalentFrame_LoadUI(); --Load the talent UI early
        if TubTalent_Vars.CurrentLevellingPlan ~= 0 then
            _, TubTalents_CurrentLevellingPlan = TubTalents_FindPlan(TubTalent_Vars.CurrentLevellingPlan)
            if TubTalents_CurrentLevellingPlan == nil then 
                TubTalents_Out(TubTalents_ERRNoPlanLoaded)
                TubTalent_Vars.CurrentLevellingPlan = 0 
                TubTalents_CurrentLevellingPlan = nil
                TubTalents_StagedTalentFrame_CurrentTab = TubTalents_STAGEDTALENTTABS.StagedPlan
            else
                if TubTalents_CheckPlan(TubTalents_CurrentLevellingPlan.plan) then
                    TubTalents_CatchUpPlan()
                else
                    TubTalent_Vars.CurrentLevellingPlan = 0 
                    TubTalents_CurrentLevellingPlan = nil
                end
            end
            TubTalents_StagedTalentFrame_CurrentTab = TubTalents_STAGEDTALENTTABS.CurrentPlan
        end
        TubTalents_StagedTalentsFrame_SetTab()
        TubTalents_MinimapIconRegister()
        TubTalents_StagedTalentsFramePlans_DewdropRegister()
        TubTalents_Settings_DewDropRegister()
        --Detecting client mods, and adjusting functionality...
        if (not (RQ_GetVersion and SUPERWOW_STRING)) or TubTalents_FakeNoMods then
            TubTalents_NoClientMods()
        end
    elseif event == "ADDON_LOADED" then
        if arg1=="Blizzard_TalentUI" then
            --If you wait for the addon to load hooking is fine, won't hook properly otherwise
            TubTalents_InitFrameAdditions()
            TubTalents_StagedTalentsFrame_FrameSetup()
            PanelTemplates_UpdateTabs(TubTalents_StagedTalentsFrame)
            TubTalents_TalentFrameButtons_OnUpdate()
            TubTalents_StagedTalentsFrame_Update()
            TubTalents_FunctionOverloads()
            TubTalents_TalentFramePreferences_DewdropRegister()
        end
    elseif event == "CHAT_MSG_ADDON" and TubTalent_Vars.AddonSharing then
        if (arg4 ~= UnitName("PLAYER") or TubTalents_DebugMode) then --Filter out your own messages unless debugging
            if arg1==TubTalents_AMPREFIX then
                TubTalents_AMHANDLER(arg2,arg3,arg4) 
            end
        end
    end
end

--Zeroes out any saved variables
function TubTalents_ResetSettings()
    TubTalent_Vars = {
        Version = 1,
        MaxTalentPoints = TubTalents_MAX_TALENTPOINTS,
        TalentPresets = {},
        LevellingPlans = {},
        CurrentLevellingPlan = 0,
        LevellingPlanIDMax = 0,
        TalentPresetIDMax = 0,
        AutoLearnPlans=TubTalents_AUTOLEARN.Prompt,
    }
    TubTalent_Vars.ShowSpellIDs = false
    TubTalent_Vars.MaxTalentPoints = TubTalents_MAX_TALENTPOINTS
    TubTalent_Vars.ShowLevellingPlanFrame = true
    TubTalent_Vars.AddonSharing = true
    TubTalent_Vars.AutoLearnPlans = TubTalents_AUTOLEARN.Prompt
    TubTalent_Vars.Version = 2
    TubTalents_ShowMinimap()
    ReloadUI()
end
--StaticPopup_Show("TUBTALENTS_RESETSETTINGS_POPUP")
StaticPopupDialogs["TUBTALENTS_RESETSETTINGS_POPUP"] = {
    text = TubTalents_CATCHUPPROMPT,
    button1 = "Yes",
    button2 = "No",
    OnAccept = TubTalents_ResetSettings,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}


-- Minimap Icon Setup
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
	if TubTalents_Icon == nil then --Setup saved variable for hiding, and moving
		TubTalents_Icon = {
			hide = false
		}
	end
	if not TubTalents_Icon.hide then
		local iconData = libData:NewDataObject("TubTalents icon data", {
			OnClick = function()
                TalentFrame_Toggle();
			end,
			OnTooltipShow = function(tooltip)
				tooltip:SetText("TubTalents");
			end,
			icon = TubTalents_MINIMAPICON
		});

		libIcon:Register("TubTalents icon", iconData, TubTalents_Icon);
	end
end

function TubTalents_MinimapIconToggle()
    if TubTalents_Icon.hide then
        TubTalents_ShowMinimap()
    else
        TubTalents_HideMinimap()
    end
end