--Dropdown Setup/Utilities
function TT_TalentFramePreferences_DewdropRegister()
    TT_TalentPresets_Dewdrop:Register(TalentFramePresetsButton, --Bound Frame
        'point', function(parent) --Point
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value) TT_TalentPresets_DewdropGen(level, value, TT_PresetOpts) end,
        'dontHook', true
    )
end

-- WIP wrapper around ace DewDrop library
-- Can pass a value up to the next level with a value
-- value = "value:arg1:arg2:arg3:arg4:arg5"
-- inner element args overwrite the value args
function TT_TalentPresets_DewdropGen(level, value, opts)
    if value ~= nil then
        if string.find(value,":") then --accepts values after colons as arguments. Used to pass arguments a level up
            local parsed_args = {}
            local a = string.gfind(value, ':([^:]+)') --parses info after :
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

-- Best attempt at making a good solution for many types, and using function returns
-- for checked status. May use functions for tooltips more in the future.
-- But some adjusting may be required for some un-forseen scenarios
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
            if j.disabled and j.disabled(args1) then
                TT_TalentPresets_Dewdrop:AddLine(
                    'text', j.name,
                    'tooltipTitle', j.tooltipTitle or nil,
                    'tooltipText', j.disabledTooltip or nil,  
                    'textR', 0.4,
                    'textG', 0.4,
                    'textB', 0.4,
                    'disabled', j.disabled(args1),
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
                    'arg1', j.arg1 or args1 or nil,
                    'arg2', j.arg2 or args2 or nil,
                    'arg3', j.arg3 or args3 or nil,
                    'arg4', j.arg4 or args4 or nil,
                    'checked', j.checked(j.id) or nil,
                    'notCheckable', false
                )
            end
        elseif j.disabled and j.disabled(args1) then
            if j.checked ~= nil then
                TT_TalentPresets_Dewdrop:AddLine(
                    'text', j.name,
                    'tooltipTitle', j.tooltipTitle or nil,
                    'tooltipText', j.disabledTooltip or nil,  
                    'textR', 0.4,
                    'textG', 0.4,
                    'textB', 0.4,
                    'arg1', j.arg1 or args1 or nil,
                    'arg2', j.arg2 or args2 or nil,
                    'arg3', j.arg3 or args3 or nil,
                    'arg4', j.arg4 or args4 or nil,
                    'func', j.func,
                    'value', j.value,
                    'hasArrow', false,
                    'disabled', j.disabled(args1),
                    --'id',j.id or nil,
                    'checked', j.checked(j.id) or nil,
                    'notCheckable', j.notCheckable
                )     
            else
                TT_TalentPresets_Dewdrop:AddLine(
                    'text', j.name,
                    'tooltipTitle', j.tooltipTitle or nil,
                    'tooltipText', j.disabledTooltip or nil,  
                    'textR', 0.4,
                    'textG', 0.4,
                    'textB', 0.4,
                    'func', j.func,
                    'value', j.value,
                    'hasArrow', false,
                    'disabled', j.disabled(args1),
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
                'editBoxText', j.editBoxText(args1),
                'editBoxArg1', j.arg1 or args1 or nil,
                'editBoxFunc', j.editBoxFunc
            )
        elseif j.notCheckable and j.func == nil then -- titles
            TT_TalentPresets_Dewdrop:AddLine(
                'text', j.name,
                'tooltipTitle', j.tooltipTitle or nil,
                'tooltipText', j.tooltip or nil,  
                'textR', 0.1,
                'textG', 0.8,
                'textB', 0.1,
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

