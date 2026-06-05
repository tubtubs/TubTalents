--May be helpful for localising to other languages
-- Mostly strings, but some constants too
--Missing chat commands, and dropdown options. They're kinda hard to move.
-- Check TT_PlanOpts, and TT_PresetOpts for dropdowns
TT_ADDONAME = "TubTalents"
TT_ADDONVERSION = "2"
TT_AUTHOR = "Tubtubs"
TT_ADDONFULLNAME = format("%s V%s", TT_ADDONAME, TT_ADDONVERSION)
TT_MAX_TALENTS = 3
TT_MAX_TALENTPOINTS = 51
TT_AUTOLEARN = {
    Never=0,
    Prompt=1,
    FullAuto=2,
}
TT_PROFILEMODES = {
    None = 0,
    ExportPreset = 1,
    ImportPreset = 2,
    ExportPlan = 3,
    ExportPlan = 4,
}

TT_TEST = "ERROR" --if a widget has this text it's probably getting filled in later
TT_MINIMAPICON = "Interface\\Icons\\ability_marksmanship"
TT_MINLEVEL = 9

--ERRORS
TT_ERRNoPlanLoaded = "Error: No levelling plan loaded... Invalid levelling plan selected."
TT_ERRSimMode = "Not available in Sim Mode"
TT_ERRLevelPlan = "ERROR WITH LEVELLING PLAN - DESELECTING"
TT_ERRDeleteSelctedPlan = "Can't delete currently selected levelling plan."
TT_ERRStagedPresetsLearnedConflict = "Learned ranks conflict, can't stage preset. Reset, or enable Sim mode."
TT_ERRStagedPresetsPoints = "Not enough points, can't stage preset. Reset, or enable Sim mode."

--Talent Tooltips
TT_TalentTipRank = "|cFFffffffRank %s/%s|r"
TT_TalentTipTier = "|cFFFF2020Requires %s points in %s Talents|r"
TT_TalentTipPreReq = "|cFFFF2020Requires %s points in %s|r"
TT_TalentTipNextRank = "Next Rank:"
TT_TalentTipLeftClick = "|cff00ff00Click to stage|r"
TT_TalentTipRightClick = "|cff00ff00Right click to remove points|r"

--Import/Export
TT_ExportPreset = "Export Preset"
TT_ExportPlan = "Export Plan"
TT_ImportPreset = "Import Preset"
TT_ImportPresetSameName = "Import successful, there's another preset with the same name though.\nWould you like to rename?"
TT_ImportPlan = "Import Plan"
TT_ImportPlanSameName = "Import successful, there's another plan with the same name though.\nWould you like to rename?"
TT_ERRBADCorrupPreset = "Imported preset is really corrupt, try re-exporting"
TT_ERRCorruptPreset = "Imported preset is corrupt, try re-exporting"
TT_ERRPresetClass = "Imported preset doesn't match your class"
TT_ACKPresetImport = "Successfully imported preset"

TT_ERRBADCorruptPlan = "Imported plan is really corrupt, try re-exporting"
TT_ERRCorruptPlan = "Imported plan is corrupt, try re-exporting"
TT_ERRPlanClass = "Imported plan doesn't match your class"
TT_ACKPlanImport = "Successfully imported plan"

--Chat Commands
TT_CHATHELP = format("|cFF00FF00%s by %s commands:|r\n/tubtalents minimap toggles minimap buton\n/tubtalents toggle - opens/closes talent frame", TT_ADDONFULLNAME, TT_AUTHOR)

--Plans
TT_PLANDROPTOOLTIP = [[ID: %s
%s
Min Level: %s
Max Level: %s
|cff1eff0cClick to select this plan|r]]

TT_PLANDEFAULTDROP = {
    name="Create or import a plan",
    tooltip="Enable sim mode and make a plan, or import one to get started.",
    notCheckable=true,
    value=""
}

TT_CATCHUPPROMPT = "Do you want to catch up with the current levelling plan?"
TT_STAGEDTALENTS_NOPLANSELECTED = "No levelling plan selected.\nSelect one from the button above to get started."
TT_STAGEDTALENTS_STARTPLAN = "Click on a talent to start making a levelling plan"
TT_STAGEDTALENTSERR = "Only enabled in Sim Mode.\nCannot be used with a loaded preset."
TT_STAGEDTALENTSNOPRESETS = "Can't create level plan with preset loaded.\nReset, or refund staged points to make a levelling plan."
TT_CHATLINKFORMAT = "\124ccfffffff\124Henchant:%s\124h[%s Rank %s]\124h\124r"
TT_LEVELINGPLANTITLE = "Levelling Plans"
TT_LEVELINGPLANTAB1 = "Staged Plan"
TT_LEVELINGPLANTAB2 = "Current Plan"
TT_LEVELINGPLANSDROP = "Plans >"
TT_CATCHUPNEXTPROMPT = "Learn the next talent in your levelling plan?"
TT_CATCHUPNAME = "Name"
TT_CATCHUPRANK = "Rank"

TT_STAGEDTALENTTABS = {
    StagedPlan = 1,
    CurrentPlan = 2
}

--Presets
TT_PRESETDEFAULTDROP = {
    name="Create or import a preset",
    tooltip="Stage or spend some points and then save it, or import a preset.",
    notCheckable=true,
    value=""
}

-- Sharing
TT_OKAY = OKAY or "Okay" -- uses the global string, not sure how it localises tho tbh
TT_SUBMIT = SUBMIT or "Submit" -- global string too

--Talent Frame
TT_ESTIMATEDLEVEL = "Estimated Level: %s"

TT_LEARNING = "Learning name: %s Rank: %s"
TT_LEVELINGPLANBTN = "Levelling Plans >>"
TT_LEARN = "Learn"
TT_RESET = "Reset"
TT_PRESETSBTN = "Presets >"
TT_SIMMODE = "Sim Mode"
TT_SIMMODETIP = "Click to toggle this setting.\nWill wipe your current staged talents."
TT_ENTERTOSAVE = "Enter to save"
TT_MAXPOINTS = "Max Points:"