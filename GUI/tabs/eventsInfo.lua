--###################################
--	Events Info tab
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")


local treeGroupFrame, summaryGroupFrame
local eventsInfoDB = {}


function A.GUI.tabs.eventsInfo:DrawTab(container)
	eventsInfoDB = A.db.global.core.GUI.eventsInfo

	do -- Tree group
		local treeG = AceGUI:Create("TreeGroup")
		treeG:SetFullWidth(true)
		treeG:SetFullHeight(true)
		--treeG:SetRelativeWidth(0.66)
		treeG:EnableButtonTooltips(false)
		treeG:SetTree({})
		treeG:SetCallback("OnGroupSelected", function(container, event, group)
			--drawMainTreeArea(container, charName)
		end)
		
		treeGroupFrame = treeG
		container:AddChild(treeGroupFrame)
	end

	
	-- Generate the tree for the TreeGroup
	--A.GUI.tabs.rosterInfo:GenerateTreeStructure()
end
