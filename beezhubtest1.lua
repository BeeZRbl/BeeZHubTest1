local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ================= SAVE SYSTEM =================

local SAVE_FILE = "NameHub_Save.json"

local savedData = {
	Text = "",
	Toggle = false
}

if isfile and isfile(SAVE_FILE) then
	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(SAVE_FILE))
	end)
	if success and data then
		savedData = data
	end
end

local function saveDataToFile()
	if writefile then
		writefile(SAVE_FILE, HttpService:JSONEncode(savedData))
	end
end

-- ================= HIDE NAME =================

local function hideName(name)
	local visibleLength = math.max(3, math.floor(#name * 0.5))
	local hiddenPart = string.rep("*", #name - visibleLength)
	return string.sub(name, 1, visibleLength) .. hiddenPart
end

-- ================= GUI =================

local nameHub = Instance.new("ScreenGui")
nameHub.Name = "NameHub"
nameHub.ResetOnSpawn = false
nameHub.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Parent = nameHub
mainFrame.Size = UDim2.new(0.28, 0, 0.19, 0) -- NHỎ LẠI
mainFrame.Position = UDim2.new(0.36, 0, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0.15, 0)

-- ================= TAB =================

local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1, 0, 0.25, 0)
tabFrame.BackgroundTransparency = 1

local function createTab(text, pos)
	local btn = Instance.new("TextButton", tabFrame)
	btn.Size = UDim2.new(0.33, 0, 1, 0)
	btn.Position = UDim2.new(pos, 0, 0, 0)
	btn.Text = text
	btn.BackgroundTransparency = 1
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	return btn
end

local noteTab = createTab("📌 Note", 0)
local statusTab = createTab("📊 Status", 0.33)
local settingTab = createTab("⚙ Setting", 0.66)

-- ================= PAGES =================

local function createPage()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0.75, 0)
	frame.Position = UDim2.new(0, 0, 0.25, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = mainFrame
	return frame
end

local notePage = createPage()
local statusPage = createPage()
local settingPage = createPage()

statusPage.Visible = false
settingPage.Visible = false

-- ================= NOTE PAGE =================

local nameLabel = Instance.new("TextLabel", notePage)
nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.new(1,1,1)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = "👤 Tên : " .. hideName(player.Name)

local jobBox = Instance.new("TextBox", notePage)
jobBox.Size = UDim2.new(0.9, 0, 0.4, 0)
jobBox.Position = UDim2.new(0.05, 0, 0.55, 0)
jobBox.BackgroundTransparency = 1
jobBox.TextColor3 = Color3.new(1,1,1)
jobBox.TextScaled = true
jobBox.Font = Enum.Font.GothamBold
jobBox.ClearTextOnFocus = false
jobBox.TextWrapped = true
jobBox.Text = savedData.Text

-- ================= STATUS PAGE =================

local playerCountLabel = Instance.new("TextLabel", statusPage)
playerCountLabel.Size = UDim2.new(1, 0, 1, 0)
playerCountLabel.BackgroundTransparency = 1
playerCountLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
playerCountLabel.TextScaled = true
playerCountLabel.Font = Enum.Font.GothamBold

local function updatePlayerCount()
	playerCountLabel.Text = "👥 Players in server: " .. #Players:GetPlayers()
end

Players.PlayerAdded:Connect(updatePlayerCount)
Players.PlayerRemoving:Connect(updatePlayerCount)
updatePlayerCount()

-- ================= SETTING PAGE =================

local saveLabel = Instance.new("TextLabel", settingPage)
saveLabel.Size = UDim2.new(0.6,0,0.5,0)
saveLabel.BackgroundTransparency = 1
saveLabel.Text = "Save Text"
saveLabel.TextScaled = true
saveLabel.Font = Enum.Font.GothamBold
saveLabel.TextColor3 = Color3.new(1,1,1)

-- TOGGLE nhỏ lại theo UI

local toggle = Instance.new("Frame", settingPage)
toggle.Size = UDim2.new(0,60,0,28)
toggle.Position = UDim2.new(0.72,0,0.25,-14)
toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)

local circle = Instance.new("Frame", toggle)
circle.Size = UDim2.new(0,22,0,22)
circle.Position = UDim2.new(0,3,0.5,-11)
circle.BackgroundColor3 = Color3.fromRGB(255,140,0)
Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

local saved = savedData.Toggle

if saved then
	circle.Position = UDim2.new(1,-25,0.5,-11)
	jobBox.TextEditable = false
end

toggle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		saved = not saved
		savedData.Toggle = saved
		
		if saved then
			circle:TweenPosition(UDim2.new(1,-25,0.5,-11),"Out","Quad",0.2,true)
			jobBox.TextEditable = false
			savedData.Text = jobBox.Text
		else
			circle:TweenPosition(UDim2.new(0,3,0.5,-11),"Out","Quad",0.2,true)
			jobBox.TextEditable = true
		end
		
		saveDataToFile()
	end
end)

jobBox:GetPropertyChangedSignal("Text"):Connect(function()
	if saved then
		savedData.Text = jobBox.Text
		saveDataToFile()
	end
end)

-- ================= FPS =================

local fpsLabel = Instance.new("TextLabel", settingPage)
fpsLabel.Size = UDim2.new(1,0,0.5,0)
fpsLabel.Position = UDim2.new(0,0,0.5,0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.Text = "Click to toggle FPS"

local fpsEnabled = false
local lastTime = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
	frames += 1
	if tick() - lastTime >= 1 then
		if fpsEnabled then
			fpsLabel.Text = "🎮 FPS: " .. frames
		end
		frames = 0
		lastTime = tick()
	end
end)

fpsLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fpsEnabled = not fpsEnabled
		if not fpsEnabled then
			fpsLabel.Text = "Click to toggle FPS"
		end
	end
end)

-- ================= TAB SWITCH =================

noteTab.MouseButton1Click:Connect(function()
	notePage.Visible = true
	statusPage.Visible = false
	settingPage.Visible = false
end)

statusTab.MouseButton1Click:Connect(function()
	notePage.Visible = false
	statusPage.Visible = true
	settingPage.Visible = false
end)

settingTab.MouseButton1Click:Connect(function()
	notePage.Visible = false
	statusPage.Visible = false
	settingPage.Visible = true
end)
