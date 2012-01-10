local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local syncSettings = A.db.global.settings.sync

function A.sync:SendChar( charName )
	if not syncSettings.enabled then return end
	print("Sending " .. charName)
end
