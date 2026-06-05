local _G = getfenv(0)
function TubTalents_InitFrameAdditions()
    --Buttons
    local myButton = CreateFrame("Button", "TalentFrameLearnButton", TalentFrame, "UIPanelButtonTemplate")
    myButton:SetHeight(15)
    myButton:SetWidth(60)
    myButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 55, -421)
    myButton:SetText(TubTalents_LEARN)
    myButton:SetScript("OnClick",TubTalents_LearnButton_OnClick)
    myButton:SetScript("OnEnter",TubTalents_TalentLearnButton_OnEnter)
    myButton:SetScript("OnLeave",function() GameTooltip:Hide() end)

    local myButton = CreateFrame("Button", "TalentFrameResetButton", TalentFrame, "UIPanelButtonTemplate")
    myButton:SetHeight(15)
    myButton:SetWidth(60)
    myButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 115, -421)
    myButton:SetText(TubTalents_RESET)
    myButton:SetScript("OnClick",TubTalents_ResetButton_OnClick)

    local myButton = CreateFrame("Button", "TalentFrameLevelPlanButton", TalentFrame, "UIPanelButtonTemplate")
    myButton:SetHeight(20)
    myButton:SetWidth(120)
    myButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 270, -24)
    myButton:SetText(TubTalents_LEVELINGPLANBTN)
    myButton:SetScript("OnClick",function() if TubTalents_StagedTalentsFrame:IsShown() then
        TubTalents_StagedTalentsFrame:Hide() TubTalent_Vars.ShowLevellingPlanFrame = false 
        else TubTalents_StagedTalentsFrame:Show() TubTalent_Vars.ShowLevellingPlanFrame = true
        end TubTalents_LevellingPlans_DewDrop:Close() end)

    local myButton = CreateFrame("Button", "TalentFramePresetsButton", TalentFrame, "UIPanelButtonTemplate")
    myButton:SetHeight(15)
    myButton:SetWidth(115)
    myButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 285, -42)
    myButton:SetText(TubTalents_PRESETSBTN)
    myButton:SetScript("OnClick",function() 
        if TubTalents_TalentPresets_Dewdrop:IsOpen() then
            TubTalents_TalentPresets_Dewdrop:Close();
        else
            TubTalents_TalentPresets_Dewdrop:Open(this);
        end
    end)

    --Checkboxes
    local myCheckButton = CreateFrame("CheckButton", "TalentFrameSimMode", TalentFrame, "UICheckButtonTemplate");
    myCheckButton:SetPoint("CENTER", TalentFrame, "TOPLEFT", 75, -42); -- Position it
    myCheckButton.tooltip = TubTalents_SIMMODETIP;
    myCheckButton:SetHeight(24)
    myCheckButton:SetWidth(24)
    _G["TalentFrameSimModeText"]:SetText(TubTalents_SIMMODE)
    myCheckButton:SetChecked(false);
    myCheckButton:SetScript("OnClick",TalentFrameSimMode_OnClick);

    --EditBoxes
    local myEditBox = CreateFrame("EditBox", "TalentFrameSimModePointsBox", TalentFrame,"InputBoxTemplate")
    myEditBox:SetHeight(80)
    myEditBox:SetWidth(20)
    myEditBox:SetPoint("CENTER", TalentFrame, "TOPLEFT", 225, -42); -- Position it
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
        TubTalents_TalentFrame_UpdateTalentPoints()
        this:ClearFocus()
    end)
    myEditBox:SetScript("OnEscapePressed", function(self)
        this:ClearFocus()
    end)
    myEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:SetText(TubTalents_ENTERTOSAVE);
        GameTooltip:Show();
    end)
    myEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end)
    
    --Text labels
    prompt = TalentFrame:CreateFontString("TalentFrameSimModePointsBoxPrompt", "OVERLAY", "GameFontNormalSmall")
    prompt:SetPoint("CENTER", myEditBox, "LEFT", -40, 0); -- Position it
    prompt:SetText(TubTalents_MAXPOINTS)
    prompt:Hide()

    prompt = TalentFrame:CreateFontString("TalentFrameEstimatedLevel", "OVERLAY", "GameFontNormalSmall")
    prompt:SetPoint("CENTER", TalentFrame, "TOPLEFT", 140, -24)
    prompt:SetText(format(TubTalents_ESTIMATEDLEVEL, TubTalents_MINLEVEL))
    prompt:SetFontObject("GameFontNormal")

    --Title frame
    local f = CreateFrame("Frame", nil, TalentFrame)
    f:SetFrameStrata("BACKGROUND")
    f:SetWidth(256) 
    f:SetHeight(32)

    local t = f:CreateTexture(nil, "BACKGROUND")
    t:SetTexture("Interface\\AddOns\\TubTalents\\txt\\header.tga")
    t:SetAllPoints(f)

    f.texture = t
    f:SetPoint("TOP", TalentFrame, "TOP", 0, 12); -- Position it
    --f:Show()
    f.text = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    f.text:SetAllPoints(f)
    f.text:SetText(TubTalents_ADDONFULLNAME)
    f.text:SetJustifyH("CENTER")
    f.text:SetFontObject("GameFontNormal")
    f:SetFrameStrata("HIGH")
    TalentFrameTitleText:SetText("") -- Blank out old title...
end

function TubTalents_FunctionOverloads()
    TalentFrameTalent_OnClick = TubTalents_TalentFrameTalent_OnClick
    TalentFrame_Update = TubTalents_TalentFrame_Update

    TubTalents_OldGetTalentInfo = GetTalentInfo
    GetTalentInfo = TubTalents_GetTalentInfo

    TubTalents_OldGetTalentPrereqs = GetTalentPrereqs
    GetTalentPrereqs = TubTalents_GetTalentPrereqs

    --TubTalents_OldTalentFrame_UpdateTalentPoints = TalentFrame_UpdateTalentPoints
    TalentFrame_UpdateTalentPoints = TubTalents_TalentFrame_UpdateTalentPoints
    
    TubTalents_OldGetTalentTabInfo = GetTalentTabInfo
    GetTalentTabInfo = TubTalents_GetTalentTabInfo
    TubTalents_OldTalentFrame_OnShow = TalentFrame_OnShow
    TalentFrame_OnShow = TubTalents_TalentFrame_OnShow
end


-- Talent Frame Functions --
function TubTalents_TalentFrame_OnShow()
    if TubTalent_Vars.ShowLevellingPlanFrame then
        TubTalents_StagedTalentsFrame:Show()
    else
        TubTalents_StagedTalentsFrame:Hide()
    end 
    TubTalents_OldTalentFrame_OnShow()
    TubTalents_RegenPlansDropdown()
    TubTalents_RegenPresetDropdown()
end

--Update functions (Mostly original code, overloaded)
function TubTalents_TalentFrame_Update()
	-- Setup Tabs
	local tab, name, iconTexture, pointsSpent, button;
	local numTabs = GetNumTalentTabs();
	for i=1, MAX_TALENT_TABS do
		tab = _G["TalentFrameTab"..i];
		if ( i <= numTabs ) then
			name, iconTexture, pointsSpent = GetTalentTabInfo(i);
			if ( i == PanelTemplates_GetSelectedTab(TalentFrame) ) then
				-- If tab is the selected tab set the points spent info
                --pointsSpent = pointsSpent + TubTalents_TalentPointsSpent[i];
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
                    _G["TalentFrameTalent"..i]:SetScript("OnMouseDown", TubTalents_TalentFrameTalent_OnClick)
                    _G["TalentFrameTalent"..i]:SetScript("OnEnter",TubTalents_TalentTooltip)
                    _G["TalentFrameTalent"..i]:SetScript("OnLeave",TubTalents_TalentTooltip_OnLeave)
					_G["TalentFrameTalent"..i.."Slot"]:SetVertexColor(0.1, 1.0, 0.1);
					_G["TalentFrameTalent"..i.."Rank"]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				else
                    _G["TalentFrameTalent"..i]:SetScript("OnClick", nil)
                    _G["TalentFrameTalent"..i]:SetScript("OnMouseDown", TubTalents_TalentFrameTalent_OnClick)                    
                    _G["TalentFrameTalent"..i]:SetScript("OnEnter",TubTalents_TalentTooltip)
                    _G["TalentFrameTalent"..i]:SetScript("OnLeave",TubTalents_TalentTooltip_OnLeave)
					_G["TalentFrameTalent"..i.."Slot"]:SetVertexColor(1.0, 0.82, 0);
					_G["TalentFrameTalent"..i.."Rank"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
				_G["TalentFrameTalent"..i.."RankBorder"]:Show();
				_G["TalentFrameTalent"..i.."Rank"]:Show();
			else
                _G["TalentFrameTalent"..i]:SetScript("OnClick", nil)
                _G["TalentFrameTalent"..i]:SetScript("OnMouseDown", TubTalents_TalentFrameTalent_OnClick)                
                _G["TalentFrameTalent"..i]:SetScript("OnEnter",TubTalents_TalentTooltip)
                _G["TalentFrameTalent"..i]:SetScript("OnLeave",TubTalents_TalentTooltip_OnLeave)
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
function TubTalents_TalentFrame_UpdateTalentPoints()
    local total = 0
    for i=1, TubTalents_MAX_TALENTS do
        total = total + TubTalents_TalentPointsSpent[i]
    end
    if total == 0 then
        TubTalents_PresetLoaded = false
    end
    if TubTalents_SimMode then
        TalentFrame.talentPoints = TubTalent_Vars.MaxTalentPoints - total
        TalentFrameTalentPointsText:SetText(TalentFrame.talentPoints);
    else
        local cp1, cp2 = UnitCharacterPoints("player");
        cp1 = cp1 - total
        TalentFrameTalentPointsText:SetText(cp1);
        TalentFrame.talentPoints = cp1;
    end
    TubTalents_StagedTalentsFrame_Update()
    TubTalents_TalentFrame_UpdateEstimatedLevel()
end

function TubTalents_TalentFrame_UpdateEstimatedLevel()
    local total = 0
    for i=1, TubTalents_MAX_TALENTS do
        local _, _, tabPoints = GetTalentTabInfo(i)
        total = total + tabPoints
    end
    TubTalents_StagedEstimatedLevel = TubTalents_MINLEVEL + total
    TalentFrameEstimatedLevel:SetText(format(TubTalents_ESTIMATEDLEVEL, TubTalents_StagedEstimatedLevel))
end

--Learns all staged talents
--Learns talents per tab, and then per 
function TubTalents_LearnButton_OnClick()
    for i=1, TubTalents_MAX_TALENTS do --iterate through tabs...
        local keys = {}
        local temp_tiers = {
        }
        for m=1, MAX_NUM_TALENT_TIERS do
            temp_tiers[m] = {}
        end
        for k,v in pairs (TubTalents_StagedTalents[i]) do
            local name, _, tier, _, rank, _,
            _, _ = GetTalentInfo(i,k);
            temp_tiers[tier][k] = v
        end

        for m=1, MAX_NUM_TALENT_TIERS do --iterate through tiers...
            for k,v in pairs(temp_tiers[m]) do
                local name, _, _, _, rank, _,
                _, _ = GetTalentInfo(i,k);
                TubTalents_Out(format(TubTalents_LEARNING,name, rank))
                --Need to check whats learned first so it doesn't rank too high...
                -- No I don't?
                --local _, _, _, _, oldRank, _, _, _ = TubTalents_OldGetTalentInfo(i, k);
                --rank = rank - oldRank
                if rank > 0 then
                    LearnTalentRank(i, k, rank)
                end
            end
        end
    end
    TubTalents_ResetButton_OnClick()
end

--Learn button tooltip
function TubTalents_TalentLearnButton_OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    GameTooltip:ClearLines()
    if TubTalents_SimMode then
        GameTooltip:AddLine(TubTalents_ERRSimMode, 1, 1, 1)
    end
    GameTooltip:Show()
end

--Resets all staged talents
function TubTalents_ResetButton_OnClick()
    TubTalents_TalentPointsSpent = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    } 
    TubTalents_StagedTalents = {
        [1] = {},
        [2] = {},
        [3] = {}
    }
    TubTalents_StagedLevellingPlan = {}
    TubTalents_StagedEstimatedLevel = TubTalents_MINLEVEL
    TubTalents_PresetLoaded = false
    TubTalents_TalentFrame_Update()
    TubTalents_TalentFrameButtons_OnUpdate()
end

--If any simulated points have been spent offer learning
--otherwise, disable button functionality and gray out
function TubTalents_TalentFrameButtons_OnUpdate()
    local found = 0 
    for i=1, TubTalents_MAX_TALENTS do
        if TubTalents_TalentPointsSpent[i] > 0 then
            found = 1
            break
        end
    end
    if found == 1 then
        if not TubTalents_SimMode then
            TalentFrameLearnButton:SetScript("OnClick",TubTalents_LearnButton_OnClick)
            TalentFrameLearnButton:GetNormalTexture():SetDesaturated(false)
            TalentFrameLearnButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
            TalentFrameLearnButtonText:SetTextColor(1, .8, 0)
        end
        TalentFrameResetButton:SetScript("OnClick",TubTalents_ResetButton_OnClick)
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
    TubTalents_TalentPresets_Dewdrop:Close()
end

--Sets up sim mode
--Resets simulated specs
--Hides learned specs, gives full points
function TalentFrameSimMode_OnClick()
    TubTalents_SimMode = not TubTalents_SimMode
    TubTalents_ResetButton_OnClick()
    TubTalents_StagedLevellingPlan = {}
    if TubTalents_SimMode then
        --TubTalents_WipeCurrentSpec()
        _G["TalentFrameSimModePointsBox"]:Show()
        _G["TalentFrameSimModePointsBoxPrompt"]:Show()
        TalentFrame.talentPoints = TubTalent_Vars.MaxTalentPoints
        TalentFrameTalentPointsText:SetText(TubTalent_Vars.MaxTalentPoints);
    else
        _G["TalentFrameSimModePointsBox"]:Hide()
        _G["TalentFrameSimModePointsBoxPrompt"]:Hide()
        TubTalents_TalentFrame_UpdateTalentPoints()
    end
    TubTalents_TalentFrame_Update()
    TubTalents_TalentFrameButtons_OnUpdate()
    TubTalents_StagedTalentsFrame_Update()
end

-- Talent Button baggage
--Checks if the calling button can be left clicked to spend points given the talent status
function TubTalents_TalentFrameTalentIsLeftClickable()
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
function TubTalents_TalentFrameTalentIsRightClickable()
    local rightClickable = false
    local tab = PanelTemplates_GetSelectedTab(TalentFrame)
    local btn = this:GetID()
    --local p_check, t_check, rank_check, req_check
    if TubTalents_StagedTalents[tab][btn] == nil then 
       return rightClickable
    end
    local _, _, tier, _, rank, _, 
    _, _ = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), btn);

    -- Needs to have points in it
    if rank ~= 0 then
        -- tier check maxtier, or 5 points in tier
        local maxTier = TubTalents_GetMaxTier()
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
            local isPreReq, _, _, preReqRank = TubTalents_IsTalentAPreReq(tab,btn)
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

--Left click function, stages specs and pretends to spend points
function TubTalents_TalentFrameTalent_OnLeftClick()
    tab = PanelTemplates_GetSelectedTab(TalentFrame)
    btn = this:GetID()
    --Keep track of points
    TalentFrame.talentPoints = TalentFrame.talentPoints - 1
    --Keep track of which talent was clicked...
    TubTalents_TalentPointsSpent[tab] = TubTalents_TalentPointsSpent[tab] + 1
    if TubTalents_SimMode then
        name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = TubTalents_GetTalentInfo(tab,btn);
            if TubTalents_StagedTalents[tab][btn] ~= nil then
            if TubTalents_StagedTalents[tab][btn] + 1 <= maxRank then
                TubTalents_StagedTalents[tab][btn] = TubTalents_StagedTalents[tab][btn] + 1
            end
        elseif rank + 1 <= maxRank then
            TubTalents_StagedTalents[tab][btn] = 1
        end
    else
        name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = TubTalents_OldGetTalentInfo(tab,btn);
        if TubTalents_StagedTalents[tab][btn] ~= nil then
            if TubTalents_StagedTalents[tab][btn] + rank + 1 <= maxRank then
                TubTalents_StagedTalents[tab][btn] = TubTalents_StagedTalents[tab][btn] + 1
            end
        elseif rank + 1 <= maxRank then
            TubTalents_StagedTalents[tab][btn] = 1
        end
    end
    rank = rank  + 1

    --Add to levelling plan...
    TubTalents_TalentFrame_UpdateEstimatedLevel()
    if (RQ_GetVersion and SUPERWOW_STRING) and not TubTalents_FakeNoMods then
        spellID, _ = TubTalents_GetTalentSpellID(tab, btn)
    else
        spellID = 0 -- Disabled...
    end
    if TubTalents_SimMode then -- Only allow creating a levelling plan in sim mode
        TubTalents_StagedLevellingPlan[TubTalents_StagedEstimatedLevel] = {
            tab = tab,
            tabName = GetTalentTabInfo(tab),
            btnID = btn,
            rank = rank,
            icon = iconTexture,
            spellID = spellID,
            name = name,
        }
    end

    TubTalents_TalentFrame_Update()
    TubTalents_TalentTooltip()
    TubTalents_TalentFrameButtons_OnUpdate()
end

--right click function, removes staged specs and pretends to refund points
function TubTalents_TalentFrameTalent_OnRightClick()
    tab = PanelTemplates_GetSelectedTab(TalentFrame)
    btn = this:GetID()
    local _, _, _, _, rank, 
    _, _, _ = GetTalentInfo(tab, btn);
    -- probably redudant with prior safety check
    if TubTalents_StagedTalents[tab][btn] ~= nil then 
        if TubTalents_StagedTalents[tab][btn] - 1 >= 0 then
            TubTalents_StagedTalents[tab][btn] = TubTalents_StagedTalents[tab][btn] - 1
            TalentFrame.talentPoints = TalentFrame.talentPoints + 1
            TubTalents_TalentPointsSpent[tab] = TubTalents_TalentPointsSpent[tab] - 1
        end
    end
    -- remove from levelling plan...
    -- find a match on: tab, btn, rank, and remove it.
    local found = 0
    for k, v in pairs(TubTalents_StagedLevellingPlan) do
        --Need to look for that button id... It will be in here.
        if v.btnID == btn and v.tab == tab and v.rank == rank then
            found = k 
            break
        end
    end
    TubTalents_StagedLevellingPlan[found] = nil -- removed it...
    local i = found
    -- Now need to re-do all the following levels...
    while TubTalents_StagedLevellingPlan[i + 1] ~= nil do
        TubTalents_StagedLevellingPlan[i] = TubTalents_StagedLevellingPlan[i + 1]
        i = i+1
    end
    TubTalents_TalentFrame_UpdateEstimatedLevel()
    TubTalents_TalentFrame_Update()
    TubTalents_TalentTooltip()
    TubTalents_TalentFrameButtons_OnUpdate()
end

--shift click, links the current rank of the spell in chat
--if it isn't learned yet links rank 1
function TubTalents_TalentFrameTalent_OnShiftClick()
    tab = PanelTemplates_GetSelectedTab(TalentFrame)
    btn = this:GetID()
    local name, _, _, _, rank, _, 
    _, _ = GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), btn)
    if rank == 0 then rank = 1 end
    local txt = DEFAULT_CHAT_FRAME.editBox:GetText()
    local spellId = TubTalents_GetTalentSpellID(tab , btn)
    local link = format(TubTalents_CHATLINKFORMAT,spellId, name, rank)
    txt = format("%s %s",txt, link)
    DEFAULT_CHAT_FRAME.editBox:SetText(txt)
end

-- Handler for clicking talents
function TubTalents_TalentFrameTalent_OnClick()
    if IsShiftKeyDown() then
        TubTalents_TalentFrameTalent_OnShiftClick()
        return
    end
    if arg1 == "LeftButton" and TubTalents_TalentFrameTalentIsLeftClickable() then
        TubTalents_TalentFrameTalent_OnLeftClick()
        TubTalents_StagedTalentsFrame_Update()
    elseif arg1 == "RightButton" and TubTalents_TalentFrameTalentIsRightClickable() then
        TubTalents_TalentFrameTalent_OnRightClick()
        TubTalents_StagedTalentsFrame_Update()
    --elseif arg1 == "RightButton" and not TubTalents_TalentFrameTalentIsRightClickable() then
        --TubTalents_Out("Can't remove points from this talent")
    end
    TubTalents_TalentPresets_Dewdrop:Close()
end

--Overloaded Talent button tooltip
function TubTalents_TalentTooltip_OnLeave()
    for i=1, TubTalents_TalentTooltipFrame:NumLines() do --Wipe right text, since it doesnt by default
        _G["TubTalents_TalentTooltipFrameTextRight"..i]:SetText(nil)
    end
    TubTalents_TalentTooltipFrame:Hide();
    TubTalents_NextTalentTooltipFrame:Hide();
end

-- SpellID lookup is clumsy and stupid, lets bust out the talent DBC lookup.
-- DBC: Talent.dbc Need: tierID, columnIndex which is returned by GetTalentInfo. But TalentTabID?
-- DBC: TalentTab.dbc Need: TalentTabID, using Name? 
function TubTalents_TalentTooltip()
    btnID = this:GetID()
    tab = TalentFrame.selectedTab
    local spellId1, spellId2 = TubTalents_GetTalentSpellID(tab,btnID)
    local tabName, _, _, _ = GetTalentTabInfo(tab); -- Might need to override to keep track over simulated points spent
    local name, _, tier, _, rank, maxRank, _, _ = GetTalentInfo(tab,btnID);
    
    --Setup Tooltip
    TubTalents_TalentTooltip_OnLeave() -- hide first to clear, just in case
    TubTalents_TalentTooltipFrame:SetOwner(this, "ANCHOR_RIGHT");
    TubTalents_TalentTooltipFrame:SetHyperlink("enchant:"..spellId1);
    --staging rank
    local addlines = {format(TubTalents_TalentTipRank,rank,maxRank)}
    --staging tooltip for tier requirement
    local pointsReq = (tier-1)*5
    if ( ( pointsReq <= TalentFrame.pointsSpent ) ) then
        tierUnlocked = 1;
    else
        tierUnlocked = nil;
    end
    if tierUnlocked == nil then
        table.insert(addlines, format(TubTalents_TalentTipTier, pointsReq, tabName))
    end
    local preReqTier, preReqColumn, preReqIsLearnable = TubTalents_GetTalentPrereqs(tab,btnID)
    --staging tooltip for pre-req
    if preReqTier~=nil and preReqIsLearnable ~= 1 then
        local i = TALENT_BRANCH_ARRAY[preReqTier][preReqColumn].id
        local preReqName, _, _, _, _, preReqMaxRank, _, _ = GetTalentInfo(tab,i)
        table.insert(addlines, format(TubTalents_TalentTipPreReq,preReqMaxRank,preReqName))
    end
    _G["TubTalents_TalentTooltipFrameTextLeft1"]:SetFontObject(TubTalents_TooltipText)
    for i=1, getn(addlines) do
        TubTalents_TalentTooltipFrame:AddLine("Error") -- just needs to be something so it doesn't get removed

        -- Shift all lines but title down addedLines times
        for i=TubTalents_TalentTooltipFrame:NumLines(), 2,-1 do
            _G["TubTalents_TalentTooltipFrameTextLeft"..i]:SetFontObject(TubTalents_TooltipTextSmall)
            _G["TubTalents_TalentTooltipFrameTextLeft"..i]:SetTextColor(_G["TubTalents_TalentTooltipFrameTextLeft"..i-1]:GetTextColor())
            _G["TubTalents_TalentTooltipFrameTextLeft"..i]:SetText(_G["TubTalents_TalentTooltipFrameTextLeft"..i-1]:GetText())
            _G["TubTalents_TalentTooltipFrameTextLeft"..i]:SetWidth(_G["TubTalents_TalentTooltipFrameTextLeft"..i-1]:GetWidth())
            --Carefully check right texts
            if _G["TubTalents_TalentTooltipFrameTextRight"..i-1]:GetText() ~= nil then
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:SetFontObject(TubTalents_TooltipTextSmall)
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:SetTextColor(_G["TubTalents_TalentTooltipFrameTextRight"..i-1]:GetTextColor())
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:SetText(_G["TubTalents_TalentTooltipFrameTextRight"..i-1]:GetText())
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:SetWidth(_G["TubTalents_TalentTooltipFrameTextRight"..i-1]:GetWidth())
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:Show()
                _G["TubTalents_TalentTooltipFrameTextRight"..i-1]:Hide()
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:SetWidth(_G["TubTalents_TalentTooltipFrameTextRight"..i]:GetStringWidth())
            else
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:SetText(nil)
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:SetWidth(0)
                _G["TubTalents_TalentTooltipFrameTextRight"..i]:Hide()
            end
        end
    end
    -- Add staged newlines to the tooltip, after the talent name
    for i=2, getn(addlines)+1 do
        _G["TubTalents_TalentTooltipFrameTextLeft"..i]:SetText(addlines[i-1])
        _G["TubTalents_TalentTooltipFrameTextLeft"..i]:SetWidth(
            _G["TubTalents_TalentTooltipFrameTextLeft"..i]:GetStringWidth()
        )
    end

    --Setup next rank tooltip (if relevant)
    if rank ~=0 and rank ~= maxRank then
        t=""
        TubTalents_NextTalentTooltipFrame:SetOwner(TubTalents_TalentTooltipFrame, "ANCHOR_BOTTOM");
        TubTalents_NextTalentTooltipFrame:SetHyperlink("enchant:"..spellId2);
        for i=2, 8 do
            _G["TubTalents_NextTalentTooltipFrameTextLeft"..i]:SetFontObject(TubTalents_TooltipTextSmall)
        end
        TubTalents_NextTalentTooltipFrameTextLeft1:SetFontObject(TubTalents_TooltipTextSmall)
        TubTalents_NextTalentTooltipFrameTextLeft1:SetText(TubTalents_TalentTipNextRank)
    end
    -- Add click to stage/remove tooltips
    if TubTalents_TalentFrameTalentIsLeftClickable() then
        if rank ~=0 and rank ~= maxRank then
            TubTalents_NextTalentTooltipFrame:AddLine(TubTalents_TalentTipLeftClick)
            n = TubTalents_NextTalentTooltipFrame:NumLines()
            _G["TubTalents_NextTalentTooltipFrameTextLeft"..n]:SetFontObject(TubTalents_TooltipTextSmall)
        else
            TubTalents_TalentTooltipFrame:AddLine(TubTalents_TalentTipLeftClick)
            n = TubTalents_TalentTooltipFrame:NumLines()
            _G["TubTalents_TalentTooltipFrameTextLeft"..n]:SetFontObject(TubTalents_TooltipTextSmall)
        end
    end
    if TubTalents_TalentFrameTalentIsRightClickable() then
        if rank ~=0 and rank ~= maxRank then
            TubTalents_NextTalentTooltipFrame:AddLine(TubTalents_TalentTipRightClick)
            n = TubTalents_NextTalentTooltipFrame:NumLines()
            _G["TubTalents_TalentTooltipFrameTextLeft"..n]:SetFontObject(TubTalents_TooltipTextSmall)
        else
            TubTalents_TalentTooltipFrame:AddLine(TubTalents_TalentTipRightClick)
            n = TubTalents_TalentTooltipFrame:NumLines()
            _G["TubTalents_TalentTooltipFrameTextLeft"..n]:SetFontObject(TubTalents_TooltipTextSmall)
        end
    end
    TubTalents_TalentTooltipFrame:Show()
    TubTalents_NextTalentTooltipFrame:Show()
    TubTalents_NextTalentTooltipFrame:ClearAllPoints()
    TubTalents_NextTalentTooltipFrame:SetPoint("TOPLEFT", TubTalents_TalentTooltipFrame, "BOTTOMLEFT", 0, 0)
end