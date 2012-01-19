--###################################
--	Events Info tab
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")


local treeGroupFrame, summaryGroupFrame
local eventsInfoDB = {}


function A.GUI.tabs.eventsInfo:DrawTab(container)
	eventsInfoDB = A.db.global.core.GUI.eventsInfo

	container:SetLayout("Flow")
	container:SetFullHeight(true)
	container:SetFullWidth(true)
	local outerContainer = container

	--[[do -- inner container, to contain tree and summary groups
		container = AceGUI:Create("SimpleGroup")
		container:SetLayout("Flow")
		container:SetFullHeight(true)
		container:SetFullWidth(true)

		outerContainer:AddChild(container)
	end]]


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
		container:AddChild(treeG)
		
		treeGroupFrame = treeG
	end

	do -- summary group container
		summaryGroupFrame = AceGUI:Create("InlineGroup")
		summaryGroupFrame:SetLayout("Flow")
		summaryGroupFrame:SetFullHeight(true)
		summaryGroupFrame:SetFullWidth(false)
		summaryGroupFrame:SetRelativeWidth(0.33)

		treeGroupFrame:AddChild(summaryGroupFrame)
	end

	--[[
	local scrollContainer
	do -- Add an inner scrolling container
		scrollContainer = AceGUI:Create("ScrollFrame")
		scrollContainer:SetLayout("Flow")
		scrollContainer:SetFullWidth(true)
		summaryGroupFrame:AddChild(scrollContainer)

		-- The scroll frame should be the container
		--container = scrollContainer

		do -- Search EditBox
			local searchTextbox = AceGUI:Create("EditBox")
			searchTextbox:SetLabel(L['Search'])
			searchTextbox:SetText()
			searchTextbox:DisableButton(true)
			scrollContainer:AddChild(searchTextbox)
		end
	end
	]]

	
	


	outerContainer:DoLayout()
	container:DoLayout()
	
	-- Generate the tree for the TreeGroup
	--A.GUI.tabs.rosterInfo:GenerateTreeStructure()
end
