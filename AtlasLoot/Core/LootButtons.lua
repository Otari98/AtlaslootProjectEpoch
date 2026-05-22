local AL = LibStub("AceLocale-3.0"):GetLocale("AtlasLoot")
local GREY = "|cff999999"
local RED = "|cffff0000"
local WHITE = "|cffFFFFFF"
local GREEN = "|cff1eff00"
local PURPLE = "|cff9F3FFF"
local BLUE = "|cff0070dd"
local ORANGE = "|cffFF8400"
local DEFAULT = "|cffFFd200"

local memory = {}
function AtlasLoot_GetEnchantLink(enchantID)
    if not enchantID then return end
    if memory[enchantID] then return memory[enchantID] end
    local link = nil
    local tooltip = AtlasLootScanTooltip or CreateFrame("GameTooltip", "AtlasLootScanTooltip", nil, "GameTooltipTemplate")
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink("enchant:"..enchantID);
    local text = AtlasLootScanTooltipTextLeft1:GetText()
    if text and text ~= "" then
        link = "|cffffd000|Henchant:"..enchantID.."|h["..text.."]|h|r"
    else
        link = GetSpellLink(enchantID)
    end
    memory[enchantID] = link
    return link
end

function AtlasLootTooltip_OnLoad(self)
    GameTooltip_OnLoad(self)
    self.shoppingTooltips = { ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 }
    -- Hook AtlasLootTooltip:GetItem() in this way so we can show comparison tooltip when hovering over crafting spells
    local m = getmetatable(self).__index
    local getitem = m.GetItem
    m.GetItem = function(self)
        local owner = self:GetOwner()
        if owner and owner.spellitemID and owner.spellitemID ~= "" and owner.spellitemID ~= 0 then
            local itemName, itemLink = GetItemInfo(owner.spellitemID)
            if itemName then
                return itemName, itemLink
            end
        end
        return getitem(self)
    end
end

--------------------------------------------------------------------------------
-- Item OnEnter
-- Called when a loot item is moused over
--------------------------------------------------------------------------------
function AtlasLootItem_OnEnter(self)
    local itemID = self.itemID
    if not (itemID and itemID ~= 0 and itemID ~= "") then return end

    local isSpell = string.sub(itemID, 1, 1) == "s"
    if not isSpell then
        local dkp, priority
        if AtlasLootDKPValues and AtlasLootClassPriority then
            local identifier = "Item"..itemID
            dkp = AtlasLootDKPValues[identifier]
            priority = AtlasLootClassPriority[identifier]
        else
            dkp = nil
            priority = nil
        end
        --Lootlink tooltips
        if AtlasLoot.db.profile.LootlinkTT then
            --If we have seen the item, use the game tooltip to minimise same name item problems
            AtlasLootTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 0)
            AtlasLootTooltip:SetHyperlink("item:"..itemID..":0:0:0")
            if GetItemInfo(itemID) then
                if AtlasLoot.db.profile.ItemIDs then
                    AtlasLootTooltip:AddLine(AL["ItemID:"].." "..itemID)
                end
                if self.droprate then
                    AtlasLootTooltip:AddLine(AL["Drop Rate: "]..self.droprate, 1, 1, 0)
                end
                if dkp and dkp ~= "" then
                    AtlasLootTooltip:AddLine(RED..dkp.." "..AL["DKP"], 1, 1, 0, 1)
                end
                if priority and priority ~= "" then
                    AtlasLootTooltip:AddLine(GREEN..AL["Priority:"].." "..priority, 1, 1, 0, 1)
                end
                if LootLink_AddItem then
                    local name, link, quality = GetItemInfo(itemID)
                    local r, g, b, color = GetItemQualityColor(quality)
                    LootLink_AddItem(name, itemID..":0:0:0", color)
                end
            else
                if LootLink_Database and LootLink_Database[itemID] then
                    LootLink_SetTooltip(AtlasLootTooltip, LootLink_Database[itemID][1], 1)
                else
                    LootLink_SetTooltip(AtlasLootTooltip, strsub(_G["AtlasLootItem_"..self:GetID().."_Name"]:GetText(), 11), 1)
                end
                if AtlasLoot.db.profile.ItemIDs then
                    AtlasLootTooltip:AddLine(AL["ItemID:"].." "..itemID)
                end
                if self.droprate then
                    AtlasLootTooltip:AddLine(AL["Drop Rate: "]..self.droprate, 1, 1, 0, 1)
                end
                if dkp and dkp ~= "" then
                    AtlasLootTooltip:AddLine(RED..dkp.." "..AL["DKP"], 1, 1, 0)
                end
                if priority and priority ~= "" then
                    AtlasLootTooltip:AddLine(GREEN..AL["Priority:"].." "..priority, 1, 1, 0)
                end
            end
            AtlasLootTooltip:Show()
            if IsShiftKeyDown() or (AtlasLoot.db.profile.EquipCompare and (not EquipCompare_RegisterTooltip or not EquipCompare_Enabled)) then
                GameTooltip_ShowCompareItem(AtlasLootTooltip, true)
            end
            --Item Sync tooltips
        elseif AtlasLoot.db.profile.ItemSyncTT then
            ItemSync:ButtonEnter()
            if AtlasLoot.db.profile.ItemIDs then
                GameTooltip:AddLine(AL["ItemID:"].." "..itemID)
            end
            if self.droprate then
                GameTooltip:AddLine(AL["Drop Rate: "]..self.droprate, 1, 1, 0)
            end
            if dkp and dkp ~= "" then
                GameTooltip:AddLine(RED..dkp.." "..AL["DKP"], 1, 1, 0)
            end
            if priority and priority ~= "" then
                GameTooltip:AddLine(GREEN..AL["Priority:"].." "..priority, 1, 1, 0)
            end
            GameTooltip:Show()
            if IsShiftKeyDown() or (AtlasLoot.db.profile.EquipCompare and (not EquipCompare_RegisterTooltip or not EquipCompare_Enabled)) then
                GameTooltip_ShowCompareItem(GameTooltip, true)
            end
            --Default game tooltips
        else
            AtlasLootTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 0)
            AtlasLootTooltip:SetHyperlink("item:"..itemID..":0:0:0")
            if GetItemInfo(itemID) then
                if AtlasLoot.db.profile.ItemIDs then
                    AtlasLootTooltip:AddLine(AL["ItemID:"].." "..itemID)
                end
                if self.droprate then
                    AtlasLootTooltip:AddLine(AL["Drop Rate: "]..self.droprate, 1, 1, 0)
                end
                if dkp and dkp ~= "" then
                    AtlasLootTooltip:AddLine(RED..dkp.." "..AL["DKP"], 1, 1, 0)
                end
                if priority and priority ~= "" then
                    AtlasLootTooltip:AddLine(GREEN..AL["Priority:"].." "..priority, 1, 1, 0)
                end
            end
            AtlasLootTooltip:Show()
            if IsShiftKeyDown() or (AtlasLoot.db.profile.EquipCompare and (not EquipCompare_RegisterTooltip or not EquipCompare_Enabled)) then
                GameTooltip_ShowCompareItem(AtlasLootTooltip, true)
            end
        end
        local _, _, quality = GetItemInfo(itemID)
        if quality then
            local r, g, b = GetItemQualityColor(quality)
            self.IconBorder:SetVertexColor(r, g, b)
        end
    else
        local spellID = string.sub(itemID, 2)
        local link = GetSpellLink(spellID)
        if link then
            AtlasLootTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 0)
            AtlasLootTooltip:SetHyperlink(link)
            if AtlasLoot.db.profile.ItemIDs then
                AtlasLootTooltip:AddLine(AL["SpellID:"].." "..spellID)
            end
            if self.spellitemID > 0 then
                if AtlasLoot.db.profile.ItemIDs then
                    AtlasLootTooltip:AddLine(AL["ItemID:"].." "..self.spellitemID)
                end
                if IsShiftKeyDown() or (AtlasLoot.db.profile.EquipCompare and (not EquipCompare_RegisterTooltip or not EquipCompare_Enabled)) then
                    GameTooltip_ShowCompareItem(AtlasLootTooltip, true)
                end
                local _, _, quality = GetItemInfo(self.spellitemID)
                if quality then
                    local r, g, b = GetItemQualityColor(quality)
                    self.IconBorder:SetVertexColor(r, g, b)
                end
            end
            AtlasLootTooltip:Show()
        end
    end
    CursorUpdate(self)
end

--------------------------------------------------------------------------------
-- Item OnLeave
-- Called when the mouse cursor leaves a loot item
--------------------------------------------------------------------------------
function AtlasLootItem_OnLeave(self)
    AtlasLootTooltip:Hide()
    GameTooltip:Hide()
    ShoppingTooltip1:Hide()
    ShoppingTooltip2:Hide()
    ResetCursor()
end

--------------------------------------------------------------------------------
-- Item OnClick
-- Called when a loot item is clicked on
--------------------------------------------------------------------------------
function AtlasLootItem_OnClick(self, button)
    if self.container then
        AtlasLoot_ShowContainerFrame(self)
        return
    end

    local itemID = self.itemID
    if not (itemID and itemID ~= 0 and itemID ~= "") then return end

    local isSpell = string.sub(itemID, 1, 1) == "s"
    if not isSpell then
        local itemName, itemLink = GetItemInfo(itemID)
        if button == "RightButton" then
            AtlasLootItemsFrame:Hide()
            AtlasLoot_ShowItemsFrame(AtlasLootItemsFrame.refresh[1], AtlasLootItemsFrame.refresh[2], AtlasLootItemsFrame.refresh[3])
        elseif IsShiftKeyDown() then
            ChatEdit_InsertLink(itemLink)
        elseif IsControlKeyDown() then
            DressUpItemLink(itemLink)
        elseif IsAltKeyDown() then
            if AtlasLootItemsFrame.refresh[1] == "WishList" then
                AtlasLoot_DeleteFromWishList(itemID)
            elseif AtlasLootItemsFrame.refresh[1] == "SearchResult" then
                AtlasLoot:GetOriginalDataFromSearchResult(itemID, self)
            elseif itemName then
                AtlasLoot_ShowWishListDropDown(itemID, string.gsub(self.itemTexture, "Interface\\Icons\\", ""), itemName, AtlasLoot_BossName:GetText(), AtlasLootItemsFrame.refreshOri[1].."|"..AtlasLootItemsFrame.refreshOri[2], self)
            end
        elseif self.sourcePage and (AtlasLootItemsFrame.refresh[1] == "SearchResult" or AtlasLootItemsFrame.refresh[1] == "WishList") then
            local dataID, dataSource = strsplit("|", self.sourcePage)
            if dataID and dataSource and AtlasLoot_IsLootTableAvailable(dataID) then
                AtlasLoot_ShowItemsFrame(dataID, dataSource, AtlasLoot_TableNames[dataID][1])
            end
        end
    else
        local spellID = string.sub(itemID, 2)
        if IsShiftKeyDown() then
            local link = AtlasLoot_GetEnchantLink(spellID)
            ChatEdit_InsertLink(link)
        elseif IsAltKeyDown() then
            if AtlasLootItemsFrame.refresh[1] == "WishList" then
                AtlasLoot_DeleteFromWishList(itemID)
            else
                local spellName = GetSpellInfo(spellID)
                AtlasLoot_ShowWishListDropDown(itemID, self.dressingroomID, "=ds="..spellName, "=ds="..AtlasLootItemsFrame.refresh[3], AtlasLootItemsFrame.refreshOri[1].."|"..AtlasLootItemsFrame.refreshOri[2], self)
            end
        elseif IsControlKeyDown() then
            DressUpItemLink("item:"..self.dressingroomID)
        elseif self.sourcePage and (AtlasLootItemsFrame.refresh[1] == "SearchResult" or AtlasLootItemsFrame.refresh[1] == "WishList") then
            local dataID, dataSource = strsplit("|", self.sourcePage)
            if dataID and dataSource and AtlasLoot_IsLootTableAvailable(dataID) then
                AtlasLoot_ShowItemsFrame(dataID, dataSource, AtlasLootItemsFrame.refresh[3])
            end
        end
    end
end

function AtlasLootMenuItem_OnClick(self)
    if self.container then
        AtlasLoot_ShowContainerFrame(self)
    else
        AtlasLoot_ShowBossLoot(self.lootpage)
    end
end

function AtlasLoot_ShowContainerFrame(self)
    local items = self.container
    if not items then return end

    if self ~= AtlasLootItemsFrameContainer.owner then
        AtlasLootItemsFrameContainer:Show()
        AtlasLootItemsFrameContainer.owner = self
    elseif AtlasLootItemsFrameContainer:IsVisible() then
        AtlasLootItemsFrameContainer:Hide()
        AtlasLootItemsFrameContainer.owner = nil
        return
    end

    if not AtlasLootItemsFrameContainer:IsVisible() and AtlasLootItemsFrameContainer.owner == self then
        AtlasLootItemsFrameContainer:Show()
    end

    for i = 1, #AtlasLootItemsFrameContainer.frames do
        AtlasLootItemsFrameContainer.frames[i]:Hide()
    end

    local row = 0
    local col = 0
    local buttonIndex = 1
    local maxCols = 1

    for i = 1, #items do
        col = 0
        for j = 1, #items[i] do
            if not AtlasLootItemsFrameContainer.frames[buttonIndex] then
                AtlasLootItemsFrameContainer.frames[buttonIndex] = CreateFrame("Button", "AtlasLootContainerItem"..buttonIndex, AtlasLootItemsFrameContainer, "AtlasLootContainerItemTemplate")
            end
            local itemButton = AtlasLootItemsFrameContainer.frames[buttonIndex]
            local itemID = items[i][j]
            local _, _, quality = GetItemInfo(itemID)
            local tex = GetItemIcon(itemID)
            local r, g, b = 1, 1, 1
            if quality then r, g, b = GetItemQualityColor(quality) end
            if not tex then tex = "Interface\\Icons\\INV_Misc_QuestionMark" end
            itemButton:SetPoint("TOPLEFT", AtlasLootItemsFrameContainer, (col * 35) + 5, -(row * 35) - 5)
            itemButton.IconBorder:SetVertexColor(r, g, b)
            itemButton.Icon:SetTexture(tex)
            itemButton.itemID = itemID
            itemButton.spellitemID = 0
            itemButton.dressingroomID = itemID
            itemButton.hasItem = IsEquippableItem(itemID)
            itemButton.itemTexture = tex
            itemButton.extra = ""
            itemButton:Show()
            col = col + 1
            if col > maxCols then maxCols = col end
            buttonIndex = buttonIndex + 1
        end
        row = row + 1
    end
    AtlasLootItemsFrameContainer:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -2, 2)
    AtlasLootItemsFrameContainer:SetWidth(16 + (maxCols * 35))
    AtlasLootItemsFrameContainer:SetHeight(16 + (row * 35))
end
