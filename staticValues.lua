--###################################
--	Static Values
--###################################

-- addon, locale, info
local A,L,I = unpack(select(2, ...))

local tIns = table.insert

-- Calls on initialization of the addon,
-- loads/sets most static values (some are set later as not all are available)
function A:LoadStaticValues()
	I.hasGuild = IsInGuild()
	I.charName = select(1, UnitName("player"))
	I.charClass = L[ select(2, UnitClass("player")) ];

	-- These are all update later on
	I.numGuildAFK, I.numGuildOnline, I.numGuildMembers = nil, nil, nil
	I.guildMembers, I.guildOnline, I.guildAFK = {}, {}, {}

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
		[L['WARRIOR']] = {
			[L['FURY']] = { text = L['Fury'], role = "DAMAGER" }, 
			[L['ARMS']] = { text = L['Arms'], role = "DAMAGER" },
			[L['PROTECTION']] = { text = L['Protection'], role = "TANK" },
		}, 
		[L['DEATHKNIGHT']] = { 
			[L['BLOOD']] = { text = L['Blood'], role = "TANK" },
			[L['FROST']] = { text = L['Frost'], role = "DAMAGER" },
			[L['UNHOLY']] = { text = L['Unholy'], role = "DAMAGER" }, 
		},
		[L['PALADIN']] = { 
			[L['HOLY']] = { text = L['Holy'], role = "HEALER" },
			[L['RETRIBUTION']] = { text = L['Retribution'], role = "DAMAGER" },
			[L['PROTECTION']] = { text = L['Protection'], role = "TANK" },
		},
		[L['PRIEST']] = {
			[L['HOLY']] = { text = L['Holy'], role = "HEALER" },
			[L['SHADOW']] = { text = L['Shadow'], role = "DAMAGER" },
			[L['DISCIPLINE']] = { text = L['Discipline'], role = "HEALER" },
		},
		[L['SHAMAN']] = { 
			[L['ELEMENTAL']] = { text = L['Elemental'], role = "DAMAGER" },
			[L['ENHANCEMENT']] = { text = L['Enhancement'], role = "DAMAGER" },
			[L['RESTORATION']] = { text = L['Restoration'], role = "HEALER" },
		},
		[L['DRUID']] = { 
			[L['RESTORATION']] = { text = L['Restoration'], role = "HEALER" },
			[L['BALANCE']] = { text = L['Balance'], role = "DAMAGER" },
			[L['FERAL CAT']] = { text = L['Feral (Cat)'], role = "DAMAGER" },
			[L['FERAL BEAR']] = { text = L['Feral (Bear)'], role = "TANK" },
		},
		[L['ROGUE']] = { 
			[L['COMBAT']] = { text = L['Combat'], role = "DAMAGER" },
			[L['ASSASSINATION']] = { text = L['Assassination'], role = "DAMAGER" },
			[L['SUBTLETY']] = { text = L['Subtlety'], role = "DAMAGER" }, 
		},
		[L['MAGE']] = {
			[L['FIRE']] = { text = L['Fire'], role = "DAMAGER" },
			[L['FROST']] = { text = L['Frost'], role = "DAMAGER" },
			[L['ARCANE']] = { text = L['Arcane'], role = "DAMAGER" },
		},
		[L['WARLOCK']] = {
			[L['AFFLICTION']] = { text = L['Affliction'], role = "DAMAGER" },
			[L['DEMONOLOGY']] = { text = L['Demonology'], role = "DAMAGER" },
			[L['DESTRUCTION']] = { text = L['Destruction'], role = "DAMAGER" },
		},
		[L['HUNTER']] = {
			[L['BEAST MASTERY']] = { text = L['Beast Mastery'], role = "DAMAGER" }, 
			[L['SURVIVAL']] = { text = L['Survival'], role = "DAMAGER" },
			[L['MARKSMANSHIP']] = { text = L['Marksmanship'], role = "DAMAGER" }, 
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
