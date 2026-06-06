

TubTalents_SettingsOpts = {
    [1] = {
        {
            name="In Game Sharing",
            tooltip="Toggle Addon Message sharing, export/import work regardless",
            notCheckable=false,
            checked=function() 
                return TubTalent_Vars.AddonSharing
            end,
            func=function() 
                TubTalent_Vars.AddonSharing = not TubTalent_Vars.AddonSharing
            end,
            value=""
        },
        {   
            name="Show Minimap Icon",
            tooltip="Show Minimap Icon",
            notCheckable=false,
            checked=function() 
                return not TubTalents_Icon.hide
            end,
            func=function() 
                TubTalents_MinimapIconToggle()
            end,
            value=""
        },
        {   
            name="Reset Addon",
            tooltip="Resets all presets, plans, configurations\nHas a popup warning",
            notCheckable=true,
            func=function() 
                StaticPopup_Show("TUBTALENTS_RESETSETTINGS_POPUP")
            end,
            value=""
        },
        {
            name="Debug Flags",
            tooltip="Under utilized debug flags",
            notCheckable=true,
            value="debugflags"
        },
        {
            name="About",
            tooltip=TubTalents_ABOUT,
            notCheckable=true,
            value=""
        },
    },
    [2] = {
        ["debugflags"] = {
            {
                name="Debug",
                tooltip="Toggle Debug Mode. Under utilized, really\nMostly for testing",
                notCheckable=false,
                checked=function() 
                    return TubTalents_DebugMode
                end,
                func=function() 
                    TubTalents_DebugMode = not TubTalents_DebugMode
                end,
                value=""
            },
            {
                name="Fake No Mods Mode",
                tooltip="Pretends you don't have client mods\nNeeds to reloadUI to undo",
                notCheckable=false,
                checked=function() 
                    return TubTalents_FakeNoMods
                end,
                func=function() 
                    TubTalents_FakeNoMods = not TubTalents_FakeNoMods
                    if TubTalents_FakeNoMods then
                        TubTalents_NoClientMods()
                    else
                        ReloadUI()
                    end
                end,
                value=""
            },
        }
    }
}

function TubTalents_Settings_DewDropRegister()
    TubTalents_Settings_DewDrop:Register(TalentFrameCancelButton, --Bound Frame
        'point', function(parent) --Point
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value) TubTalents_TalentPresets_DewdropGen(level, value, TubTalents_SettingsOpts) end,
        'dontHook', true
    )
end