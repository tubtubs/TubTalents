--May be helpful for localising to other languages
-- Mostly strings, but some constants too
-- Check TubTalents_PlanOpts, and TubTalents_PresetOpts for dropdowns
TubTalents_ADDONAME = "TubTalents"
TubTalents_ADDONVERSION = "2"
TubTalents_AUTHOR = "Tubtubs"
TubTalents_ADDONFULLNAME = format("%s V%s", TubTalents_ADDONAME, TubTalents_ADDONVERSION)
TubTalents_MAX_TALENTS = 3 -- Don't have any means to test more than 3 specs, it is technically possible though?
TubTalents_MAX_TALENTPOINTS = 51
TubTalents_MINLEVEL = 9

TubTalents_AUTOLEARN = {
    Never=0,
    Prompt=1,
    FullAuto=2,
}
TubTalents_PROFILEMODES = {
    None = 0,
    ExportPreset = 1,
    ImportPreset = 2,
    ExportPlan = 3,
    ExportPlan = 4,
}

TubTalents_TEST = "ERROR" --if a widget has this text it's probably getting filled in later
TubTalents_MINIMAPICON = "Interface\\Icons\\ability_marksmanship"

--Chat Commands
TubTalents_CHATCATCHUP = "catchup"
TubTalents_CHATCATCHUPDESC = "Prompts to catch up on your levelling plan"
TubTalents_CHATMINIMAP = "minimap"
TubTalents_CHATMINIMAPDESC = "Toggles minimap button"
TubTalents_CHATTOGGLE = "toggle"
TubTalents_CHATTOGGLEDESC = "Opens/closes talent frame"
TubTalents_CHATHELP = format(
[[|cFF00FF00%s by %s commands:|r
/%s %s - %s
/%s %s - %s
/%s %s - %s]], 
TubTalents_ADDONFULLNAME, TubTalents_AUTHOR,
TubTalents_ADDONAME,TubTalents_CHATCATCHUP,TubTalents_CHATCATCHUPDESC,
TubTalents_ADDONAME,TubTalents_CHATMINIMAP,TubTalents_CHATMINIMAPDESC,
TubTalents_ADDONAME,TubTalents_CHATTOGGLE,TubTalents_CHATTOGGLEDESC)

--ERRORS
TubTalents_ERRNoPlanLoaded = "Error: No levelling plan loaded... Invalid levelling plan selected."
TubTalents_ERRSimMode = "Not available in Sim Mode"
TubTalents_ERRLevelPlan = "ERROR WITH LEVELLING PLAN - DESELECTING"
TubTalents_ERRDeleteSelctedPlan = "Can't delete currently selected levelling plan."
TubTalents_ERRStagedPresetsLearnedConflict = "Learned ranks conflict, can't stage preset. Reset, or enable Sim mode."
TubTalents_ERRStagedPresetsPoints = "Not enough points, can't stage preset. Reset, or enable Sim mode."

--Talent Tooltips
TubTalents_TalentTipRank = "|cFFffffffRank %s/%s|r"
TubTalents_TalentTipTier = "|cFFFF2020Requires %s points in %s Talents|r"
TubTalents_TalentTipPreReq = "|cFFFF2020Requires %s points in %s|r"
TubTalents_TalentTipNextRank = "Next Rank:"
TubTalents_TalentTipLeftClick = "|cff00ff00Click to stage|r"
TubTalents_TalentTipRightClick = "|cff00ff00Right click to remove points|r"

--Import/Export
TubTalents_ExportPreset = "Export Preset"
TubTalents_ExportPlan = "Export Plan"
TubTalents_ImportPreset = "Import Preset"
TubTalents_ImportPresetSameName = "Import successful, there's another preset with the same name though.\nWould you like to rename?"
TubTalents_ImportPlan = "Import Plan"
TubTalents_ImportPlanSameName = "Import successful, there's another plan with the same name though.\nWould you like to rename?"
TubTalents_ERRBADCorrupPreset = "Imported preset is really corrupt, try re-exporting"
TubTalents_ERRCorruptPreset = "Imported preset is corrupt, try re-exporting"
TubTalents_ERRPresetClass = "Imported preset doesn't match your class"
TubTalents_ACKPresetImport = "Successfully imported preset"

TubTalents_ERRBADCorruptPlan = "Imported plan is really corrupt, try re-exporting"
TubTalents_ERRCorruptPlan = "Imported plan is corrupt, try re-exporting"
TubTalents_ERRPlanClass = "Imported plan doesn't match your class"
TubTalents_ACKPlanImport = "Successfully imported plan"

--Plans
TubTalents_PLANDROPTOOLTIP = [[ID: %s
%s
Min Level: %s
Max Level: %s
|cff1eff0cClick to select this plan|r]]

TubTalents_PLANDEFAULTDROP = {
    name="Create or import a plan",
    tooltip="Enable sim mode and make a plan, or import one to get started.",
    notCheckable=true,
    value=""
}

TubTalents_CATCHUPPROMPT = "Do you want to catch up with the current levelling plan?"
TubTalents_STAGEDTALENTS_NOPLANSELECTED = "No levelling plan selected.\nSelect one from the button above to get started."
TubTalents_STAGEDTALENTS_STARTPLAN = "Click on a talent to start making a levelling plan"
TubTalents_STAGEDTALENTSERR = "Only enabled in Sim Mode.\nCannot be used with a loaded preset."
TubTalents_STAGEDTALENTSNOPRESETS = "Can't create level plan with preset loaded.\nReset, or refund staged points to make a levelling plan."
TubTalents_CHATLINKFORMAT = "\124ccfffffff\124Henchant:%s\124h[%s Rank %s]\124h\124r"
TubTalents_LEVELINGPLANTITLE = "Levelling Plans"
TubTalents_LEVELINGPLANTAB1 = "Staged Plan"
TubTalents_LEVELINGPLANTAB2 = "Current Plan"
TubTalents_LEVELINGPLANSDROP = "Plans >"
TubTalents_CATCHUPNEXTPROMPT = "Learn the next talent in your levelling plan?"
TubTalents_CATCHUPNAME = "Name"
TubTalents_CATCHUPRANK = "Rank"

TubTalents_STAGEDTALENTTABS = {
    StagedPlan = 1,
    CurrentPlan = 2
}

--Presets
TubTalents_PRESETDEFAULTDROP = {
    name="Create or import a preset",
    tooltip="Stage or spend some points and then save it, or import a preset.",
    notCheckable=true,
    value=""
}

-- Sharing
TubTalents_OKAY = OKAY or "Okay" -- uses the global string, not sure how it localises tho tbh
TubTalents_SUBMIT = SUBMIT or "Submit" -- global string too
TubTalents_CHECK = "Checking %s..."
TubTalents_AMPREFIX = "TTA"

--Talent Frame
TubTalents_ESTIMATEDLEVEL = "Estimated Level: %s"

TubTalents_LEARNING = "Learning name: %s Rank: %s"
TubTalents_LEVELINGPLANBTN = "Levelling Plans >>"
TubTalents_LEARN = "Learn"
TubTalents_RESET = "Reset"
TubTalents_PRESETSBTN = "Presets >"
TubTalents_SIMMODE = "Sim Mode"
TubTalents_SIMMODETIP = "Click to toggle this setting.\nWill wipe your current staged talents."
TubTalents_ENTERTOSAVE = "Enter to save"
TubTalents_MAXPOINTS = "Max Points:"