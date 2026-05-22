local AL = LibStub("AceLocale-3.0"):GetLocale("AtlasLoot")
local BabbleInventory = AtlasLoot_GetLocaleLibBabble("LibBabble-Inventory-3.0")
local BabbleEpoch = AtlasLoot_GetLocaleLibBabble("LibBabble-Epoch-3.0")
local BabbleFaction = AtlasLoot_GetLocaleLibBabble("LibBabble-Faction-3.0")
local BabbleZone = AtlasLoot_GetLocaleLibBabble("LibBabble-Zone-3.0")

AtlasLoot_Data["SETMENU"] = {
	{ 1, "SETSCLASSIC", "INV_Sword_43", "=ds=Misc Tier 0 & Tier 0.5", "" },
	{ 2, "WORLDEPICS", "INV_Sword_76", "=ds="..AL["BoE World Epics"], "" },
	{ 4, "OldKeys", "inv_misc_key_14", "=ds=Keys", "" },
	{ 5, "Tabards1", "INV_Shirt_GuildTabard_01", "=ds="..AL["Tabards"], "" },
	{ 6, "ShopCosmetics", "inv_rod_enchantedeternium", "=ds=Shop Cosmetics", "" },
	{ 8, "EpochChallenges", "inv_misc_bone_skull_02", "=ds=Challenge Rewards", "" },
	{ 16, "T0SET", "INV_Chest_Chain_03", "=ds="..AL["Tier 0 & Tier 0.5"], "" },
	{ 17, "T1SETMENU", "INV_Pants_Mail_03", "=ds="..AL["Tier 1"], "" },
	{ 19, "MOUNTMENU", "INV_Misc_QirajiCrystal_05", "=ds="..AL["Mounts"], "" },
	{ 20, "PETMENU", "INV_Box_PetCarrier_01", "=ds="..AL["Vanity Pets"], "" },
	{ 21, "TOYMENU", "Inv_misc_toy_10", "=ds="..BabbleEpoch["Toys"], "" },
	-- { 23, "Abandoned1", "inv_misc_questionmark", "=ds="..BabbleEpoch["Probably Abandoned Epoch Loot"], "" },
}

AtlasLoot_Data["WORLDEPICS"] = {
	{ 1, "WorldEpics1", "INV_Jewelry_Ring_15", "=ds="..AL["Level 30-39"], "" },
	{ 2, "WorldEpics2", "INV_Staff_29", "=ds="..AL["Level 40-49"], "" },
	{ 3, "WorldEpics3", "INV_Jewelry_Amulet_01", "=ds="..BabbleEpoch["Level 50-55"], "" },
	{ 4, "WorldEpics4", "Inv_weapon_halberd_04", "=ds="..BabbleEpoch["Level 56-60"], "" },
	Back = "SETMENU",
}

AtlasLoot_Data["MOUNTMENU"] = {
	{ 3, "MountsAlliance1", "achievement_pvp_a_16", "=ds="..AL["Alliance Mounts"], "" },
	{ 1, "MountsDrop1", "ability_mount_undeadhorse", "=ds="..BabbleEpoch["Mount Drops"], "" },
	{ 16, "MountsShop", "inv_misc_coin_01", "=ds="..BabbleEpoch["Shop Mounts"], "" },
	{ 18, "MountsHorde1", "achievement_pvp_h_16", "=ds="..AL["Horde Mounts"], "" },
	Back = "SETMENU",
}

AtlasLoot_Data["PETMENU"] = {
	{ 1, "PetsMerchant1", "Inv_valentinescandysack", "=ds="..AL["Merchant Sold"], "" },
	{ 2, "PetsDrop1", "Inv_box_petcarrier_01", "=ds="..AL["Drop"].." / "..AL["Quest"].." / "..AL["Crafted"], "" },
	{ 3, "PetsAchievent1", "inv_misc_pheonixpet_01", "=ds="..AL["World Events"].." / "..AL["Achievement"], "" },
	{ 4, "PetsShop", "inv_misc_coin_01", "=ds="..BabbleEpoch["Shop Pets"], "" },
	Back = "SETMENU",
}

AtlasLoot_Data["TOYMENU"] = {
	{ 1, "ToysShop", "inv_misc_coin_01", "=ds="..BabbleEpoch["Shop"], "" },
	Back = "SETMENU",
}

AtlasLoot_Data["SETSCLASSIC"] = {
	{ 1, "VWOWSets1", "INV_Pants_12", "=ds="..AL["Defias Leather"], "=q5="..BabbleZone["The Deadmines"] },
	{ 2, "VWOWSets2", "INV_Shirt_16", "=ds="..AL["Embrace of the Viper"], "=q5="..BabbleZone["Wailing Caverns"] },
	{ 3, "VWOWSets3", "INV_Gauntlets_19", "=ds="..AL["Chain of the Scarlet Crusade"], "=q5="..BabbleZone["Scarlet Monastery"] },
	{ 5, "VWOWSets4", "INV_Helmet_01", "=ds="..AL["The Gladiator"], "=q5="..BabbleZone["Blackrock Depths"] },
	{ 6, "VWOWSets5", "INV_Boots_02", "=ds="..AL["The Postmaster"], "=q5="..BabbleZone["Stratholme"] },
	{ 7, "VWOWSets6", "INV_Boots_Cloth_05", "=ds="..AL["Ironweave Battlesuit"], "=q5="..AL["Various Locations"] },
	{ 4, "VWOWSets7", "inv_chest_plate16", "=ds="..BabbleEpoch["Uldic Plate"], "=q5="..BabbleZone["Uldaman"] },
	{ 8, "VWOWScholo", "INV_Shoulder_02", "=ds="..AL["Scholomance Sets"], "=q5="..BabbleZone["Scholomance"] },
	{ 10, "Epochset0", "INV_Shoulder_03", "=ds="..BabbleEpoch["Rune Warder Set"], "=q5="..BabbleEpoch["Baradin Hold"] },
	{ 16, "VWOWWeapons", "INV_Weapon_ShortBlade_16", "=ds="..AL["Spider's Kiss"], "=q5="..BabbleZone["Lower Blackrock Spire"] },
	{ 17, "VWOWWeapons", "INV_Sword_43", "=ds="..AL["Dal'Rend's Arms"], "=q5="..BabbleZone["Upper Blackrock Spire"] },
	Back = "SETMENU",
}

AtlasLoot_Data["T0SET"] = {
	{ 1, "T0Warrior", "WARRIOR", "=ds="..LOCALIZED_CLASS_NAMES_MALE["WARRIOR"], "", container = {
		{ 16731, 16733, 16730, 16735, 16737, 16736, 16732, 16734 },
		{ 60362, 60361, 60363, 60358, 60359, 60357, 60364, 60360 },
		{ 21999, 22001, 21997, 21996, 21998, 21994, 22000, 21995 }
	} },
	{ 2, "T0Paladin", "PALADIN", "=ds="..LOCALIZED_CLASS_NAMES_MALE["PALADIN"], "", container = {
		{ 16727, 16729, 16726, 16722, 16724, 16723, 16728, 16725 },
		{ 60318, 60317, 60319, 60314, 60315, 60313, 60320, 60316 },
		{ 22091, 22093, 22089, 22088, 22090, 22086, 22092, 22087 },
		{ 60310, 60309, 60311, 60306, 60307, 60305, 60312, 60308 }
	} },
	{ 3, "T0Priest", "PRIEST", "=ds="..LOCALIZED_CLASS_NAMES_MALE["PRIEST"], "", container = {
		{ 16693, 16695, 16690, 16697, 16692, 16696, 16694, 16691 },
		{ 60326, 60325, 60327, 60322, 60323, 60321, 60328, 60324 },
		{ 22080, 22082, 22083, 22079, 22081, 22078, 22085, 22084 }
	} },
	{ 4, "T0Shaman", "SHAMAN", "=ds="..LOCALIZED_CLASS_NAMES_MALE["SHAMAN"], "", container = {
		{ 16667, 16669, 16666, 16671, 16672, 16673, 16668, 16670 },
		{ 22097, 22101, 22102, 22095, 22099, 22098, 22100, 22096 },
		{ 60354, 60353, 60355, 60350, 60351, 60349, 60356, 60352 },
		{ 60346, 60345, 60347, 60342, 60343, 60341, 60348, 60344 }
	} },
	{ 5, "T0Druid", "DRUID", "=ds="..LOCALIZED_CLASS_NAMES_MALE["DRUID"], "", container = {
		{ 16720, 16718, 16706, 16714, 16717, 16716, 16719, 16715 },
		{ 60299, 60298, 60300, 60295, 60296, 60294, 60301, 60297 },
		{ 22109, 22112, 22113, 22108, 22110, 22106, 22111, 22107 },
		{ 60290, 60289, 60291, 60286, 60287, 60285, 60292, 60288 }
	} },
	{ 6, "T0Rogue", "ROGUE", "=ds="..LOCALIZED_CLASS_NAMES_MALE["ROGUE"], "", container = {
		{ 16707, 16708, 16721, 16710, 16712, 16713, 16709, 16711 },
		{ 22005, 22008, 22009, 22004, 22006, 22002,22007 ,22003 }
	} },
	{ 7, "T0Mage", "MAGE", "=ds="..LOCALIZED_CLASS_NAMES_MALE["MAGE"], "", container = {
		{ 16686, 16689, 16688, 16683, 16684, 16685, 16687, 16682 },
		{ 22065, 22068, 22069, 22063, 22066, 22062, 22067, 22064 }
	} },
	{ 8, "T0Warlock", "WARLOCK", "=ds="..LOCALIZED_CLASS_NAMES_MALE["WARLOCK"], "", container = {
		{ 16698, 16701, 16700, 16703, 16705, 16702, 16699, 16704 },
		{ 22074, 22073, 22075, 22071, 22077, 22070, 22072, 22076 }
	} },
	{ 9, "T0Hunter", "HUNTER", "=ds="..LOCALIZED_CLASS_NAMES_MALE["HUNTER"], "", container = {
		{ 16677, 16679, 16674, 16681, 16676, 16680, 16678, 16675 },
		{ 22013, 22016, 22060, 22011, 22015, 22010, 22017, 22061 }
	} },
	Back = "SETMENU",
}

AtlasLoot_Data["T1SETMENU"] = {
	{ 1, "T1Warrior", "WARRIOR", "=ds="..LOCALIZED_CLASS_NAMES_MALE["WARRIOR"], "" , container = {
		{ 61634, 61635, 61636, 61637, 61638, 61639 },
		{ 61640, 61641, 61642, 61643, 61644, 61645 }
	} },
	{ 2, "T1Paladin", "PALADIN", "=ds="..LOCALIZED_CLASS_NAMES_MALE["PALADIN"], "" , container = {
		{ 61574, 61575, 61576, 61577, 61578, 61579 },
		{ 61580, 61581, 61582, 61583, 61584, 61585 },
		{ 61586, 61587, 61588, 61589, 61590, 61591 }
	} },
	{ 3, "T1Priest", "PRIEST", "=ds="..LOCALIZED_CLASS_NAMES_MALE["PRIEST"], "" , container = {
		{ 61592, 61593, 61594, 61595, 61596, 61597 },
		{ 61598, 61599, 61600, 61601, 61602, 61603 }
	} },
	{ 4, "T1Shaman", "SHAMAN", "=ds="..LOCALIZED_CLASS_NAMES_MALE["SHAMAN"], "" , container = {
		{ 61610, 61611, 61612, 61613, 61614, 61615 },
		{ 61616, 61617, 61618, 61619, 61620, 61621 },
		{ 61622, 61623, 61624, 61625, 61626, 61627 }
	} },
	{ 5, "T1Druid", "DRUID", "=ds="..LOCALIZED_CLASS_NAMES_MALE["DRUID"], "" , container = {
		{ 61544, 61545, 61546, 61547, 61548, 61549 },
		{ 61550, 61551, 61552, 61553, 61554, 61555 },
		{ 61556, 61557, 61558, 61559, 61560, 61561 }
	} },
	{ 6, "T1Rogue", "ROGUE", "=ds="..LOCALIZED_CLASS_NAMES_MALE["ROGUE"], "" , container = {
		{ 61604, 61605, 61606, 61607, 61608, 61609 }
	} },
	{ 7, "T1Mage", "MAGE", "=ds="..LOCALIZED_CLASS_NAMES_MALE["MAGE"], "" , container = {
		{ 61569, 61572, 61571, 61570, 61568, 61573 }
	} },
	{ 8, "T1Warlock", "WARLOCK", "=ds="..LOCALIZED_CLASS_NAMES_MALE["WARLOCK"], "" , container = {
		{ 61629, 61632, 61631, 61630, 61628, 61633 }
	} },
	{ 9, "T1Hunter", "HUNTER", "=ds="..LOCALIZED_CLASS_NAMES_MALE["HUNTER"], "" , container = {
		{ 61563, 61566, 61565, 61564, 61562, 61567 }
	} },
	Back = "SETMENU",
}
