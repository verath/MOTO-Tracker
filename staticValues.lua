--###################################
--	Static Values
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

local tIns = table.insert

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
			ARMS = { text = L['Arms'], role = "DAMAGER" },
			PROTECTION = { text = L['Protection'], role = "TANK" },
		}, 
		DEATHKNIGHT = { 
			BLOOD = { text = L['Blood'], role = "TANK" },
			FROST = { text = L['Frost'], role = "DAMAGER" },
			UNHOLY = { text = L['Unholy'], role = "DAMAGER" }, 
		},
		PALADIN = { 
			HOLY = { text = L['Holy'], role = "HEALER" },
			RETRIBUTION = { text = L['Retribution'], role = "DAMAGER" },
			PROTECTION = { text = L['Protection'], role = "TANK" },
		},
		PRIEST = {
			HOLY = { text = L['Holy'], role = "HEALER" },
			SHADOW = { text = L['Shadow'], role = "DAMAGER" },
			DISCIPLINE = { text = L['Discipline'], role = "HEALER" },
		},
		SHAMAN = { 
			ELEMENTAL = { text = L['Elemental'], role = "DAMAGER" },
			ENHANCEMENT = { text = L['Enhancement'], role = "DAMAGER" },
			RESTORATION = { text = L['Restoration'], role = "HEALER" },
		},
		DRUID = { 
			RESTORATION = { text = L['Restoration'], role = "HEALER" },
			BALANCE = { text = L['Balance'], role = "DAMAGER" },
			FERAL_CAT = { text = L['Feral (Cat)'], role = "DAMAGER" },
			FERAL_BEAR = { text = L['Feral (Bear)'], role = "TANK" },
		},
		ROGUE = { 
			COMBAT = { text = L['Combat'], role = "DAMAGER" },
			ASSASSINATION = { text = L['Assassination'], role = "DAMAGER" },
			SUBTLETY = { text = L['Subtlety'], role = "DAMAGER" }, 
		},
		MAGE = {
			FIRE = { text = L['Fire'], role = "DAMAGER" },
			FROST = { text = L['Frost'], role = "DAMAGER" },
			ARCANE = { text = L['Arcane'], role = "DAMAGER" },
		},
		WARLOCK = {
			AFFLICTION = { text = L['Affliction'], role = "DAMAGER" },
			DEMONOLOGY = { text = L['Demonology'], role = "DAMAGER" },
			DESTRUCTION = { text = L['Destruction'], role = "DAMAGER" },
		},
		HUNTER = {
			BEAST_MASTERY = { text = L['Beast Mastery'], role = "DAMAGER" }, 
			SURVIVAL = { text = L['Survival'], role = "DAMAGER" },
			MARKSMANSHIP = { text = L['Marksmanship'], role = "DAMAGER" }, 
		},
	}

	-- List that can be used with dropdwons for each class
	I.classSpecDropdownList = {}
	I.classSpecDropdownListOrder = {}
	(function ()
		
		for class, specs in pairs(I.classSpecs) do
			I.classSpecDropdownList[class] = { NONE = L['NONE'] }
			I.classSpecDropdownListOrder[class] = {'NONE'}
			for spec, specValues in pairs( specs )do
				I.classSpecDropdownList[class][spec] = specValues.text
				tIns(I.classSpecDropdownListOrder[class], spec)
			end
		end	
	end)()

end
