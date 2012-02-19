--###################################
--	LibDataBroker Feed
--###################################


local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

local dataobj

function A.GUI.LDB:SetupLDB()
	dataobj = LibStub("LibDataBroker-1.1"):NewDataObject('MOTOTracker', {
		type = 'data source',
		text = L['MOTO Tracker'],
	})

	function dataobj:OnClick( clickedframe, button )
		if IsControlKeyDown() then
			InterfaceOptionsFrame_OpenToCategory(A.ConfigFrame)
		else
			A.GUI:ToggleMainFrame()
		end
	end

	function dataobj:OnTooltipShow()
		self:AddLine("This is a test!")
		self:AddLine("Don't mind me...")
	end
end