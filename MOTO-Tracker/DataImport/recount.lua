--###################################
--	Import dps from Recount (http://www.curse.com/addons/wow/recount)
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

if not A.DataImport then
	A.DataImport = {}
end
A.DataImport.recount = {}

-- Do we have recount
function A.DataImport.recount:IsEnabled()
	if Recount and Recount.HasEnabled == true then
		return true
	else
		return false
	end 
end


