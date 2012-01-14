--###################################
--	Events Info tab
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")


local treeGroupFrame
local eventsInfoDB = {}


function A.GUI.tabs.events:DrawTab(container)
	eventsInfoDB = A.db.global.core.GUI.eventsInfo

	do -- Setup the tree element
		local treeG = AceGUI:Create("TreeGroup")
		treeG:SetFullWidth(true)
		treeG:SetFullHeight(true)
		treeG:EnableButtonTooltips(false)
		treeGroupFrame = treeG
	end

	-- Add the TreeGroup element
	container:AddChild(treeGroupFrame)

	treeGroupFrame:SetCallback("OnGroupSelected", function(container, event, group)
		--drawMainTreeArea(container, charName)
	end)
	
	-- Generate the tree for the TreeGroup
	--A.GUI.tabs.rosterInfo:GenerateTreeStructure()
end
