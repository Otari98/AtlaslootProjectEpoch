--[[
Atlasloot Enhanced
Author Daviesh
Loot browser associating loot with instance bosses

Functions:
AtlasLootItemsFrame_OnEvent(event)
AtlasLoot_ShowMenu()
AtlasLootOptions_Toggle()
AtlasLootItemsFrame_OnLoad()
AtlasLootBoss_OnClick()
AtlasLoot_ShowItemsFrame()
AtlasLoot_SetupForAtlas()
AtlasLoot_SetItemInfoFrame()
AtlasLootMenuItem_OnClick()
AtlasLoot_NavButton_OnClick()
AtlasLoot_HeroicModeToggle()
AtlasLoot_IsLootTableAvailable(dataID)
AtlasLoot_GetLODModule(dataSource)
AtlasLoot_LoadAllModules()
AtlasLoot_ShowQuickLooks(button)
AtlasLoot_RefreshQuickLookButtons()
AtlasLoot_AddTooltip(frameb, tooltiptext)
]]

AtlasLoot = LibStub("AceAddon-3.0"):NewAddon("AtlasLoot")

--Instance required libraries
local BabbleBoss = AtlasLoot_GetLocaleLibBabble("LibBabble-Boss-3.0")
local BabbleEpoch = AtlasLoot_GetLocaleLibBabble("LibBabble-Epoch-3.0")
local AL = LibStub("AceLocale-3.0"):GetLocale("AtlasLoot")

--Establish version number and compatible version of Atlas
local EPOCH_VERSION_MAJOR = "1"
local EPOCH_VERSION_MINOR = "13"
local EPOCH_VERSION_BOSSES = "2"

local VERSION_MAJOR = "5"
local VERSION_MINOR = "11"
local VERSION_BOSSES = "04"

ATLASLOOT_VERSION = "|cffFF8400AtlasLoot Epoch v"..EPOCH_VERSION_MAJOR.."."..EPOCH_VERSION_MINOR.."."..EPOCH_VERSION_BOSSES.."|r"
--Now allows for multiple compatible Atlas versions.  Always put the newest first
ATLASLOOT_CURRENT_ATLAS = { "1.17.1", "1.17.0" }
ATLASLOOT_PREVIEW_ATLAS = { "1.17.3", "1.17.2" }

ATLASLOOT_POSITION = AL["Position:"]
ATLASLOOT_DEBUGMESSAGES = false
ATLASLOOT_FILTER_ENABLE = false

--Standard indent to line text up with Atlas text
ATLASLOOT_INDENT = "   "

--Make the Dewdrop menu in the standalone loot browser accessible here
AtlasLoot_Dewdrop = AceLibrary("Dewdrop-2.0")
AtlasLoot_DewdropSubMenu = AceLibrary("Dewdrop-2.0")

--Variable to cap debug spam
ATLASLOOT_DEBUGSHOWN = false

-- Colours stored for code readability
local GREY = "|cff999999"
local RED = "|cffff0000"
local WHITE = "|cffFFFFFF"
local GREEN = "|cff1eff00"
local PURPLE = "|cff9F3FFF"
local BLUE = "|cff0070dd"
local ORANGE = "|cffFF8400"

--Set the default anchor for the loot frame to the Atlas frame
AtlasLoot.AnchorDefault = { "TOPLEFT", "AtlasLootDefaultFrame", "TOPLEFT", 45, -88 }
AtlasLoot.AnchorAtlas = { "TOPLEFT", "AtlasFrame", "TOPLEFT", 18, -84 }
AtlasLoot.AnchorAlphaMap = { "TOPLEFT", "AlphaMapAlphaMapFrame", "TOPLEFT", 0, 0 }
AtlasLoot.AnchorPoint = AtlasLoot.AnchorDefault

--Variables to hold hooked Atlas functions
AtlasLoot.hooks = {}

AtlasLootCharDB = {}

local AtlasLootDBDefaults = {
	profile = {
		SavedTooltips = {},
		SafeLinks = true,
		DefaultTT = true,
		LootlinkTT = false,
		ItemSyncTT = false,
		EquipCompare = false,
		Opaque = false,
		ItemIDs = false,
		ItemSpam = false,
		MinimapButton = false,
		FuBarAttached = true,
		FuBarText = true,
		FuBarIcon = true,
		HidePanel = false,
		LastBoss = "EmptyTable",
		HeroicMode = false,
		BigraidHeroic = false,
		Bigraid = false,
		AtlasLootVersion = "1",
		AtlasNaggedVersion = "",
		FuBarPosition = 1,
		LoadAllLoDStartup = false,
		PartialMatching = true,
		MatchItemNames = true,
		MatchDescriptors = true,
		LootBrowserStyle = 1,
		CraftingLink = 1,
		MinimapButtonAngle = 240,
		MinimapButtonRadius = 75,
		LootBrowserScale = 1.0,
		SearchOn = {
			All = true,
		},
		AtlasType = "Release",
	}
}

AtlasLoot_MenuList = {
	"PVPSET",
	"PVP70RepSET",
	"ARENASET",
	"ARENA2SET",
	"ARENA3SET",
	"ARENA4SET",
}

-- Popup Box for first time users
StaticPopupDialogs["ATLASLOOT_SETUP"] = {
	text = AL["Welcome to Atlasloot Enhanced.  Please take a moment to set your preferences."],
	button1 = AL["Setup"],
	OnAccept = function()
		AtlasLootOptions_Toggle()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

--Popup Box for an old version of Atlas
StaticPopupDialogs["ATLASLOOT_OLD_ATLAS"] = {
	text = AL["It has been detected that your version of Atlas does not match the version that Atlasloot is tuned for ("]..ATLASLOOT_CURRENT_ATLAS[1].."/"..ATLASLOOT_PREVIEW_ATLAS[1]..BabbleEpoch[").  Depending on changes, there may be the occasional error, so please visit https://github.com/reneas/AtlaslootProjectEpoch/tree/main as soon as possible to update."],
	button1 = AL["OK"],
	OnAccept = function()
		DEFAULT_CHAT_FRAME:AddMessage(BLUE..AL["AtlasLoot"]..": "..RED..AL["Incompatible Atlas Detected"])
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

--Enable the use of /al or /atlasloot to open the loot browser
SLASH_ATLASLOOT1 = "/atlasloot"
SLASH_ATLASLOOT2 = "/al"

SlashCmdList["ATLASLOOT"] = function(msg)
	if msg == AL["reset"] then
		AtlasLoot_Reset("frames")
	elseif msg == AL["options"] then
		AtlasLootOptions_Toggle()
	else
		AtlasLootDefaultFrame:Show()
	end
end

--[[
AtlasLootItemsFrame_OnLoad:
Performs inital setup of the mod and registers it for further setup when
the required resources are in place
]]
function AtlasLootItemsFrame_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterForDrag("LeftButton")
	self.time = nil
	self.queue = {}
	self.refreshCount = 0
	AtlasLootItemsFrame_CloseButton:HookScript("OnClick", AtlasLootItemsFrame_OnCloseButton)
end

--[[
AtlasLootItemsFrame_OnEvent(event):
event - Name of the event, passed from the API
Invoked whenever a relevant event is detected by the engine.  The function then
decides what action to take depending on the event.
]]
function AtlasLootItemsFrame_OnEvent(self, event, arg1)
	if arg1 ~= "AtlasLoot" then return end

	self:UnregisterEvent("ADDON_LOADED")

	local AtlasCheck = false
	AtlasLoot.db = LibStub("AceDB-3.0"):New("AtlasLootDB")
	AtlasLoot.db:RegisterDefaults(AtlasLootDBDefaults)
	if not AtlasLootCharDB then AtlasLootCharDB = {} end
	if not AtlasLootCharDB["WishList"] then AtlasLootCharDB["WishList"] = {} end
	if not AtlasLootCharDB["QuickLooks"] then AtlasLootCharDB["QuickLooks"] = {} end
	if not AtlasLootCharDB["SearchResult"] then AtlasLootCharDB["SearchResult"] = {} end
	if not AtlasLoot.db.profile.LastBoss then AtlasLoot.db.profile.LastBoss = "EmptyTable" end
	if AtlasLoot_TableNames then
		AtlasLoot_TableNames["EmptyTable"] = { AL["Select a Loot Table..."], "Menu" }
		AtlasLoot_TableNames["EmptyInstance"] = { "AtlasLoot", "AtlasLootFallback" }
		AtlasLoot_TableNames["AtlasLootFallback"] = { "AtlasLoot", "AtlasLootFallback" }
	end
	if AtlasLoot_Data then
		AtlasLoot_Data["EmptyTable"] = {}
	end
	--Figure out if it is a compatible Atlas version
	for i = 1, #ATLASLOOT_CURRENT_ATLAS do
		if ATLAS_VERSION == ATLASLOOT_CURRENT_ATLAS[i] then
			AtlasCheck = true
			AtlasLoot.db.profile.AtlasType = "Release"
		end
	end
	for i = 1, #ATLASLOOT_PREVIEW_ATLAS do
		if ATLAS_VERSION == ATLASLOOT_PREVIEW_ATLAS[i] then
			AtlasCheck = true
			AtlasLoot.db.profile.AtlasType = "Preview"
		end
	end
	if AtlasCheck == false then
		AtlasLoot.db.profile.AtlasType = "Unknown"
	end
	--Set up options frame
	AtlasLootOptions_OnLoad()
	AtlasLoot_CreateOptionsInfoTooltips()
	--Legacy code for those using the ultimately failed attempt at making Atlas load on demand
	if AtlasButton_LoadAtlas then
		AtlasButton_LoadAtlas()
	end
	--Hook the necessary Atlas functions
	AtlasLoot.hooks.Atlas_Refresh = Atlas_Refresh
	AtlasLoot.hooks.Atlas_OnShow = Atlas_OnShow
	AtlasLoot.hooks.AtlasScrollBar_Update = AtlasScrollBar_Update
	AtlasLoot.hooks.Atlas_ToggleLock = Atlas_ToggleLock
	Atlas_Refresh = AtlasLoot_Refresh
	Atlas_OnShow = AtlasLoot_Atlas_OnShow
	AtlasScrollBar_Update = AtlasLoot_AtlasScrollBar_Update
	Atlas_ToggleLock = AtlasLoot_Atlas_ToggleLock
	-- Replace search wrapper function
	Atlas_Search = AtlasLoot_Atlas_Search
	if not AtlasLoot.db.profile.LootBrowserStyle then
		AtlasLoot.db.profile.LootBrowserStyle = 1
	end
	--Set visual style for the loot browser
	if not AtlasLoot.db.profile.CraftingLink then
		AtlasLoot.db.profile.CraftingLink = 1
	end
	if AtlasLoot.db.profile.LootBrowserStyle == 1 then
		AtlasLoot_SetNewStyle("new")
	else
		AtlasLoot_SetNewStyle("old")
	end
	--Disable options that don't have the supporting mods
	if not LootLink_SetTooltip and AtlasLoot.db.profile.LootlinkTT == true then
		AtlasLoot.db.profile.LootlinkTT = false
		AtlasLoot.db.profile.DefaultTT = true
	end
	if not ItemSync and AtlasLoot.db.profile.ItemSyncTT == true then
		AtlasLoot.db.profile.ItemSyncTT = false
		AtlasLoot.db.profile.DefaultTT = true
	end
	--If using an opaque items frame, change the alpha value of the backing texture
	if AtlasLoot.db.profile.Opaque then
		AtlasLootItemsFrame_Background:SetTexture(0, 0, 0, 1)
	else
		AtlasLootItemsFrame_Background:SetTexture(0, 0, 0, 0.65)
	end
	--If Atlas is installed, set up for Atlas
	if AtlasFrame then
		AtlasLoot_SetupForAtlas()
		--If a first time user, set up options
		if AtlasLoot.db.profile.AtlasLootVersion == nil or tonumber(AtlasLoot.db.profile.AtlasLootVersion) < 40500 then
			AtlasLoot.db.profile.SafeLinks = true
			AtlasLoot.db.profile.AllLinks = false
			AtlasLoot.db.profile.AtlasLootVersion = VERSION_MAJOR..VERSION_MINOR..VERSION_BOSSES
			StaticPopup_Show("ATLASLOOT_SETUP")
		end
		--If not the expected Atlas version, nag the user once
		if AtlasLoot.db.profile.AtlasType == "Unknown" and AtlasLoot.db.profile.AtlasNaggedVersion ~= ATLAS_VERSION then
			StaticPopup_Show("ATLASLOOT_OLD_ATLAS")
			AtlasLoot.db.profile.AtlasNaggedVersion = ATLAS_VERSION
		end
		if AtlasLoot.db.profile.AtlasType == "Preview" then
			AtlasLootBossButtons = AtlasLootNewBossButtons
		end
		AtlasLoot.hooks.Atlas_Refresh()
	end
	--Check and migrate old WishList entry format to the newer one
	if (AtlasLootCharDB.AtlasLootVersion == nil or tonumber(AtlasLootCharDB.AtlasLootVersion) < 100001) and AtlasLootCharDB and AtlasLootCharDB["WishList"] and #AtlasLootCharDB["WishList"] ~= 0 then
		--Check if we really need to do a migration since it will load all modules
		--We also create a helper table here which store IDs that need to search for
		local idsToSearch = {}
		for i = 1, #AtlasLootCharDB["WishList"] do
			if AtlasLootCharDB["WishList"][i][1] > 0 and not AtlasLootCharDB["WishList"][i][5] then
				tinsert(idsToSearch, i, AtlasLootCharDB["WishList"][i][1])
			end
		end
		if #idsToSearch > 0 then
			--Let's do this
			AtlasLoot_LoadAllModules()
			for _, dataSource in ipairs(AtlasLoot_SearchTables) do
				if AtlasLoot_Data[dataSource] then
					for dataID, lootTable in pairs(AtlasLoot_Data[dataSource]) do
						for _, entry in ipairs(lootTable) do
							for k, v in pairs(idsToSearch) do
								if entry[1] == v then
									AtlasLootCharDB["WishList"][k][5] = dataID.."|"..dataSource
									break
								end
							end
						end
					end
				end
			end
		end
		AtlasLootCharDB.AtlasLootVersion = VERSION_MAJOR..VERSION_MINOR..VERSION_BOSSES
	end
	if AtlasLootCharDB.AtlasLootVersion == nil or tonumber(AtlasLootCharDB.AtlasLootVersion) < 40301 then
		AtlasLootCharDB.AtlasLootVersion = VERSION_MAJOR..VERSION_MINOR..VERSION_BOSSES
		AtlasLootOptions_Init()
	end
	--Adds an AtlasLoot button to the Feature Frame in Cosmos
	if EarthFeature_AddButton then
		EarthFeature_AddButton(
		{
				id = string.sub(ATLASLOOT_VERSION, 11, 28),
				name = string.sub(ATLASLOOT_VERSION, 11, 28),
				subtext = string.sub(ATLASLOOT_VERSION, 30, 39),
				tooltip = "",
				icon = "Interface\\Icons\\INV_Box_01",
				callback = AtlasLoot_ShowMenu,
				test = nil,
			}
		)
		--Adds AtlasLoot to old style Cosmos installations
	elseif Cosmos_RegisterButton then
		Cosmos_RegisterButton(
			string.sub(ATLASLOOT_VERSION, 11, 28),
			string.sub(ATLASLOOT_VERSION, 11, 28),
			"",
			"Interface\\Icons\\INV_Box_01",
			AtlasLoot_ShowMenu
		)
	end
	--Set up the menu in the loot browser
	AtlasLoot_DewdropRegister()
	--If EquipCompare is available, use it
	if EquipCompare_RegisterTooltip and AtlasLoot.db.profile.EquipCompare == true then
		EquipCompare_RegisterTooltip(AtlasLootTooltip)
	end
	--Position relevant UI objects for loot browser and set up menu
	AtlasLootDefaultFrame_SelectedCategory:SetPoint("TOP", "AtlasLootDefaultFrame_Menu", "BOTTOM", 0, -4)
	AtlasLootDefaultFrame_SelectedTable:SetPoint("TOP", "AtlasLootDefaultFrame_SubMenu", "BOTTOM", 0, -4)
	AtlasLootDefaultFrame_SelectedCategory:SetText(AL["Choose Table ..."])
	AtlasLootDefaultFrame_SelectedTable:SetText("")
	AtlasLootDefaultFrame_SelectedCategory:Show()
	AtlasLootDefaultFrame_SelectedTable:Show()
	AtlasLootDefaultFrame_SubMenu:Disable()
	if AtlasLoot.db.profile.LoadAllLoDStartup == true then
		AtlasLoot_LoadAllModules()
	end
	local panel = AtlasLootOptionsFrame
	panel.name = AL["AtlasLoot"]
	InterfaceOptions_AddCategory(panel)
	--Filter and wishlist options menus creates as part of the next 2 commands
	AtlasLoot_CreateFilterOptions()
	AtlasLoot_CreateWishlistOptions()
	panel = AtlasLootHelpFrame
	panel.name = AL["Help"]
	panel.parent = AL["AtlasLoot"]
	InterfaceOptions_AddCategory(panel)
	if LibStub:GetLibrary("LibAboutPanel", true) then
		LibStub("LibAboutPanel").new(AL["AtlasLoot"], "AtlasLoot")
	end
	AtlasLoot_UpdateLootBrowserScale()

	AtlasLoot.db.profile.Bigraid = false
	AtlasLoot.db.profile.BigraidHeroic = false
	AtlasLoot.db.profile.HeroicMode = false

	AtlasLoot_SetupFilterButton()

	AtlasLootDefaultFrame_Notice:SetText(AL["This is a loot browser only.  To view maps as well, install either Atlas or Alphamap."])
    AtlasLootDefaultFrame_LoadModules:SetText(AL["Load Modules"])
    AtlasLootDefaultFrame_Options:SetText(AL["Options"])
    AtlasLootDefaultFrame_Menu:SetText(AL["Select Loot Table"])
    AtlasLootDefaultFrame_SubMenu:SetText(AL["Select Sub-Table"])
    AtlasLootDefaultFrameSearchButton:SetText(AL["Search"])
    AtlasLootDefaultFrameSearchClearButton:SetText(AL["Clear"])
    AtlasLootDefaultFrameLastResultButton:SetText(AL["Last Result"])
    AtlasLootDefaultFrameWishListButton:SetText(AL["Wishlist"])
	AtlasLootInfoHidePanel:SetText(AL["Toggle AL Panel"])
	AtlasLootInfoHidePanel:SetWidth(AtlasLootInfoHidePanel:GetTextWidth() + 20)
	AtlasLootInfo_Text2:SetText(AL["Click boss name to view loot."])
	AtlasLoot_QuickLooks:SetText(AL["Add to QuickLooks:"])
	AtlasLootItemsFrame_BACK:SetText(AL["Back"])
	AtlasLootItemsFrame_HeroicText:SetText(AL["Heroic Mode"])
	AtlasLootFilterCheckText:SetText(AL["Filter"])
	AtlasLootHelpFrame_Title:SetText(AL["AtlasLoot Help"])
	AtlasLootOptionsFrameDefaultTTText:SetText(AL["Default Tooltips"])
	AtlasLootOptionsFrameLootlinkTTText:SetText(AL["Lootlink Tooltips"])
	AtlasLootOptionsFrameItemSyncTTText:SetText(AL["ItemSync Tooltips"])
	AtlasLootOptionsFrameOpaqueText:SetText(AL["Make Loot Table Opaque"])
	AtlasLootOptionsFrameItemIDText:SetText(AL["Show itemIDs at all times"])
	AtlasLootOptionsFrameLoDStartupText:SetText(AL["Load Loot Modules at Startup"])
	AtlasLootOptionsFrameSafeLinksText:SetText(AL["Safe Chat Links"])
	AtlasLootOptionsFrameEquipCompareText:SetText(AL["Show Comparison Tooltips"])
	AtlasLootOptionsFrameItemSpamText:SetText(AL["Suppress Item Query Text"])
	AtlasLootOptionsFrameHidePanelText:SetText(AL["Hide AtlasLoot Panel"])
	AtlasLootOptionsFrame_ResetWishlist:SetText(AL["Reset Wishlist"])
	AtlasLootOptionsFrame_ResetWishlist:SetWidth(AtlasLootOptionsFrame_ResetWishlist:GetTextWidth() + 20)
	AtlasLootOptionsFrame_ResetAtlasLoot:SetText(AL["Reset Frames"])
	AtlasLootOptionsFrame_ResetAtlasLoot:SetWidth(AtlasLootOptionsFrame_ResetAtlasLoot:GetTextWidth() + 20)
	AtlasLootOptionsFrame_ResetQuicklooks:SetText(AL["Reset Quicklooks"])
	AtlasLootOptionsFrame_ResetQuicklooks:SetWidth(AtlasLootOptionsFrame_ResetQuicklooks:GetTextWidth() + 20)
	AtlasLootOptionsFrame_FuBarShow:SetText(AL["Show FuBar Plugin"])
	AtlasLootOptionsFrame_FuBarHide:SetText(AL["Hide FuBar Plugin"])
	AtlasLootOptionsFrame_FuBarNotice:SetText(AL["The Minimap Button is generated by the FuBar Plugin."].."\n"..AL["This is automatic, you do not need FuBar installed."])
	AtlasLootPanel_WorldEvents:SetText(AL["World Events"])
	AtlasLootPanel_Sets:SetText(AL["Collections"])
	AtlasLootPanel_Reputation:SetText(AL["Factions"])
	AtlasLootPanel_PvP:SetText(AL["PvP Rewards"])
	AtlasLootPanel_Crafting:SetText(AL["Crafting"])
	AtlasLootPanel_WishList:SetText(AL["Wishlist"])
	AtlasLootPanel_Options:SetText(AL["Options"])
	AtlasLootPanel_LoadModules:SetText(AL["Load Modules"])
	AtlasLootSearchButton:SetText(AL["Search"])
	AtlasLootSearchClearButton:SetText(AL["Clear"])
	AtlasLootLastResultButton:SetText(AL["Last Result"])
end

--[[
AtlasLoot_ShowMenu:
Legacy function used in Cosmos integration to open the loot browser
]]
function AtlasLoot_ShowMenu()
	AtlasLootDefaultFrame:Show()
end

function AtlasLoot_Reset(data)
	AtlasLootDefaultFrame:Hide()
	if AtlasFrame then
		AtlasFrame:Hide()
	end
	if data == "frames" then
		AtlasLoot.db.profile.LastBoss = "EmptyTable"
		AtlasLootDefaultFrame:ClearAllPoints()
		AtlasLootDefaultFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
		if AtlasLootFu then
			AtlasLootFu.db.profile.minimapPosition = 200
			AtlasLootFu:Hide()
			AtlasLootFu:Show()
		end
		AtlasLoot.db.profile.LootBrowserScale = 1.0
		AtlasLoot_UpdateLootBrowserScale()
	elseif data == "quicklooks" then
		AtlasLoot.db.profile.LastBoss = "EmptyTable"
		AtlasLootCharDB["QuickLooks"] = {}
		AtlasLoot_RefreshQuickLookButtons()
	elseif data == "wishlist" then
		AtlasLoot.db.profile.LastBoss = "EmptyTable"
		AtlasLootCharDB["WishList"] = {}
		AtlasLootCharDB["SearchResult"] = {}
		AtlasLootCharDB.LastSearchedText = ""
	elseif data == "all" then
		AtlasLoot.db.profile.LastBoss = "EmptyTable"
		AtlasLootDefaultFrame:ClearAllPoints()
		AtlasLootDefaultFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
		if AtlasLootFu then
			AtlasLootFu.db.profile.minimapPosition = 200
			AtlasLootFu:Hide()
			AtlasLootFu:Show()
		end
		AtlasLoot.db.profile.LootBrowserScale = 1.0
		AtlasLoot_UpdateLootBrowserScale()
		AtlasLootCharDB["QuickLooks"] = {}
		AtlasLoot_RefreshQuickLookButtons()
		AtlasLootCharDB["WishList"] = {}
		AtlasLootCharDB["SearchResult"] = {}
		AtlasLootCharDB.LastSearchedText = ""
	end
	DEFAULT_CHAT_FRAME:AddMessage(BLUE..AL["AtlasLoot"]..": "..RED..AL["Reset complete!"])
end

--[[
AtlasLootOptions_Toggle:
Toggle on/off the options window
]]
function AtlasLootOptions_Toggle()
	if InterfaceOptionsFrame_OpenToCategory then
		InterfaceOptionsFrame_OpenToCategory(AL["AtlasLoot"])
	else
		InterfaceOptionsFrame_OpenToFrame(AL["AtlasLoot"])
	end
	InterfaceOptionsFrame:SetFrameStrata("DIALOG")
	if AtlasLoot.db.profile.DefaultTT == true then
		AtlasLootOptions_DefaultTTToggle()
	elseif AtlasLoot.db.profile.LootlinkTT == true then
		AtlasLootOptions_LootlinkTTToggle()
	elseif AtlasLoot.db.profile.ItemSyncTT == true then
		AtlasLootOptions_ItemSyncTTToggle()
	end
end

--[[
AtlasLoot_GetLoottableHeroic:
Set up checks to see if we have a heroic loot table or not.
Returns: HeroicCheck, HeroicdataID, NonHeroicdataID, BigraidCheck, BigraiddataID, SmallraiddataID, heroname
]]
function AtlasLoot_GetLoottableHeroic(dataID)
	local NormalID, HeroicID, Normal25ID, Heroic25ID = nil, nil, nil, nil
	local dataSource = AtlasLoot_Data
	local englishFaction = UnitFactionGroup("player")
	-- remove all Heroic etc infos from the dataID**
	dataID = gsub(dataID, "_H", "")          -- Horde
	dataID = gsub(dataID, "_A", "")          -- Alliance
	dataID = gsub(dataID, "HEROIC", "")      -- Hero Table (10)
	dataID = gsub(dataID, "25Man", "")       -- 25 Man Table
	dataID = gsub(dataID, "25ManHEROIC", "") -- Heroic Table (25)

	-- dataID from normal <return>
	-- Check tables if Heroic etc exists
	if dataSource[dataID] or dataSource[dataID.."_H"] or dataSource[dataID.."_A"] then
		NormalID = dataID
		if englishFaction == "Horde" and dataSource[NormalID.."_H"] then
			NormalID = NormalID.."_H"
		elseif englishFaction ~= "Horde" and dataSource[NormalID.."_A"] then
			NormalID = NormalID.."_A"
		end
	end
	if dataSource[dataID.."HEROIC"] or dataSource[dataID.."HEROIC".."_H"] or dataSource[dataID.."HEROIC".."_A"] then
		HeroicID = dataID.."HEROIC"
		if englishFaction == "Horde" and dataSource[HeroicID.."_H"] then
			HeroicID = HeroicID.."_H"
		elseif englishFaction ~= "Horde" and dataSource[HeroicID.."_A"] then
			HeroicID = HeroicID.."_A"
		end
	end
	if dataSource[dataID.."25Man"] or dataSource[dataID.."25Man".."_H"] or dataSource[dataID.."25Man".."_A"] then
		Normal25ID = dataID.."25Man"
		if englishFaction == "Horde" and dataSource[Normal25ID.."_H"] then
			Normal25ID = Normal25ID.."_H"
		elseif englishFaction ~= "Horde" and dataSource[Normal25ID.."_A"] then
			Normal25ID = Normal25ID.."_A"
		end
	end
	if dataSource[dataID.."25ManHEROIC"] or dataSource[dataID.."25ManHEROIC".."_H"] or dataSource[dataID.."25ManHEROIC".."_A"] then
		Heroic25ID = dataID.."25ManHEROIC"
		if englishFaction == "Horde" and dataSource[Heroic25ID.."_H"] then
			Heroic25ID = Heroic25ID.."_H"
		elseif englishFaction ~= "Horde" and dataSource[Heroic25ID.."_A"] then
			Heroic25ID = Heroic25ID.."_A"
		end
	end

	return NormalID, HeroicID, Normal25ID, Heroic25ID
end

--[[
AtlasLoot_ShowItemsFrame(dataID, dataSource, title):
dataID - Key of the AtlasLoot_Data table
dataSourceString - string representing LOD module
title - Text string to use as a title for the loot page
This fuction is not normally called directly, it is usually invoked by AtlasLoot_ShowBossLoot.
It is the workhorse of the mod and allows the loot tables to be displayed any way anywhere in any mod.
]]
function AtlasLoot_ShowItemsFrame(dataID, dataSourceString, title)
	if not dataID then return end

	if AtlasLootItemsFrame.refresh and (dataID ~= AtlasLootItemsFrame.refresh[1] or dataSourceString ~= AtlasLootItemsFrame.refresh[2]) then
		AtlasLootItemsFrame.refreshCount = 0
	end

	if AtlasLootItemsFrameContainer:IsShown() and AtlasLootItemsFrame.refreshCount == 0 then
		AtlasLootItemsFrameContainer:Hide()
	end

	-- Get AtlasQuest out of the way
	if AtlasQuestInsideFrame then
		HideUIPanel(AtlasQuestInsideFrame)
	end

	-- Hide the toggle to switch between heroic and normal loot tables, we will only show it if required
	AtlasLootItemsFrame_Heroic:Hide()
	AtlasLoot10Man25ManSwitch:Hide()

	-- Hide the Filter Check-Box
	AtlasLootFilterCheck:Hide()

	local page, pageMax = 1, 1
	local dataSource = AtlasLoot_Data
	if dataID == "SearchResult" or dataID == "WishList" then
		-- Ditch the Quicklook selector
		AtlasLoot_QuickLooks:Hide()
		AtlasLootQuickLooksButton:Hide()
		-- Match the page number to display
		page = tonumber(string.match(dataSourceString, "%d+$")) or 1
		-- Aquiring items of the page
		if not dataSource[dataID] then dataSource[dataID] = {} end
		if dataID == "SearchResult" then
			dataSource[dataID], pageMax = AtlasLoot:GetSearchResultPage(page)
		elseif dataID == "WishList" then
			dataSource[dataID], pageMax = AtlasLoot_GetWishListPage(page)
		end
		-- Make page number reasonable
		if page < 1 then page = 1 end
		if page > pageMax then page = pageMax end
	else
		AtlasLoot_QuickLooks:Show()
		AtlasLootQuickLooksButton:Show()
	end

	-- Set up checks to see if we have a heroic loot table or not
	local NormalID, HeroicID, Normal25ID, Heroic25ID = AtlasLoot_GetLoottableHeroic(dataID)
	if AtlasLoot.db.profile.HeroicMode and HeroicID then
		dataID = HeroicID
	elseif AtlasLoot.db.profile.Bigraid and Normal25ID then
		dataID = Normal25ID
	elseif AtlasLoot.db.profile.BigraidHeroic and Heroic25ID then
		dataID = Heroic25ID
	else
		if not NormalID then
			if Normal25ID and not AtlasLoot.db.profile.HeroicMode then
				dataID = Normal25ID
				AtlasLoot.db.profile.Bigraid = true
				AtlasLoot.db.profile.BigraidHeroic = false
				AtlasLoot.db.profile.HeroicMode = false
			elseif HeroicID then
				dataID = HeroicID
				AtlasLoot.db.profile.Bigraid = false
				AtlasLoot.db.profile.BigraidHeroic = false
				AtlasLoot.db.profile.HeroicMode = true
			elseif Heroic25ID then
				dataID = Heroic25ID
				AtlasLoot.db.profile.Bigraid = false
				AtlasLoot.db.profile.BigraidHeroic = true
				AtlasLoot.db.profile.HeroicMode = false
			end
		else
			dataID = NormalID
		end
	end

	--Hide UI objects so that only needed ones are shown
	for i = 1, 30, 1 do
		_G["AtlasLootMenuItem_"..i]:Hide()
		_G["AtlasLootItem_"..i]:Hide()
		_G["AtlasLootItem_"..i].itemID = 0
		_G["AtlasLootItem_"..i].spellitemID = 0
	end

	--Store data about the state of the items frame to allow minor tweaks or a recall of the current loot page
	AtlasLootItemsFrame.refresh = { dataID, dataSourceString, title }
	if dataID ~= "FilterList" then
		AtlasLootItemsFrame.refreshOri = { dataID, dataSourceString, title }
		AtlasLoot.db.profile.LastBoss = dataID
	end

	local tableBase = dataSource[dataID]

	if AtlasLoot_TableNames[dataID][2] == "Menu" then
		-- This is a menu page
		for i = 1, 30, 1 do
			local info = tableBase[i]
			if info then
				local index = info[1]
				local itemButton = _G["AtlasLootMenuItem_"..index]
				local iconFrame = _G["AtlasLootMenuItem_"..index.."_Icon"]
				local nameFrame = _G["AtlasLootMenuItem_"..index.."_Name"]
				local extraFrame = _G["AtlasLootMenuItem_"..index.."_Extra"]
				local border = _G["AtlasLootMenuItem_"..index.."_IconBorder"]
				itemButton.itemTexture = info[3]
				itemButton.lootpage = info[2]
				itemButton.container = info.container
				itemButton.hasItem = false
				local class = string.upper(info[3])
				local coords = CLASS_ICON_TCOORDS[class]
				if coords then
					iconFrame:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
					iconFrame:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
				else
					iconFrame:SetTexture("Interface\\Icons\\"..(info[3] or "INV_Misc_QuestionMark"))
					iconFrame:SetTexCoord(0, 1, 0, 1)
				end
				nameFrame:SetText(AtlasLoot_FixText(info[4] or ""))
				extraFrame:SetText(AtlasLoot_FixText(info[5] or ""))
				border:SetVertexColor(1, 1, 1, 1)
				itemButton.ContainerBorder:SetVertexColor(1, 1, 1, 1)
				if itemButton.container then
					border:Hide()
					itemButton.ContainerBorder:Show()
					for row = 1, #itemButton.container do
						for col = 1, #itemButton.container[row] do
							local itemID = itemButton.container[row][col]
							if AtlasLoot.CacheItem(itemID) then
								AtlasLootItemsFrame.queue[itemID] = true
								AtlasLootItemsFrame.time = 0.5
							end
						end
					end
					itemButton.Icon:SetWidth(22)
					itemButton.Icon:SetHeight(22)
				else
					border:Show()
					itemButton.ContainerBorder:Hide()
					itemButton.Icon:SetWidth(27)
					itemButton.Icon:SetHeight(27)
				end
				itemButton:Show()
			end
		end
		AtlasLootFilterCheck:Hide()
		AtlasLootItemsFrame_Heroic:Hide()
		AtlasLoot10Man25ManSwitch:Hide()
	else
		-- This is a regular items page
		for i = 1, 30, 1 do
			local info = tableBase[i]
			if info and info[4] ~= "" then
				local isSpell    = string.sub(info[2], 1, 1) == "s"
				local itemButton = _G["AtlasLootItem_"..info[1]]
				local iconFrame  = _G["AtlasLootItem_"..info[1].."_Icon"]
				local nameFrame  = _G["AtlasLootItem_"..info[1].."_Name"]
				local extraFrame = _G["AtlasLootItem_"..info[1].."_Extra"]
				local border     = _G["AtlasLootItem_"..info[1].."_IconBorder"]

				if isSpell then
					local spellName, _, spellIcon = GetSpellInfo(string.sub(info[2], 2))
					if spellName then
						nameFrame:SetText(spellName)
					else
						nameFrame:SetText(AtlasLoot_FixText(info[4]))
					end
					border:SetVertexColor(1, 1, 1, 1)
					if tonumber(info[3]) then
						local itemName, itemLink, itemQuality = GetItemInfo(info[3])
						local r, g, b, color = GetItemQualityColor(itemQuality or 1)
						if itemName then
							nameFrame:SetText(color..itemName)
							border:SetVertexColor(r, g, b, 1)
						end
						iconFrame:SetTexture(GetItemIcon(info[3]))
					elseif spellIcon then
						iconFrame:SetTexture(spellIcon)
					else
						iconFrame:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
					end
				else
					local itemName, itemLink, itemQuality = GetItemInfo(info[2])
					local r, g, b, color = GetItemQualityColor(itemQuality or 1)
					if itemName then
						nameFrame:SetText(color..itemName)
						border:SetVertexColor(r, g, b, 1)
					else
						nameFrame:SetText(AtlasLoot_FixText(info[4]))
						border:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1)
						if AtlasLoot.CacheItem(info[2]) then
							AtlasLootItemsFrame.queue[info[2]] = true
							AtlasLootItemsFrame.time = 0.5
						end
					end
					if info[3] and info[3] ~= "" then
						iconFrame:SetTexture("Interface\\Icons\\"..info[3])
					else
						iconFrame:SetTexture(GetItemIcon(info[2]))
					end
				end

				local class = string.upper(info[3])
				local coords = CLASS_ICON_TCOORDS[class]
				if coords then
					iconFrame:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
					iconFrame:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
				else
					iconFrame:SetTexCoord(0, 1, 0, 1)
				end

				if not iconFrame:GetTexture() then
					iconFrame:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				end
				itemButton.itemTexture = iconFrame:GetTexture()
				itemButton.container = info.container
				if info.container then
					itemButton.IconBorder:Hide()
					itemButton.ContainerBorder:Show()
					for row = 1, #info.container do
						for col = 1, #info.container[row] do
							local itemID = info.container[row][col]
							if AtlasLoot.CacheItem(itemID) then
								AtlasLootItemsFrame.queue[itemID] = true
								AtlasLootItemsFrame.time = 0.5
							end
						end
					end
					itemButton.Icon:SetWidth(22)
					itemButton.Icon:SetHeight(22)
				else
					itemButton.IconBorder:Show()
					itemButton.Icon:SetWidth(27)
					itemButton.Icon:SetHeight(27)
					itemButton.ContainerBorder:Hide()
				end
				extraFrame:SetText(AtlasLoot_FixText(info[5]))

				if isSpell then
					itemButton.itemID = info[2]
					itemButton.dressingroomID = tonumber(info[3]) or 0
				else
					itemButton.itemID = tonumber(info[2]) or 0
					itemButton.dressingroomID = itemButton.itemID
				end

				itemButton.hasItem = IsEquippableItem(itemButton.dressingroomID)

				itemButton.spellitemID = tonumber(info[3]) or 0
				if AtlasLoot.CacheItem(itemButton.spellitemID) then
					AtlasLootItemsFrame.queue[itemButton.spellitemID] = true
					AtlasLootItemsFrame.time = 0.5
				end

				if info[7] and info[7] ~= "" then
					itemButton.droprate = info[7]
				else
					itemButton.droprate = nil
				end

				if dataID == "SearchResult" or dataID == "WishList" then
					itemButton.sourcePage = info[8] or nil
				end

				itemButton:Show()
			end
		end

		-- Show the Filter Check-Box
		if dataID ~= "WishList" and dataID ~= "SearchResult" and dataSourceString ~= "AtlasLootCrafting" then
			AtlasLootFilterCheck:Show()
		end

		--Decide whether to show the Heroic mode toggle
		--Checks if a heroic version of the loot table is available.
		NormalID, HeroicID, Normal25ID, Heroic25ID = AtlasLoot_GetLoottableHeroic(AtlasLootItemsFrame.refreshOri[1])

		if AtlasLoot.db.profile.Bigraid and Normal25ID and NormalID then
			AtlasLoot10Man25ManSwitch:SetText(AL["Show 10 Man Loot"])
			AtlasLoot10Man25ManSwitch.lootpage = NormalID
			AtlasLoot10Man25ManSwitch:Show()
		elseif AtlasLoot.db.profile.BigraidHeroic and Heroic25ID and HeroicID then
			AtlasLoot10Man25ManSwitch:SetText(AL["Show 10 Man Loot"])
			AtlasLoot10Man25ManSwitch.lootpage = HeroicID
			AtlasLoot10Man25ManSwitch:Show()
		elseif AtlasLoot.db.profile.HeroicMode and HeroicID and Heroic25ID then
			AtlasLoot10Man25ManSwitch:SetText(AL["Show 25 Man Loot"])
			AtlasLoot10Man25ManSwitch.lootpage = Heroic25ID
			AtlasLoot10Man25ManSwitch:Show()
		elseif not AtlasLoot.db.profile.Bigraid and NormalID and Normal25ID then
			AtlasLoot10Man25ManSwitch:SetText(AL["Show 25 Man Loot"])
			AtlasLoot10Man25ManSwitch.lootpage = Normal25ID
			AtlasLoot10Man25ManSwitch:Show()
		end
		-- Heroic check
		if AtlasLoot.db.profile.Bigraid and Normal25ID and Heroic25ID then
			AtlasLootItemsFrame_Heroic:Show()
			AtlasLootItemsFrame_Heroic:SetChecked(false)
			AtlasLootItemsFrame_Heroic:Enable()
		elseif AtlasLoot.db.profile.BigraidHeroic and Heroic25ID then
			AtlasLootItemsFrame_Heroic:Show()
			AtlasLootItemsFrame_Heroic:SetChecked(true)
			if Normal25ID then
				AtlasLootItemsFrame_Heroic:Enable()
			else
				AtlasLootItemsFrame_Heroic:Disable()
			end
		elseif AtlasLoot.db.profile.HeroicMode and HeroicID then
			AtlasLootItemsFrame_Heroic:Show()
			AtlasLootItemsFrame_Heroic:SetChecked(true)
			AtlasLootItemsFrame_Heroic:Enable()
			if NormalID then
				AtlasLootItemsFrame_Heroic:Enable()
			else
				AtlasLootItemsFrame_Heroic:Disable()
			end
		elseif NormalID and HeroicID then
			AtlasLootItemsFrame_Heroic:Show()
			AtlasLootItemsFrame_Heroic:SetChecked(false)
			AtlasLootItemsFrame_Heroic:Enable()
		end

	end

	-- Set title text
	if dataID ~= "SearchResult" and dataID ~= "WishList" then
		AtlasLoot_BossName:SetText(AtlasLoot_TableNames[dataID][1])
	else
		AtlasLoot_BossName:SetText(title)
	end

	-- Hide navigation buttons by default
	AtlasLootItemsFrame_BACK:Hide()
	AtlasLootItemsFrame_NEXT:Hide()
	AtlasLootItemsFrame_PREV:Hide()
	-- Determine what nav buttons are required
	if dataID == "SearchResult" or dataID == "WishList" then
		if page < pageMax then
			AtlasLootItemsFrame_NEXT:Show()
			AtlasLootItemsFrame_NEXT.lootpage = dataID.."Page"..(page + 1)
		end
		if page > 1 then
			AtlasLootItemsFrame_PREV:Show()
			AtlasLootItemsFrame_PREV.lootpage = dataID.."Page"..(page - 1)
		end
	else
		if tableBase.Next then
			AtlasLootItemsFrame_NEXT:Show()
			AtlasLootItemsFrame_NEXT.lootpage = tableBase.Next
		end
		if tableBase.Prev then
			AtlasLootItemsFrame_PREV:Show()
			AtlasLootItemsFrame_PREV.lootpage = tableBase.Prev
		end
		if tableBase.Back then
			AtlasLootItemsFrame_BACK:Show()
			AtlasLootItemsFrame_BACK.lootpage = tableBase.Back
		end
	end

	-- For Alphamap and Atlas integration, show a 'close' button to hide the loot table and restore the map view
	if AtlasLoot.AnchorPoint ~= AtlasLoot.AnchorDefault then
		AtlasLootItemsFrame_CloseButton:Show()
	else
		AtlasLootItemsFrame_CloseButton:Hide()
	end

	if ATLASLOOT_FILTER_ENABLE == true and dataID ~= "FilterList" then
		AtlasLoot_HideNoUsableItems()
	end

	-- Anchor the item frame where it is supposed to be
	AtlasLootItemsFrame:SetParent(_G[AtlasLoot.AnchorPoint[2]])
	AtlasLootItemsFrame:ClearAllPoints()
	AtlasLootItemsFrame:SetPoint(AtlasLoot.AnchorPoint[1], AtlasLoot.AnchorPoint[2], AtlasLoot.AnchorPoint[3], AtlasLoot.AnchorPoint[4], AtlasLoot.AnchorPoint[5])
	AtlasLootItemsFrame:Show()

	-- Update buttons in Atlas scroll frame
	if AtlasFrame and AtlasFrame:IsShown() then
		AtlasLootItemsFrame.activeLootPage = AtlasLoot.db.profile.LastBoss
		AtlasLoot_AtlasScrollBar_Update()
	end
end

--[[
AtlasLootItemsFrame_OnCloseButton:
Called when the close button on the item frame is clicked
]]
function AtlasLootItemsFrame_OnCloseButton()
	--Set no loot table as currently selected
	AtlasLootItemsFrame.activeLootPage = nil
	AtlasLoot_AtlasScrollBar_Update()
	--Hide the item frame
	AtlasLootItemsFrame:Hide()
end

--[[
AtlasLoot_NavButton_OnClick:
Called when <-, -> or 'Back' are pressed and calls up the appropriate loot page
]]
function AtlasLoot_NavButton_OnClick(self)
	if AtlasLootItemsFrame.refresh then
		if strsub(self.lootpage, 1, 16) == "SearchResultPage" then
			AtlasLoot_ShowItemsFrame("SearchResult", self.lootpage, (AL["Search Result: %s"]):format(AtlasLootCharDB.LastSearchedText or ""))
		elseif strsub(self.lootpage, 1, 12) == "WishListPage" then
			AtlasLoot_ShowItemsFrame("WishList", self.lootpage, AL["Wishlist"])
		else
			AtlasLoot_ShowItemsFrame(self.lootpage, AtlasLootItemsFrame.refresh[2], "")
		end
	else
		--Fallback for if the requested loot page is a menu and does not have a .refresh instance
		AtlasLoot_ShowItemsFrame(self.lootpage, "", "")
	end
end

--[[
AtlasLoot_HeroicModeToggle:
Switches between the heroic and normal versions of a loot page
]]
function AtlasLoot_HeroicModeToggle()
	local Heroic
	local dataID
	if ATLASLOOT_FILTER_ENABLE then
		dataID = AtlasLootItemsFrame.refreshOri[1]
	else
		dataID = AtlasLootItemsFrame.refresh[1]
	end
	local NormalID, HeroicID, Normal25ID, Heroic25ID = AtlasLoot_GetLoottableHeroic(dataID)

	if AtlasLoot.db.profile.Bigraid and Heroic25ID then
		AtlasLoot.db.profile.Bigraid = false
		AtlasLoot.db.profile.BigraidHeroic = true
		dataID = Heroic25ID
	elseif AtlasLoot.db.profile.HeroicMode and NormalID then
		AtlasLoot.db.profile.HeroicMode = false
		dataID = NormalID
	elseif AtlasLoot.db.profile.BigraidHeroic and Normal25ID then
		AtlasLoot.db.profile.Bigraid = true
		AtlasLoot.db.profile.BigraidHeroic = false
		dataID = Normal25ID
	else
		AtlasLoot.db.profile.HeroicMode = true
		AtlasLoot.db.profile.Bigraid = false
		AtlasLoot.db.profile.BigraidHeroic = false
		dataID = HeroicID
	end
	AtlasLoot_ShowItemsFrame(dataID, AtlasLootItemsFrame.refresh[2], "")
end

--[[
AtlasLoot_10Man25ManToggle:
Switches between the heroic and normal versions of a loot page
]]
function AtlasLoot_10Man25ManToggle()
	local Lootpage = AtlasLoot10Man25ManSwitch.lootpage
	--Deal with loot filter issue
	if ATLASLOOT_FILTER_ENABLE == true then
		Lootpage = AtlasLootItemsFrame.refreshOri[1]
	end

	local NormalID, HeroicID, Normal25ID, Heroic25ID = AtlasLoot_GetLoottableHeroic(Lootpage)
	if AtlasLoot.db.profile.Bigraid and Normal25ID then
		AtlasLoot.db.profile.Bigraid = false
	elseif AtlasLoot.db.profile.BigraidHeroic and Heroic25ID then
		AtlasLoot.db.profile.BigraidHeroic = false
		AtlasLoot.db.profile.HeroicMode = true
	elseif AtlasLoot.db.profile.HeroicMode and HeroicID then
		AtlasLoot.db.profile.HeroicMode = false
		AtlasLoot.db.profile.BigraidHeroic = true
	else
		AtlasLoot.db.profile.Bigraid = true
		AtlasLoot.db.profile.BigraidHeroic = false
		AtlasLoot.db.profile.HeroicMode = false
	end

	AtlasLoot_ShowItemsFrame(Lootpage, AtlasLootItemsFrame.refresh[2], "")
end

--[[
AtlasLoot_IsLootTableAvailable(dataID):
Checks if a loot table is in memory and attempts to load the correct LoD module if it isn't
dataID: Loot table dataID
]]
function AtlasLoot_IsLootTableAvailable(dataID)
	if not dataID then return false end
	for k, v in pairs(AtlasLoot_MenuList) do
		if v == dataID then return true end
	end

	if not AtlasLoot_TableNames[dataID] then
		DEFAULT_CHAT_FRAME:AddMessage(RED..AL["AtlasLoot Error!"].." "..WHITE..dataID..AL[" not listed in loot table registry, please report this message to the AtlasLoot forums at http://www.atlasloot.net"])
		return false
	end

	if AtlasLoot_Data[dataID] then return true end

	local dataSource = AtlasLoot_TableNames[dataID][2]
	local moduleName = AtlasLoot_GetLODModule(dataSource)
	if moduleName then
		if not IsAddOnLoaded(moduleName) then
			local loaded, reason = LoadAddOn(moduleName)
			if not loaded then
				if reason == "MISSING" or reason == "DISABLED" then
					DEFAULT_CHAT_FRAME:AddMessage(GREEN..AL["AtlasLoot"]..": "..ORANGE..AtlasLoot_TableNames[dataID][1]..WHITE..AL[" is unavailable, the following load on demand module is required: "]..ORANGE..moduleName)
					return false
				else
					DEFAULT_CHAT_FRAME:AddMessage(RED..AL["AtlasLoot Error!"].." "..WHITE..AL["Status of the following module could not be determined: "]..ORANGE..moduleName)
					return false
				end
			end
		end
		if AtlasLoot_Data[dataID] then
			if ATLASLOOT_DEBUGMESSAGES then
				DEFAULT_CHAT_FRAME:AddMessage(GREEN..AL["AtlasLoot"]..": "..ORANGE..moduleName..WHITE.." "..AL["sucessfully loaded."])
			end
			collectgarbage("collect")
			return true
		else
			DEFAULT_CHAT_FRAME:AddMessage(RED..AL["AtlasLoot Error!"].." "..ORANGE..AtlasLoot_TableNames[dataID][1]..WHITE..AL[" could not be accessed, the following module may be out of date: "]..ORANGE..moduleName)
			return false
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage(RED..AL["AtlasLoot Error!"].." "..ORANGE..AL["Loot module returned as nil!"])
		return false
	end
end

--[[
AtlasLoot_GetLODModule(dataSource)
Returns the name of the module that needs to be loaded
dataSource: Location of the loot table
]]
function AtlasLoot_GetLODModule(dataSource)
	if dataSource == "AtlasLootOriginalWoW" then
		return "AtlasLoot_OriginalWoW"
	elseif dataSource == "AtlasLootCrafting" then
		return "AtlasLoot_Crafting"
	elseif dataSource == "AtlasLootWorldEvents" then
		return "AtlasLoot_WorldEvents"
	end
end

--[[
AtlasLoot_LoadAllModules()
Used to load all available LoD modules
]]
function AtlasLoot_LoadAllModules()
	local orig, bc, wotlk, craft, world
	orig, _ = LoadAddOn("AtlasLoot_OriginalWoW")
	craft, _ = LoadAddOn("AtlasLoot_Crafting")
	world, _ = LoadAddOn("AtlasLoot_WorldEvents")
	local flag = 0
	if not orig then
		LoadAddOn("AtlasLoot_OriginalWoW")
		flag = 1
	end
	if not craft then
		LoadAddOn("AtlasLoot_Crafting")
		flag = 1
	end
	if not world then
		LoadAddOn("AtlasLoot_WorldEvents")
		flag = 1
	end
	if flag == 1 then
		if ATLASLOOT_DEBUGMESSAGES then
			DEFAULT_CHAT_FRAME:AddMessage(GREEN..AL["AtlasLoot"]..": "..WHITE..AL["All Available Modules Loaded"])
		end
		collectgarbage("collect")
	end
end

--[[
AtlasLoot_ShowQuickLooks(button)
button: Identity of the button pressed to trigger the function
Shows the GUI for setting Quicklooks
]]
function AtlasLoot_ShowQuickLooks(button)
	local dewdrop = AceLibrary("Dewdrop-2.0")
	if dewdrop:IsOpen(button) then
		dewdrop:Close(1)
	else
		local setOptions = function()
			dewdrop:AddLine(
				"text", AL["QuickLook"].." 1",
				"tooltipTitle", AL["QuickLook"].." 1",
				"tooltipText", AL["Assign this loot table\n to QuickLook"].." 1",
				"func", function()
					AtlasLootCharDB["QuickLooks"][1] = { AtlasLootItemsFrame.refreshOri[1], AtlasLootItemsFrame.refreshOri[2], AtlasLootItemsFrame.refreshOri[3], AtlasLootItemsFrame.refreshOri[4] }
					AtlasLoot_RefreshQuickLookButtons()
					dewdrop:Close(1)
				end
			)
			dewdrop:AddLine(
				"text", AL["QuickLook"].." 2",
				"tooltipTitle", AL["QuickLook"].." 2",
				"tooltipText", AL["Assign this loot table\n to QuickLook"].." 2",
				"func", function()
					AtlasLootCharDB["QuickLooks"][2] = { AtlasLootItemsFrame.refreshOri[1], AtlasLootItemsFrame.refreshOri[2], AtlasLootItemsFrame.refreshOri[3], AtlasLootItemsFrame.refreshOri[4] }
					AtlasLoot_RefreshQuickLookButtons()
					dewdrop:Close(1)
				end
			)
			dewdrop:AddLine(
				"text", AL["QuickLook"].." 3",
				"tooltipTitle", AL["QuickLook"].." 3",
				"tooltipText", AL["Assign this loot table\n to QuickLook"].." 3",
				"func", function()
					AtlasLootCharDB["QuickLooks"][3] = { AtlasLootItemsFrame.refreshOri[1], AtlasLootItemsFrame.refreshOri[2], AtlasLootItemsFrame.refreshOri[3], AtlasLootItemsFrame.refreshOri[4] }
					AtlasLoot_RefreshQuickLookButtons()
					dewdrop:Close(1)
				end
			)
			dewdrop:AddLine(
				"text", AL["QuickLook"].." 4",
				"tooltipTitle", AL["QuickLook"].." 4",
				"tooltipText", AL["Assign this loot table\n to QuickLook"].." 4",
				"func", function()
					AtlasLootCharDB["QuickLooks"][4] = { AtlasLootItemsFrame.refreshOri[1], AtlasLootItemsFrame.refreshOri[2], AtlasLootItemsFrame.refreshOri[3], AtlasLootItemsFrame.refreshOri[4] }
					AtlasLoot_RefreshQuickLookButtons()
					dewdrop:Close(1)
				end
			)
		end
		dewdrop:Open(button,
			'point', function(parent)
				return "BOTTOMLEFT", "BOTTOMRIGHT"
			end,
			"children", setOptions
		)
	end
end

--[[
AtlasLoot_RefreshQuickLookButtons()
Enables/disables the quicklook buttons depending on what is assigned
]]
function AtlasLoot_RefreshQuickLookButtons()
	for i = 1, 4 do
		if not AtlasLootCharDB["QuickLooks"][i] or not AtlasLootCharDB["QuickLooks"][i][1] then
			_G["AtlasLootPanel_Preset"..i]:Disable()
			_G["AtlasLootDefaultFrame_Preset"..i]:Disable()
		else
			_G["AtlasLootPanel_Preset"..i]:Enable()
			_G["AtlasLootDefaultFrame_Preset"..i]:Enable()
		end
	end
end

--[[
AtlasLoot_AddTooltip(frameb, tooltiptext)
Adds explanatory tooltips to UI objects.
]]
function AtlasLoot_AddTooltip(frameb, tooltiptext)
	if not tooltiptext or not frameb then return end
	local frame = _G[frameb]
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltiptext)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", GameTooltip_Hide)
end

function AtlasLoot.CacheItem(item)
	if not item then return false end
	local id = tonumber(item) or string.match(item, "item:(%d+)") or 0
	if id < 1 then return false end

	if GetItemInfo(id) then return false end

	local tooltip = AtlasLootScanTooltip or CreateFrame("GameTooltip", "AtlasLootScanTooltip", nil, "GameTooltipTemplate")
	tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltip:SetHyperlink("item:"..id)
	return true
end

function AtlasLootItemsFrame_OnUpdate(self, elapsed)
	if not self.time then return end
	self.time = self.time - elapsed
	local ready = true
	for itemID in pairs(self.queue) do
		if not GetItemInfo(itemID) then
			ready = false
			break
		end
	end
	if self.time <= 0 or ready then
		-- local size = 0
		-- for _ in pairs(self.queue) do size = size + 1 end
		-- print(format("caching %d items on this page took %.3f sec", size, 0.5 - max(0, self.time)))
		self.time = nil
		table.wipe(self.queue)
		local refresh = self.refresh
		if refresh and self.refreshCount == 0 then
			AtlasLoot_ShowItemsFrame(refresh[1], refresh[2], refresh[3])
			self.refreshCount = self.refreshCount + 1
		end
	end
end

function AtlasLootItemsFrame_OnShow(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 3)
end
