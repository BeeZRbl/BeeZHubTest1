-- BeeZ Hub v2.0 - Fixed với Toggle UI hoạt động và Farming dễ dùng
-- Works on Delta, Xeno, Synapse, etc.

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local Config = {
    AutoFarm = false,
    FarmDistance = 25,
    FarmPriority = "Nearest",
    StackFarming = false,
    StackCount = 3,
    
    -- Safety
    SafeMode = true,
    AntiAfk = true,
    
    -- Skills
    PrimarySkill = "Z",
    SecondarySkill = "X",
    
    -- UI
    UIVisible = true,
    Notifications = true
}

-- Farming Variables
local FarmEnabled = false
local ToggleIcon = nil
local BeeZ_GUI = nil
local UIEnabled = true
local FarmingLoop = nil

-- ==================== SIMPLE TOGGLE UI ====================
local function CreateSimpleToggleIcon()
    if ToggleIcon then ToggleIcon:Destroy() end
    
    local IconGui = Instance.new("ScreenGui")
    IconGui.Name = "BeeZToggleIcon"
    IconGui.Parent = game.CoreGui
    IconGui.ResetOnSpawn = false
    
    local IconFrame = Instance.new("Frame")
    IconFrame.Name = "ToggleIcon"
    IconFrame.Size = UDim2.new(0, 40, 0, 40)
    IconFrame.Position = UDim2.new(0, 10, 0.5, -20)
    IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    IconFrame.BackgroundTransparency = 0.2
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = IconGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = IconFrame
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🐝"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 20
    IconLabel.Parent = IconFrame
    
    -- Simple click to toggle
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleUI()
        end
    end)
    
    ToggleIcon = IconGui
    return IconGui
end

local function ToggleUI()
    if BeeZ_GUI then
        -- Tìm MainWindow để toggle
        for _, obj in pairs(game.CoreGui:GetChildren()) do
            if obj.Name == "Kavo" then
                UIEnabled = not UIEnabled
                obj.Enabled = UIEnabled
                
                -- Update icon
                if ToggleIcon then
                    local iconFrame = ToggleIcon:FindFirstChild("ToggleIcon")
                    if iconFrame then
                        if UIEnabled then
                            iconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                            IconLabel.Text = "🐝"
                        else
                            iconFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                            IconLabel.Text = "🔒"
                        end
                    end
                end
                
                Notify("UI " .. (UIEnabled and "BẬT" or "TẮT"))
                break
            end
        end
    end
end

-- ==================== SIMPLE NOTIFICATION ====================
local function Notify(message, duration)
    if Config.Notifications then
        game.StarterGui:SetCore("SendNotification", {
            Title = "🐝 BeeZ Hub",
            Text = message,
            Duration = duration or 2,
        })
    end
end

-- ==================== SIMPLE FARMING SYSTEM ====================
local function GetNearbyEnemies()
    local enemies = {}
    for _, npc in pairs(Workspace.Enemies:GetChildren()) do
        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
            if npc.Humanoid.Health > 0 then
                local distance = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distance <= Config.FarmDistance then
                    table.insert(enemies, {
                        NPC = npc,
                        Distance = distance,
                        Health = npc.Humanoid.Health
                    })
                end
            end
        end
    end
    return enemies
end

local function AttackEnemy(enemy)
    if not enemy or not enemy.NPC then return end
    
    -- Move to enemy
    HumanoidRootPart.CFrame = CFrame.new(
        enemy.NPC.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
    )
    
    -- Use skills
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Config.PrimarySkill, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Config.PrimarySkill, false, game)
    
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Config.SecondarySkill, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Config.SecondarySkill, false, game)
    
    -- Basic attack
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "LeftControl", false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "LeftControl", false, game)
end

local function SimpleFarmingLoop()
    while FarmEnabled do
        if Config.AntiAfk then
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
        
        local enemies = GetNearbyEnemies()
        
        if #enemies > 0 then
            -- Sort by priority
            if Config.FarmPriority == "Nearest" then
                table.sort(enemies, function(a, b)
                    return a.Distance < b.Distance
                end)
            elseif Config.FarmPriority == "Lowest HP" then
                table.sort(enemies, function(a, b)
                    return a.Health < b.Health
                end)
            end
            
            -- Attack enemies
            local attackCount = Config.StackFarming and math.min(Config.StackCount, #enemies) or 1
            
            for i = 1, attackCount do
                if enemies[i] then
                    AttackEnemy(enemies[i])
                end
            end
            
            -- Update status
            if FarmingStatusLabel then
                FarmingStatusLabel:UpdateLabel("🟢 Farming | Enemies: " .. #enemies)
            end
        else
            if FarmingStatusLabel then
                FarmingStatusLabel:UpdateLabel("🟡 No enemies found")
            end
        end
        
        -- Safe mode delay
        if Config.SafeMode then
            task.wait(0.5)
        else
            task.wait(0.2)
        end
    end
end

local function StartFarming()
    if FarmEnabled then
        Notify("Farming đã chạy rồi!")
        return
    end
    
    FarmEnabled = true
    Notify("🚀 Bắt đầu Farming!", 2)
    
    if FarmingStatusLabel then
        FarmingStatusLabel:UpdateLabel("🟢 Đang Farming...")
    end
    
    -- Start farming loop
    FarmingLoop = coroutine.create(SimpleFarmingLoop)
    coroutine.resume(FarmingLoop)
end

local function StopFarming()
    if not FarmEnabled then
        Notify("Farming chưa chạy!")
        return
    end
    
    FarmEnabled = false
    Notify("⏹️ Dừng Farming!", 2)
    
    if FarmingStatusLabel then
        FarmingStatusLabel:UpdateLabel("🔴 Đã dừng")
    end
end

-- ==================== CREATE SIMPLE GUI ====================
local function CreateBeeZGUI()
    -- Load Kavo UI
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    
    local Window = Library.CreateLib("🐝 BeeZ Hub v2.0", "DarkTheme")
    BeeZ_GUI = Window
    
    -- ===== MAIN TAB =====
    local MainTab = Window:NewTab("Main")
    local MainSection = MainTab:NewSection("Điều Khiển Chính")
    
    MainSection:NewLabel("🐝 BeeZ Hub v2.0")
    MainSection:NewLabel("Farm Blox Fruits Dễ Dàng")
    
    FarmingStatusLabel = MainSection:NewLabel("🔴 Chưa farming")
    
    MainSection:NewButton("▶️ BẮT ĐẦU FARM", "Bắt đầu auto farm", function()
        Config.AutoFarm = true
        StartFarming()
    end)
    
    MainSection:NewButton("⏹️ DỪNG FARM", "Dừng auto farm", function()
        Config.AutoFarm = false
        StopFarming()
    end)
    
    MainSection:NewButton("🎯 THỬ FARM (5s)", "Test farm 5 giây", function()
        Config.AutoFarm = true
        StartFarming()
        task.wait(5)
        StopFarming()
    end)
    
    -- ===== FARMING SETTINGS TAB =====
    local FarmingTab = Window:NewTab("Cài Đặt Farm")
    
    local BasicSettings = FarmingTab:NewSection("Cài Đặt Cơ Bản")
    BasicSettings:NewSlider("Khoảng Cách Farm", "Khoảng cách tối đa", 50, 10, function(value)
        Config.FarmDistance = value
        Notify("Khoảng cách: " .. value)
    end)
    
    BasicSettings:NewDropdown("Ưu Tiên Mục Tiêu", "Chọn mục tiêu", {"Nearest", "Lowest HP"}, function(option)
        Config.FarmPriority = option
        Notify("Ưu tiên: " .. option)
    end)
    
    local AdvancedSettings = FarmingTab:NewSection("Cài Đặt Nâng Cao")
    AdvancedSettings:NewToggle("Stack Farming", "Farm nhiều mục tiêu", function(state)
        Config.StackFarming = state
        Notify("Stack Farming: " .. (state and "BẬT" or "TẮT"))
    end)
    
    AdvancedSettings:NewSlider("Số Lượng Stack", "Số mục tiêu tối đa", 5, 1, function(value)
        Config.StackCount = value
    end)
    
    -- ===== SKILL SETTINGS TAB =====
    local SkillTab = Window:NewTab("Cài Đặt Skill")
    
    local SkillSettings = SkillTab:NewSection("Skill Settings")
    SkillSettings:NewDropdown("Skill Chính", "Skill sử dụng nhiều", {"Z", "X", "C", "V", "F"}, function(skill)
        Config.PrimarySkill = skill
        Notify("Skill chính: " .. skill)
    end)
    
    SkillSettings:NewDropdown("Skill Phụ", "Skill hỗ trợ", {"Z", "X", "C", "V", "F"}, function(skill)
        Config.SecondarySkill = skill
        Notify("Skill phụ: " .. skill)
    end)
    
    SkillSettings:NewButton("🔧 TEST SKILL", "Test skill hiện tại", function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Config.PrimarySkill, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Config.PrimarySkill, false, game)
        Notify("Test skill: " .. Config.PrimarySkill)
    end)
    
    -- ===== SAFETY TAB =====
    local SafetyTab = Window:NewTab("An Toàn")
    
    local SafetySettings = SafetyTab:NewSection("Cài Đặt An Toàn")
    SafetySettings:NewToggle("Chế Độ An Toàn", "Giảm nguy cơ bị ban", function(state)
        Config.SafeMode = state
        Notify("Safe mode: " .. (state and "BẬT" or "TẮT"))
    end)
    
    SafetySettings:NewToggle("Chống AFK", "Tự động chống AFK", function(state)
        Config.AntiAfk = state
        Notify("Anti-AFK: " .. (state and "BẬT" or "TẮT"))
    end)
    
    -- ===== TELEPORT TAB =====
    local TeleportTab = Window:NewTab("Di Chuyển")
    
    local TeleportSettings = TeleportTab:NewSection("Teleport Nhanh")
    TeleportSettings:NewButton("🏝️ Ra Đảo Gần Nhất", "Tìm đảo gần nhất", function()
        local islands = {}
        for _, part in pairs(Workspace:GetChildren()) do
            if string.find(part.Name:lower(), "island") or string.find(part.Name:lower(), "sea") then
                table.insert(islands, part)
            end
        end
        
        if #islands > 0 then
            HumanoidRootPart.CFrame = islands[1].CFrame + Vector3.new(0, 10, 0)
            Notify("Đã teleport đến đảo")
        else
            Notify("Không tìm thấy đảo!")
        end
    end)
    
    TeleportSettings:NewButton("🛡️ Vùng An Toàn", "Teleport lên cao", function()
        HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
        Notify("Đã đến vùng an toàn")
    end)
    
    TeleportSettings:NewButton("🏰 Castle on the Sea", "Đến Castle", function()
        HumanoidRootPart.CFrame = CFrame.new(-5000, 100, 500)
        Notify("Đang đến Castle...")
    end)
    
    -- ===== HƯỚNG DẪN TAB =====
    local HelpTab = Window:NewTab("Hướng Dẫn")
    
    local HelpSection = HelpTab:NewSection("📖 HƯỚNG DẪN SỬ DỤNG")
    HelpSection:NewLabel("CÁCH FARM:")
    HelpSection:NewLabel("1. Vào Main tab")
    HelpSection:NewLabel("2. Nhấn ▶️ BẮT ĐẦU FARM")
    HelpSection:NewLabel("3. Nhấn ⏹️ DỪNG FARM khi cần")
    
    HelpSection:NewLabel("")
    HelpSection:NewLabel("TOGGLE UI:")
    HelpSection:NewLabel("• Click icon 🐝 góc trái")
    HelpSection:NewLabel("• Hoặc nhấn phím F8")
    
    HelpSection:NewLabel("")
    HelpSection:NewLabel("HOTKEYS:")
    HelpSection:NewLabel("F9 = Bật/Tắt Farm")
    HelpSection:NewLabel("F8 = Bật/Tắt UI")
    
    return Window
end

-- ==================== INITIALIZATION ====================
-- Tạo icon toggle
CreateSimpleToggleIcon()

-- Tạo GUI
CreateBeeZGUI()

-- Thông báo
Notify("🐝 BeeZ Hub v2.0 Đã Sẵn Sàng!", 3)
Notify("Click icon 🐝 để bật/tắt UI", 3)
Notify("Nhấn F9 để bật/tắt Farm nhanh", 3)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F9 then
            -- Toggle Farm
            Config.AutoFarm = not Config.AutoFarm
            if Config.AutoFarm then
                StartFarming()
            else
                StopFarming()
            end
        elseif input.KeyCode == Enum.KeyCode.F8 then
            -- Toggle UI
            ToggleUI()
        end
    end
end)

print("========================================")
print("🐝 BEEZ HUB v2.0 - ĐÃ SẴN SÀNG!")
print("========================================")
print("CÁCH DÙNG:")
print("1. Nhấn ▶️ BẮT ĐẦU FARM trong Main tab")
print("2. Icon 🐝 góc trái: Bật/Tắt UI")
print("3. F9 = Bật/Tắt Farm nhanh")
print("4. F8 = Bật/Tắt UI nhanh")
print("========================================")
print("TÍNH NĂNG HOẠT ĐỘNG:")
print("- Auto farm quái trong phạm vi")
("- Dùng skill Z, X tự động")
print("- Stack farming (nhiều mục tiêu)")
print("- Teleport nhanh")
print("- Anti-AFK")
print("========================================")
