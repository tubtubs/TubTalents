local _G = getfenv(0)
--Utility function that returns a spellID for a talent given their tab/button id, and the next rank if available
-- TODO: Optimize, consider caching tab IDs for the played class for that session after first lookup
function TubTalents_GetTalentSpellID(tab,btn,reqRank)
    local tabName, texture, points, fileName = GetTalentTabInfo(tab);
    local name, iconTexture, tier, column, stagedRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab,btn);
    local rank = reqRank or stagedRank
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
    if err ~= nil then TubTalents_Out(err) end
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
function TubTalents_IsTalentAPreReq(tab, btn)
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
function TubTalents_GetMaxTier()
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

function TubTalents_Out(msg)
    DEFAULT_CHAT_FRAME:AddMessage(format("%s: %s","TT", msg))
end

--Mostly overloaded for sim mode
function TubTalents_GetTalentTabInfo(tab)
    local name, iconTexture, pointsSpent, fileName = TubTalents_OldGetTalentTabInfo(tab)
    if TubTalents_SimMode then
        pointsSpent=TubTalents_TalentPointsSpent[tab];
    else
        pointsSpent = pointsSpent + TubTalents_TalentPointsSpent[tab];
    end
    return name, iconTexture, pointsSpent, fileName
end

--Overloaded to return staged talents and sim mode
function TubTalents_GetTalentInfo(tab, btn)
    local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = TubTalents_OldGetTalentInfo(tab, btn);
    if TubTalents_SimMode then
        if TubTalents_StagedTalents[tab][btn] == nil then
            TubTalents_StagedTalents[tab][btn] = 0
        end
        return name, iconTexture, tier, column, TubTalents_StagedTalents[tab][btn], maxRank, isExceptional, meetsPrereq
    else
        if TubTalents_StagedTalents[tab][btn]~=nil then
            rank = rank+TubTalents_StagedTalents[tab][btn] 
        end
        return name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq
    end
end

--Overrides GetTalentPrereqs() returns:
--tier, column, isLearnable = GetTalentPrereqs( tabIndex , talentIndex[, inspect] );
function TubTalents_GetTalentPrereqs(tab, btn)
    --Call the old one, and return a different isLearnable? I guess so.
    tier, column, isLearnable = TubTalents_OldGetTalentPrereqs(tab, btn)
    if tier == nil then 
        return 
    end
    if isLearnable==nil then
        -- I need to translate the tier, column to tab, btn somehow?
        local i = TALENT_BRANCH_ARRAY[tier][column].id
        local preReq_btn = _G["TalentFrameTalent"..i]
        name, iconTexture, _, _, rank, maxRank, isExceptional, meetsPrereq = TubTalents_OldGetTalentInfo(tab,i);
        local t=0
        if TubTalents_StagedTalents[tab][i] ~= nil then
            t = rank + TubTalents_StagedTalents[tab][i]
        end
        if t == maxRank then
            isLearnable=1 -- its expecting 1 instead of true by default here, may as well stick to it.
        else
            isLearnable=nil
        end
    end    return tier, column, isLearnable
end

function TubTalents_PrintEachLine(s)
    for w in string.gfind(s, "([^\r\n]+)") do
        DEFAULT_CHAT_FRAME:AddMessage(w,1,1,1)
    end
end

function TubTalents_ToolTipAddLines(tooltip, index, num)
    for i=1, num do
        tooltip:AddLine("Error") -- just needs to be something so it doesn't get removed

        -- Shift all lines but title down addedLines times
        for i=tooltip:NumLines(), index,-1 do
            _G[tooltip:GetName() .. "TextLeft"..i]:SetFontObject(TubTalents_TooltipTextSmall)
            _G[tooltip:GetName() .. "TextLeft"..i]:SetTextColor(_G[tooltip:GetName() .. "TextLeft"..i-1]:GetTextColor())
            _G[tooltip:GetName() .. "TextLeft"..i]:SetText(_G[tooltip:GetName() .. "TextLeft"..i-1]:GetText())
            _G[tooltip:GetName() .. "TextLeft"..i]:SetWidth(_G[tooltip:GetName() .. "TextLeft"..i-1]:GetWidth())
            --Carefully check right texts
            if _G[tooltip:GetName() .. "TextRight"..i-1]:GetText() ~= nil then
                _G[tooltip:GetName() .. "TextRight"..i]:SetFontObject(TubTalents_TooltipTextSmall)
                _G[tooltip:GetName() .. "TextRight"..i]:SetTextColor(_G[tooltip:GetName() .. "TextRight"..i-1]:GetTextColor())
                _G[tooltip:GetName() .. "TextRight"..i]:SetText(_G[tooltip:GetName() .. "TextRight"..i-1]:GetText())
                _G[tooltip:GetName() .. "TextRight"..i]:SetWidth(_G[tooltip:GetName() .. "TextRight"..i-1]:GetWidth())
                _G[tooltip:GetName() .. "TextRight"..i]:Show()
                _G[tooltip:GetName() .. "TextRight"..i-1]:Hide()
                _G[tooltip:GetName() .. "TextRight"..i]:SetWidth(_G[tooltip:GetName() .. "TextRight"..i]:GetStringWidth())
            else
                _G[tooltip:GetName() .. "TextRight"..i]:SetText(nil)
                _G[tooltip:GetName() .. "TextRight"..i]:SetWidth(0)
                _G[tooltip:GetName() .. "TextRight"..i]:Hide()
            end
        end
    end
end