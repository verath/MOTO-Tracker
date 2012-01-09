local L = LibStub("AceLocale-3.0"):NewLocale("MOTOTracker", "enUS", true)

if L then
	-- Options
	L['Show load message'] = true
	L['Display a message when the addon is loaded or enabled.'] = true
	L['Character Specific Settings'] = true
	L['Global Settings'] = true
	L['Restore Defaults'] = true
	L['Restores ALL settings to their default values. Does not clear the database.'] = true
	L['Are you sure you want to restore ALL settings?'] = true
	L['Reset Database'] = true
	L['Resets the whole database (including settings).'] = true
	L['Are you sure you want to reset the whole database? This can not be undone!'] = true
	
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
end
