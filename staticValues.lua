--###################################
--	Static Values
--###################################

-- addon, locale, info
local A,L,I = unpack(select(2, ...))

local tableInsert = table.insert

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

	-- Spec ids for each class
	-- http://www.wowpedia.org/API_GetInspectSpecialization
	I.classSpecs = {
		[L['WARRIOR']] = {
			[71] = L['Arms'],
			[72] = L['Fury'],
			[73] = L['Protection']
		},
		[L['DEATHKNIGHT']] = { 
			[250] = "Blood", 
			[251] = "Frost", 
			[252] = "Unholy",
		},
		[L['DRUID']] = { 
			[102] = L['Balance'],
			[103] = L['Feral'],
			[104] = L['Guardian'],
			[105] = L['Restoration'],
		},
		[L['HUNTER']] = {
			[253] = L['Beast Mastery'],
			[254] = L['Marksmanship'],
			[255] = L['Survival'],
		},
		[L['MAGE']] = {
			[62] = L['Arcane'],
			[63] = L['Fire'],
			[64] = L['Frost'],
		},
		[L['MONK']] = {
			[268] = L['Brewmaster'],
			[270] = L['Mistweaver'],
			[269] = L['Windwalker'],
		},
		[L['PALADIN']] = { 
			[65] = L['Holy'],
			[66] = L['Protection'],
			[67] = L['Retribution'],
		},
		[L['PRIEST']] = {
			[256] = L['Discipline'],
			[257] = L['Holy'],
			[258] = L['Shadow'],
		},
		[L['ROGUE']] = { 
			[259] = L['Assassination'],
			[260] = L['Combat'],
			[261] = L['Subtlety'],
		},
		[L['SHAMAN']] = { 
			[262] = L['Elemental'],
			[263] = L['Enhancement'],
			[264] = L['Restoration'],
		},

		[L['WARLOCK']] = {
			[265] = L['Affliction'],
			[266] = L['Demonology'],
			[267] = L['Destruction'],
		},
	}

	-- List that can be used with dropdwons for each class
	I.classSpecDropdownList = {}
	I.classSpecDropdownListOrder = {}
	(function ()
		
		for class, specs in pairs(I.classSpecs) do
			I.classSpecDropdownList[class] = { [-1] = L['NONE'] }
			I.classSpecDropdownListOrder[class] = {-1}
			for specId, specName in pairs( specs ) do
				I.classSpecDropdownList[class][specId] = specName
				tableInsert(I.classSpecDropdownListOrder[class], specId)
			end
		end	
	end)()

end
