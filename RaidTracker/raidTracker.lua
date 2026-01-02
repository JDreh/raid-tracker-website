print("Raid Tracker Loaded")

if not RaidDB then
	RaidDB = {}
end

-- Create main frame
local mainFrame = CreateFrame("Frame", "MyAddonMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(600, 450)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame.TitleBg:SetHeight(30)
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)
mainFrame.title:SetText("Raid Tracker")
mainFrame:Hide()


-- Player name display
mainFrame.playerName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.playerName:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -35)
mainFrame.playerName:SetText("Character: " .. UnitName("player"))

-- Import button in top left
local importButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
importButton:SetSize(80, 25)
importButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -60)
importButton:SetText("Import")

-- Create scroll frame for raid list
local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -95)
scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -30, 10)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(scrollFrame:GetWidth(), 1)
scrollFrame:SetScrollChild(scrollChild)

-- Table to store raid entry frames
local raidEntryFrames = {}

local function clearRaidList()
	for _, frame in ipairs(raidEntryFrames) do
		frame:Hide()
		frame:SetParent(nil)
	end
	raidEntryFrames = {}
end

local function updateRaidDisplay()
	clearRaidList()

	-- Convert RaidDB to sorted array
	local raids = {}
	for raidName, timestamp in pairs(RaidDB) do
		table.insert(raids, {name = raidName, time = timestamp})
	end

	-- Sort by timestamp
	table.sort(raids, function(a, b) return a.time < b.time end)

	-- Display raids
	local yOffset = -5
	for i, raid in ipairs(raids) do
		local entryFrame = CreateFrame("Frame", nil, scrollChild)
		entryFrame:SetSize(scrollChild:GetWidth() - 10, 30)
		entryFrame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, yOffset)

		-- Background
		local bg = entryFrame:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		if i % 2 == 0 then
			bg:SetColorTexture(0.2, 0.2, 0.2, 0.3)
		else
			bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)
		end

		-- Raid name
		local nameText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		nameText:SetPoint("LEFT", entryFrame, "LEFT", 5, 0)
		nameText:SetText(raid.name)

		-- Delete button
		local deleteButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
		deleteButton:SetSize(50, 20)
		deleteButton:SetPoint("RIGHT", entryFrame, "RIGHT", -5, 0)
		deleteButton:SetText("X")
		deleteButton:SetScript("OnClick", function()
			RaidDB[raid.name] = nil
			print("Deleted: " .. raid.name)
			updateRaidDisplay()
		end)

		-- Timestamp and countdown
		local currentTime = time()
		local timeRemaining = raid.time - currentTime
		local daysUntil = math.floor(timeRemaining / 86400)
		local hoursUntil = math.floor((timeRemaining % 86400) / 3600)

		local timeText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		timeText:SetPoint("RIGHT", deleteButton, "LEFT", -5, 0)

		if timeRemaining > 0 then
			if daysUntil > 0 then
				timeText:SetText(string.format("%dd %dh", daysUntil, hoursUntil))
			else
				timeText:SetText(string.format("%dh", hoursUntil))
			end
			timeText:SetTextColor(0.5, 1, 0.5)
		else
			timeText:SetText("Past")
			timeText:SetTextColor(0.7, 0.7, 0.7)
		end

		table.insert(raidEntryFrames, entryFrame)
		yOffset = yOffset - 35
	end

	scrollChild:SetHeight(math.abs(yOffset) + 5)
end

-- Create import dialog frame
local importFrame = CreateFrame("Frame", "RaidTrackerImportFrame", UIParent, "BackdropTemplate")
importFrame:SetSize(400, 300)
importFrame:SetPoint("CENTER", UIParent, "CENTER", 50, 50)
importFrame:Hide()
importFrame:SetFrameStrata("DIALOG")
importFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = {left = 11, right = 12, top = 12, bottom = 11}
})

-- Title bar
local titleBar = importFrame:CreateTexture(nil, "ARTWORK")
titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
titleBar:SetSize(256, 64)
titleBar:SetPoint("TOP", 0, 12)

importFrame.title = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
importFrame.title:SetPoint("TOP", titleBar, "TOP", 0, -14)
importFrame.title:SetText("Import Raid Data")

-- Close button (X)
local closeButton = CreateFrame("Button", nil, importFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", importFrame, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function()
	importFrame:Hide()
end)

-- Instructions text
local instructionText = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
instructionText:SetPoint("TOPLEFT", importFrame, "TOPLEFT", 20, -50)
instructionText:SetText("Paste raid data (one per line):")

-- Create multi-line EditBox with ScrollFrame
local importScrollFrame = CreateFrame("ScrollFrame", nil, importFrame, "UIPanelScrollFrameTemplate")
importScrollFrame:SetPoint("TOPLEFT", importFrame, "TOPLEFT", 20, -75)
importScrollFrame:SetPoint("BOTTOMRIGHT", importFrame, "BOTTOMRIGHT", -35, 55)

local importEditBox = CreateFrame("EditBox", nil, importScrollFrame)
importEditBox:SetMultiLine(true)
importEditBox:SetAutoFocus(false)
importEditBox:SetFontObject("ChatFontNormal")
importEditBox:SetWidth(importScrollFrame:GetWidth())
importEditBox:SetMaxLetters(0)
importEditBox:SetScript("OnEscapePressed", function(self)
	importFrame:Hide()
end)

importScrollFrame:SetScrollChild(importEditBox)

-- Import button
local doImportButton = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
doImportButton:SetSize(100, 25)
doImportButton:SetPoint("BOTTOMLEFT", importFrame, "BOTTOMLEFT", 20, 20)
doImportButton:SetText("Import")
doImportButton:SetScript("OnClick", function()
	local input = importEditBox:GetText()

	if input and input ~= "" then
		-- Parse the input (format: "title,startTime,name" per line)
		local lines = {}
		for line in string.gmatch(input, "[^\r\n]+") do
			table.insert(lines, line)
		end

		local imported = 0

		for i, line in ipairs(lines) do
			if line and line ~= "" then
				local parts = {strsplit(",", line)}

				if #parts >= 2 then
					local raidName = parts[1]
					local timestamp = tonumber(parts[2])

					if raidName and timestamp then
						RaidDB[raidName] = timestamp
						imported = imported + 1
					end
				end
			end
		end

		print("Imported " .. imported .. " raid entries")
		updateRaidDisplay()
		importFrame:Hide()
	end
end)

-- Cancel button
local cancelImportButton = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
cancelImportButton:SetSize(100, 25)
cancelImportButton:SetPoint("BOTTOMRIGHT", importFrame, "BOTTOMRIGHT", -20, 20)
cancelImportButton:SetText("Cancel")
cancelImportButton:SetScript("OnClick", function()
	importFrame:Hide()
end)

-- Make import frame draggable
importFrame:EnableMouse(true)
importFrame:SetMovable(true)
importFrame:RegisterForDrag("LeftButton")
importFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
importFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

-- Allow ESC to close import frame
table.insert(UISpecialFrames, "RaidTrackerImportFrame")

-- Import button click handler
importButton:SetScript("OnClick", function()
	importEditBox:SetText("")
	importFrame:Show()
	importEditBox:SetFocus()
end)

-- Create minimap button
local minimapButton = CreateFrame("Button", "RaidTrackerMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -15, 0)

-- Button background
local minimapButtonBg = minimapButton:CreateTexture(nil, "BACKGROUND")
minimapButtonBg:SetSize(20, 20)
minimapButtonBg:SetPoint("CENTER")
minimapButtonBg:SetTexture("Interface\\Icons\\INV_Misc_Bell_01")

-- Button border
local minimapButtonBorder = minimapButton:CreateTexture(nil, "OVERLAY")
minimapButtonBorder:SetSize(52, 52)
minimapButtonBorder:SetPoint("TOPLEFT")
minimapButtonBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

-- Make it draggable around the minimap
minimapButton:SetMovable(true)
minimapButton:EnableMouse(true)
minimapButton:RegisterForDrag("LeftButton")

local function updateMinimapButtonPosition(angle)
	local x = math.cos(angle) * 80
	local y = math.sin(angle) * 80
	minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local angle = 0
minimapButton:SetScript("OnDragStart", function(self)
	self:LockHighlight()
	self:SetScript("OnUpdate", function()
		local mx, my = Minimap:GetCenter()
		local px, py = GetCursorPosition()
		local scale = Minimap:GetEffectiveScale()
		px, py = px / scale, py / scale
		angle = math.atan2(py - my, px - mx)
		updateMinimapButtonPosition(angle)
	end)
end)

minimapButton:SetScript("OnDragStop", function(self)
	self:UnlockHighlight()
	self:SetScript("OnUpdate", nil)
end)

-- Click to open main frame
minimapButton:SetScript("OnClick", function(self, button)
	if mainFrame:IsShown() then
		mainFrame:Hide()
	else
		mainFrame:Show()
	end
end)

-- Tooltip on hover
minimapButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText("Raid Tracker", 1, 1, 1)

	-- Get upcoming raids
	local raids = {}
	local currentTime = time()
	for raidName, timestamp in pairs(RaidDB) do
		if timestamp >= currentTime then
			table.insert(raids, {name = raidName, time = timestamp})
		end
	end

	-- Sort by time
	table.sort(raids, function(a, b) return a.time < b.time end)

	if #raids > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Upcoming Raids:", 0.5, 1, 0.5)

		for i = 1, math.min(#raids, 5) do
			local raid = raids[i]
			local timeRemaining = raid.time - currentTime
			local daysUntil = math.floor(timeRemaining / 86400)
			local hoursUntil = math.floor((timeRemaining % 86400) / 3600)

			local timeStr
			if daysUntil > 0 then
				timeStr = string.format("%dd %dh", daysUntil, hoursUntil)
			else
				timeStr = string.format("%dh", hoursUntil)
			end

			GameTooltip:AddDoubleLine(raid.name, timeStr, 1, 1, 1, 0.8, 0.8, 0.8)
		end

		if #raids > 5 then
			GameTooltip:AddLine(string.format("... and %d more", #raids - 5), 0.6, 0.6, 0.6)
		end
	else
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("No upcoming raids", 0.7, 0.7, 0.7)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Click: Toggle tracker", 0.5, 0.8, 1)
	GameTooltip:AddLine("Drag: Move button", 0.5, 0.8, 1)

	GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
end)

-- Enable dragging
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
mainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

-- OnShow handler
mainFrame:SetScript("OnShow", function()
	PlaySound(808)
	updateRaidDisplay()
end)

-- OnHide handler
mainFrame:SetScript("OnHide", function()
	PlaySound(808)
end)

-- Slash commands
SLASH_RAIDTRACKER1 = "/raidtracker"
SLASH_RAIDTRACKER2 = "/rt"
SlashCmdList["RAIDTRACKER"] = function()
	if mainFrame:IsShown() then
		mainFrame:Hide()
	else
		mainFrame:Show()
	end
end

-- Allow ESC key to close frame
table.insert(UISpecialFrames, "MyAddonMainFrame")
