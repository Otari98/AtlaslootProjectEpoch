--[[
This file contains all the Atlas specific functions
]]

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
    AtlasLootItemsFrame:Hide()
    AtlasLoot.AnchorPoint = AtlasLoot.AnchorAtlas
end

--[[
AtlasLootBoss_OnClick:
Invoked whenever a boss line in Atlas is clicked
Shows a loot page if one is associated with the button
]]
local buttons = { AtlasLootBossButtons, AtlasLootWBBossButtons, AtlasLootBattlegrounds }
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
        for _, dataSource in ipairs(buttons) do
            if dataSource[zoneID] and dataSource[zoneID][id] and dataSource[zoneID][id] ~= "" then
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
