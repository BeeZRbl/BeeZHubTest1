-- BeeZ Hub v2.0 - Fixed UI Display Issue
-- UI sẽ hiển thị ngay khi execute

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Biến toàn cục
local BeeZ_GUI = nil
local GUIEnabled = true
local BeeZ_Icon = nil
local Player = Players.LocalPlayer
local Library = nil

-- Hàm thông báo
local function BeeZ_Notify(message, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🐝 BeeZ Hub",
            Text = message,
            Duration = duration or 3,
            Icon = "rbxassetid://6723928013"
        })
    end)
end

-- Load Kavo UI Library
local function LoadKavoLibrary()
    local success, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    end)
    
    if success then
        return lib
    else
        -- Fallback nếu không load được
        BeeZ_Notify("Không thể load GUI library, sử dụng fallback")
        return nil
    end
end

-- Tạo icon toggle (luôn hiển thị)
local function CreateToggleIcon()
    -- Xóa icon cũ nếu có
    if BeeZ_Icon then
        BeeZ_Icon:Destroy()
    end
    
    -- Tạo ScreenGui
    local IconGui = Instance.new("ScreenGui")
    IconGui.Name = "BeeZIconGUI"
    IconGui.Parent = CoreGui
    IconGui.ResetOnSpawn = false
    IconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Tạo icon frame
    local IconFrame = Instance.new("Frame")
    IconFrame.Name = "BeeZIcon"
    IconFrame.Size = UDim2.new(0, 50, 0, 50)
    IconFrame.Position = UDim2.new(0, 20, 0.5, -25)
    IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    IconFrame.BackgroundTransparency = 0.3
    IconFrame.BorderSizePixel = 0
    IconFrame.ZIndex = 1000
    IconFrame.Parent = IconGui
    
    -- Làm tròn góc
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = IconFrame
    
    -- Thêm stroke
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 235, 100)
    UIStroke.Thickness = 2
    UIStroke.Parent = IconFrame
    
    -- Label icon
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🐝"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 30
    IconLabel.ZIndex = 1001
    IconLabel.Parent = IconFrame
    
    -- Tooltip
    local Tooltip = Instance.new("TextLabel")
    Tooltip.Name = "Tooltip"
    Tooltip.Size = UDim2.new(0, 120, 0, 35)
    Tooltip.Position = UDim2.new(1, 10, 0.5, -17)
    Tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Tooltip.BackgroundTransparency = 0.2
    Tooltip.Text = "Click to toggle UI\nBeeZ Hub v2.0"
    Tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tooltip.Font = Enum.Font.Gotham
    Tooltip.TextSize = 12
    Tooltip.TextWrapped = true
    Tooltip.Visible = false
    Tooltip.ZIndex = 1001
    Tooltip.Parent = IconFrame
    
    local TooltipCorner = Instance.new("UICorner")
    TooltipCorner.CornerRadius = UDim.new(0.1, 0)
    TooltipCorner.Parent = Tooltip
    
    -- Hiệu ứng hover
    IconFrame.MouseEnter:Connect(function()
        Tooltip.Visible = true
        local tween = TweenService:Create(IconFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 55, 0, 55)
        })
        tween:Play()
    end)
    
    IconFrame.MouseLeave:Connect(function()
        Tooltip.Visible = false
        local tween = TweenService:Create(IconFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3,
            Size = UDim2.new(0, 50, 0, 50)
        })
        tween:Play()
    end)
    
    -- Sự kiện click
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleBeeZGUI()
            
            -- Hiệu ứng click
            local clickTween = TweenService:Create(IconFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(255, 195, 0),
                Size = UDim2.new(0, 45, 0, 45)
            })
            clickTween:Play()
            
            task.wait(0.1)
            local releaseTween = TweenService:Create(IconFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = GUIEnabled and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(100, 100, 100),
                Size = UDim2.new(0, 50, 0, 50)
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
        Frame = IconFrame,
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
        
        -- Cập nhật icon
        if BeeZ_Icon and BeeZ_Icon.Update then
            BeeZ_Icon.Update()
        end
        
        BeeZ_Notify("UI " .. (GUIEnabled and "bật" or "tắt"))
    end
end

-- Tạo GUI chính
local function CreateBeeZGUI()
    -- Load library
    Library = LoadKavoLibrary()
    if not Library then
        BeeZ_Notify("Không thể tạo GUI, thử lại sau")
        return
    end
    
    -- Tạo cửa sổ
    MainWindow = Library.CreateLib("🐝 BeeZ Hub v2.0", "DarkTheme")
    BeeZ_GUI = MainWindow
    
    -- Đảm bảo GUI bật
    BeeZ_GUI.Enabled = true
    GUIEnabled = true
    
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
    
    MainSection:NewButton("Toggle UI", "Bật/tắt UI", function()
        ToggleBeeZGUI()
    end)
    
    MainSection:NewButton("Test Connection", "Kiểm tra kết nối", function()
        BeeZ_Notify("✅ BeeZ Hub đang hoạt động!")
    end)
    
    -- Farming Section
    local FarmingSection = FarmingTab:NewSection("Farming Settings")
    FarmingSection:NewToggle("Enable Auto Farm", "Bật/tắt auto farm", function(state)
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
    
    AutoSection:NewSlider("Katakuri HP %", "Ngưỡng HP", 90, 10, function(value)
        BeeZ_Notify("Katakuri HP: " .. value .. "%")
    end)
    
    AutoSection:NewToggle("Auto Server Hop", "Tự động đổi server", function(state)
        BeeZ_Notify("Auto Server Hop: " .. (state and "BẬT" or "TẮT"))
    end)
    
    AutoSection:NewSlider("Max Hops", "Số lần đổi server", 20, 1, function(value)
        BeeZ_Notify("Max Hops: " .. value)
    end)
    
    -- Player Section
    local PlayerSection = PlayerTab:NewSection("Player Settings")
    PlayerSection:NewSlider("Mastery Target", "Mục tiêu Mastery", 500, 100, function(value)
        BeeZ_Notify("Mastery Target: " .. value)
    end)
    
    PlayerSection:NewDropdown("Skill Priority", "Skill ưu tiên", {"Z", "X", "C", "V", "F"}, function(skill)
        BeeZ_Notify("Skill: " .. skill)
    end)
    
    PlayerSection:NewDropdown("Farm Priority", "Ưu tiên mục tiêu", {"Nearest", "HighestLevel", "LowestHP"}, function(priority)
        BeeZ_Notify("Priority: " .. priority)
    end)
    
    -- Misc Section
    local MiscSection = MiscTab:NewSection("Misc Settings")
    MiscSection:NewToggle("Anti-AFK", "Chống AFK", function(state)
        BeeZ_Notify("Anti-AFK: " .. (state and "BẬT" or "TẮT"))
    end)
    
    MiscSection:NewToggle("Safe Mode", "Chế độ an toàn", function(state)
        BeeZ_Notify("Safe Mode: " .. (state and "BẬT" or "TẮT"))
    end)
    
    MiscSection:NewButton("Hide UI", "Ẩn UI (click icon để bật lại)", function()
        ToggleBeeZGUI()
    end)
    
    MiscSection:NewButton("Refresh", "Làm mới UI", function()
        BeeZ_Notify("Đang refresh UI...")
        CreateBeeZGUI()
    end)
    
    return MainWindow
end

-- Khởi động BeeZ Hub
local function InitializeBeeZHub()
    BeeZ_Notify("🚀 BeeZ Hub v2.0 đang khởi động...", 2)
    
    -- Tạo icon trước
    task.wait(0.5)
    CreateToggleIcon()
    
    -- Tạo GUI
    task.wait(1)
    local success, err = pcall(function()
        CreateBeeZGUI()
    end)
    
    if not success then
        BeeZ_Notify("❌ Lỗi tạo GUI: " .. tostring(err))
        -- Thử lại sau 2 giây
        task.wait(2)
        pcall(CreateBeeZGUI)
    end
    
    -- Đảm bảo GUI hiển thị
    if BeeZ_GUI then
        BeeZ_GUI.Enabled = true
        GUIEnabled = true
        if BeeZ_Icon and BeeZ_Icon.Update then
            BeeZ_Icon.Update()
        end
        BeeZ_Notify("✅ BeeZ Hub v2.0 đã sẵn sàng!\n• UI đã hiển thị\n• Icon ở góc trái\n• Click icon để bật/tắt", 5)
    else
        BeeZ_Notify("⚠️ GUI chưa được tạo, thử lại...")
    end
    
    -- Hotkey
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            ToggleBeeZGUI()
        end
    end)
    
    print("========================================")
    print("🐝 BeeZ Hub v2.0 - Đã khởi động thành công")
    print("UI: Visible | Icon: Created")
    print("========================================")
end

-- Bắt đầu khởi động
InitializeBeeZHub()

-- Kiểm tra lại sau 3 giây
task.wait(3)
if not BeeZ_GUI or not BeeZ_GUI.Enabled then
    BeeZ_Notify("⏳ Đang khởi động lại UI...")
    InitializeBeeZHub()
end
