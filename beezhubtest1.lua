-- BeeZ Hub v2.0 - Simple Working Version
-- Chắc chắn hiện UI khi execute

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Biến toàn cục
local GUIEnabled = true
local BeeZ_Icon = nil

-- Hàm thông báo
local function BeeZ_Notify(message, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🐝 BeeZ Hub",
        Text = message,
        Duration = duration or 3,
        Icon = "rbxassetid://6723928013"
    })
end

-- Tạo icon đơn giản
local function CreateSimpleIcon()
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
    IconFrame.Position = UDim2.new(0, 20, 0.5, -22)
    IconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    IconFrame.BackgroundTransparency = 0.3
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
    IconLabel.TextSize = 24
    IconLabel.Parent = IconFrame
    
    -- Sự kiện click
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleBeeZGUI()
        end
    end)
    
    BeeZ_Icon = IconGui
    return IconGui
end

-- Toggle GUI
local function ToggleBeeZGUI()
    if BeeZ_GUI then
        GUIEnabled = not GUIEnabled
        BeeZ_GUI.Enabled = GUIEnabled
        
        -- Cập nhật icon
        if BeeZ_Icon then
            local iconFrame = BeeZ_Icon:FindFirstChild("BeeZIcon")
            if iconFrame then
                local iconLabel = iconFrame:FindFirstChildOfClass("TextLabel")
                if iconLabel then
                    if GUIEnabled then
                        iconFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                        iconLabel.Text = "🐝"
                    else
                        iconFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                        iconLabel.Text = "🔒"
                    end
                end
            end
        end
        
        BeeZ_Notify("UI " .. (GUIEnabled and "ON" or "OFF"))
    end
end

-- Tạo GUI đơn giản với Rayfield (dễ load hơn)
local function CreateSimpleGUI()
    -- Load Rayfield UI Library (dễ hơn Kavo)
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    
    -- Tạo Window
    local Window = Rayfield:CreateWindow({
        Name = "🐝 BeeZ Hub v2.0",
        LoadingTitle = "BeeZ Hub Loading...",
        LoadingSubtitle = "by BeeZ Team",
        ConfigurationSaving = {
            Enabled = false
        },
        Discord = {
            Enabled = false
        },
        KeySystem = false
    })
    
    -- Main Tab
    local MainTab = Window:CreateTab("Main", 4483362458)
    local MainSection = MainTab:CreateSection("BeeZ Hub Control")
    
    MainSection:CreateLabel("🐝 BeeZ Hub v2.0")
    MainSection:CreateLabel("Advanced Blox Fruits Automation")
    
    MainSection:CreateButton({
        Name = "Toggle UI",
        Callback = function()
            ToggleBeeZGUI()
        end
    })
    
    -- Farming Tab
    local FarmingTab = Window:CreateTab("Farming", 4483362458)
    local FarmingSection = FarmingTab:CreateSection("Farming Settings")
    
    FarmingSection:CreateToggle({
        Name = "Enable Auto Farm",
        CurrentValue = false,
        Flag = "AutoFarmToggle",
        Callback = function(Value)
            BeeZ_Notify("Auto Farm: " .. (Value and "ON" or "OFF"))
        end
    })
    
    FarmingSection:CreateToggle({
        Name = "Stack Farming",
        CurrentValue = false,
        Flag = "StackFarmToggle",
        Callback = function(Value)
            BeeZ_Notify("Stack Farming: " .. (Value and "ON" or "OFF"))
        end
    })
    
    local FarmMethod = FarmingSection:CreateDropdown({
        Name = "Farm Method",
        Options = {"Normal", "Fast", "Safe", "Boss"},
        CurrentOption = "Normal",
        Flag = "FarmMethodDropdown",
        Callback = function(Option)
            BeeZ_Notify("Farm Method: " .. Option)
        end
    })
    
    local FarmDistance = FarmingSection:CreateSlider({
        Name = "Farm Distance",
        Range = {10, 50},
        Increment = 5,
        Suffix = "studs",
        CurrentValue = 25,
        Flag = "FarmDistanceSlider",
        Callback = function(Value)
            BeeZ_Notify("Farm Distance: " .. Value)
        end
    })
    
    -- Auto Tab
    local AutoTab = Window:CreateTab("Auto", 4483362458)
    local AutoSection = AutoTab:CreateSection("Auto Settings")
    
    AutoSection:CreateToggle({
        Name = "Ignore Katakuri",
        CurrentValue = false,
        Flag = "IgnoreKatakuriToggle",
        Callback = function(Value)
            BeeZ_Notify("Ignore Katakuri: " .. (Value and "ON" or "OFF"))
        end
    })
    
    AutoSection:CreateToggle({
        Name = "Auto Server Hop",
        CurrentValue = false,
        Flag = "AutoHopToggle",
        Callback = function(Value)
            BeeZ_Notify("Auto Server Hop: " .. (Value and "ON" or "OFF"))
        end
    })
    
    -- Player Tab
    local PlayerTab = Window:CreateTab("Player", 4483362458)
    local PlayerSection = PlayerTab:CreateSection("Player Settings")
    
    PlayerSection:CreateSlider({
        Name = "Mastery Target",
        Range = {100, 500},
        Increment = 10,
        Suffix = "level",
        CurrentValue = 300,
        Flag = "MasterySlider",
        Callback = function(Value)
            BeeZ_Notify("Mastery Target: " .. Value)
        end
    })
    
    PlayerSection:CreateDropdown({
        Name = "Skill Priority",
        Options = {"Z", "X", "C", "V", "F"},
        CurrentOption = "Z",
        Flag = "SkillPriorityDropdown",
        Callback = function(Option)
            BeeZ_Notify("Skill Priority: " .. Option)
        end
    })
    
    -- Misc Tab
    local MiscTab = Window:CreateTab("Misc", 4483362458)
    local MiscSection = MiscTab:CreateSection("Misc Settings")
    
    MiscSection:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
        Flag = "AntiAFKToggle",
        Callback = function(Value)
            BeeZ_Notify("Anti-AFK: " .. (Value and "ON" or "OFF"))
        end
    })
    
    MiscSection:CreateToggle({
        Name = "Safe Mode",
        CurrentValue = false,
        Flag = "SafeModeToggle",
        Callback = function(Value)
            BeeZ_Notify("Safe Mode: " .. (Value and "ON" or "OFF"))
        end
    })
    
    MiscSection:CreateButton({
        Name = "Hide UI",
        Callback = function()
            ToggleBeeZGUI()
        end
    })
    
    MiscSection:CreateButton({
        Name = "Test Button",
        Callback = function()
            BeeZ_Notify("BeeZ Hub is working!")
        end
    })
    
    BeeZ_GUI = Window
    return Window
end

-- Khởi động
BeeZ_Notify("🚀 Loading BeeZ Hub v2.0...", 2)

-- Tạo icon
CreateSimpleIcon()
BeeZ_Notify("✅ Icon created", 1)

-- Tạo GUI
task.wait(1)
local success, err = pcall(function()
    CreateSimpleGUI()
    BeeZ_Notify("🎉 BeeZ Hub loaded successfully!", 3)
    print("🐝 BeeZ Hub v2.0 - READY")
end)

if not success then
    BeeZ_Notify("❌ Failed to load GUI: " .. tostring(err), 5)
end

-- Hotkey
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        ToggleBeeZGUI()
    end
end)

BeeZ_Notify("📢 Press RightControl to toggle UI", 3)
