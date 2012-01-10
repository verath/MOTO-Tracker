local L = LibStub("AceLocale-3.0"):NewLocale("MOTOTracker", "enUS", true)

if L then
	-- Static Values
	L['Fury'] = true
	L['Arms'] = true
	L['Protection'] = true
	L['Blood'] = true
	L['Frost'] = true
	L['Unholy'] = true
	L['Holy'] = true
	L['Retribution'] = true
	L['Shadow'] = true
	L['Discipline'] = true
	L['Elemental'] = true
	L['Enhancement'] = true
	L['Restoration'] = true
	L['Balance'] = true
	L['Feral (Cat)'] = true
	L['Feral (Bear)'] = true
	L['Combat'] = true
	L['Assassination'] = true
	L['Subtlety'] = true
	L['Fire'] = true
	L['Frost'] = true
	L['Arcane'] = true
	L['Affliction'] = true
	L['Demonology'] = true
	L['Destruction'] = true
	L['Beast Mastery'] = true
	L['Survival'] = true
	L['Marksmanship'] = true
	L['NONE'] = true


	-- Options
	L['Sync Settings'] = true
	L['Show load message'] = true
	L['Display a message when the addon is loaded or enabled.'] = true
	L['Character Specific Settings'] = true
	L['General Settings'] = true
	L['Restore Defaults'] = true
	L['Restores ALL settings to their default values. Does not clear the database.'] = true
	L['Are you sure you want to restore ALL settings?'] = true
	L['Reset Database'] = true
	L['Resets the whole database (including settings).'] = true
	L['Are you sure you want to reset the whole database? This can not be undone!'] = true
	L['Auto update own specs'] = true
	L['Automatically updates your characters main spec and off spec to your current talent specs when loggin in and/or changing specs.'] = true
	L['Enabled'] = true
	L['Enable or disable syncing.'] = true

	
	-- Core
	L['MOTO Tracker'] = true
	L['MOTO Tracker enabled.'] = true
	L['Version'] = true
	L['Name'] = true
	L['Main Spec'] = true
	L['Off Spec'] = true
	L['Guild Rank'] = true
	L['Level'] = true
	L['Class'] = true

	-- GUI
	L['A-Z'] = true
	L['Z-A'] = true
	L['High'] = true
	L['Low'] = true
	L['MOTO Tracker, version: %s'] = true
	L['Members'] = true
	L['<Not in a guild>'] = true
	L['Roster Info'] = true
	L['Something Else'] = true
	L['Primary sort by'] = true
	L['Secondary sort by'] = true
	L['Only 85s'] = true
	L['Hide offline'] = true
	L['Search'] = true
	L['General'] = true
	L['Guild Note'] = true
	L['Officer Note'] = true
	L['Private Note'] = true
	L['Online'] = true
	L['Offline'] = true
	L['Away'] = true
	L['Refresh'] = true
	L['Main'] = true
	L['Alts'] = true
	L['Currently in'] = true
	L['Last seen in'] = true
	L['Main Spec/Off Spec'] = true
	L['Share Char'] = true

	-- Sync
	L['%s is sharing data for %s.|n|nDo you want to recceive this data (this will overwrite your own data for %s)?'] = true
	L['Already sharing a character!|n|nPlease wait at least 20 seconds after sending a character before sending another one.'] = true
	L['Sharing %s for 20 seconds.'] = true
	L['Sent data for %s to %s.'] = true
end
