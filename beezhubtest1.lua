-- Blox Fruits Auto Farm Script
-- Hoàn chỉnh với GUI tự động, không cần phím tắt

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Biến toàn cục
local autoFarmEnabled = false
local targetEnemy = nil
local farmDistance = 30
local isAttacking = false
local currentFarmMode = "Normal"
local autoFarmConnection = nil
local playerData = {}
local farmStats = {
	kills = 0,
	materials = 0,
	berries = 0,
	startTime = 0,
	experience = 0
}

-- GUI Components
local screenGui
local mainFrame
local statusLabel
local modeButtons = {}
local statLabels = {}

-- Cấu hình farm cho Blox Fruits
local farmConfigs = {
	Normal = {
		searchDistance = 50,
		priority = {"Bandit", "Monkey", "Pirate", "Brute", "Snow Bandit", "Desert Bandit"},
		attackDelay = 0.5,
		color = Color3.fromRGB(0, 170, 255)
	},
	Boss = {
		searchDistance = 100,
		priority = {"Boss", "Saber Expert", "Dark Beard", "Order", "Diamond"},
		attackDelay = 1.2,
		color = Color3.fromRGB(255, 50, 50)
	},
	Material = {
		searchDistance = 80,
		priority = {"Blox Fruit", "Material", "Chest", "Treasure", "Devil Fruit"},
		attackDelay = 0.3,
		color = Color3.fromRGB(50, 255, 50)
	},
	Elite = {
		searchDistance = 120,
		priority = {"Elite", "Raid Boss", "Golem", "Terror Shark", "Sea Beast"},
		attackDelay = 0.8,
		color = Color3.fromRGB(255, 170, 0)
	},
	AutoFarm = {
		searchDistance = 60,
		priority = {"Bandit", "Monkey", "Pirate"},
		attackDelay = 0.6,
		color = Color3.fromRGB(170, 0, 255)
	}
}

-- Các đảo trong Blox Fruits để auto di chuyển
local islands = {
	["Starter Island"] = Vector3.new(-100, 50, 100),
	["Jungle"] = Vector3.new(-500, 50, 800),
	["Pirate Village"] = Vector3.new(-1200, 50, 400),
	["Desert"] = Vector3.new(1000, 50, 1000),
	["Snow Village"] = Vector3.new(1200, 50, -800),
	["Marine Fortress"] = Vector3.new(-800, 50, -1200)
}

-- Khởi tạo GUI
local function createGUI()
	-- Tạo ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BloxFruitsAutoFarm"
	screenGui.Parent = player.PlayerGui
	
	-- Main Frame
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 350, 0, 450)
	mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	mainFrame.BackgroundTransparency = 0.2
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	
	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame
	
	-- Stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 170, 255)
	stroke.Thickness = 2
	stroke.Parent = mainFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	title.BackgroundTransparency = 0.5
	title.Text = "🍊 BLOX FRUITS AUTO FARM 🏴‍☠️"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = title
	
	-- Status Label
	statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -20, 0, 40)
	statusLabel.Position = UDim2.new(0, 10, 0, 60)
	statusLabel.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	statusLabel.BackgroundTransparency = 0.3
	statusLabel.Text = "❌ AUTO FARM: TẮT"
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.TextSize = 16
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.Parent = mainFrame
	
	local statusCorner = Instance.new("UICorner")
	statusCorner.CornerRadius = UDim.new(0, 8)
	statusCorner.Parent = statusLabel
	
	-- Mode Selection Title
	local modeTitle = Instance.new("TextLabel")
	modeTitle.Name = "ModeTitle"
	modeTitle.Size = UDim2.new(1, -20, 0, 30)
	modeTitle.Position = UDim2.new(0, 10, 0, 110)
	modeTitle.BackgroundTransparency = 1
	modeTitle.Text = "CHẾ ĐỘ FARM:"
	modeTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	modeTitle.TextSize = 14
	modeTitle.Font = Enum.Font.GothamSemibold
	modeTitle.TextXAlignment = Enum.TextXAlignment.Left
	modeTitle.Parent = mainFrame
	
	-- Tạo nút cho các chế độ farm
	local modeYPosition = 145
	local modeNames = {"Normal", "Boss", "Material", "Elite", "AutoFarm"}
	
	for i, modeName in ipairs(modeNames) do
		local button = Instance.new("TextButton")
		button.Name = modeName .. "Button"
		button.Size = UDim2.new(1, -20, 0, 40)
		button.Position = UDim2.new(0, 10, 0, modeYPosition)
		button.BackgroundColor3 = farmConfigs[modeName].color
		button.BackgroundTransparency = 0.3
		button.Text = modeName .. " FARM"
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 14
		button.Font = Enum.Font.GothamBold
		button.Parent = mainFrame
		
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = button
		
		-- Hiệu ứng hover
		button.MouseEnter:Connect(function()
			game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
		end)
		
		button.MouseLeave:Connect(function()
			game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
		end)
		
		-- Click event
		button.MouseButton1Click:Connect(function()
			if autoFarmEnabled then
				changeFarmMode(modeName)
			else
				toggleAutoFarm(modeName)
			end
		end)
		
		modeButtons[modeName] = button
		modeYPosition = modeYPosition + 45
	end
	
	-- Stats Frame
	local statsFrame = Instance.new("Frame")
	statsFrame.Name = "StatsFrame"
	statsFrame.Size = UDim2.new(1, -20, 0, 120)
	statsFrame.Position = UDim2.new(0, 10, 0, modeYPosition + 10)
	statsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	statsFrame.BackgroundTransparency = 0.5
	statsFrame.Parent = mainFrame
	
	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 8)
	statsCorner.Parent = statsFrame
	
	local statsTitle = Instance.new("TextLabel")
	statsTitle.Name = "StatsTitle"
	statsTitle.Size = UDim2.new(1, 0, 0, 30)
	statsTitle.Position = UDim2.new(0, 0, 0, 0)
	statsTitle.BackgroundTransparency = 1
	statsTitle.Text = "📊 THỐNG KÊ FARM:"
	statsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	statsTitle.TextSize = 14
	statsTitle.Font = Enum.Font.GothamSemibold
	statsTitle.TextXAlignment = Enum.TextXAlignment.Left
	statsTitle.Parent = statsFrame
	
	-- Stats labels
	local statNames = {"Kills", "Materials", "Berries", "XP", "Time"}
	local statYPos = 35
	
	for i, statName in ipairs(statNames) do
		local label = Instance.new("TextLabel")
		label.Name = statName .. "Stat"
		label.Size = UDim2.new(1, -10, 0, 16)
		label.Position = UDim2.new(0, 5, 0, statYPos)
		label.BackgroundTransparency = 1
		label.Text = statName .. ": 0"
		label.TextColor3 = Color3.fromRGB(220, 220, 220)
		label.TextSize = 12
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = statsFrame
		
		statLabels[statName] = label
		statYPos = statYPos + 18
	end
	
	-- Stop Button
	local stopButton = Instance.new("TextButton")
	stopButton.Name = "StopButton"
	stopButton.Size = UDim2.new(1, -20, 0, 35)
	stopButton.Position = UDim2.new(0, 10, 1, -45)
	stopButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	stopButton.BackgroundTransparency = 0.3
	stopButton.Text = "⏹️ DỪNG FARM"
	stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopButton.TextSize = 14
	stopButton.Font = Enum.Font.GothamBold
	stopButton.Parent = mainFrame
	
	local stopCorner = Instance.new("UICorner")
	stopCorner.CornerRadius = UDim.new(0, 8)
	stopCorner.Parent = stopButton
	
	stopButton.MouseButton1Click:Connect(function()
		toggleAutoFarm(currentFarmMode)
	end)
	
	-- Đóng/Mở GUI Button
	local toggleGUIButton = Instance.new("TextButton")
	toggleGUIButton.Name = "ToggleGUI"
	toggleGUIButton.Size = UDim2.new(0, 40, 0, 40)
	toggleGUIButton.Position = UDim2.new(1, 5, 0, 0)
	toggleGUIButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	toggleGUIButton.BackgroundTransparency = 0.3
	toggleGUIButton.Text = "⚙️"
	toggleGUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleGUIButton.TextSize = 20
	toggleGUIButton.Font = Enum.Font.GothamBold
	toggleGUIButton.Parent = mainFrame
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleGUIButton
	
	local isGUIVisible = true
	toggleGUIButton.MouseButton1Click:Connect(function()
		isGUIVisible = not isGUIVisible
		mainFrame.Visible = isGUIVisible
		toggleGUIButton.Text = isGUIVisible and "⚙️" or "⚙️"
	end)
	
	-- Make GUI draggable
	local dragging = false
	local dragInput, dragStart, startPos
	
	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	mainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Hàm cập nhật trạng thái GUI
local function updateGUIStatus()
	if autoFarmEnabled then
		statusLabel.Text = "✅ AUTO FARM: BẬT (" .. currentFarmMode .. ")"
		statusLabel.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
	else
		statusLabel.Text = "❌ AUTO FARM: TẮT"
		statusLabel.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	end
	
	-- Cập nhật màu nút chế độ hiện tại
	for modeName, button in pairs(modeButtons) do
		if modeName == currentFarmMode then
			button.BackgroundColor3 = farmConfigs[modeName].color
			button.BackgroundTransparency = 0.1
		else
			button.BackgroundColor3 = farmConfigs[modeName].color
			button.BackgroundTransparency = 0.3
		end
	end
end

-- Hàm cập nhật thống kê
local function updateStats()
	local currentTime = tick()
	local elapsedTime = currentTime - farmStats.startTime
	
	if farmStats.startTime > 0 then
		local minutes = math.floor(elapsedTime / 60)
		local seconds = math.floor(elapsedTime % 60)
		statLabels["Time"].Text = "Time: " .. string.format("%02d:%02d", minutes, seconds)
	end
	
	statLabels["Kills"].Text = "Kills: " .. farmStats.kills
	statLabels["Materials"].Text = "Materials: " .. farmStats.materials
	statLabels["Berries"].Text = "Berries: " .. farmStats.berries
	statLabels["XP"].Text = "XP: " .. farmStats.experience
end

-- Tìm quái trong Blox Fruits
local function findNearestEnemy(mode)
	local config = farmConfigs[mode] or farmConfigs["Normal"]
	local character = player.Character
	if not character then return nil end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end
	
	local nearest = nil
	local shortestDistance = config.searchDistance
	
	-- Tìm trong workspace
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
			local enemyHumanoid = obj.Humanoid
			local enemyRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
			
			if enemyHumanoid and enemyHumanoid.Health > 0 and enemyRoot then
				local isPriority = false
				local enemyName = obj.Name:lower()
				
				-- Kiểm tra ưu tiên
				for _, priorityName in ipairs(config.priority) do
					if string.find(enemyName, priorityName:lower()) then
						isPriority = true
						break
					end
				end
				
				-- Kiểm tra khoảng cách
				local distance = (humanoidRootPart.Position - enemyRoot.Position).Magnitude
				
				if distance <= shortestDistance then
					if isPriority or nearest == nil then
						nearest = obj
						shortestDistance = distance
					end
				end
			end
		end
	end
	
	return nearest
end

-- Di chuyển đến mục tiêu
local function moveToTarget(target)
	if not target or not target.PrimaryPart then return end
	
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not humanoidRootPart then return end
	
	local targetPos = target.PrimaryPart.Position
	local direction = (targetPos - humanoidRootPart.Position).Unit
	
	-- Di chuyển đến mục tiêu
	humanoid:MoveTo(targetPos - direction * 5)
	
	-- Xoay về phía mục tiêu
	local lookAt = CFrame.new(humanoidRootPart.Position, Vector3.new(targetPos.X, humanoidRootPart.Position.Y, targetPos.Z))
	humanoidRootPart.CFrame = lookAt
end

-- Tấn công mục tiêu (giả lập)
local function attackTarget(target)
	if not target or isAttacking then return end
	
	isAttacking = true
	
	-- Tìm tool trong backpack
	local character = player.Character
	if not character then return end
	
	-- Giả lập tấn công
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			-- Equip tool
			tool.Parent = character
			
			-- Activate tool (giả lập)
			if tool:FindFirstChild("Handle") then
				-- Đây là nơi bạn có thể thêm logic tấn công thực tế
				-- Tùy thuộc vào cơ chế combat của Blox Fruits
			end
			break
		end
	end
	
	-- Giả lập delay tấn công
	local config = farmConfigs[currentFarmMode] or farmConfigs["Normal"]
	wait(config.attackDelay)
	
	isAttacking = false
end

-- Thu thập vật phẩm rơi
local function collectDrops()
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	-- Tìm vật phẩm trong phạm vi
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:match("Drop") or obj.Name:match("Material") or obj.Name:match("Fruit") then
			local distance = (humanoidRootPart.Position - obj.Position).Magnitude
			
			if distance < 15 then
				-- Di chuyển đến vật phẩm
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid:MoveTo(obj.Position)
					
					-- Tăng thống kê
					if obj.Name:match("Material") then
						farmStats.materials = farmStats.materials + 1
					elseif obj.Name:match("Fruit") then
						farmStats.berries = farmStats.berries + 1000 -- Giả lập
					end
				end
			end
		end
	end
end

-- Hàm chính auto farm
local function autoFarmLoop()
	if not autoFarmEnabled then 
		targetEnemy = nil
		return 
	end
	
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or humanoid.Health <= 0 or not humanoidRootPart then
		targetEnemy = nil
		return
	end
	
	-- Tìm quái mới nếu cần
	if not targetEnemy or not targetEnemy:FindFirstChild("Humanoid") or targetEnemy.Humanoid.Health <= 0 then
		targetEnemy = findNearestEnemy(currentFarmMode)
		
		if targetEnemy then
			-- Tạo particle effect cho mục tiêu (tùy chọn)
			local highlight = Instance.new("Highlight")
			highlight.FillColor = farmConfigs[currentFarmMode].color
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.Parent = targetEnemy
			
			-- Tự động xóa highlight sau 2 giây
			game:GetService("Debris"):AddItem(highlight, 2)
		end
	end
	
	-- Nếu có mục tiêu
	if targetEnemy and targetEnemy:FindFirstChild("Humanoid") and targetEnemy.Humanoid.Health > 0 then
		local enemyRoot = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy:FindFirstChild("Torso")
		
		if enemyRoot then
			local distance = (humanoidRootPart.Position - enemyRoot.Position).Magnitude
			local config = farmConfigs[currentFarmMode] or farmConfigs["Normal"]
			
			if distance > 10 then
				-- Di chuyển đến mục tiêu
				moveToTarget(targetEnemy)
			else
				-- Tấn công
				attackTarget(targetEnemy)
				humanoid:MoveTo(humanoidRootPart.Position)
				
				-- Kiểm tra nếu quái chết
				if targetEnemy.Humanoid.Health <= 0 then
					farmStats.kills = farmStats.kills + 1
					farmStats.experience = farmStats.experience + 100 -- Giả lập XP
					
					-- Thu thập vật phẩm sau khi giết
					spawn(function()
						wait(0.5)
						collectDrops()
					end)
					
					targetEnemy = nil
				end
			end
		end
	else
		-- Di chuyển ngẫu nhiên để tìm quái
		local randomDirection = Vector3.new(
			math.random(-20, 20),
			0,
			math.random(-20, 20)
		)
		humanoid:MoveTo(humanoidRootPart.Position + randomDirection)
	end
end

-- Bật/Tắt auto farm
local function toggleAutoFarm(mode)
	autoFarmEnabled = not autoFarmEnabled
	
	if autoFarmEnabled then
		-- Bật farm
		currentFarmMode = mode or "Normal"
		
		-- Reset và bắt đầu thống kê
		if farmStats.startTime == 0 then
			farmStats.startTime = tick()
		end
		
		-- Tạo kết nối
		if autoFarmConnection then
			autoFarmConnection:Disconnect()
		end
		
		autoFarmConnection = RunService.RenderStepped:Connect(function()
			autoFarmLoop()
			updateStats()
		end)
		
		-- Cập nhật thông báo
		StarterGui:SetCore("SendNotification", {
			Title = "AUTO FARM",
			Text = "Đã bật Auto Farm: " .. currentFarmMode,
			Duration = 3,
			Icon = "rbxassetid://4483345998"
		})
	else
		-- Tắt farm
		if autoFarmConnection then
			autoFarmConnection:Disconnect()
			autoFarmConnection = nil
		end
		
		-- Dừng di chuyển
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid:MoveTo(character:FindFirstChild("HumanoidRootPart").Position)
			end
		end
		
		targetEnemy = nil
		
		StarterGui:SetCore("SendNotification", {
			Title = "AUTO FARM",
			Text = "Đã tắt Auto Farm",
			Duration = 3,
			Icon = "rbxassetid://4483345998"
		})
	end
	
	updateGUIStatus()
	return autoFarmEnabled
end

-- Thay đổi chế độ farm
local function changeFarmMode(mode)
	if farmConfigs[mode] then
		local wasEnabled = autoFarmEnabled
		
		if wasEnabled then
			toggleAutoFarm(currentFarmMode) -- Tắt trước
		end
		
		currentFarmMode = mode
		
		if wasEnabled then
			toggleAutoFarm(mode) -- Bật lại với chế độ mới
		end
		
		StarterGui:SetCore("SendNotification", {
			Title = "CHẾ ĐỘ FARM",
			Text = "Đã chuyển sang: " .. mode,
			Duration = 3,
			Icon = "rbxassetid://4483345998"
		})
		
		updateGUIStatus()
		return true
	end
	return false
end

-- Auto farm thông minh (tự động chọn chế độ)
local function startSmartFarm()
	-- Kiểm tra level của player để chọn chế độ phù hợp
	-- Giả sử có thể lấy level từ leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	local level = 1
	
	if leaderstats then
		local levelStat = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Lvl")
		if levelStat then
			level = levelStat.Value or 1
		end
	end
	
	-- Chọn chế độ dựa trên level
	local mode
	if level < 50 then
		mode = "Normal"
	elseif level < 100 then
		mode = "Material"
	elseif level < 200 then
		mode = "Elite"
	else
		mode = "Boss"
	end
	
	-- Bật farm với chế độ đã chọn
	if not autoFarmEnabled then
		toggleAutoFarm(mode)
	else
		changeFarmMode(mode)
	end
	
	StarterGui:SetCore("SendNotification", {
		Title = "SMART FARM",
		Text = "Đã kích hoạt Smart Farm (Level " .. level .. ")",
		Duration = 4,
		Icon = "rbxassetid://4483345998"
	})
end

-- Reset thống kê
local function resetStats()
	farmStats = {
		kills = 0,
		materials = 0,
		berries = 0,
		startTime = tick(),
		experience = 0
	}
	updateStats()
end

-- Khởi động
local function initialize()
	-- Chờ player load
	repeat wait() until player.Character
	
	-- Tạo GUI
	createGUI()
	updateGUIStatus()
	resetStats()
	
	-- Thêm nút Smart Farm vào GUI
	local smartButton = Instance.new("TextButton")
	smartButton.Name = "SmartFarmButton"
	smartButton.Size = UDim2.new(1, -20, 0, 35)
	smartButton.Position = UDim2.new(0, 10, 1, -85)
	smartButton.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
	smartButton.BackgroundTransparency = 0.3
	smartButton.Text = "🧠 SMART FARM"
	smartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	smartButton.TextSize = 14
	smartButton.Font = Enum.Font.GothamBold
	smartButton.Parent = mainFrame
	
	local smartCorner = Instance.new("UICorner")
	smartCorner.CornerRadius = UDim.new(0, 8)
	smartCorner.Parent = smartButton
	
	smartButton.MouseButton1Click:Connect(startSmartFarm)
	
	-- Auto-defense system
	spawn(function()
		while true do
			wait(1)
			if autoFarmEnabled then
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid and humanoid.Health < humanoid.MaxHealth * 0.3 then
						-- Tự động chạy trốn nếu máu thấp
						local runDirection = Vector3.new(
							math.random(-50, 50),
							0,
							math.random(-50, 50)
						)
						humanoid:MoveTo(character:FindFirstChild("HumanoidRootPart").Position + runDirection)
						
						StarterGui:SetCore("SendNotification", {
							Title = "AUTO DEFENSE",
							Text = "Máu thấp! Đang chạy trốn...",
							Duration = 2,
							Icon = "rbxassetid://4483345998"
						})
					end
				end
			end
		end
	end)
	
	-- Auto update stats
	spawn(function()
		while true do
			wait(1)
			updateStats()
		end
	end)
	
	print("Blox Fruits Auto Farm đã sẵn sàng!")
	print("Chỉ cần bấm vào nút trong GUI để bắt đầu farm!")
end

-- Chạy khởi động
spawn(initialize)

-- Xuất API
return {
	ToggleFarm = toggleAutoFarm,
	ChangeMode = changeFarmMode,
	StartSmartFarm = startSmartFarm,
	ResetStats = resetStats,
	IsEnabled = function() return autoFarmEnabled end,
	GetStats = function() return farmStats end
}
