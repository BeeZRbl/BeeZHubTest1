-- BeeZ Hub v2.0 - UI sẽ HIỆN NGAY khi execute
-- Fixed với Delta, Xeno, và mọi executor

-- Đảm bảo services load
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- Biến global để dễ truy cập
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration đơn giản
local Config = {
    AutoFarm = false,
    FarmDistance = 30,
    FarmPriority = "Nearest",
    PrimarySkill = "Z",
    SecondarySkill = "X",
    AntiAfk = true,
    Notifications = true
}

-- Biến farming
local FarmEnabled = false
local ToggleIcon = nil
local BeeZ_GUI = nil
local FarmingLoop = nil

-- ==================== HÀM THÔNG BÁO ====================
local function Notify(message, duration)
    if Config.Notifications then
        game.StarterGui:SetCore("SendNotification", {
            Title = "🐝 BeeZ Hub",
            Text = message,
            Duration = duration or 2,
        })
    end
    print("[BeeZ Hub] " .. message)
end

-- ==================== TẠO ICON TOGGLE ====================
local function CreateToggleIcon()
    -- Xóa icon cũ nếu có
    if ToggleIcon then
        ToggleIcon:Destroy()
    end
    
    -- Tạo ScreenGui
    local IconGui = Instance.new("ScreenGui")
    IconGui.Name = "BeeZToggleIcon"
    IconGui.Parent = game.CoreGui
    IconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    IconGui.ResetOnSpawn = false
    
    -- Tạo frame icon
    local IconFrame = Instance.new("Frame")
    IconFrame.Name = "ToggleIcon"
    IconFrame.Size = UDim2.new(0, 45, 0, 45)
    IconFrame.Position = UDim2.new(0, 15, 0.5, -22)
    IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    IconFrame.BackgroundTransparency = 0.2
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = IconGui
    
    -- Làm tròn góc
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = IconFrame
    
    -- Label icon
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Name = "IconLabel"
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🐝"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 24
    IconLabel.Parent = IconFrame
    
    -- Sự kiện click
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleUI()
        end
    end)
    
    ToggleIcon = IconGui
    return IconGui
end

-- ==================== TOGGLE UI FUNCTION ====================
local function ToggleUI()
    if BeeZ_GUI then
        -- Tìm tất cả Kavo UI trong CoreGui
        for _, gui in pairs(game.CoreGui:GetChildren()) do
            if gui.Name == "Kavo" then
                gui.Enabled = not gui.Enabled
                
                -- Cập nhật icon
                if ToggleIcon then
                    local iconFrame = ToggleIcon:FindFirstChild("ToggleIcon")
                    if iconFrame then
                        local iconLabel = iconFrame:FindFirstChild("IconLabel")
                        if iconLabel then
                            if gui.Enabled then
                                iconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                                iconLabel.Text = "🐝"
                                Notify("UI ĐÃ BẬT")
                            else
                                iconFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                                iconLabel.Text = "🔒"
                                Notify("UI ĐÃ TẮT")
                            end
                        end
                    end
                end
                break
            end
        end
    end
end

-- ==================== FARMING SYSTEM ====================
local function GetEnemies()
    local enemies = {}
    local maxDistance = Config.FarmDistance or 30
    
    for _, npc in pairs(Workspace.Enemies:GetChildren()) do
        if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
            if npc.Humanoid.Health > 0 then
                local distance = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distance <= maxDistance then
                    table.insert(enemies, {
                        Object = npc,
                        Distance = distance,
                        Health = npc.Humanoid.Health
                    })
                end
            end
        end
    end
    
    return enemies
end

local function AttackTarget(target)
    if not target or not target.Object then return end
    
    -- Di chuyển đến target
    HumanoidRootPart.CFrame = CFrame.new(
        target.Object.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
    )
    
    -- Dùng skill
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

local function StartFarmingLoop()
    while FarmEnabled do
        -- Anti-AFK
        if Config.AntiAfk then
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
        
        -- Tìm enemies
        local enemies = GetEnemies()
        
        if #enemies > 0 then
            -- Sắp xếp theo priority
            if Config.FarmPriority == "Nearest" then
                table.sort(enemies, function(a, b)
                    return a.Distance < b.Distance
                end)
            elseif Config.FarmPriority == "Lowest HP" then
                table.sort(enemies, function(a, b)
                    return a.Health < b.Health
                end)
            end
            
            -- Attack enemy đầu tiên
            AttackTarget(enemies[1])
            
            -- Update status nếu có
            if FarmingStatusLabel then
                FarmingStatusLabel:UpdateLabel("🟢 ĐANG FARMING (" .. #enemies .. " enemies)")
            end
        else
            if FarmingStatusLabel then
                FarmingStatusLabel:UpdateLabel("🟡 KHÔNG CÓ ENEMY")
            end
            task.wait(1) -- Chờ lâu hơn nếu không có enemy
        end
        
        task.wait(0.3) -- Delay giữa các lần farm
    end
end

local function StartFarming()
    if FarmEnabled then
        Notify("Farm đang chạy rồi!")
        return
    end
    
    FarmEnabled = true
    Notify("🚀 BẮT ĐẦU FARMING!", 2)
    
    if FarmingStatusLabel then
        FarmingStatusLabel:UpdateLabel("🟢 ĐANG FARMING...")
    end
    
    -- Bắt đầu farming loop
    FarmingLoop = coroutine.create(StartFarmingLoop)
    coroutine.resume(FarmingLoop)
end

local function StopFarming()
    if not FarmEnabled then
        Notify("Farm chưa chạy!")
        return
    end
    
    FarmEnabled = false
    Notify("⏹️ DỪNG FARMING!", 2)
    
    if FarmingStatusLabel then
        FarmingStatusLabel:UpdateLabel("🔴 ĐÃ DỪNG")
    end
end

-- ==================== TẠO GUI ====================
local function CreateBeeZGUI()
    -- Load Kavo UI Library
    local success, Library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    end)
    
    if not success then
        Notify("Lỗi load UI Library!")
        return nil
    end
    
    -- Tạo Window
    local Window = Library.CreateLib("🐝 BeeZ Hub v2.0", "DarkTheme")
    BeeZ_GUI = Window
    
    -- ===== MAIN TAB =====
    local MainTab = Window:NewTab("Main")
    local MainSection = MainTab:NewSection("ĐIỀU KHIỂN")
    
    MainSection:NewLabel("🐝 BEEZ HUB v2.0")
    MainSection:NewLabel("Auto Farm Blox Fruits")
    
    -- Status label
    FarmingStatusLabel = MainSection:NewLabel("🔴 CHƯA FARMING")
    
    -- Start Farming button
    MainSection:NewButton("▶️ BẮT ĐẦU FARM", "Bắt đầu auto farming", function()
        StartFarming()
    end)
    
    -- Stop Farming button
    MainSection:NewButton("⏹️ DỪNG FARM", "Dừng farming", function()
        StopFarming()
    end)
    
    -- Test Farm button
    MainSection:NewButton("🔧 TEST FARM 3s", "Test farm 3 giây", function()
        StartFarming()
        task.wait(3)
        StopFarming()
    end)
    
    -- ===== FARM SETTINGS TAB =====
    local FarmTab = Window:NewTab("Farm Settings")
    
    local BasicSettings = FarmTab:NewSection("CÀI ĐẶT CƠ BẢN")
    
    BasicSettings:NewSlider("Khoảng Cách", "Khoảng cách tối đa", 50, 10, function(value)
        Config.FarmDistance = value
        Notify("Khoảng cách: " .. value)
    end)
    
    BasicSettings:NewDropdown("Ưu Tiên", "Chọn mục tiêu ưu tiên", {"Nearest", "Lowest HP"}, function(option)
        Config.FarmPriority = option
        Notify("Ưu tiên: " .. option)
    end)
    
    -- ===== SKILL SETTINGS TAB =====
    local SkillTab = Window:NewTab("Skill Settings")
    
    local SkillSettings = SkillTab:NewSection("CÀI ĐẶT SKILL")
    
    SkillSettings:NewDropdown("Skill Chính", "Skill sử dụng chính", {"Z", "X", "C", "V", "F"}, function(skill)
        Config.PrimarySkill = skill
        Notify("Skill chính: " .. skill)
    end)
    
    SkillSettings:NewDropdown("Skill Phụ", "Skill hỗ trợ", {"Z", "X", "C", "V", "F"}, function(skill)
        Config.SecondarySkill = skill
        Notify("Skill phụ: " .. skill)
    end)
    
    SkillSettings:NewButton("🔨 TEST SKILL", "Test skill hiện tại", function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Config.PrimarySkill, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Config.PrimarySkill, false, game)
        Notify("Test skill: " .. Config.PrimarySkill)
    end)
    
    -- ===== TELEPORT TAB =====
    local TeleportTab = Window:NewTab("Teleport")
    
    local TeleportSection = TeleportTab:NewSection("DI CHUYỂN NHANH")
    
    TeleportSection:NewButton("🛡️ VÙNG AN TOÀN", "Teleport lên cao", function()
        HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
        Notify("Đến vùng an toàn")
    end)
    
    TeleportSection:NewButton("🏝️ RA BIỂN", "Đến khu vực biển", function()
        HumanoidRootPart.CFrame = CFrame.new(1000, 50, 1000)
        Notify("Đang ra biển...")
    end)
    
    -- ===== SETTINGS TAB =====
    local SettingsTab = Window:NewTab("Settings")
    
    local UISettings = SettingsTab:NewSection("CÀI ĐẶT UI")
    
    UISettings:NewToggle("Notifications", "Bật/tắt thông báo", function(state)
        Config.Notifications = state
        Notify("Notifications: " .. (state and "BẬT" or "TẮT"))
    end)
    
    UISettings:NewToggle("Anti-AFK", "Tự động chống AFK", function(state)
        Config.AntiAfk = state
        Notify("Anti-AFK: " .. (state and "BẬT" or "TẮT"))
    end)
    
    -- ===== HELP TAB =====
    local HelpTab = Window:NewTab("Help")
    
    local HelpSection = HelpTab:NewSection("📖 HƯỚNG DẪN")
    
    HelpSection:NewLabel("CÁCH DÙNG:")
    HelpSection:NewLabel("1. Vào Main tab")
    HelpSection:NewLabel("2. Nhấn ▶️ BẮT ĐẦU FARM")
    HelpSection:NewLabel("3. Farm sẽ tự động chạy")
    HelpSection:NewLabel("4. Nhấn ⏹️ DỪNG FARM để dừng")
    
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

-- ==================== KHỞI TẠO ====================
-- Thông báo bắt đầu
print("========================================")
print("🐝 BEEZ HUB v2.0 - ĐANG KHỞI ĐỘNG...")
print("========================================")

-- Tạo icon toggle trước
task.wait(0.5)
CreateToggleIcon()
Notify("Icon toggle đã tạo", 1)

-- Tạo GUI
task.wait(1)
local window = CreateBeeZGUI()

if window then
    Notify("✅ BEEZ HUB ĐÃ SẴN SÀNG!", 3)
    Notify("UI đang hiển thị...", 2)
    Notify("Nhấn ▶️ BẮT ĐẦU FARM để bắt đầu", 3)
else
    Notify("❌ Lỗi tạo GUI!", 3)
end

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F9 then
            -- Toggle Farm
            if FarmEnabled then
                StopFarming()
            else
                StartFarming()
            end
        elseif input.KeyCode == Enum.KeyCode.F8 then
            -- Toggle UI
            ToggleUI()
        end
    end
end)

-- Final message
print("========================================")
print("✅ BEEZ HUB v2.0 - ĐÃ LOAD THÀNH CÔNG!")
print("========================================")
print("TÍNH NĂNG:")
print("- Auto Farming (Tự động farm)")
print("- Toggle UI (Icon 🐝 góc trái)")
print("- Skill Management (Z, X, C, V, F)")
print("- Teleport System")
print("- Anti-AFK System")
print("========================================")
print("CÁCH DÙNG:")
print("1. Nhấn ▶️ BẮT ĐẦU FARM trong Main tab")
print("2. Icon 🐝 để bật/tắt UI")
print("3. F9 = Bật/Tắt Farm nhanh")
print("4. F8 = Bật/Tắt UI nhanh")
print("========================================")
