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
function A.DataImport.skada:GetSelectedSetDPS( window )
	if not self:IsEnabled() then return nil end

	local window = window or 1
	if not Skada:GetWindows()[window] then return nil end

	local set = Skada:GetWindows()[window]:get_selected_set()
	if not set then return nil end
	
	local playersDPS = {}
	for i, player in ipairs(set.players) do
		if player.damage > 0 then
			local totaltime = Skada:PlayerActiveTime(set, player)
			local dps = player.damage / math.max(1, totaltime)
			playersDPS[player.name] = dps
		end
	end

	if #playersDPS >= 1 then 
		return playersDPS 
	else 
		return nil
	end
end
