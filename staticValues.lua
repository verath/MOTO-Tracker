--###################################
--	Static Values
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

-- Calls on initialization of the addon,
-- loads/sets most static values (some are set later as not all are available)
function A:LoadStaticValues()
	I.hasGuild = IsInGuild()

	-- For dropdown lists that sorts roster
	I.guildSortableBy = {
		name = L['Name'] .. ' (' .. L['A-Z'] .. ')',
		INVERTname = L['Name'] .. ' (' .. L['Z-A'] .. ')',
		rankIndex = L['Guild Rank'] .. ' (' .. L['High'] .. ')', 
		INVERTrankIndex = L['Guild Rank'] .. ' (' .. L['Low'] .. ')', 
		class = L['Class'] .. ' (' .. L['A-Z'] .. ')',
		INVERTclass = L['Class'] .. ' (' .. L['Z-A'] .. ')',
		level = L['Level']  .. ' (' .. L['Low'] .. ')', 
		INVERTlevel = L['Level'] .. ' (' .. L['High'] .. ')', 
	}
	I.guidSortableByOrder = {'name', 'INVERTname', 'rankIndex', 'INVERTrankIndex', 'class', 'INVERTclass', 'INVERTlevel', 'level'}

	-- Specs and roles for each class
	I.classSpecs = {
		WARRIOR = {
			FURY = { text = L['Fury'], role = "DAMAGER" }, 
			ARMS = { text = L['ARMS'], role = "DAMAGER" },
			PROTECTION = { text = L['Protection'], role = "TANK" },
		}, 
		DEATHKNIGHT = { 
			BLOOD = { text = L['Blood'], role = "TANK" },
			FROST = { text = L['Frost'], role = "DAMAGER" },
			UNHOLY = { text = L['Unholy'], role = "DAMAGER" }, 
		},
		PALADIN = { 
			HOLY = { text = L['Holy'], role = "HEALER" },
			RETRIBUTION = { text = L[''], role = "" },
			PROTECTION = { text = L[''], role = "" },
		},
		PRIEST = {
			HOLY = { text = L[''], role = "" },
			SHADOW = { text = L[''], role = "" },
			DISCIPLINE = { text = L[''], role = "" },
		},
		SHAMAN = { 
			ELEMENTAL = { text = L[''], role = "" },
			ENHANCEMENT = { text = L[''], role = "" },
			RESTORATION = { text = L[''], role = "" },
		},
		DRUID = { 
			RESTORATION = { text = L[''], role = "" },
			BALANCE = { text = L[''], role = "" },
			FERAL_CAT = { text = L[''], role = "" },
			FERAL_BEAR = { text = L[''], role = "" },
		},
		ROGUE = { },
		MAGE = { },
		WARLOCK = { },
		HUNTER = { },
	}

end