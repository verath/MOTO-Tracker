--###################################
--   Set Up
--###################################
MOTOTracker = {
	addon = LibStub("AceAddon-3.0"):NewAddon("MOTOTracker", "AceConsole-3.0", "AceEvent-3.0"),
	locale = LibStub("AceLocale-3.0"):GetLocale("MOTOTracker", true),
	info = { -- Static global values
		versionName = '0.01a',
		addonName = 'MOTOTracker',
	}
}

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info




--###################################
--   Helper Functions
--###################################

function A:UpdateGuildRoster()
	
end




--###################################
--   Event functions
--###################################

-- Called by ace3 once saved variables are available
function A:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MOTOTrackerDB", MOTOTracker.defaults)

	self:RegisterEvent('PLAYER_LOGIN', 'PlayerLogin')
end

-- When player enters world
function A:PlayerLogin()
	if self.db.char.loadMessage then
		A:Print(L['MOTO Tracker loaded.'])
	end
end
