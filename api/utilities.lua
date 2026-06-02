local _G = getfenv(0)
--Utility function that returns a spellID for a talent given their tab/button id, and the next rank if available
-- TODO: Optimize, consider caching tab IDs for the played class for that session after first lookup
function TT_GetTalentSpellID(tab,btn,reqRank)
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