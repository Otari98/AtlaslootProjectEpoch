--[[
File containing all the Atlas replacement functions and the External API
]]

--Establish number of boss lines in the Atlas frame for scrolling
local BOSS_SCROLL_LIST = {}
local buttons = { "AtlasLootBossButtons", "AtlasLootWBBossButtons", "AtlasLootBattlegrounds" }

--[[
AtlasLoot_SetupForAtlas:
This function sets up the Atlas specific XML objects
]]
function AtlasLoot_SetupForAtlas()
    --Position the frame with the AtlasLoot version details in the Atlas frame
    AtlasLootInfo:ClearAllPoints()
    AtlasLootInfo:SetParent(AtlasFrame)
    AtlasLootInfo:SetPoint("TOPLEFT", "AtlasFrame", "TOPLEFT", 546, -3)

    --Anchor the bottom panel to the Atlas frame
    AtlasLootPanel:ClearAllPoints()
    AtlasLootPanel:SetParent(AtlasFrame)
    AtlasLootPanel:SetPoint("TOP", "AtlasFrame", "BOTTOM", 0, 9)

    --Anchor the loot table to the Atlas frame
    -- AtlasLootItemsFrame:Hide()
    AtlasLoot.AnchorPoint = AtlasLoot.AnchorAtlas
end

--[[
AtlasLootBoss_OnClick:
Invoked whenever a boss line in Atlas is clicked
Shows a loot page if one is associated with the button
]]
function AtlasLootBoss_OnClick(self)
    local zoneID = ATLAS_DROPDOWNS[AtlasOptions.AtlasType][AtlasOptions.AtlasZone]
    local id = self.originalIndex

    --If the loot table was already shown and boss clicked again, hide the loot table and fix boss list icons
    if self.selected then
        AtlasLootItemsFrame:Hide()
        AtlasLootItemsFrame.activeLootPage = nil
        AtlasLoot_AtlasScrollBar_Update()
    else
        local lootPage
        for _, value in ipairs(buttons) do
            local dataSource = _G[value]
            if dataSource and dataSource[zoneID] and dataSource[zoneID][id] and dataSource[zoneID][id] ~= "" then
                lootPage = dataSource[zoneID][id]
                break
            end
        end
        if lootPage then
            AtlasLootItemsFrame.activeLootPage = lootPage
            AtlasLoot_ShowBossLoot(lootPage)
            AtlasLoot_AtlasScrollBar_Update()
        end
    end

    --This has been invoked from Atlas, so we remove any claim external mods have on the loot table
    AtlasLootItemsFrame.externalBoss = nil

    --Hide the AtlasQuest frame if present so that the AtlasLoot items frame is not stuck under it
    if AtlasQuestInsideFrame then
        HideUIPanel(AtlasQuestInsideFrame)
    end
end


--[[
AtlasLoot_Atlas_OnShow:
Hooks Atlas_OnShow() to add extra setup routines that AtlasLoot needs for
integration purposes.
]]
function AtlasLoot_Atlas_OnShow()
    AtlasLoot_Refresh()
    --We don't want Atlas and the Loot Browser open at the same time, so the Loot Browser is close
    if AtlasLootDefaultFrame:IsShown() then
        AtlasLootDefaultFrame:Hide()
        AtlasLoot_SetupForAtlas()
    end
    --Call the Atlas function
    AtlasLoot.hooks.Atlas_OnShow()
    --If we were looking at a loot table earlier in the session, it is still
    --saved on the item frame, so restore it in Atlas
    if AtlasLootItemsFrame.activeLootPage ~= nil then
        AtlasLootItemsFrame:Show()
    end
    --Consult the saved variable table to see whether to show the bottom panel
    if AtlasLoot.db.profile.HidePanel == true then
        AtlasLootPanel:Hide()
    else
        AtlasLootPanel:Show()
    end
    AtlasLoot_AtlasScrollBar_Update()
    if AtlasOptions then
        AtlasFrame:SetMovable(not AtlasOptions.AtlasLocked)
    end
end

--[[
AtlasLoot_Refresh:
Replacement for Atlas_Refresh, required as the template for the boss buttons in Atlas is insufficient
Called whenever the state of Atlas changes
]]
function AtlasLoot_Refresh()
    -- Reset which loot page is 'current'
    AtlasLootItemsFrame.activeLootPage = nil
    AtlasLootItemsFrame:Hide()

    local zoneID = ATLAS_DROPDOWNS[AtlasOptions.AtlasType][AtlasOptions.AtlasZone]
    if AtlasLoot_ExtraText[zoneID] then
        for i = 1, #AtlasLoot_ExtraText[zoneID] do
            table.insert(AtlasMaps[zoneID], { AtlasLoot_ExtraText[zoneID][i] })
        end
        AtlasLoot_ExtraText[zoneID] = nil
    end

    -- Call original function
    AtlasLoot.hooks.Atlas_Refresh()

    for i = 1, ATLAS_NUM_LINES do
        local entry = _G["AtlasEntry"..i]
        if entry and not _G["AtlasEntry"..i.."_Loot"] then
            -- Add icon
            local icon = entry:CreateTexture("$parent_Loot", "OVERLAY")
            icon:SetWidth(16)
            icon:SetHeight(16)
            icon:SetPoint("RIGHT", entry, 0, 0)
            icon:SetTexture("Interface\\AddOns\\AtlasLoot\\Images\\silver")
            icon:Show()
            -- Add OnClick function
            entry:SetScript("OnClick", AtlasLootBoss_OnClick)
            -- Fit text and add highlight
            _G["AtlasEntry"..i.."_Text"]:SetWidth(310)
            entry:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            entry.selected = false
        end
    end
end

function AtlasLoot_Atlas_Search(text)
    local data = nil
    table.wipe(BOSS_SCROLL_LIST)

    if ATLAS_SEARCH_METHOD == nil then
        data = ATLAS_DATA
    else
        data = ATLAS_SEARCH_METHOD(ATLAS_DATA, text)
    end

    --populate the scroll frame entries list, the update func will do the rest
    local i = 1
    while (data[i] ~= nil) do
        ATLAS_SCROLL_LIST[i] = data[i][1]

        local j = 1
        if text ~= "" then
            -- Link the search results to their original indices
            while j <= #ATLAS_DATA and ATLAS_DATA[j][1] ~= data[i][1] do
                j = j + 1
            end
            BOSS_SCROLL_LIST[i] = j
        else
            BOSS_SCROLL_LIST[i] = i
        end

        i = i + 1
    end

    ATLAS_CUR_LINES = i - 1
end

function AtlasSimpleSearch(data, text)
    local new = {}
    local search_text = string.lower(text)
    for i = 1, #data do
        if string.find(string.lower(data[i][1]), search_text, 1, true) then
            table.insert(new, data[i])
        end
    end
    return new
end

--[[
AtlasLoot_AtlasScrollBar_Update:
Hooks the Atlas scroll frame.
Required as the Atlas function cannot deal with the AtlasLoot button template or the added Atlasloot entries
]]
function AtlasLoot_AtlasScrollBar_Update()
    AtlasLoot.hooks.AtlasScrollBar_Update()
    local zoneID = ATLAS_DROPDOWNS[AtlasOptions.AtlasType][AtlasOptions.AtlasZone]

    --Make note of how far in the scroll frame we are
    for i = 1, ATLAS_NUM_LINES do
        local index = i + FauxScrollFrame_GetOffset(AtlasScrollBar)
        local entry = _G["AtlasEntry"..i]
        local loot = _G["AtlasEntry"..i.."_Loot"]
        local originalIndex = BOSS_SCROLL_LIST[index] -- Original line number before filtering/sorting.
        if loot and originalIndex and index <= ATLAS_CUR_LINES then
            local lootPage
            for _, value in ipairs(buttons) do
                local dataSource = _G[value]
                if dataSource and dataSource[zoneID] and dataSource[zoneID][originalIndex] and dataSource[zoneID][originalIndex] ~= "" then
                    lootPage = dataSource[zoneID][originalIndex]
                    break
                end
            end
            if lootPage then
                loot:Show()
                entry:Enable()
                if lootPage == AtlasLootItemsFrame.activeLootPage then
                    loot:SetTexture("Interface\\AddOns\\AtlasLoot\\Images\\gold")
                    entry.selected = true
                else
                    loot:SetTexture("Interface\\AddOns\\AtlasLoot\\Images\\silver")
                    entry.selected = false
                end
            else
                loot:Hide()
                entry:Disable()
            end

            _G["AtlasEntry"..i.."_Text"]:SetText(ATLAS_SCROLL_LIST[index])
            entry.originalIndex = originalIndex
        end
    end
end

function AtlasLoot_Atlas_ToggleLock()
    AtlasLoot.hooks.Atlas_ToggleLock()
    AtlasFrame:SetMovable(not AtlasOptions.AtlasLocked)
end

--[[
AtlasLoot_ShowBossLoot(dataID):
dataID - Name of the loot table
This is the intended API for external mods to use for displaying loot pages.
This function figures out where the loot table is stored, then sends the relevant info to AtlasLoot_ShowItemsFrame
]]
function AtlasLoot_ShowBossLoot(dataID)
    if not AtlasLoot_IsLootTableAvailable(dataID) then return end

    local parent = AtlasLootItemsFrame:GetParent()
    --If the loot table is already being displayed, it is hidden and the current table selection cancelled
    if dataID == AtlasLootItemsFrame.externalBoss and parent ~= AtlasFrame and parent ~= AtlasLootDefaultFrame then
        AtlasLootItemsFrame.externalBoss = nil
        AtlasLootItemsFrame:Hide()
    else
        local dataSource = AtlasLoot_TableNames[dataID][2]
        local title = AtlasLoot_TableNames[dataID][1] or ""
        AtlasLootItemsFrame.externalBoss = dataID
        AtlasLoot_ShowItemsFrame(dataID, dataSource, title)
    end
end
