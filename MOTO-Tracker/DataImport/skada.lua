--###################################
--	Import dps from Skada (http://www.curse.com/addons/wow/skada)
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

if not A.DataImport then
	A.DataImport = {}
end
A.DataImport.skada = {}

-- Local versions is faster
tInsert = table.insert
local sUpper = string.upper

-- Do we have skada
function A.DataImport.skada:IsEnabled()
	if Skada and Skada.GetWindows and #Skada:GetWindows() >= 1 then
		return true
	else
		return false
	end 
end

-- Returns a list of name: dps. Calculated pretty
-- much the same as in the damage module for Skada
function A.DataImport.skada:GetDPSForPlayer( playerName )
	if not self:IsEnabled() then return nil end

	local window = 1 -- Might have to add an option to choose here
	if not Skada:GetWindows()[window] then return nil end

	local set = Skada:GetWindows()[window]:get_selected_set()
	if not set then return nil end
	
	local playerDPS = nil
	for i, player in ipairs(set.players) do
		if sUpper(player.name) == sUpper(playerName) then
			if player.damage > 0 then
				local totaltime = Skada:PlayerActiveTime(set, player)
				local dps = player.damage / math.max(1, totaltime)
				playerDPS = dps
			end
			break
		end
	end

	return playerDPS
end
