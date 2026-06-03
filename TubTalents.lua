-- TODO: Add other markers for previewed talent points vs already spent points?
-- TODO: Add caching to tooltips? 

-- TODO: Cleanup
-- Localisation.lua -> Pull a lot of strings and constants out
-- More lua files to split up functionality if possible
-- Remove test prints/functions
-- Check variable names


-- TODO: Polish
-- Refine Chat commands
-- Rename prompt for import presets doesn't accept enter Fixed?
---- Renaming doesn't actually work lol
-- Doesn't catch up on levelup Fixed?

--Functions to overwrite TalentFrame functionality
local _G = getfenv(0)
local libIcon = LibStub("LibDBIcon-1.0");
local libData = LibStub("LibDataBroker-1.1");
TT_TalentPresets_Dewdrop = AceLibrary("Dewdrop-2.0");
TT_LevellingPlans_DewDrop = AceLibrary("Dewdrop-2.0");
--Testing
TT_DebugMode = false
TT_FakeNoMods = false

TT_CurrentTab = 1 --TODO: Better variable name
TT_LearnedTalentsFlag = true
TT_SimMode = false

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

TT_StagedEstimatedLevel = TT_MINLEVEL

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
    if event == "PLAYER_LEVEL_UP" then
        if TubTalent_Vars.AutoLearnPlans ~= TT_AUTOLEARN.Never then
            TT_CatchUpPlan()
        end
    elseif event=="CHARACTER_POINTS_CHANGED" then
        -- check plan viability... But only if points have been spent, not gained.
        -- Unless spent by the addon
        if (arg1 < 0) then --indicates learned talents...
            if TubTalent_Vars.CurrentLevellingPlan ~= 0  and not TT_LearnedTalentsFlag then -- indicates if learned by this addon...
                if TT_CheckPlan(TT_CurrentLevellingPlan.plan) then
                    TT_CatchUpPlan()
                else
                    TubTalent_Vars.CurrentLevellingPlan = 0 
                    TT_CurrentLevellingPlan = nil
                end
            else
                TT_LearnedTalentsFlag = false
            end
        elseif (arg1 > 0) then --DING!
            if TT_CurrentLevellingPlan ~= 0 then
                if TT_CheckPlan(TT_CurrentLevellingPlan.plan) then
                else
                    TubTalent_Vars.CurrentLevellingPlan = 0 
                    TT_CurrentLevellingPlan = nil
                end
            end
        end 
    elseif event=="PLAYER_LOGIN" then --INIT
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
        if TubTalent_Vars.Version < 2 then --Upgrading Saved variables
            for k,v in pairs(TubTalent_Vars.TalentPresets) do
                v.class = UnitClass("player")
            end
            for k,v in pairs(TubTalent_Vars.LevellingPlans) do
                v.class = UnitClass("player")
            end
            TubTalent_Vars.ShowLevellingPlanFrame = true
            TubTalent_Vars.Version = 2
        end
        --Convenient shorthand names for the saved variable lists
        TT_TalentPresets = TubTalent_Vars.TalentPresets
        TT_LevellingPlans = TubTalent_Vars.LevellingPlans
        TalentFrame_LoadUI(); --Load the talent UI early
        if TubTalent_Vars.CurrentLevellingPlan ~= 0 then
            _, TT_CurrentLevellingPlan = TT_FindPlan(TubTalent_Vars.CurrentLevellingPlan)
            if TT_CurrentLevellingPlan == nil then 
                TT_Out(TT_ERRNoPlanLoaded)
                TubTalent_Vars.CurrentLevellingPlan = 0 
                TT_CurrentLevellingPlan = nil
                TT_CurrentTab = 1 --TODO: Make fake enum for tab indexes
            else
                if TT_CheckPlan(TT_CurrentLevellingPlan.plan) then
                    TT_CatchUpPlan()
                else
                    TubTalent_Vars.CurrentLevellingPlan = 0 
                    TT_CurrentLevellingPlan = nil
                end
            end
            TT_CurrentTab = 2
        end
        TT_StagedTalentsFrame_SetTab()
        TubTalents_MinimapIconRegister()
        TT_StagedTalentsFramePlans_DewdropRegister()
        --Detecting client mods, and adjusting functionality...
        if (not (RQ_GetVersion and SUPERWOW_STRING)) or TT_FakeNoMods then
            TT_NoClientMods()
        end
    elseif event == "ADDON_LOADED" then
        if arg1=="Blizzard_TalentUI" then
            --If you wait for the addon to load hooking is fine, won't hook properly otherwise
            TubTalents_InitFrameAdditions()
            TT_StagedTalentsFrame_FrameSetup()
            PanelTemplates_UpdateTabs(TT_StagedTalentsFrame)
            TT_TalentFrameButtons_OnUpdate()
            TT_StagedTalentsFrame_Update()
            TubTalents_FunctionOverloads()
            TT_TalentFramePreferences_DewdropRegister()
        end
    end
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
			icon = "Interface\\Icons\\Ability_Rogue_Disguise" --TODO: Find a different icon
		});

		libIcon:Register("TubTalents icon", iconData, TubTalents_Icon);
	end
end