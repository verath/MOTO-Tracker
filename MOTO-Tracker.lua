--###################################
--   Set Up
--###################################

MOTOTracker = LibStub("AceAddon-3.0"):NewAddon("MOTOTracker", "AceConsole-3.0", "AceEvent-3.0");

function MOTOTracker:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MOTOTrackerDB")
end
