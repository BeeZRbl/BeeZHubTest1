-- BeeZ Hub v2.0 - Tự động hiện UI khi execute
-- Có toggle icon để bật/tắt UI

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- Biến toàn cục
local BeeZ_GUI = nil
local GUIEnabled = true  -- Mặc định BẬT
local BeeZ_Icon = nil
local MainWindow = nil

-- Tạo icon toggle
local function CreateToggleIcon()
    if BeeZ_Icon then
        BeeZ_Icon:Destroy()
    end
    
    local IconGui = Instance.new("ScreenGui")
    IconGui.Name = "BeeZIconGUI"
    IconGui.Parent = game:GetService("CoreGui")
    IconGui.ResetOnSpawn = false
    
    local IconFrame = Instance.new("Frame")
    IconFrame.Name = "BeeZIcon"
    IconFrame.Size = UDim2.new(0, 45, 0, 45)
    IconFrame.Position = UDim2.new(0, 15, 0.5, -22)
    IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    IconFrame.BackgroundTransparency = 0.2
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = IconGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = IconFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 235, 100)
    UIStroke.Thickness = 2
    UIStroke.Parent = IconFrame
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🐝"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 28
    IconLabel.Parent = IconFrame
    
    -- Sự kiện click
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleBeeZGUI()
            
            local clickTween = TweenService:Create(IconFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(255, 195, 0),
                Size = UDim2.new(0, 40, 0, 40)
            })
            clickTween:Play()
            
            task.wait(0.1)
            local releaseTween = TweenService:Create(IconFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = GUIEnabled and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 100, 100),
                Size = UDim2.new(0, 45, 0, 45)
            })
            releaseTween:Play()
        end
    end)
    
    -- Cập nhật trạng thái icon
    local function UpdateIconState()
        if GUIEnabled then
            IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            IconLabel.Text = "🐝"
        else
            IconFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            IconLabel.Text = "🔒"
        end
    end
    
    -- Cho phép kéo
    local dragging = false
    local dragStart, startPos
    
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = IconFrame.Position
        end
    end)
    
    IconFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            IconFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    BeeZ_Icon = {
        Gui = IconGui,
        Update = UpdateIconState
    }
    
    UpdateIconState()
    return IconGui
end

-- Toggle GUI
local function ToggleBeeZGUI()
    if BeeZ_GUI then
        GUIEnabled = not GUIEnabled
        BeeZ_GUI.Enabled = GUIEnabled
        
        if BeeZ_Icon and BeeZ_Icon.Update then
            BeeZ_Icon.Update()
        end
        
        BeeZ_Notify("UI " .. (GUIEnabled and "bật" or "tắt"))
    end
end

-- Tạo GUI chính
local function CreateBeeZGUI()
    if BeeZ_GUI then
        BeeZ_GUI:Destroy()
    end
    
    local success, Library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    end)
    
    if not success then
        BeeZ_Notify("Không thể load GUI library")
        return
    end
    
    MainWindow = Library.CreateLib("🐝 BeeZ Hub v2.0", "DarkTheme")
    BeeZ_GUI = MainWindow
    
    -- Tạo tabs
    local MainTab = MainWindow:NewTab("Main")
    local FarmingTab = MainWindow:NewTab("Farming")
    local AutoTab = MainWindow:NewTab("Auto")
    local PlayerTab = MainWindow:NewTab("Player")
    local MiscTab = MainWindow:NewTab("Misc")
    
    -- Main Section
    local MainSection = MainTab:NewSection("BeeZ Hub Control")
    MainSection:NewLabel("🐝 BeeZ Hub v2.0")
    MainSection:NewLabel("Advanced Blox Fruits Automation")
    MainSection:NewLabel("Nhấn icon 🐝 để bật/tắt UI")
    
    MainSection:NewButton("Bật/Tắt UI", "Toggle UI manually", function()
        ToggleBeeZGUI()
    end)
    
    -- Farming Section
    local FarmingSection = FarmingTab:NewSection("Farming Settings")
    FarmingSection:NewToggle("Enable Auto Farm", "Bật tự động farm", function(state)
        BeeZ_Notify("Auto Farm: " .. (state and "BẬT" or "TẮT"))
    end)
    
    FarmingSection:NewToggle("Stack Farming", "Farm nhiều mục tiêu", function(state)
        BeeZ_Notify("Stack Farming: " .. (state and "BẬT" or "TẮT"))
    end)
    
    FarmingSection:NewDropdown("Farm Method", "Chọn cách farm", {"Normal", "Fast", "Safe", "Boss"}, function(method)
        BeeZ_Notify("Farm method: " .. method)
    end)
    
    FarmingSection:NewSlider("Farm Distance", "Khoảng cách farm", 50, 10, function(value)
        BeeZ_Notify("Farm Distance: " .. value)
    end)
    
    -- Auto Section
    local AutoSection = AutoTab:NewSection("Auto Settings")
    AutoSection:NewToggle("Ignore Katakuri", "Bỏ qua Katakuri", function(state)
        BeeZ_Notify("Ignore Katakuri: " .. (state and "BẬT" or "TẮT"))
    end)
    
    AutoSection:NewSlider("Ignore Katakuri HP %", "Ngưỡng HP bỏ qua", 90, 10, function(value)
        BeeZ_Notify("Katakuri HP: " .. value .. "%")
    end)
    
    AutoSection:NewToggle("Auto Server Hop", "Tự động đổi server", function(state)
        BeeZ_Notify("Auto Server Hop: " .. (state and "BẬT" or "TẮT"))
    end)
    
    AutoSection:NewSlider("Max Hop Attempts", "Số lần đổi server", 20, 1, function(value)
        BeeZ_Notify("Max Hops: " .. value)
    end)
    
    -- Player Section
    local PlayerSection = PlayerTab:NewSection("Player Settings")
    PlayerSection:NewSlider("Mastery Target", "Mục tiêu Mastery", 500, 100, function(value)
        BeeZ_Notify("Mastery Target: " .. value)
    end)
    
    PlayerSection:NewDropdown("Skill Priority", "Ưu tiên skill", {"Z", "X", "C", "V", "F"}, function(skill)
        BeeZ_Notify("Skill Priority: " .. skill)
    end)
    
    PlayerSection:NewDropdown("Farm Priority", "Ưu tiên mục tiêu", {"Nearest", "HighestLevel", "LowestHP"}, function(priority)
        BeeZ_Notify("Farm Priority: " .. priority)
    end)
    
    -- Misc Section
    local MiscSection = MiscTab:NewSection("Misc Settings")
    MiscSection:NewToggle("Anti-AFK", "Chống AFK", function(state)
        BeeZ_Notify("Anti-AFK: " .. (state and "BẬT" or "TẮT"))
    end)
    
    MiscSection:NewToggle("Safe Mode", "Chế độ an toàn", function(state)
        BeeZ_Notify("Safe Mode: " .. (state and "BẬT" or "TẮT"))
    end)
    
    MiscSection:NewButton("Hide UI", "Ẩn UI (dùng icon để bật lại)", function()
        ToggleBeeZGUI()
    end)
    
    MiscSection:NewButton("Test Button", "Nút kiểm tra", function()
        BeeZ_Notify("BeeZ Hub đang hoạt động!")
    end)
    
    return MainWindow
end

-- Hàm thông báo
function BeeZ_Notify(message, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "🐝 BeeZ Hub",
            Text = message,
            Duration = duration or 2,
            Icon = "rbxassetid://6723928013"
        })
    end
    print("[BeeZ Hub] " .. message)
end

-- Khởi động
BeeZ_Notify("BeeZ Hub v2.0 đang khởi động...", 3)

-- Tạo icon và GUI
task.wait(1)
CreateToggleIcon()
task.wait(0.5)
CreateBeeZGUI()

-- Đảm bảo GUI bật
if BeeZ_GUI then
    BeeZ_GUI.Enabled = true
    GUIEnabled = true
    if BeeZ_Icon and BeeZ_Icon.Update then
        BeeZ_Icon.Update()
    end
end

-- Hotkey
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        ToggleBeeZGUI()
    end
end)

BeeZ_Notify("✅ BeeZ Hub v2.0 đã sẵn sàng!\n• UI đã hiện\n• Icon ở góc trái\n• Nhấn icon hoặc RightCtrl để bật/tắt UI", 5)

print("========================================")
print("🐝 BeeZ Hub v2.0 - Loaded Successfully")
print("UI: Visible | Icon: Created")
print("========================================")
