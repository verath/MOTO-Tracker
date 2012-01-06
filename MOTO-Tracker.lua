--###################################
--   Set Up
--###################################
MOTOTracker = {}
MOTOTracker.addon = LibStub("AceAddon-3.0"):NewAddon("MOTOTracker", "AceConsole-3.0", "AceEvent-3.0")
MOTOTracker.locale = LibStub("AceLocale-3.0"):GetLocale("MOTOTracker", true)

MOTOTracker.info = {
	versionName = '0.01a',
	addonName = 'MOTOTracker',
	addonNameSpace = 'MOTO Tracker',
}

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info


function A:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MOTOTrackerDB", MOTOTracker.defaults)

	self:RegisterEvent('PLAYER_LOGIN', 'PlayerLogin')
end

function A:PlayerLogin()
	if self.db.char.LoadMessage then
		A:Print(L['MOTO Tracker loaded.'])
	end
end


